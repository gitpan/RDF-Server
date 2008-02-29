use Test::More;
use lib 't/lib';

BEGIN {
  eval 'require POE::Component::Server::HTTP';

  if($@) {
      plan skip_all => 'Testing HTTP protocol requires POE::Component::Server::HTTP';
  }

  plan tests => 4;

  use_ok('RDF::Server::Protocol::HTTP');

  use_ok('My::HTTPRestAtomServer');
};

my $server = My::HTTPRestAtomServer -> new(
  handler => [ collection => {
    title => 'Example Collection',
    model => {
        class => 'RDFCore',
        namespace => 'http://www.example.com/',
    }
  }]
);

isa_ok( $server, 'My::HTTPRestAtomServer' );

isa_ok( $server -> logger, 'Log::Handler' );
