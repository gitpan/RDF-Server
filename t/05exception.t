use strict;
use warnings;
use Test::More tests => 10;

use RDF::Server::Types qw( Exception );

BEGIN { use_ok 'RDF::Server::Exception' }

eval {
   RDF::Server::Exception -> throw( 
       status => 401,
       content => 'Access forbidden!'
   );
};

my $e = $@;

isnt( $e, undef, 'we have an exception');

isa_ok( $e, 'RDF::Server::Exception' );

is( $e -> status, 401 );

is( $e -> content, 'Access forbidden!' );

eval {
   throw RDF::Server::Exception::Forbidden;
};

$e = $@;

isnt( $e, undef, 'we have an exception');

isa_ok( $e, 'RDF::Server::Exception::Forbidden' );

is( $e -> status, 403 );

is( $e -> content, 'Forbidden!' );

ok( is_Exception( $e ), "is exception" );
