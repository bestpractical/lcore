package LCore::Exception;
use Exception::Class
    ( 'LCore::Exception' =>
      { fields => ['details'] },
      'LCore::Exception::Runtime' =>
      { isa => 'LCore::Exception'},
      'LCore::Exception::Params' =>
      { isa => 'LCore::Exception',
        fields => ['missing', 'unwanted'] },
   );


sub as_string {
    my $self = shift;
    "LCore: ".$self->message;
}

package LCore::Exception::Params;

sub as_string {
    my $self = shift;
    $self->message."\n".
        (@{$self->missing}  ? "The following arguments were missing: " . join(", ", @{$self->missing}) ."\n" : '').
        (@{$self->unwanted} ? "The following arguments were unwanted: " . join(", ", @{$self->unwanted})."\n" : '');
}

1;
