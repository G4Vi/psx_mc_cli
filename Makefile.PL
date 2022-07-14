use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
    NAME             => 'PlayStation::MemoryCard',
    AUTHOR           => "Gavin Hayes <gahayes\@cpan.org>",
    VERSION_FROM     => 'lib/PlayStation/MemoryCard.pm',
    ABSTRACT_FROM    => 'lib/PlayStation/MemoryCard.pm',
    LICENSE          => 'perl_5',
    MIN_PERL_VERSION => '5.006',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    PREREQ_PM => {
    },
    EXE_FILES => ['bin/lsmc', 'bin/mciconextract', 'bin/mcs2raw', 'bin/mcsaveextract', 'bin/mkmcd', 'bin/raw2mcs'],
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => ['PlayStation-MemoryCard-*', 'bin_cmd', 'bin_sh']},
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/G4Vi/psx_mc_cli.git',
                web  => 'https://github.com/G4Vi/psx_mc_cli',
            },
            bugtracker => {
                web => 'https://github.com/G4Vi/psx_mc_cli/issues'
            },
            homepage   => 'https://github.com/G4Vi/psx_mc_cli',
        },
    },
);

# Compatibility with old versions of ExtUtils::MakeMaker
unless (eval { ExtUtils::MakeMaker->VERSION('6.64'); 1 }) {
    my $test_requires = delete $WriteMakefileArgs{TEST_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$test_requires} = values %$test_requires;
}

unless (eval { ExtUtils::MakeMaker->VERSION('6.55_03'); 1 }) {
    my $build_requires = delete $WriteMakefileArgs{BUILD_REQUIRES} || {};
    @{$WriteMakefileArgs{PREREQ_PM}}{keys %$build_requires} = values %$build_requires;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
    unless eval { ExtUtils::MakeMaker->VERSION('6.52'); 1 };
delete $WriteMakefileArgs{MIN_PERL_VERSION}
    unless eval { ExtUtils::MakeMaker->VERSION('6.48'); 1 };
delete $WriteMakefileArgs{LICENSE}
    unless eval { ExtUtils::MakeMaker->VERSION('6.31'); 1 };

WriteMakefile(%WriteMakefileArgs);

if(-f 'build_intree_bin.pl') {
    exec('perl', 'build_intree_bin.pl');
}
