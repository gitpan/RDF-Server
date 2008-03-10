use Test::More;
#use lib 't/lib';

use t::lib::utils;

my $lighttpd;
BEGIN {
    $lighttpd = utils::find_lighttpd();

    plan skip_all => "A lighttpd binary must be available for this test"   
        unless $lighttpd;
}


BEGIN {
  foreach my $class (qw(
      RDF::Core
      FCGI
      Log::Handler
      MooseX::Daemonize
  )) {
      plan skip_all => "Testing FCGI protocol requires $class"
          unless not not eval "require $class";
  }

  plan tests => 4;
}

use t::lib::FCGIRestAtomServer;

my $PORT = 2090;

my $UA = FCGIRestAtomServer -> fork_and_return_ua(
    port => $PORT,
    loglevel => 8, # test debugging levels
    default_renderer => 'Atom',
    handler => [
      collection => {
        path_prefix => '/',
        title => 'Example Collection',
        categories => [
            { term => 'foo', scheme => 'http://www.example.com/' },
            { term => 'bar', scheme => 'http://www.example.com/' },
        ],
        model => {
            class => 'RDFCore',
            namespace => 'http://www.example.com/',
        }
      }
    ]
);

ok( $UA, 'we have a user agent' );

my $req = HTTP::Request -> new(GET => "http://localhost:$PORT/");
my $resp = $UA -> request($req);

ok( $resp -> is_success );

$req = HTTP::Request -> new(GET => "http://localhost:$PORT/foo/");
$resp = $UA -> request($req);

ok( $resp -> is_success );
is( $resp -> header('Content-Type'), 'application/atom+xml' );
