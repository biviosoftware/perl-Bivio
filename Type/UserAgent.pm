# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::UserAgent;
use strict;
$Bivio::Type::UserAgent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::UserAgent - defines type of the user agent for a request

=head1 SYNOPSIS

    use Bivio::Type::UserAgent;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::UserAgent::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::UserAgent> defines the type of user agent requesting
information.

=head1 VALUES

=over 4

=item UNKNOWN

Could not determine user agent.

=item BROWSER

Netscape, IE, etc.

=item MAIL

Mail transfer agent

=item JOB

Background job

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    UNKNOWN => [0],
    BROWSER => [1],
    MAIL => [2],
    JOB => [3],
);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
