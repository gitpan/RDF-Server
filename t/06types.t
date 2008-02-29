package My::Tests;

use Test::More tests => 5;

BEGIN {
    use_ok('RDF::Server::Types');
    use_ok('RDF::Server::Semantic::Atom::Types');
}

use RDF::Server::Types qw( Handler );
use RDF::Server::Semantic::Atom::Types qw( AtomHandler );
use RDF::Server;



ok(AtomHandler -> is_subtype_of(Handler), "AtomHandler is a type of Handler");
#ok(is_Handler( AtomHandler ), "AtomHandler is a type of Handler");

ok( !is_Handler( 'Test::More' ) );
ok( !is_Handler( 'RDF::Server') );
