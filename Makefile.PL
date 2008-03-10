use inc::Module::Install;

name 'RDF-Server';
all_from 'lib/RDF/Server.pm';

##
# TODO: offer choices for the following few
##

# for RDFCore interfacing modules
feature 'RDF::Core',
  -default => 0,
  'RDF::Core' => 0;

# for JSON formatter
feature 'JSON Formatting',
  -default => 0,
  'JSON::Any' => 0;

# for HTTP protocol handler
feature 'HTTP Protocol',
  -default => 0,
  'MooseX::Daemonize' => 0,
  'POE::Component::Server::HTTP' => 0,
  'Log::Handler' => 0;

# for FastCGI protocol support
feature 'FastCGI',
  -default => 0,
  'MooseX::Daemonize' => 0,
  'Log::Handler' => 0,
  'FCGI' => 0;

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
build_requires 'Test::Moose';


tests('t/*.t t/*/*.t');
author_tests('xt');

install_script glob('script/*.pl');

auto_install;
WriteAll;
