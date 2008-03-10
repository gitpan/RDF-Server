use Test::More;
use Test::Moose;

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

  plan tests => 7;

  use_ok('RDF::Server::Protocol::FCGI');

  use_ok('t::lib::FCGIRestAtomServer');
};

my $server = FCGIRestAtomServer -> new(
  socket => '/tmp/fcgi_rest_atom.socket',
  handler => [ collection => {
    title => 'Example Collection',
    model => {
        class => 'RDFCore',
        namespace => 'http://www.example.com/',
    }
  }]
);

isa_ok( $server, 'FCGIRestAtomServer' );

does_ok( $server, 'RDF::Server::Protocol::FCGI' );
does_ok( $server, 'RDF::Server::Interface::REST' );
does_ok( $server, 'RDF::Server::Semantic::Atom' );

isa_ok( $server -> logger, 'Log::Handler' );
