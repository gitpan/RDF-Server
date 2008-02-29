package RDF::Server;

use Moose;

use RDF::Server::Types qw( Handler Protocol Interface Semantic Formatter );
use Sub::Exporter;
use Sub::Name 'subname';
use Class::MOP ();
use MooseX::Types::Moose qw( ArrayRef );

our $VERSION='0.01';

has 'handler' => (
    is => 'rw',
    isa => Handler,
    required => 1,
);

has default_renderer => (
    is => 'rw',
    isa => 'Str',
    default => 'RDF'
);

# we put behaviors here that we want for everything in the namespace

{
    sub _load_class {
        my( $class ) = @_;
        eval { Class::MOP::load_class($class); };
        return Class::MOP::is_class_loaded($class);
    }

    sub _map_classes {
        my($parent_class, $prefix, $is_type, $message, $c) = @_;
        my $class;
        if( substr($c, 0, 1) eq '+' ) {
            $class = substr($c, 1);
        }
        else {
            $class = $prefix . '::' . $c;
        }

        if( not _load_class($class) || !$is_type -> ($class) ) {
            confess $class . ' ' . $message;
        }
        else {
            Moose::Util::apply_all_roles($parent_class -> meta, $class);
        }
    };

    my @imported_into;

    CHECK {
        foreach my $class ( @imported_into ) {
            next unless $class -> can('meta') && $class -> isa('RDF::Server');
            Moose::Util::apply_all_roles(
                $class -> meta, 
                'RDF::Server::Protocol::Embedded'
            ) unless is_Protocol( $class );
            Moose::Util::apply_all_roles(
                $class -> meta, 
                'RDF::Server::Interface::REST'
            ) unless is_Interface( $class );
            Moose::Util::apply_all_roles(
                $class -> meta, 
                'RDF::Server::Semantic::Atom'
            ) unless is_Semantic( $class );
            #Moose::Util::apply_all_roles($class -> meta, @with);
        }
    }
           

    sub import {
        my $CALLER = caller();

        push @imported_into, $CALLER;

        my @addons = @_;
        shift @addons;
        @_ = ($_[0]);

        my %exports = (
            'protocol' => sub {
                my $class = $CALLER;
                return subname 'RDF::Server::protocol' => sub ($) {
                    _map_classes($class, 'RDF::Server::Protocol', \&is_Protocol, 'does not fill the RDF::Server::Protocol role', @_);
                };
            },
            'interface' => sub {
                my $class = $CALLER;
                return subname 'RDF::Server::interface' => sub ($) {
                    _map_classes($class, 'RDF::Server::Interface', \&is_Interface, 'does not fill the RDF::Server::Interface role', @_);
                };
            },
            'semantic' => sub {
                my $class = $CALLER;
                return subname 'RDF::Server::semantic' => sub ($) {
                    _map_classes($class, 'RDF::Server::Semantic', \&is_Semantic, 'does not fill the RDF::Server::Semantic role', @_);
                };
            },

            'render' => sub {
                my $class = $CALLER;
                return subname 'RDF::Server::render' => sub ($$) {
                    my($extension, $as) = @_;
                    # format $ext => $as
                    # RDF::Server::Format::$as to_rdf from_rdf
                    my $formatter;
                    $extension = [ $extension ] unless is_ArrayRef( $extension );
                    if( _load_class( "RDF::Server::Formatter::$as" ) ) {
                        $formatter = "RDF::Server::Formatter::$as";
                    }
                    elsif( _load_class($as) ) 
                    {
                        $formatter = $as;
                    }
                    if( is_Formatter( $formatter ) ) {
                        no strict 'refs';
                        @{$class . '::FORMATTERS'}{@$extension} = $formatter;
                    }
                    elsif( $formatter ) {
                        confess "$formatter does not fill the RDF::Server::Formatter role";
                        }
                    else {
                        confess "Unable to load $as";
                    }
                };
            },
        );

        my $exporter = Sub::Exporter::build_exporter({
            exports => \%exports,
            groups => { default => [':all'] }
        });


        strict -> import;
        warnings -> import;

        return if $CALLER eq 'main';

        Moose -> import( { into => $CALLER } );

        $CALLER -> meta -> superclasses( __PACKAGE__ );

        my $class;

        foreach my $addon (@addons) {
            # Path: RDF::Server::Protocol, R:S::Interface
            #       MooseX::


            if( _load_class('RDF::Server::Protocol::' . $addon) ) {
                $class = 'RDF::Server::Protocol::' . $addon;
            }
            elsif( _load_class('RDF::Server::Interface::' . $addon) ) {
                $class = 'RDF::Server::Interface::' . $addon;
            }
            elsif( _load_class('RDF::Server::Semantic::' . $addon) ) {
                $class = 'RDF::Server::Semantic::' . $addon;
            }
            elsif( _load_class('MooseX::' . $addon) ) {
                $class = 'MooseX::' . $addon;
            }
            elsif( _load_class($addon) ) {
                $class = $addon;
            }
            elsif( substr($addon, 0, 1) eq '+' && _load_class( substr($addon,1) ) ) {
                $class = substr($addon, 1);
            }
            else {
                confess "Unable to find $class";
                next;
            }
            Moose::Util::apply_all_roles($CALLER -> meta, $class);
        }

        goto &$exporter;
    }
}

no Moose;

