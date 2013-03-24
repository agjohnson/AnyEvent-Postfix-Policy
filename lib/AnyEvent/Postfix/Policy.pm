package AnyEvent::Postfix::Policy;

use 5.010;
use strict;
use warnings FATAL => 'all';

=head1 NAME

AnyEvent::Postfix::Policy - Event driven Postfix policy service

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

=head1 METHODS

=cut

use AnyEvent;
use AnyEvent::Socket qw/tcp_server/;
use Data::Dumper;

use AnyEvent::Postfix::Policy::Handle;

$| = 1;


sub new {
    my $class = shift;

    bless {
        conns => []
    }, $class;
}

sub run {
    my ($self, $host, $port) = @_;
    $self->{guard} = AE::cv;
    $self->{guard}->begin;
    my $guard = tcp_server(
        $host,
        $port,
        $self->accept_client($host, $port)
    );

    # Register wait condvar
    my $w; $w = AE::signal QUIT => sub {
        printf "Got quit signal, shutting down\n";
        $self->{guard}->end;
        undef $w;
    };
    $self->{guard}->recv;
}

sub accept_client {
    my ($self, $local_host, $local_port) = @_;
    printf "Listening on %s\n", $local_port;

    return sub {
        my ($sock, $host, $port) = @_;

        printf "Client connection from %s:%s\n", $host, $port;
        $self->{guard}->begin;

        push(@{$self->{conns}}, AnyEvent::Postfix::Policy::Handle->new(
            fh => $sock,
            poll => 'rw',
            on_read => sub {
                my ($sock) = @_;
                $sock->push_read(line => $self->parse_inbound($sock));
            },
            on_eof => sub {
                printf "Closed connection %s:%s\n", $host, $port;
                $self->{guard}->end
            },
            on_error => sub {
                my ($handle, $fatal, $message) = @_;
                printf("Error: %s\nClosed connection %s:%s\n",
                  $message, $host, $port);
                $handle->destroy;
                $self->{guard}->end;
            }
        ));
    }
}

sub parse_inbound {
    my ($self, $sock) = @_;

    return sub {
        my ($sock, $line, $eol) = @_;

        if ($line eq '') {
            print Dumper $sock->{params};
            $sock->clear_params;
            return 1;
        }
        elsif (my @param = ($line =~ m/([\w\-\_]+)=(.*)/)) {
            $sock->param(@param);
        }

        return 0;
    }
}

=head1 AUTHOR

Anthony Johnson, C<< <aj at ohess.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Anthony Johnson.

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut
1;
