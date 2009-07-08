package LCore::Level2;
use Moose;
use LCore;
use LCore::Primitive;
use MooseX::ClassAttribute;
use LCore::Expression::Application;

extends 'LCore::Level1';

sub analyze_application {
    my ($self, $exp) = @_;

    # make expression class with traits into common factory
    my $meta = LCore::Expression::Application->meta;
    return $meta->create_anon_class
        ( superclasses => [ $meta->name ],
          roles => [ 'LCore::Expression::TypedApplication' ] )
        ->name->analyze($self, $exp);
}

sub analyze_lambda {
    my ($self, $exp) = @_;

    my $meta = LCore::Expression::Lambda->meta;
    return $meta->create_anon_class
        ( superclasses => [ $meta->name ],
          roles => [ 'LCore::TypedExpression' ] )
        ->name->analyze($self, $exp);
}

sub analyze_self_evaluating {
    my ($self, $exp) = @_;
    return if ref($exp);

    return LCore::Expression::SelfEvaluating->new_with_traits
        ( traits => ['LCore::TypedExpression'],
          code => sub { $exp },
          value => $exp );
}


sub BUILD {
    my ($self, $params) = @_;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;


1;