sub formatter {
    my( $self, $extension ) = @_;

    my $class = $self -> meta -> name;
    my $r;

    no strict 'refs';

    if( defined $extension ) {
        $r = ${"${class}::FORMATTERS"}{$extension};

        return $r if defined $r;
    }

    $r = $self -> default_renderer;
    if( _load_class("RDF::Server::Formatter::$r") ) {
        return "RDF::Server::Formatter::$r";
    }
    elsif( _load_class($r) ) {
        return $r;
    }
}

1;

__END__

=pod

=head1 NAME

RDF::Server - toolkit for building RDF servers

=head1 SYNOPSIS

 # Define basic server behavior:

 package My::Server;

 use RDF::Server;
 with 'MooseX::Daemonize';

 interface 'REST';
 protocol  'HTTP';
 semantic  'Atom';   
                
 render xml => 'Atom';
 render rss => 'RDF';
            
 # Run server (if daemonizable):
                        
 my $daemon = My::Server -> new( ... );
     
 $daemon -> run();
                        

=head1 DESCRIPTION

RDF::Server provides a flexible framework with which you can design
your own RDF service.  By dividing itself into several areas of responsibility,
the framework allows you to mix and match any capabilities you need to create
the service that fits your RDF data and how you need to access it.
            
The framework identifies four areas of responsibility:
            
=head2 Protocol
        
The protocol modules manage the outward facing part of the framework and
translating the requested operation into an HTTP::Request object that is
understood by any of the interface modules.  Conversely, it translates the
resulting HTTP::Response object into the form required by the environment
in which the server is operating.  
    
For example, the Embedded protocol provides a Perl API that can be used
by other modules without having to frame operations in terms of HTTP requests
and responses.
        
The methods expected of protocol modules are defined in
L<RDF::Server::Protocol>.  The outward-facing API is dependent on
the environment the server is expected to operate within.
                
Available protocols in the standard distribution:
L<RDF::Server::Protocol::Embedded>,
L<RDF::Server::Protocol::HTTP>.
    
=head2 Interface

The interface modules define how the HTTP requests are translated into
operations on various handlers that manage different aspects of the RDF
triple store.   

=head2 Semantic

The semantic modules define the meaning attached to and information 
contained in the various documents and the heirarchy of resources 
available through the interface modules.  Most of the content handlers 
are attached to a particular semantic.

The available semantic is:
L<RDF::Server::Semantic::Atom>.

=head2 Formatters

The same information can be rendered in several different formats.  The
format modules manage this rendering.

The available formatters are:
L<RDF::Server::Formatter::Atom>,
L<RDF::Server::Formatter::JSON>,
L<RDF::Server::Formatter::RDF>.

=head1 CLASS METHODS

In addition to the methods exported by Moose, several helper methods 
are exported when you C<use> RDF::Server.  These can be used to easily
specify the interface or protocol role if the name is ambiguous.

By default, these helpers will search for the appropriate class by 
prepending the appropriate C<RDF::Server::> namespace.  You may 
override this by prepending C<+> to the class name.

The class will be applied to your class as a role.  The helper will also
make sure that the class provides the appropriate role.

=over 4

=item interface

The interface defines how HTTP requests are mapped to actions on resources.

Available interfaces: REST.

Default is RDF::Server::Interface::REST.

=item protocol

The protocol is how the RDF server communicates with the world.

Available protocols: Embedded, HTTP.  
(Apache2 and FastCGI are on the TODO list.)

Default is RDF::Server::Protocol::Embedded.

=item semantic

The server semantic determines how the RDF stores are structured and 
presented in documents by managing how the handler is configured.

Available semantics: Atom.

Default is RDF::Server::Semantic::Atom.

=item render

The interface maps file types to formatters using the mappings defined by the
C<render> method.

=back

=head1 OBJECT METHODS

=over 4

=item formatter

This will return the formatter for a particular file format as defined by the
C<render> method.

=back

=head1 CONFIGURATION

=over 4

=item default_rendering

This determines the default file format when none is provided.  The file format
should map to a formatter defined by the C<render> method in the class
definition.

=item handler

This object is used by the interface to find the proper handler for a
request.  This object must inherit from RDF::Server::Handler.

The server semantic can redefine the handler type and provide a way to 
configure the handler from a configuration file or Perl data structure.

=back

=head1 NAMESPACE DESIGN

The RDF::Server namespace is divided into these broad areas:

=over 4

=item Protocol

Modules in RDF::Server::Protocol provide the interface with the world.  Examples
include HTTP, Apache/mod_perl, and FastCGI.

=item Interface

RDF::Server::Interface modules determine the type of URI and HTTP method 
management that is used.  RDF::Server comes with a REST interface.

=item Semantic

RDF::Server::Semantic modules manage the configuration and interpretation 
of URIs once the Interface module has passed the request on.  RDF::Server 
comes with an Atom semantic of URI heirarchies and configuration.

=item Formatter

RDF::Server::Formatter modules translate the internal data structures to
particular document types.  The formatter for a request is selected by the
Interface module.

=item Model

RDF::Server:Model modules interface between the Semantic and Formatter 
modules and the backend triple store.

=item Resource

RDF::Server:Resource modules represent particular resources and associated 
data within a triple store.

=back

=head1 SEE ALSO

L<Moose>,
L<RDF::Server::Formatter>,
L<RDF::Server::Interface>,
L<RDF::Server::Model>,
L<RDF::Server::Protocol>,
L<RDF::Server::Resource>,
L<RDF::Server::Semantic>.

=head1 AUTHOR
        
James Smith, C<< <jsmith@cpan.org> >>
            
=head1 LICENSE
            
Copyright (c) 2008  Texas A&M University.
            
This library is free software.  You can redistribute it and/or modify
it under the same terms as Perl itself.
            
=cut

