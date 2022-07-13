#!/bin/bash

# use 'source' or '.' to load this script

PSXMCDIR=$(realpath $(dirname "$BASH_SOURCE"))
LIBDIR="$PSXMCDIR/lib"
BINDIR="$PSXMCDIR/bin"

alias lsmc="perl -I $LIBDIR $BINDIR/lsmc"
alias mciconextract="perl -I $LIBDIR $BINDIR/mciconextract"
alias mcs2raw="perl -I $LIBDIR $BINDIR/mcs2raw"
alias mcsaveextract="perl -I $LIBDIR $BINDIR/mcsaveextract"
alias mkmcd="perl -I $LIBDIR $BINDIR/mkmcd"
alias raw2mcs="perl -I $LIBDIR $BINDIR/raw2mcs"

unset BINDIR
unset LIBDIR
unset PSXMCDIR
