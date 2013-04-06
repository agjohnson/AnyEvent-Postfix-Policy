use Test::More;

use AnyEvent;
use AnyEvent::Postfix::Policy;
use AnyEvent::Postfix::Policy::Handle;

plan tests => 3;

# Rule add
my $srv = AnyEvent::Postfix::Policy->new();

$srv->rule(recipient => qr/foo/, cb => sub { return 'FOO' });
is(length(@{$srv->{rules}}), 1, 'Rule added');

# Test return
my $guard = AnyEvent->condvar;
my $cv;
my $h = AnyEvent::Postfix::Policy::Handle->new(
    fh => *STDIN,
);

# Pass
$h->param('recipient', 'foobar');
$cv = AnyEvent->condvar(
    cb => sub {
        is(shift->recv, 'FOO', 'Rule match');
        return $guard->end;
    }
);
$guard->begin;
$srv->{on_receive}->($cv)->send($h);
$h->clear_params;

# Fail
$h->param('recipient', 'bar');
$cv = AnyEvent->condvar(
    cb => sub {
        is(
            ref shift->recv,
            AnyEvent::Postfix::Policy::Response,
            'Rule miss'
        );
        return $guard->end;
    }
);
$guard->begin;
$srv->{on_receive}->($cv)->send($h);
$h->clear_params;

# Wait
$guard->recv;

1;
