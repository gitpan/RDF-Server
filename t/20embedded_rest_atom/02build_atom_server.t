use Test::More tests => 17;

BEGIN { 
    use_ok 'RDF::Server';
    use_ok 'RDF::Server::Types';
    use_ok 'RDF::Server::Semantic::Atom';
};

use RDF::Server::Types qw( Protocol Interface Semantic Container );

my $e;

eval {
    package My::Server;

    use RDF::Server;

#    semantic '+RDF::Server::Semantic::Atom';

    render xml => 'Atom';
};

$e = $@;
is( $e, '', 'No error creating test package' );

ok( is_Protocol( 'My::Server' ), 'Protocol is set' );
ok( is_Interface( 'My::Server' ), 'Interface is set' );
ok( is_Semantic( 'My::Server' ), 'Semantic is set' );

ok( My::Server -> does( 'RDF::Server::Protocol::Embedded' ), 'Protocol is Embedded' );
ok( My::Server -> does( 'RDF::Server::Interface::REST' ), 'Interface is REST' );

ok( My::Server -> does( 'RDF::Server::Semantic::Atom' ), 'Semantic is Atom' );

ok( My::Server -> meta -> get_attribute('handler') -> should_coerce(), 'handler should coerce');
ok( My::Server -> meta -> get_attribute('handler') -> type_constraint -> has_coercion(), 'handler type has coercion');

my $server;

eval {
    $server = My::Server -> new(
        default_renderer => 'Atom',
        handler => [ workspace => {
            title => 'title',
            collections => [
              {
                  title => 'title',
                  categories => [ ],
                  model => {
                      class => 'RDFCore',
                      namespace => 'http://www.example.org/ns/'
                  }
              }
            ]
        } ]
    );
};

$e = $@;

is( $e, '', 'No error creating server instance' ); 

isa_ok( $server -> handler, 'RDF::Server::Semantic::Atom::Workspace', 'top-level handler');

isa_ok( $server -> handler -> handlers -> (), 'ARRAY');

isa_ok( $server -> handler -> handlers -> () -> [0], 'RDF::Server::Semantic::Atom::Collection');

isa_ok( $server -> handler -> handlers -> () -> [0] -> model, 'RDF::Server::Model::RDFCore' );
