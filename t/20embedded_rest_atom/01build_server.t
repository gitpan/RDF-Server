use Test::More tests => 18;

BEGIN { 
    use_ok 'RDF::Server';
    use_ok 'RDF::Server::Types';
};

use RDF::Server::Types qw( Protocol Interface Formatter );

my $e;

BEGIN {
eval {
    package My::Server;

    use RDF::Server;
   
    render xml => 'Atom';
};

$e = $@;

is( $e, '', 'No error creating test package' );


# we test with interface and protocol swapped to make sure we
# can declare them in either order
eval {
    package My::Server2;

    use RDF::Server;

#    interface 'REST';
#    protocol 'HTTP';
    semantic 'Atom';
};

$e = $@;

is( $e, '', 'No error creating test package (Atom)' );

eval {
    package My::Server3;

    use RDF::Server;

#    interface 'REST';
    protocol 'HTTP';
#    semantic 'Atom';
};

$e = $@;

is( $e, '', 'No error creating test package (HTTP)' );

eval {
    package My::Server4;

    use RDF::Server;

#    interface 'REST';
    protocol 'HTTP';
    semantic 'Atom';
};

$e = $@;

is( $e, '', 'No error creating test package (HTTP Atom)' );

eval {
    package My::Server5;

    use RDF::Server;

    interface 'REST';
#    protocol 'HTTP';
#    semantic 'Atom';
};

$e = $@;

is( $e, '', 'No error creating test package (REST)' );

eval {
    package My::Server6;

    use RDF::Server;

    interface 'REST';
#    protocol 'HTTP';
    semantic 'Atom';
};

$e = $@;

is( $e, '', 'No error creating test package (REST Atom)' );

eval {
    package My::Server7;

    use RDF::Server;

    interface 'REST';
    protocol 'HTTP';
#    semantic 'Atom';
};

$e = $@;

is( $e, '', 'No error creating test package (REST HTTP)' );

eval {
    package My::Server8;

    use RDF::Server;

    interface 'REST';
    protocol 'HTTP';
    semantic 'Atom';
};

$e = $@;

is( $e, '', 'No error creating test package (REST HTTP Atom)' );

eval {
    package My::Server9;
    use RDF::Server qw( REST HTTP +RDF::Server::Semantic::Atom );
};

$e = $@;

is( $e, '', 'No error creating test package using import line' );

}


ok( is_Protocol( 'My::Server' ), 'Protocol is set' );
ok( is_Interface( 'My::Server' ), 'Interface is set' );

ok( is_Formatter( My::Server -> formatter( 'xml' ) ), 'Formatter for xml is set');

ok( My::Server7 -> does( 'RDF::Server::Protocol::HTTP' ), 'Protocol is HTTP' );
ok( My::Server7 -> does( 'RDF::Server::Interface::REST' ), 'Interface is REST' );

ok( My::Server6 -> does( 'RDF::Server::Protocol::Embedded' ), 'Default protocol is set' );
ok( My::Server3 -> does( 'RDF::Server::Semantic::Atom' ), 'Semantic is Atom' );
