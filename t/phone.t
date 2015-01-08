use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Test::Mojo;
use Mojo::Util qw(url_escape);

plugin 'AdditionalValidationChecks';

get '/' => sub {
  my $c = shift;

  my $validation = $c->validation;
  $validation->input( $c->req->params->to_hash );

  $validation->required( 'phone' )->phone();

  my $result = $validation->has_error() ? 0 : 1;
  $c->render(text => $result );
};

my %phones = (
    '+49 123 / 1321352'  => 1,
    '00 123 / 1321352'   => 0,
    '0049 123 / 1321352' => 1,
    '0124 / 1321352'     => 1,
    'abc'                => 0,
    '+49123/1321352'     => 1,
    '00123/1321352'      => 1,
    '+49123-1321352'     => 1,
    '00123-1321352'      => 1,

    '+491232341251-1321352' => 0,
    '00123123124-1321352'   => 0,
);

my $t = Test::Mojo->new;
for my $phone ( keys %phones ) {
    my $esc = url_escape $phone;
    $t->get_ok('/?phone=' . $esc)->status_is(200)->content_is( $phones{$phone}, "Phone number: $phone" );
}

done_testing();
