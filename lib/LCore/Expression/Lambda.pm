package LCore::Expression::Lambda;
use Moose;
use LCore::Procedure;
use LCore::Parameter;

extends 'LCore::Expression';

has procedure => (is => "ro", does => "LCore::Function");

sub analyze {
    my ($class, $env, $exp) = @_;

    return unless ref($exp) eq 'ARRAY' && $exp->[0] eq 'lambda';

    my (undef, $params, $body) = @$exp;

    die 'param error' unless ref($params) eq 'ARRAY';

    my $lambda_body = $env->analyze($body);

    $params = [ map { LCore::Parameter->new( { name => "$_" } ) } @$params ];

    my $function = LCore::Procedure->new( { env => $env,
                                            body => $lambda_body,
                                            parameters => $params } );

    return $class->new
        ( procedure => $function,
          code => sub { $function },
      );
}


__PACKAGE__->meta->make_immutable;
no Moose;
1;
