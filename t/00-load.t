#!perl -T
use 5.010;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'AnyEvent::Postfix::Policy' ) || print "Bail out!\n";
}

diag( "Testing AnyEvent::Postfix::Policy $AnyEvent::Postfix::Policy::VERSION, Perl $], $^X" );
