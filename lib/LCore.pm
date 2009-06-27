package LCore;
use LCore::Env;
use LCore::Thunk;
use Data::SExpression qw(cons consp);
use UNIVERSAL::isa;
my $ds = Data::SExpression->new({use_symbol_class=>1,
                                 fold_lists => 1,
                                 fold_alists => 1,
                             });

our $global_env = LCore::Env->new();

sub is_self_evaluating {
    my ($self, $exp) = @_;
    return !ref($exp);
}

sub is_variable {
    my ($self, $exp) = @_;
    return ref($exp) && ref($exp) eq 'Data::SExpression::Symbol';
}

sub analyze_variable {
    my ($self, $exp) = @_;
    return sub { my $env = shift; $env->get_value($exp) };
}

sub is_application {
    my ($self, $exp) = @_;
    return ref($exp) eq 'ARRAY';
}

sub analyze_application {
    my ($self, $exp) = @_;
    my ($op, @exp) = @$exp;
    my $operator = $self->analyze($op);
    my @args = map { $self->analyze($_) } @exp;

    return sub {
        my $env = shift;
        my $o = $operator->($env);

        # clean up later.

        my $lazy = $o->isa('LCore::Primitive') ? 0 : 1;

        my @a = $lazy
            ? map { LCore::Thunk->new( env => $env, delayed => $_ ) } @args
            : map { $_->($env) } @args;

        # eager
        if ($o->isa('LCore::Primitive') || $o->isa('LCore::Lazy')) {
            return $o->(@a);
        }

        if ($o->isa('LCore::Procedure')) {
            die "argument number mismatch" if $#{$o->parameters} ne $#a;
            my %args = map { $_ => shift @a } @{$o->parameters};
            return $o->body->($env->extend(\%args));
        }
        die 'unknown application';
    }

}

sub analyze_it {
    my ($self, $expression_string) = @_;

    my $exp = $ds->read($expression_string);
    return $self->analyze($exp);
}

sub analyze {
    my ($self, $exp) = @_;
    my $result;
    if ($self->is_self_evaluating($exp)) {
        return sub { $exp };
    }
    elsif ($self->is_variable($exp)) {
        return $self->analyze_variable($exp);
    }
    elsif ($self->is_application($exp)) {
        return $self->analyze_application($exp);
    }
    else {
        die "unknown expression type".Dumper($exp);use Data::Dumper;
    }

}

1;
