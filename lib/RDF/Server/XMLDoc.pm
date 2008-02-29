package RDF::Server::XMLDoc;

use Moose;

use MooseX::Types::Moose qw(Str Object);

has document => (
    is => 'rw',
    isa => 'XML::LibXML::Document',
    lazy => 1,
    default => sub {
        my( $self ) = @_;
        my $parser = XML::LibXML -> new();
        my $xml = $self -> xml;
        $self -> xml(undef);
        $parser -> parse_string( $xml );
    }
);

has xml => (
    is => 'rw',
    isa => Str,
    lazy => 1,
    default => sub {
        (shift) -> document -> toStringC14N;
    }
);

use overload '""' => sub { (shift) -> document -> toStringC14N };

around new => sub {
    my($method, $self) = splice @_, 0, 2;

    if( @_ % 2 == 0 ) {
        return $self -> $method( @_ );
    }

    my $doc = shift @_;

    if( blessed $doc ) {
        if( $doc -> isa('XML::LibXML::Document') ) {
            return $self -> $method( document => $doc );
        }
        elsif( $doc -> isa('RDF::Server::XMLDoc') ) {
            return $doc;
        }
    }
    else {
        return $self -> $method( xml => $doc );
    }
};

no Moose;

1;

__END__
