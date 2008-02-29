use inc::Module::Install;

name 'RDF-Server';
all_from 'lib/RDF/Server.pm';

##
# TODO: offer choices for the following few
##

# for RDFCore interfacing modules
requires 'RDF::Core';

# for JSON formatter
requires 'JSON::Any';

# for HTTP protocol handler
requires 'MooseX::Daemonize';
requires 'POE::Component::Server::HTTP';
requires 'Log::Handler';

###
# Following are basic modules
###

requires 'Moose';
requires 'Class::MOP';
requires 'Sub::Exporter';
requires 'Sub::Name';
requires 'MooseX::Types';

requires 'HTTP::Status';
requires 'HTTP::Request';
requires 'HTTP::Response';

requires 'DateTime';

requires 'XML::LibXML';

###
# for Model
###
requires 'Iterator::Simple' => 0.04;
requires 'Data::UUID';

###
# for Resource
###
requires 'XML::Simple';


build_requires 'Test::More';

tests('t/*.t t/*/*.t');

auto_install;
WriteAll;
