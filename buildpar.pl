#!/usr/bin/perl

use strict; use warnings;
use feature 'say';
use FindBin;
use File::Copy;


my $indir = "$FindBin::Bin/bin";
my $outdir = "$FindBin::Bin/compiled/psx_mc_cli";

#opendir(my $dh, $indir) || die "Can't open $indir: $!";
#my @scripts;
#while (readdir $dh) {
#    next if($_ =~ /^\.{1,2}$/);
#    push @scripts, "$indir/$_";   
#}
#closedir $dh;
#system('pp', '--multiarch', '-B', '-p', '-o', "$outdir/psx_mc_cli.par", @scripts) == 0 or die("Failed to package");

opendir(my $dh, $indir) || die "Can't open $indir: $!";
while (readdir $dh) {
    next if($_ =~ /^\.{1,2}$/);
    system('pp', '-u', '-B', '-o', "$outdir/$_.exe", "$indir/$_") == 0 or die("Failed to package");
}
closedir $dh;

copy("README.md", "$outdir/README.md");
copy("LICENSE", "$outdir/LICENSE");

say "all exes built";