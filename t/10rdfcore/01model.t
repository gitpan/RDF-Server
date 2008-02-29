BEGIN {
    use Test::More;

    eval "use RDF::Core::Model";
    plan skip_all => 'RDF::Core required' if $@;

    plan tests => 17;

    use_ok('RDF::Server::Model::RDFCore');
}

my $model;

eval {
    $model = RDF::Server::Model::RDFCore -> new(
        namespace => 'http://example.com/ns/'
    );
};

is( $@, '', 'Model object created');

is( $model -> namespace, 'http://example.com/ns/', 'namespace set' );

isa_ok( $model -> store, 'RDF::Core::Model' );

###
# _make_resource
###

my $r = $model -> _make_resource( 'http://example.com/ns/foo' );

isa_ok( $r, 'RDF::Core::Resource' );



$r = $model -> _make_resource( [ $model -> namespace, 'foo' ] );

isa_ok( $r, 'RDF::Core::Resource' );


###
# load model with some stuff
###

use RDF::Core::Parser;
use RDF::Server::Constants qw( :ns );

my $parser = RDF::Core::Parser -> new(
    Assert => sub {
        my $stmt = RDF::Server::Resource::RDFCore -> _triple(@_);
        $model -> store -> addStmt( $stmt );
    },
    BaseURI => $model -> namespace
);

$parser -> parse(<<eoRDF);
<?xml version="1.0" ?>
<rdf:RDF xmlns:rdf="@{[ RDF_NS ]}"
         xmlns:x="http://example.com/ns/"
>
  <rdf:Description rdf:about="http://example.com/ns/foo">
    <x:title>Foo's Title</x:title>
  </rdf:Description>

  <rdf:Description rdf:about="http://example.com/ns/bar">
    <x:title>Bar's Title</x:title>
  </rdf:Description>
</rdf:RDF>
eoRDF

###
# has_triple
###

ok( $model -> has_triple( 
       [ $model -> namespace, 'foo' ],
       [ $model -> namespace, 'title' ],
       "Foo's Title"
    )
);

###
# resource_exists
###

ok(  $model -> resource_exists( $model -> namespace, 'foo' ) );
ok(  $model -> resource_exists( $model -> namespace, 'bar' ) );
ok( !$model -> resource_exists( $model -> namespace, 'baz' ) );
ok( !$model -> resource_exists( $model -> namespace, 'title' ) );

###
# resource
###

isa_ok( $model -> resource( $model -> namespace, 'foo' ), 'RDF::Server::Resource::RDFCore' );

###
# resources
###

my $iter = $model -> resources;

# should be a list of Resources
use Iterator::Simple qw( list is_iterator );

ok( is_iterator($iter), 'resources returns an iterator' );

my @resources = @{ list $iter };
is( scalar(@resources), 2, 'Two resources' );

isa_ok( $resources[0], 'RDF::Server::Resource::RDFCore' );
isa_ok( $resources[1], 'RDF::Server::Resource::RDFCore' );

my $ids = join ':::', sort map { $_ -> id } @resources;

is( $ids, 'bar:::foo', 'Resource ids are right' );
