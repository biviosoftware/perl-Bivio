# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Type;
use strict;
$Bivio::Agent::Type::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Type - enum kinds of agents

=head1 SYNOPSIS

    use Bivio::Agent::Type;
    Bivio::Agent::Type->HTTP;
    Bivio::Agent::Type->MAIL;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Agent::Type::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Agent::Type> defines the following agents:

=over 4

=item MAIL

=item HTTP

=back

=cut

#=IMPORTS

#=VARIABLES

__PACKAGE__->compile({
    'HTTP' => [
    	0,
    ],
    'MAIL' => [
    	1,
    ],
});


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
