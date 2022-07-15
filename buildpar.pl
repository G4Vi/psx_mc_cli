#!/usr/bin/perl

use strict; use warnings;
use feature 'say';
use FindBin;
use File::Copy qw(copy);
use File::Path qw(make_path);
use lib "$FindBin::Bin/PlayStation-MemoryCard/lib";
use PlayStation::MemoryCard;

my $reldir = "$FindBin::Bin/psx-mc-cli-$PlayStation::MemoryCard::VERSION-windows-exe";
my $relbindir = "$reldir/bin";
make_path($reldir, $relbindir);
my @tocopy = ("README.md", "LICENSE", "PlayStation-MemoryCard/Changes");
foreach my $file (@tocopy) {
	copy("$FindBin::Bin/$file", $reldir);
}
my $psxmcdir = "$FindBin::Bin/PlayStation-MemoryCard";
my $inbindir = "$psxmcdir/bin";
opendir(my $dh, $inbindir) || die "Can't open $inbindir: $!";
while (readdir $dh) {
    next if($_ =~ /^\.{1,2}$/);
    system('pp', "--lib=$psxmcdir/lib", '-M', 'PlayStation::MemoryCard',
	"--lib=$FindBin::Bin/gifenc-pl/lib", '-M', 'Image::GIF::Encoder::PP',
	'-u', '-B', '-o', "$relbindir/$_.exe", "$inbindir/$_") == 0 or die("Failed to package");
}
closedir $dh;
