use strict;
use warnings;

use Test::More tests => 6;

BEGIN {
use_ok 'RDF::Server';
}
use_ok 'RDF::Server::Exception';
use_ok 'RDF::Server::Constants';
use_ok 'RDF::Server::Interface';
use_ok 'RDF::Server::Protocol';
use_ok 'RDF::Server::Formatter';
