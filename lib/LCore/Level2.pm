package LCore::Level2;
use Moose;
use LCore;
use LCore::Primitive;
use MooseX::ClassAttribute;
use LCore::Expression::Application;
use LCore::Expression::Lambda;

extends 'LCore::Level1';

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
