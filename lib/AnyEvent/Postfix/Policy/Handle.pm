package AnyEvent::Postfix::Policy::Handle;

use base 'AnyEvent::Handle';

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{params} = {};

    bless $self, $class;
}

sub params { shift->{params} }

sub param {
    my ($self, $param, $value) = @_;
    $self->{params}->{$param} = $value
      if ($value);
    return $self->{params}->{$param} // '';
}

sub clear_params {
    my $self = shift;
    $self->{params} = {};
}

1;
