package LCore::Expression::Application;
use Moose;
extends 'LCore::Expression';

has operator => (is => "ro", isa => "LCore::Expression|CodeRef");

# XXX: separate by name and by position expression, and hide the
# details with get_operands.
has operands => (is => "ro", isa => "HashRef|ArrayRef[LCore::Expression|CodeRef]");

sub analyze {
    my ($class, $env, $exp) = @_;

    return unless ref($exp) eq 'ARRAY';

    my ($op, @exp) = @$exp;
    my $operator = $env->analyze($op);

    my $operands;
    if ($#exp == 0 && ref($exp[0]) eq 'HASH') { # by name
        $operands = { map { $_ => $env->analyze($exp[0]{$_}) } keys %{$exp[0]} };
    }
    else {
        $operands = [map { $env->analyze($_) } @exp];
    }

    return $class->mk_expression( $env, $operator, $operands );
}

sub get_operands {
    my ($class, $proc, $operands) = @_;
    return @$operands if ref($operands) eq 'ARRAY';

    my $params = $proc->parameters or die "params by name unavailable for functions not defined with params: $proc";
    return map { $operands->{$_} } @$params;
}

sub mk_expression {
    my ($class, $env, $operator, $operands) = @_;
    return $class->new(
        operator => $operator,
        operands => $operands,
        code     => sub {
            my $env = shift;
            my $o = $operator->($env) or die "can't find operator";

            my @args = $class->get_operands($o, $operands);

            my @a = $o->lazy
                ? map { ref $_ ? LCore::Thunk->new( env => $env, delayed => $_ ): $_ } @args
                : map { $_->($env) } @args;

            return $o->apply(@a);
        });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
