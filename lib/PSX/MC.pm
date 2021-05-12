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
	# A PSX memory card is 1 Mebibyte/ 128 kibibyte/ 131072 bytes
	# 1 header block of 8192 and 15 data blocks of 8192.
	return (length($res) == 131072);
}

sub is_mcs {
	my ($res) = @_;
	# A PSX mcs save is 1 directory frame and X data frames
	my $datasize = length($res) - 0x80;
	(($datasize % 0x2000) == 0) or return 0;

	return 1;
}

1;