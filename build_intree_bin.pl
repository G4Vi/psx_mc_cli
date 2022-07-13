#!/usr/bin/perl

use strict; use warnings;
use feature 'say';
use FindBin;
use File::Path qw(make_path);

my $bindir = "$FindBin::Bin/bin";
my @formats = (
    # bat
    {
        'out' => "$FindBin::Bin/bin_cmd",
        'name' => sub { return $_[0].'.bat';},
        'writefilecontents' => sub {
            my ($fh, $scriptname) = @_;
            print $fh '@echo off'."\r\n";
            print $fh "where /q perl\r\n";
            print $fh "IF ERRORLEVEL 1 (\r\n";
            print $fh 'SET "PERLEXE=C:\Program Files\Git\usr\bin\perl.exe"' . "\r\n";
            print $fh ") ELSE (\r\n";
            print $fh 'SET "PERLEXE=perl"' . "\r\n";
            print $fh ")\r\n";
            print $fh '"%PERLEXE%" "-I" "%~dp0..\lib" "%~dp0..\bin'."\\" . $scriptname . '" %*'."\r\n";
        }
    },
    # sh
    {
        'out' => "$FindBin::Bin/bin_sh",
        'name' => sub { return $_[0];},
        'writefilecontents' => sub {
            my ($fh, $scriptname) = @_;
            print $fh '#!/bin/sh'."\n";
            print $fh 'SCRIPTLOC=$(dirname $0)'."\n";
            print $fh 'exec perl -I "$SCRIPTLOC/../lib" "$SCRIPTLOC/../bin/'. $scriptname.'" "$@"'."\n";
            my $perm = (stat $fh)[2] & 07777;
            chmod($perm | 0111, $fh);
        }
    }

);

# create the open directories
foreach my $format (@formats) {
    make_path($format->{out});
}

# loop through the scripts
opendir(my $dh, $bindir) || die "Can't open $bindir: $!";
while (readdir $dh) {
    next if($_ =~ /^\.{1,2}$/);
    # make the wrapper scripts
    foreach my $format (@formats) {
        my $outpath = $format->{out}."/".$format->{name}($_);
        say "converting $bindir/$_ to $outpath";
        open(my $fh, '>', $outpath) or die("Error creating bat");
        $format->{writefilecontents}($fh, $_);
        close($fh);
    }
}
closedir $dh;
say "Wrote all files";
