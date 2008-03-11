use strict;
use warnings;

eval "use Carp::Always"; # for those who don't have it

use Test::More tests => 20;

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
    foreach my $m (qw(
        FCGI Log::Handler MooseX::Daemonize
    )) {
        skip("$m not found", 1) && last 
            unless not not eval "require $m";
    }

    use_ok( 'RDF::Server::Protocol::FCGI' );
}

SKIP: {
    foreach my $m (qw(
        POE::Component::Server::HTTP Log::Handler MooseX::Daemonize
    )) {
        skip("$m not found", 1) && last 
            unless not not eval "require $m";
    }

    use_ok( 'RDF::Server::Protocol::HTTP' );
}
}
