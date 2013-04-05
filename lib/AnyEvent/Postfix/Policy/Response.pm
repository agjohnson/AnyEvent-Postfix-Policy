package AnyEvent::Postfix::Policy::Response;

sub new {
    my $class = shift;
    my %args = @_;

    bless {
        action => 'dunno',
        message => '',
        %args
    }, $class;
}

sub action {
    my ($self, $val) = @_;
    $self->{action} = $val
      if ($val);
    return $self->{action};
}

sub message {
    my ($self, $val) = @_;
    $self->{message} = $val
      if ($val);
    return $self->{message};
}

sub as_string {
    my $self = shift;
    return sprintf("action=%s %s\n\n", $self->action, $self->message);
}

1;
