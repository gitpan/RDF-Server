use strict;
use warnings;

use Test::More tests => 19;

BEGIN {
use_ok 'RDF::Server::Interface';
use_ok 'RDF::Server::Protocol';
use_ok 'RDF::Server::Formatter';

use_ok 'RDF::Server::Types';
use_ok 'RDF::Server::Constants';
use_ok 'RDF::Server::Exception';

use_ok 'RDF::Server';

use_ok "RDF::Server::Role::$_" for qw[
   Container
   Handler
   Model
   Mutable
   Renderable
   Resource
];

use_ok 'RDF::Server::Formatter::RDF';
use_ok 'RDF::Server::Formatter::Atom';

SKIP: {
    skip 'RDF::Core not found', 2 unless not not eval 'require RDF::Core';

    use_ok( 'RDF::Server::Model::RDFCore' );
    use_ok( 'RDF::Server::Resource::RDFCore' );
};

SKIP: {
    skip 'JSON::Any not found', 1 unless not not eval 'require JSON::Any';

    use_ok( 'RDF::Server::Formatter::JSON' );
}

SKIP: {
    skip 'FCGI::Engine not found', 1 unless not not eval 'require FCGI::Engine';

    use_ok( 'RDF::Server::Protocol::FCGI' );
}
}
