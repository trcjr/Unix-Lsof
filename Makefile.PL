use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Unix::Lsof',
    AUTHOR              => 'Marc Beyer <japh@tirwhan.org>',
    VERSION_FROM        => 'lib/Unix/Lsof.pm',
    ABSTRACT_FROM       => 'lib/Unix/Lsof.pm',
    PL_FILES            => {},
    PREREQ_PM => {
                  'Test::More' => 0,
                  'version'    => 0,
                  'IPC::Run3'  => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Unix-Lsof-*' },
);
