package LCore::Expression::Application;
use Moose;
extends 'LCore::Expression';

has operator => (is => "ro", isa => "LCore::Expression|CodeRef");

has operands => (is => "ro", isa => "ArrayRef[LCore::Expression|CodeRef]");

sub analyze {
    my ($class, $env, $exp) = @_;

    return unless ref($exp) eq 'ARRAY';

    my ($op, @exp) = @$exp;
    my $operator = $env->analyze($op);

    return $class->mk_expression( $env, $operator,
                                  [map { $env->analyze($_) } @exp] );
}

sub mk_expression {
    my ($class, $env, $operator, $operands) = @_;
    my @args = @$operands;
    return $class->new(
        operator => $operator,
        operands => $operands,
        code     => sub {
            my $env = shift;
            my $o = $operator->($env) or die "can't find operator";

            my @a = $o->lazy
                ? map { ref $_ ? LCore::Thunk->new( env => $env, delayed => $_ ): $_ } @args
                : map { $_->($env) } @args;

            return $o->apply(@a);
        });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
