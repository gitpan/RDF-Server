use Test::More tests => 3;

BEGIN {
  use_ok( 'RDF::Server::Formatter::Atom' );
}

use RDF::Server::Types qw( Exception );

# this formatter does not want rdf
ok( RDF::Server::Formatter::Atom -> wants_rdf );

my( $type, $atom );

eval {
( $type, $atom ) = RDF::Server::Formatter::Atom -> feed( );
};

ok( $@ );
