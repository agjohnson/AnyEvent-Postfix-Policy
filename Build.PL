use 5.010;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'AnyEvent::Postfix::Policy',
    license             => 'MIT',
    dist_author         => q{Anthony Johnson <aj@ohess.org>},
    dist_version_from   => 'lib/AnyEvent/Postfix/Policy.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    add_to_cleanup     => [ 'AnyEvent-Postfix-Policy-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
