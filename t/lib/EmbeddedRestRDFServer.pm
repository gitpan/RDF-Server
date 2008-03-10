package EmbeddedRestRDFServer;

use RDF::Server;

protocol 'Embedded';
interface 'REST';
semantic 'RDF';

render 'xml' => 'RDF';
render 'atom' => 'Atom';
render 'json' => 'JSON';

1;

__END__
