package RDF::Server::Semantic::Atom;

use Moose::Role;

with 'RDF::Server::Semantic';

use Class::MOP ();
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( HashRef );

use RDF::Server::Types qw( Handler Model );
use RDF::Server::Semantic::Atom::Types qw( AtomHandler );

has '+handler' => (
    coerce => 1,
    isa => AtomHandler
);

{

my %info = (
    service => {
        class => 'Service',
        children => 'workspaces',
        child => 'workspace',
    },
    workspace => {
        class => 'Workspace',
        children => 'collections',
        child => 'collection',
    },
    collection => {
        class => 'Collection',
        children => 'categories',
        child => 'category'
    },
    category => {
        class => 'Category',
    },
);

sub build_atomic_handler {
    my( $semantic, $config ) = @_;

    $semantic = $semantic -> meta -> name;
    # we expect $config -> [0] to tell us the top-level type
    my $info = $info{ $config -> [0] };

    if( !defined $info ) {
        confess "Unknown Atom ($semantic) document type: " . $config -> [0];
        return;
    }

    my $class = $semantic . '::' . $info -> {'class'};

    Class::MOP::load_class($class);
        
    my %c = %{$config -> [1]};
    if( is_HashRef( $c{model} ) ) {
        my %eh_config = %{delete $c{model}};
        my $eh_class = delete($eh_config{class});
        eval {
            Class::MOP::load_class('RDF::Server::Model::' . $eh_class);
            $eh_class = 'RDF::Server::Model::' . $eh_class;
        };
        if( $@ ) {
            eval {
                Class::MOP::load_class($eh_class);
            };
            if( $@ ) {
                confess "Unable to load $eh_class or RDF::Server::Model::$eh_class";
            }
        }

        if( is_Model( $eh_class ) ) {
            $c{model} = $eh_class -> new( %eh_config,
                semantic => $semantic,
            );
        }
        else {
            confess "$eh_class isn't a Model";
        }
    }

    if( $info -> {'children'} ) {
        my $handlers = delete $c{$info -> {'children'}};
        if( defined $info -> {'children'} ) {
            $c{handlers} = [
                map { $semantic -> build_atomic_handler( [ 
                    $info -> {'child'}, 
                    { model => $c{model}, %$_ }
                ] ) } @$handlers
            ];
        }
    }

    delete $c{model} unless defined $c{model};

    return $class -> new(
        %c
    );
}

}

1;

__END__

=pod

=head1 NAME

RDF::Server::Semantic::Atom - RDF service with Atom-ic semantics

=head1 SYNOPSIS

 package My::Server;

 semantic 'Atom';

 ---

 my $server = My::Server -> new(
      handler => [ workspace => {
          collections => [
              { entry_handler => { },
                categories => [ ]
              }
          ]
      ]
  );

=head1 DESCRIPTION

The Atom semantic module modifies the server configuration by adding an
ArrayRef to Handler coercion that allows configuration from plain text
files without Perl code.  The Atom semantic assumes a heirarchy of document
types: Services :> Workspaces :> Collections :> Categories :> Entries.
Collections can also manage Entries without Categories.

The top-level handler can be any of the available Atom document types, but
sub-handlers are expected to be the proper child type.

 Handler Type   Child Type   Entries   Child Configuration
 ------------   ----------   -------   -------------------
 service        workspace              workspaces
 workspace      collection             collections
 collection     category        X      categories
 category                       X

=head1 METHODS

=head1 SEE ALSO

L<RDF::Server::Style::Atom::Service>,
L<RDF::Server::Style::Atom::Workspace>,
L<RDF::Server::Style::Atom::Collection>,
L<RDF::Server::Style::Atom::Category>,
L<RDF::Server::Style::Atom::Entry>

=head1 AUTHOR 
            
James Smith, C<< <jsmith@cpan.org> >>
      
=head1 LICENSE
    
Copyright (c) 2008  Texas A&M University.
    
This library is free software.  You can redistribute it and/or modify
it under the same terms as Perl itself.
            
=cut
