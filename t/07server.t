use Test::More tests => 8;
use Test::Moose;
use RDF::Server;

##
# test things that aren't in other tests
##

my $class = RDF::Server -> build_from_config(
    interface => 'REST',
    protocol => 'HTTP',
    semantic => 'Atom',
    renderers => {
        'rdf' => 'RDF',
        'atom' => 'Atom',
        'json' => 'JSON'
    },
    port => '8000',
    loglevel => 2
);

meta_ok( $class, "server class has a meta" );
ok( $class -> isa('RDF::Server'), 'server class isa RDF::Server' );
does_ok( $class, 'RDF::Server::Semantic::Atom' );
does_ok( $class, 'RDF::Server::Protocol::HTTP' );
does_ok( $class, 'RDF::Server::Interface::REST' );

my $server;

eval {
$server = $class -> new(
    handler => [ workspace => {
        title => 'Foo'
    } ]
);
};

is( $@, '' );

is( $server -> port, '8000' );
is( $server -> loglevel, 2 );
