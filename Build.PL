use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Unix::Lsof',
    license             => 'perl',
    dist_author         => 'Marc Beyer <japh@tirwhan.org>',
    dist_version_from   => 'lib/Unix/Lsof.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'Unix-Lsof-*' ],
);

$builder->create_build_script();
