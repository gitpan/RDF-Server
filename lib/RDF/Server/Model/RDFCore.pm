package RDF::Server::Model::RDFCore;

use Moose;
with 'RDF::Server::Role::Model';

use MooseX::Types::Moose qw( ArrayRef );

use RDF::Core::Model;
use RDF::Server::Resource::RDFCore;
use Iterator::Simple qw( iterator );

has store => (
    is => 'rw',
    isa => 'RDF::Core::Model',
    lazy => 1,
    default => sub {
        Class::MOP::load_class('RDF::Core::Storage::Memory');
        new RDF::Core::Model( Storage => new RDF::Core::Storage::Memory )
    }
);

no Moose;

sub resource {
    my($self, $id) = @_;

    if( !is_ArrayRef($id) ) {
        $id = [ $self -> namespace, $id ];
    }

    return RDF::Server::Resource::RDFCore -> new(
        model => $self,
        namespace => $id -> [0],
        localname => $id -> [1],
        id => $id -> [1]
    );
}

sub resources {
    my($self, $namespace) = @_;

    $namespace ||= $self -> namespace;

    # return a list of Resource objects for subjects in the namespace
    # or an iterator if we can

    my $iter = $self -> store -> getStmts();
    my $next = $iter -> getFirst();
    my %seen_subjects;
    iterator {
        while( 
            defined( $next )
            && ( $seen_subjects{ $next -> getSubject -> getURI }++
                 || index($next -> getSubject -> getURI, $namespace) != 0 
               ) 
        ) {
            $next = $iter -> getNext();
        }
        return unless defined $next;
        RDF::Server::Resource::RDFCore -> new(
            model => $self,
            namespace => $namespace,
            id => substr( $next -> getSubject -> getURI, length($namespace) )
        );
    };
}

sub resource_exists {
   my($self, $namespace, $id) = @_;

   $self -> has_triple( [ $namespace, $id ] );
}

sub has_triple {
    my($self, $s, $p, $o) = @_;

    $self -> store -> existsStmt(
        $self -> _make_resource( $s ),
        $self -> _make_resource( $p ),
        is_ArrayRef( $o ) ? $self -> _make_resource( $o ) 
                          : $self -> _make_literal( $o )
    );
}

#sub get_triples {
#    my($self, $s, $p, $o) = @_;
#
#    my $iter = $self -> store -> getStmts(
#        $self -> _make_resource( $s ),
#        $self -> _make_resource( $p ),
#        is_ArrayRef( $o ) ? $self -> _make_resource( $o ) 
#                          : $self -> _make_literal( $o )
#    );
#
#    my $e = $iter -> getFirst;
#    my $t;
#    iterator {
#        return unless $e;
#        $t = $e -> getLabel;
#        $e = $iter -> getNext;
#        $t;
#    };
#}

sub add_triple {
    my($self, $s, $p, $o) = @_;

    return unless defined($s) && defined($p) && defined($o);

    $self -> store -> addStmt( RDF::Core::Statement -> new(
        $self -> _make_resource($s),
        $self -> _make_resource($p),
        is_ArrayRef($o) ? $self -> _make_resource( $o )
                        : $self -> _make_literal( $o )
    ) );
}

sub _make_resource {
    my($self, $r) = @_;

    return undef unless defined $r;

    return $r if blessed($r) && (
        $r -> isa('RDF::Core::Literal') 
        || $r -> isa('RDF::Core::Resource')
    );

    if(is_ArrayRef( $r )) {
        RDF::Core::Resource -> new( @$r );
    }
    else {
        RDF::Core::Resource -> new( $r );
    }
}

sub _make_literal {
    my($self, $l) = @_;

    return undef unless defined $l;

    return $l if blessed($l) && (
        $l -> isa('RDF::Core::Literal') 
        || $l -> isa('RDF::Core::Resource')
    );

    RDF::Core::Literal -> new( $l );
}

1;

__END__

=pod

=head1 NAME

RDF::Server::Model::RDFCore

=head1 SYNOPSIS

=head1 DESCRIPTION

Manages a triple store based on RDF::Core.

=head1 CONFIGURATION

=over 4

=item namespace

The default namespace in which resources are located.  While the store
can support resources in other namespaces, the RDF::Server modules expect
resources to be in this namespace.

=item store

The store is a RDF::Core::Model object that manages the triples.

=back

=head1 METHODS

=over 4

=item has_triple ($s, $p, $o)

Given a subject, predicate, and object, returns true if the store contains
the triple.  Any of the parameters may be undefined to serve as wildcards.

Each parameter may be a single value or an array ref.  

If the subject or predicate are an array ref, then the referenced 
array consists of two elements: the namespace and the local name.  
Otherwise, the string is the URI (namespace and local name combined) 
of the parameter.  

If the object is a string, then it is considered a literal.  Otherwise, 
it is interpreted in the same manner as the other parameters.

=item resource ( $id | [ $namespace, $id ] )

Returns a RDF::Server::Resource::RDFCore object representing all the triples
in the store that are associated with the given either an array 
reference containing the namespace and the local name, or a string 
containing the local name.  The default namespace is the one defined 
for the model.

This will return an object regardless of the existance of the resource.  It
is not an error to have an empty RDF document associated with a URL.

=item resources ( $namespace )

Returns an iterator (see L<Iterator::Simple>) that will iterate over the
resources in the store in the provided namespace (or the model's namespace if
none is given).  Each iteration will return a
RDF::Server::Resource::RDFCore object.

=item resource_exists ( $namespace, $id )

Returns true if there is at least one triple in the store associated with the
provided namespace and local name.

=back

=head1 AUTHOR 
            
James Smith, C<< <jsmith@cpan.org> >>
      
=head1 LICENSE
    
Copyright (c) 2008  Texas A&M University.
    
This library is free software.  You can redistribute it and/or modify
it under the same terms as Perl itself.
            
=cut
