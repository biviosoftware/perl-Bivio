# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::ReplyCode;
use strict;
$Bivio::Agent::ReplyCode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::ReplyCode - reply codes enum

=head1 SYNOPSIS

    use Bivio::Agent::ReplyCode;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Agent::ReplyCode::ISA = qw(Bivio::Type::Enum);

=head1 DESCRIPTION

C<Bivio::Agent::ReplyCode> defines the following reply codes:

=over 4

=item OK

success: operation was successful

=item FORBIDDEN

not authorized: user not authorized to process request

=item NOT_HANDLED

not found: unable to process request

=item AUTH_REQUIRED

need authentication: user must supply valid credentials

=item SERVER_ERROR

server error: internal failure

=item UNKNOWN

unknown error: unexpected or unknown error

=back

=cut

__PACKAGE__->compile({
    'OK' => [
    	0,
	'success',
	'operation was successful',
    ],
    'FORBIDDEN' => [
    	1,
	'not authorized',
	'user not authorized to process request',
    ],
    'NOT_HANDLED' => [
    	2,
	'not found',
	'unable to process request',
    ],
    'AUTH_REQUIRED' => [
    	3,
	'need authentication',
	'user must supply valid credentials',
    ],
    'SERVER_ERROR' => [
    	4,
	'server error',
	'internal failure',
    ],
    'UNKNOWN' => [
    	5,
	'unknown error',
	'unexpected or unknown error',
    ],
});

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
