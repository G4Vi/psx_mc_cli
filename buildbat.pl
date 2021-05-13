#!/usr/bin/perl

use strict; use warnings;
use feature 'say';
use FindBin;

my $indir = "$FindBin::Bin/bin";
my $outdir = "$FindBin::Bin/bin_cmd";

opendir(my $dh, $indir) || die "Can't open $indir: $!";
while (readdir $dh) {
    next if($_ =~ /^\.{1,2}$/);
    say "converting $indir/$_ to $outdir/$_.bat";
    open(my $fh, '>', "$outdir/$_.bat") or die("Error creating bat");
    print $fh '@echo off'."\r\n";
    print $fh '"C:\Program Files\Git\usr\bin\perl.exe" "-I" "%~dp0..\lib" "%~dp0..\bin'."\\" . $_ . '" %*'."\r\n";
    close($fh);    
}
closedir $dh;
say "Wrote all files";