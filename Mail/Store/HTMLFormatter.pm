# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Store::HTMLFormatter;
use strict;
$Bivio::Mail::Store::HTMLFormatter::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Store::HTMLFormatter - formats HTML mail for storage.

=head1 SYNOPSIS

    use Bivio::Mail::Store::HTMLFormatter;
    Bivio::Mail::Store::HTMLFormatter->new();

=cut

=head1 EXTENDS

L<Bivio::Mail::Store::Formatter>

=cut

use Bivio::Mail::Store::Formatter;
@Bivio::Mail::Store::HTMLFormatter::ISA = ('Bivio::Mail::Store::Formatter');

=head1 DESCRIPTION

C<Bivio::Mail::Store::HTMLFormatter>

HTMLFormatter formats HTML mail for storage into the file server.
This is essentially a placeholder for future parsing of HTML...

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="format_item"></a>

=head2 format_item() : 



=cut

sub format_item {
    my($proto, $body) = @_;
    _trace('body: ', $body) if $_TRACE;
    my($io) = $body->open('r');
    return format_mail($io);
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
