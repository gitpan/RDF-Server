package RDF::Server::Protocol::HTTP;

use Moose::Role;

with 'RDF::Server::Protocol';
with 'MooseX::Daemonize';

use POE::Component::Server::HTTP ();
use HTTP::Status qw(RC_OK RC_NOT_FOUND RC_METHOD_NOT_ALLOWED RC_INTERNAL_SERVER_ERROR);
use Log::Handler;
use HTTP::Request;
use HTTP::Response;

use RDF::Server::Exception;

use RDF::Server::Types qw(Exception);


has port => (
    is => 'ro',
    isa => 'Str',
    default => '8080',
);

has address => (
    is => 'ro',
    isa => 'Str',
    default => '127.0.0.1',
);

has logger => (
    is => 'rw',
    isa => 'Object',
    lazy => 1,
    noGetOpt => 1,
    default => \&_build_logger,
);

has errorlog => (
    is => 'rw',
    isa => 'Str',
    default => '*STDERR',
    trigger => sub { $_[0] -> logger( $_[0] -> _build_logger ) }
);

has loglevel => (
    is => 'rw',
    isa => 'Int',
    default => '4',
    trigger => sub { $_[0] -> logger( $_[0] -> _build_logger ) }
);

has uri_base => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub { '/' }
);


has aliases => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    noGetOpt => 1,
    default => sub {
        my $self = shift;
        POE::Component::Server::HTTP -> new(
           Port => $self -> port,
           Address => $self -> address,
           ContentHandler => {
               $self -> uri_base => sub { $self -> handle(@_) },
           },
           Headers => { Server => "RDF Server $RDF::Server::VERSION" },
        );
    }
);

after 'start' => sub {
    my $self = shift;

    return unless $self -> foreground || $self -> is_daemon;

    if(defined $self->aliases->{httpd}) {
        POE::Kernel -> run();
    }
};


no Moose::Role;

sub _build_logger {
    my $self = shift;
    Log::Handler -> new (
        filename => $self -> errorlog,
        mode => 'append',
        prefix => "[$0 $$] [<--LEVEL-->] ",
        newline => 1,
        maxlevel => $self -> loglevel,
        debug => $self -> loglevel > 7 ? 1 : 0,
    );
}

sub handle {
    my($self, $request, $response) = @_;

    eval {
        $self -> handle_request($request, $response);
    };

    my $e = $@;
    if($e) {
        if(is_Exception($e)) {
            $response -> code( $e -> status );
            $response -> content( $e -> content );
            $response -> headers -> push_header( $_ => $e -> headers -> {$_} )
                foreach keys %{$e -> headers};
        }
        else { 
          $self -> logger -> error( $e ); 
          $response -> code( 500 );
          $response -> content( 'Uh oh! ' . $e );
        }
    }
    return $response -> code;
}

1;

__END__

=pod

=head1 NAME

RDF::Server::Protocol::HTTP - POE-based standalone HTTP server

=head1 SYNOPSIS

 package My::Server;

 use RDF::Server;
 with 'MooseX::SimpleConfig';
 with 'MooseX::Getopt';

 protocol 'HTTP';
 interface 'SomeInterface';
 semantic 'SomeSemantic';

=head1 DESCRIPTION

This protocol handler interfaces between the RDF::Server framework and
a POE::Component::Server::HTTP server.  

The MooseX::Daemonize role is included in this module.  The C<start>
method is extended to start the POE::Kernal event loop in the daemonized 
process.

=head1 CONFIGURATION

=over 4

=item address

This is the IP address on which the server should listen.

Default: 127.0.0.1 (localhost)

=item port

This is the port on which the server should listen.

Default: 8080

=item errorlog

This is the filename (or one of *STDOUT, *STDERR) where errors are logged.

=item loglevel

The severity threshold above which errors are logged.  See L<Log::Handler>
for the log levels.  Any log level above 7 will turn on debugging.

=item uri_base

This is the base URI at which the server should respond to requests.  This
is the location at which the content handler responds in the
POE::Component::Server::HTTP object.  See L<POE::Component::Server::HTTP>
for more information.

=back

=head1 METHODS

=over 4

=item handle ($request, $response)

Passes the request and response objects to the appropriate interface handler.
Returns the appropriate code to the POE::Component::Server::HTTP server.

=back

=head1 SEE ALSO

L<MooseX::Daemonize>,
L<POE::Component::Server::HTTP>.

=head1 AUTHOR 
            
James Smith, C<< <jsmith@cpan.org> >>
      
=head1 LICENSE
    
Copyright (c) 2008  Texas A&M University.
    
This library is free software.  You can redistribute it and/or modify
it under the same terms as Perl itself.
            
=cut

