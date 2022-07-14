package PlayStation::MemoryCard::GIF::Encoder::PP;
# Copyright (c) 2021 Gavin Hayes, see LICENSE in the root of the project
use version; our $VERSION = version->declare("v0.2.0");
use strict;
use warnings;

sub write_num {
    my ($fh, $val) = @_;
    print $fh pack('v', $val);
}

sub new_node {
    my ($key, $degree) = @_;
    my %node = (
        'key' => $key,
        'children' => []
    );

    return \%node;
}

sub new_trie {
    my ($degree, $nkeys) = @_;
    my $root = new_node(0, $degree);
    # Create nodes for single pixels.
    for($$nkeys = 0; $$nkeys < $degree; $$nkeys += 1) {
        $root->{'children'}[$$nkeys] = new_node($$nkeys, $degree);
    }
    $$nkeys += 2; #skip clear code and stop code
    return $root;
}

sub del_trie {
    # nothing needed to free in perl
}

sub put_loop {
    my ($gif, $loop) = @_;
    print {$gif->{'fh'}} pack('CCC', 0x21, 0xFF, 0x0B);
    print {$gif->{'fh'}} "NETSCAPE2.0";
    print {$gif->{'fh'}} pack('CC', 0x03, 0x01);
    write_num($gif->{'fh'}, $loop);
    print {$gif->{'fh'}} "\0";
}

# Add packed key to buffer, updating offset and partial.
#    $gif->{'offset'} holds position to put next *bit*
#    $gif->{'partial'} holds bits to include in next byte
sub put_key {
    my ($gif, $key, $key_size) = @_;

    my $byte_offset = int($gif->{'offset'} / 8);
    my $bit_offset = $gif->{'offset'} % 8;
    $gif->{'partial'} |= ($key << $bit_offset);
    my $bits_to_write = $bit_offset + $key_size;
    while ($bits_to_write >= 8) {
        vec($gif->{'buffer'}, $byte_offset++, 8) = $gif->{'partial'} & 0xFF;
        if ($byte_offset == 0xFF) {
            print {$gif->{'fh'}} "\xFF";
            length($gif->{'buffer'}) == 0xFF or die("misport");
            print {$gif->{'fh'}} $gif->{'buffer'};
            $byte_offset = 0;
        }
        $gif->{'partial'} >>= 8;
        $bits_to_write -= 8;
    }
    
    $gif->{'offset'} = ($gif->{'offset'} + $key_size) % (0xFF * 8);
}

sub end_key {
    my ($gif) = @_;
    my $byte_offset = int($gif->{'offset'} / 8);
    if ($gif->{'offset'} % 8) {
        vec($gif->{'buffer'}, $byte_offset++, 8) = $gif->{'partial'} & 0xFF;
    }
    if ($byte_offset) {
        print {$gif->{'fh'}} pack('C', $byte_offset);
        print {$gif->{'fh'}} substr($gif->{'buffer'}, 0, $byte_offset);
    }
    print {$gif->{'fh'}} "\0";
    $gif->{'offset'} = $gif->{'partial'} = 0;
}

sub put_image {
    my ($gif, $w, $h, $x, $y) = @_;

    my $degree = 1 << $gif->{'depth'};

    print {$gif->{'fh'}} ",";
    write_num($gif->{'fh'}, $x);
    write_num($gif->{'fh'}, $y);
    write_num($gif->{'fh'}, $w);
    write_num($gif->{'fh'}, $h);
    print {$gif->{'fh'}} pack('CC', 0x0, $gif->{'depth'});
    my $nkeys;
    my $node = new_trie($degree, \$nkeys);
    my $root = $node; 
    my $key_size = $gif->{'depth'} + 1;
    
    put_key($gif, $degree, $key_size); # clear code

    for (my $i = $y; $i < $y+$h; $i++) {
        for (my $j = $x; $j < $x+$w; $j++) {            
            my $pixel = vec($gif->{'frame'}, $i*$gif->{'w'}+$j, 8) & ($degree - 1);
            my $child = $node->{'children'}[$pixel];
            if ($child) {
                $node = $child;
            } else {                
                put_key($gif, $node->{'key'}, $key_size);
                if ($nkeys < 0x1000) {
                    if ($nkeys == (1 << $key_size)) {
                        $key_size++;
                    }                        
                    $node->{'children'}[$pixel] = new_node($nkeys++, $degree);
                } else {
                    put_key($gif, $degree, $key_size); # clear code
                    del_trie($root, $degree);
                    $root = $node = new_trie($degree, \$nkeys);
                    $key_size = $gif->{'depth'} + 1;
                }
                $node = $root->{'children'}[$pixel];
            }
        }
    }
    put_key($gif, $node->{'key'}, $key_size);
    put_key($gif, $degree + 1, $key_size); # stop code
    end_key($gif);
    del_trie($root, $degree);
}

sub get_bbox {
    my ($gif, $w, $h, $x, $y) = @_;
    my $left = $gif->{'w'}; my $right = 0;
    my $top = $gif->{'h'}; my $bottom = 0;
    my $k = 0;
    for (my $i = 0; $i < $gif->{'h'}; $i++) {
        for (my $j = 0; $j < $gif->{'w'}; $j++, $k++) {
            if (vec($gif->{'frame'}, $k, 8) != vec($gif->{'back'}, $k, 8)) {
                if ($j < $left) {
                    $left = $j;
                }   
                if ($j > $right) {
                    $right   = $j;
                }  
                if ($i < $top) {
                    $top     = $i;
                }                
                if ($i > $bottom) {
                    $bottom  = $i;
                }
            }
        }
    }
    if ($left != $gif->{'w'} && $top != $gif->{'h'}) {
        $$x = $left; $$y = $top;
        $$w = $right - $left + 1;
        $$h = $bottom - $top + 1;
        return 1;
    } else {
        return 0;
    }
}

