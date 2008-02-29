package RDF::Server::Protocol;

use Moose::Role;

1;

__END__

=pod

=head1 NAME

RDF::Server::Protocol - defines how RDF::Server communicates with the world

=head1 SYNOPSIS

 package My::Protocol;

 use Moose::Role;
 with 'RDF::Server::Protocol';

=head1 DESCRIPTION

A protocol module translates between the world and the interface module,
creating and using HTTP::Request and HTTP::Response objects as needed.

=head1 REQUIRED METHODS

No methods are required by this role.

=head1 SEE ALSO

L<RDF::Server::Protocol::HTTP>

=head1 AUTHOR

James Smith, C<< <jsmith@cpan.org> >>

=head1 LICENSE

Copyright (c) 2008  Texas A&M University.

This library is free software.  You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
