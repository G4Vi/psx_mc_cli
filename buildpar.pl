#!/usr/bin/perl

use strict; use warnings;
use feature 'say';
use FindBin;

my $indir = "$FindBin::Bin/bin";
my $outdir = "$FindBin::Bin/compiled";

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
    system('pp', '-u', '-B', '-o', "$outdir/psx_mc_cli/$_.exe", "$indir/$_") == 0 or die("Failed to package");
}
closedir $dh;
say "all exes built";