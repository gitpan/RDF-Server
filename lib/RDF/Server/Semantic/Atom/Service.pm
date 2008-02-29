package RDF::Server::Semantic::Atom::Service;

use Moose;

with 'RDF::Server::Semantic::Atom::Handler';
with 'RDF::Server::Role::Renderable';

use RDF::Server::Semantic::Atom::Types qw( WorkspaceCodeRef );

use RDF::Server::Constants qw(:ns);

has '+handlers' => (
   isa => WorkspaceCodeRef
);

no Moose;

sub render {
    my($self, $formatter, $uri) = @_;
    # produce an Atom document describing the workspaces (handlers)

    return $formatter -> service( %{ $self -> data( $uri ) }  );
}

sub data {
    my($self, $uri_base) = @_;

    return +{
        workspaces => [ map { $_ -> data($uri_base . ($_ -> path_prefix || '') . '/') } @{ $self -> handlers -> () } ]
    }
}

1;

__END__

=pod

=head1 NAME

RDF::Server::Semantic::Atom::Service - supports use of Atom service documents

=head1 SYNOPSIS

 package My::Server;

 interface 'REST';
 protocol 'HTTP';

 my $server = new My::Server
    handler => RDF::Server::Semantic::Atom::Service -> new(
        uri_prefix => '/',
        handlers => [
            RDF::Server::Semantic::Atom::Workspace -> new (
                handlers => [
                    RDF::Server::Semantic::Atom::Collection -> new (
                        ...
                    )
                ]
            )
         ]
     )
 ;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item to_xml

Returns an app:service XML document.

=back

=head1 AUTHOR 
            
James Smith, C<< <jsmith@cpan.org> >>
      
=head1 LICENSE
    
Copyright (c) 2008  Texas A&M University.
    
This library is free software.  You can redistribute it and/or modify
it under the same terms as Perl itself.
            
=cut

