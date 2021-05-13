package PSX::MC;
use strict;
use warnings;
use Encode qw(decode encode);

sub parse_directory {
	my ($directory) = @_;
	my $inuse = unpack('C', $directory);
	my $datasize = unpack('V', substr($directory, 0x4, 0x4));
	my $linkindex = unpack('v', substr($directory, 0x8));
	my $codestr =  unpack('Z*', substr($directory, 0xA));
	my @toxor    = unpack('C127', $directory);
	my $storedxor = unpack('C', substr($directory, 0x7F));

	#my @blocktypes = ('INUSE', 'SRTLINK', 'MIDLINK', 'ENDLINK', 'EMPTY', 'UNUSABLE', 'UNKNOWN');
	my $blockcount = int($datasize / 0x2000);

	my $calcxor = 0;
	foreach my $char (@toxor) {
        $calcxor ^= $char; 
    }

	return {
		'inuse'     => $inuse,
		'datasize'  => $datasize,
		'linkindex' => $linkindex,
		'codename'  => $codestr,
		'xor'       => $storedxor,

		'calcxor'    => $calcxor,
		'calcblocks' => $blockcount
	};
}


sub parse_file_header {
	my ($file) = @_;
	my $id = unpack('a2', $file);
	my $displayflag = unpack('C', substr($file, 0x2));
    my $blocknum = unpack('C', substr($file, 0x3));
	my $shiftjisbuf = unpack('a64', substr($file, 0x4, 0x40));
	my @clut = unpack('v16', substr($file, 0x60, 0x20));


	my $iconfnt = 0;
    if(($displayflag >= 0x11)|| ($displayflag <= 0x13)) {
		$iconfnt = $displayflag - 0x10;
	}

	my $firstnul = index($shiftjisbuf, "\0");
	if($firstnul != -1) {	
		$shiftjisbuf = substr($shiftjisbuf, 0, $firstnul);	
	}
	my $shiftjis = decode('shiftjis', $shiftjisbuf);

	return {
		'id' => $id,
		'displayflag' => $displayflag,
		'blocknum' => $blocknum,
		'titlebuf' =>  $shiftjisbuf,
		'clut' => \@clut,
		'title' => $shiftjis,
		'framecnt' => $iconfnt
	};
}

sub is_mcd {
	my ($res) = @_;

	(substr($res, 0, 2) eq 'MC') or return 0;


	# A PSX memory card is 1 Mebibyte/ 128 kibibyte/ 131072 bytes
	# 1 header block of 8192 and 15 data blocks of 8192.
	return (length($res) == 131072);
}

sub is_mcs {
	my ($res) = @_;
	# A PSX mcs save is 1 directory frame and X data frames
	my $datasize = length($res) - 0x80;
	return (($datasize % 0x2000) == 0);
}

sub xordirectory {
	my ($directory) = @_;
	my @toxor = unpack('C127', $directory);
	my $xor = 0;
	foreach my $char (@toxor) {
        $xor ^= $char; 
    }
	return $xor;
}


sub load {
	my ($class, $filename) = @_;
	my %self = ('filename' => $filename, 'contents' => '');
	open(my $fh, '<', $filename) or die("failed to open: $filename");
	my $res = read($fh, $self{'contents'}, 131073);

	# a mcd file (full memory card dump) should be the largest file
	(defined($res) && ($res <= 131072)) or return undef;

	if(is_mcd($self{'contents'})) {
		$self{'type'} = 'mcd';
	}
	elsif(is_mcs($self{'contents'})) {
		$self{'type'} = 'mcs';
	}
	elsif(($res <= (15*0x2000)) && ($res >= 0x2000) && (($res % 0x2000) == 0)) {
		$self{'type'} = 'rawsave';
	}
	elsif(substr($res, 0, 2) == 'MC') {
		warn("File starts with MC, but filesize is $res. Assuming type is mcd");
		$self{'type'} = 'mcd';		
	}
	else {		
		return undef;
	}

	if(($self{'type'} eq 'mcd') || ($self{'type'} eq 'mcs')) {
		$self{'hasdir'} = 1;
	}

	bless \%self, $class;
	return \%self;
}

sub foreachDirEntry {
	my ($self, $callback) = @_;
	(($self->{'type'} eq 'mcd') || ($self->{'type'} eq 'mcs')) or die("Unhandled filetype");

    my $startindex;
	my $dataoffset;
	my $maxcount;
	if($self->{'type'} eq 'mcs') {
		$startindex = 0;
		$dataoffset = 0x80;
		$maxcount = 1;
	}
	elsif($self->{'type'} eq 'mcd') {
		$startindex = 1;
		$dataoffset = 0x2000;
		$maxcount = 15;
	}	

    my $save;
	for(my $i = $startindex; $i < ($startindex+$maxcount); $i++) {
		my $entrydata = substr($self->{'contents'}, ($i * 0x80), 0x80);
		my $entry = parse_directory($entrydata);
		if($entry->{'inuse'} == 0x51) {			
			$save = {
				'filename' => $entry->{'codename'},
				'data' => substr($self->{'contents'}, $dataoffset, $entry->{'datasize'}),
				'header' => parse_file_header(substr($self->{'contents'}, $dataoffset, 0x80))
			};
		}
		$callback->($entry, $save, $entrydata);
		# remove association to save when the current block isn't a startlink or midblock
		if (($entry->{'inuse'} != 0x52) && (($entry->{'inuse'} != 0x51) || ($entry->{'linkindex'} == 0xFFFF))) {
			$save = 0;
		}
		$dataoffset += 0x2000;		 
	}
}

sub _readMCSSave {
	my ($self) = @_;
	my $entrydata = substr($self->{'contents'}, 0, 0x80);
	my $entry = parse_directory($entrydata);

	return {
		'filename' => $entry->{'codename'},
		'savedata' => substr($self->{'contents'}, 0x80, $entry->{'datasize'})
	};
}

sub readSave {
	my ($self) = @_;
	if($self->{'type'} eq 'mcs') {
        return _readMCSSave($self);
	}
	else {
		die("unimplemented type");
	}
}

sub FormatSaveAsMCD {
	my ($dirstart, $save) = @_;
	my $savelen = length($save->{'savedata'});
	my $blockcount = length($save->{'savedata'}) / 0x2000;
    (($blockcount % 1) == 0) or die("not integer blocksize");
	($blockcount >= 1) or die("must have at least one block");
	my $dirindex = ($dirstart / 0x80);
	my $blockptr = ($blockcount == 1) ? 0xFFFF : $dirindex;
	
	# format the first directory
	my $directory = pack('VVvZ21x96', 0x51, $savelen, $blockptr, $save->{'filename'});
    $directory .= pack('C', xordirectory($directory));
    
	# format the possible mid and end link directories
	if($blockcount > 1) {
		while ($blockcount > 2) {
			$dirindex++;
			my $newdir = pack('VVvx117', 0x52, 0x0, $dirindex);
			$newdir .= pack('C', xordirectory($newdir));
			$directory .= $newdir;
			$blockcount--;
		}
		my $newdir = pack('VVvx117', 0x53, 0x0, 0xFFFF);
		$newdir .= pack('C', xordirectory($newdir));
		$directory .= $newdir;
	}
	
	return {
		'dirdata'     => $directory,
		'savedata' => $save->{'savedata'}
	};	
}

1;