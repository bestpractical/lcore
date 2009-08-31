package LCore::Level2;
use Moose;
use LCore;
use LCore::Primitive;
use MooseX::ClassAttribute;
use LCore::Expression::Application;
use LCore::Expression::Lambda;

extends 'LCore::Level1';

sub find_functions_by_type {
    my ($self, $expected_param_types, $expected_return_type) = @_;
    my $result = {};
    my $func = $self->all_functions;
    while (my ($name, $func) = each %$func) {
        next unless $func->parameters && $func->return_type;
        $func->return_type->is_a_type_of( $expected_return_type ) or next;
        if (ref $expected_param_types eq 'ARRAY') { # positional match
            my $i = 0;
            next if $#{$expected_param_types} > $#{$func->parameters};
            my $found = 1;
            for (@$expected_param_types) {
                $func->parameters->[$i]->type->is_a_type_of( $_ ) or $found = 0;
            }
            next unless $found;
        }
        else { # match any param
            my $found = 0;
            for (@{$func->parameters}) {
                $found = 1 if $_->type->is_a_type_of( $expected_param_types );
                # match for parameterized type of ArrayRef
                if ($_->type->isa('Moose::Meta::TypeConstraint::Parameterized')) {
                    $found = 1 if
                        $_->type->parent->name eq 'ArrayRef' &&
                            $_->type->type_parameter->is_a_type_of( $expected_param_types );
                }
            }
            next unless $found;
        }
        $result->{$name} = $func;
    }
    return $result;
}

sub all_functions {
    my ($self) = @_;
    my $result = {};
    for ($self->all_symbols) {
        my $func = $self->get_value($_);
        next unless $func->does('LCore::Function');
        $result->{$_} = $func;
    }
    return $result;
}

sub all_symbols {
    my ($self) = @_;
    my %name;
    my $env = $self;
    while ($env) {
        $name{$_} = 1 for keys %{$env->symbols};
        $env = $env->parent;
    }
    return keys %name;
}

sub typed_expression {
    my ($self, $expression_class, $specialized) = @_;
    my $class = "LCore::Expression::".$expression_class;
    # XXX: cleanup
    my $role = $specialized ? "LCore::Expression::Typed".$expression_class : 'LCore::TypedExpression';
    return $class->meta->create_anon_class
        ( superclasses => [ $class ],
          roles        => [ $role ] )
        ->name;
}

sub analyze_application {
    my ($self, $exp) = @_;

    return $self->typed_expression("Application", 1)->analyze($self, $exp);
}

sub analyze_lambda {
    my ($self, $exp) = @_;

    return $self->typed_expression("Lambda")->analyze($self, $exp);
}

sub analyze_self_evaluating {
    my ($self, $exp) = @_;
    return if ref($exp);

    return $self->typed_expression("SelfEvaluating")->new
        ( code  => sub { $exp },
          value => $exp );
}


sub BUILD {
    my ($self, $params) = @_;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


1;
