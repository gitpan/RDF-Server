use Test::More tests => 9;
use Test::Moose;
use RDF::Server;
eval "use Carp::Always"; # for those who don't have it

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

isa_ok( $server, 'RDF::Server' );

ok( $server -> meta -> get_attribute('port'), 'server meta has port attribute' );

my $p = eval { $server -> port; };

if($@ =~ m{Can't locate object method "port"} && $ENV{'AUTOMATED_TESTING'} ) {
    print STDERR "AUTOMATED TESTING info:\n";
    print STDERR "  server object: $server:\n";
    print STDERR "  attributes: ", join(", ",
        #map { $_ -> name } $server -> meta -> computer_all_applicable_attributes
        $server -> meta -> get_attribute_list
    ), "\n";
}

is( $p, '8000' );