sub add_graphics_control_extension {
    my ($gif, $d) = @_;
    my $out = "!\xF9\x04\x04";
    if($gif->{'transparent_index'} != -1) {
        vec($out, 3, 8) |= 0x1;
    }
    print {$gif->{'fh'}} $out;
    write_num($gif->{'fh'}, $d);
    vec($out, 0, 8) = 0x0;
    vec($out, 1, 8) = 0x0;
    if($gif->{'transparent_index'} != -1) {
        vec($out, 0, 8) = $gif->{'transparent_index'};
    }
    print {$gif->{'fh'}} substr($out, 0, 2);
}


# external interface
sub new {
    my ($class, $filename, $width, $height, $palette, $depth, $loop, $transparent_index) = @_;
    my $gif = {
        'w' => $width,
        'h' => $height,
        'depth' => 0,        
        'transparent_index' => $transparent_index,
        'fd' => undef,
        'offset' => 0,
        'nframes' => 0,
        #'frame' => '',
        #'back' => '',
        'partial' => 0,
        #'buffer' => ''
    };
    vec($gif->{'frame'}, $width*$height-1, 8) = 0;
    vec($gif->{'back'}, $width*$height-1, 8) = 0;
    vec($gif->{'buffer'}, 0xFF-1, 8) = 0;
    if($filename) {
        open($gif->{'fh'}, '>', $filename) or return undef;
    }
    else {
        $gif->{'fh'} = *STDOUT;
    }
    
    bless $gif, $class;

    print {$gif->{'fh'}} "GIF89a";
    write_num($gif->{'fh'}, $width);
    write_num($gif->{'fh'}, $height);
    my $store_gct; my $custom_gct;
    if ($palette) {
        if ($depth < 0) {
            $store_gct = 1;
        }            
        else {
            $custom_gct = 1;
        }            
    }
    if ($depth < 0) {
        $depth = -$depth;
    }        
    $gif->{'depth'} = $depth > 1 ? $depth : 2;
    print {$gif->{'fh'}} pack('CCC', (0xF0 | ($depth-1)), 0x00, 0x00);
    if ($custom_gct) {
        print {$gif->{'fh'}} substr($palette, 0, 3 << $depth);
    }
    else {
        warn("unimplemented mode");
        return undef;
    }

    if ($loop >= 0 && $loop <= 0xFFFF) {
         put_loop($gif, $loop);
    }       

	return $gif;
}

sub add_frame {
    my ($gif, $delay) = @_;

    if ($delay || ($gif->{'transparent_index'} != -1)) {
        add_graphics_control_extension($gif, $delay);
    }        
    my ($w, $h, $x, $y);
    if ($gif->{'nframes'} == 0) {
        $w = $gif->{'w'};
        $h = $gif->{'h'};
        $x = $y = 0;
    } elsif (!get_bbox($gif, \$w, \$h, \$x, \$y)) {
        # image's not changed; save one pixel just to add delay
        $w = $h = 1;
        $x = $y = 0;
    }
    put_image($gif, $w, $h, $x, $y);
    $gif->{'nframes'}++;
    my $tmp = $gif->{'back'};
    $gif->{'back'} = $gif->{'frame'};
    $gif->{'frame'} = $tmp;
}

sub finish {
    my ($gif) = @_;
    print {$gif->{'fh'}} ';';
}

# helper functions
sub expand_frame {
    my ($data, $srcbitsperpixel, $desiredbitsperpixel) = @_;
    (length($data) % $srcbitsperpixel) == 0 or return undef;
    my $count = (length($data) * 8) / $srcbitsperpixel;
    my $dest;
    vec($dest, $count-1, $desiredbitsperpixel) = 0;
    for(my $i = 0; $i < $count; $i++) {
        vec($dest, $i, $desiredbitsperpixel) = vec($data, $i, $srcbitsperpixel);
    }
    return $dest;
}

sub _scaleUp {
    my ($dest, $data, $w, $h, $times) = @_;
    my $desti = 0;
    for(my $y = 0; $y < $h; $y++) {
        my $ystop = $desti + ($w * $times * $times);
        while($desti < $ystop) {
            for(my $x = 0; $x < $w; $x++) {
                my $stop = $desti + $times;
                while($desti < $stop) {
                    vec($$dest, $desti++, 8) = vec($data, ($y * $w) + $x, 8);
                }
            }
        }
    }

    return 1;
}

sub _scaleDown {
    my ($dest, $data, $w, $h, $every) = @_;
    my $desti = 0;
    for(my $y = 0; $y < $h; $y += $every) {
        for(my $x = 0; $x < $w; $x += $every) {
            vec($$dest, $desti++, 8) = vec($data, ($y * $w) + $x, 8);
        }
    }

    return 1;
}

sub scale {
    my ($data, $w, $h, $times, $dest) = @_;
    ($times == int($times)) && ($times != 0) or return undef;
    my ($neww, $newh);
    if($times > 0) {
        $neww = $w * $times;
        $newh = $h * $times;
        return _scaleUp($dest, $data, $w, $h, $times);
    }
    else {
        my $div = -$times;
        $neww = $w / $div;
        $newh = $h / $div;
        ($neww == int($neww)) && ($newh == int($newh)) or return undef;
        return _scaleDown($dest, $data, $w, $h, -$times);
    }
}

1;