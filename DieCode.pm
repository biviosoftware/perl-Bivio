# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::DieCode;
use strict;
$Bivio::DieCode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::DieCode - generic error codes

=head1 SYNOPSIS

    use Bivio::DieCode;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::DieCode::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::DieCode> defines generic error codes to be passed to
L<Bivio::Die>.  Subsystems should define their own error codes
there appropriate.

Codes are defined as follows: name: attributes.  The attributes
may be passed to L<Bivio::Die::die|Bivio::Die/"die"> the I<attrs>
hash_ref.

=over 4

=item UNKNOWN

unknown: unexpected error

=item NOT_FOUND: entity, class

not found: entity was not found

=item ALREADY_EXISTS: entity, class

already exists: attempt to create an entity which already exists

=item FORBIDDEN: operation, user, entity

no permission: operation is not allowed on realm.

=item CATCH_WITHIN_DIE

catch called within die: Bivio::Die::catch was called within a call to die

=item INVALID_DIE_CODE: code, attrs

invalid die code: code passed to Bivio::Die->die is not an Bivio::Type::Enum.
I<code> is the invalid code and I<attrs> are the original attributes.

=item DIE: message

internal error: CORE::die was caught by Bivio::Die->catch

=item DIE_WITHIN_HANDLE_DIE: message, proto

die within handle_die: CORE::die was called while handling an existing die
I<proto> is either the instance or class passed to C<handle_die>.

=item AUTH_REQUIRED: operation, entity

authentication required: user must authenticate first before proceeding

=item VERSION_MISMATCH: entity, class

version mismatch: user request using invalid or old form, query, or uri.
This might be due to an old link, corrupted user input, or an error
on the server.

=item CORRUPT_QUERY: entity, class

corrupt query: user request contains invalid query value.  This is
not the same as invalid input.  The query has been corrupted.  It
might be due to an error on the server.

=item REDIRECT_TASK: task_id

redirect task: direct dispatcher to switch to the specified task.
Transactions, messages, etc. SHOULD NOT be rolled back.

=item CORRUPT_FORM: message, entity, class

corrupt form: user request contains invalid form value.  This is
not the same as invalid input.  The form has been corrupted.  It
might be due to an error on the server.

=item CLIENT_REDIRECT_TASK: task_id

redirects the user agent to the specified task. As with internal redirects,
transactions, messages, etc. SHOULD NOT be rolled back.

=back

=cut

#=IMPORTS
# Don't import, because would be circular reference.
# use Bivio::Die;

#=VARIABLES
__PACKAGE__->compile(
    UNKNOWN => [
    	0,
	'unknown',
	'unexpected error',
    ],
    NOT_FOUND => [
    	1,
	'not found',
	'entity was not found',
    ],
    ALREADY_EXISTS => [
    	2,
	'already exists',
	'attempt to create an entity which already exists',
    ],
    FORBIDDEN => [
    	3,
	'no permission',
	'operation is not allowed on entity',
    ],
    CATCH_WITHIN_DIE => [
    	4,
	'catch called within die',
	'Bivio::Die::catch was called within a call to die',
    ],
    INVALID_DIE_CODE => [
    	5,
	'invalid die code',
	'code passed to Bivio::Die->die is not an Bivio::Type::Enum',
    ],
    DIE => [
    	6,
	'internal error',
	'CORE::die was caught by Bivio::Die->catch',
    ],
    DIE_WITHIN_HANDLE_DIE => [
    	7,
	'die within handle_die',
	'CORE::die was called while handling an existing die',
    ],
    AUTH_REQUIRED => [
    	8,
	'authentication required',
	'user must authenticate first before proceeding',
    ],
    VERSION_MISMATCH => [
    	9,
	'version mismatch',
	'user request using invalid or old form, query, or uri',
    ],
    CORRUPT_QUERY => [
    	10,
	'corrupt query',
	'user request contains invalid query value',
    ],
    REDIRECT_TASK => [
	11,
	'redirect task',
	'direct dispatcher to switch to new task',
    ],
    CORRUPT_FORM => [
    	12,
	'corrupt form',
	'user request contains invalid form',
    ],
    CLIENT_REDIRECT_TASK => [
	13,
	'client redirect task',
	'direct user agent to new task',
    ],
);

=head1 METHODS

=cut

=for html <a name="die"></a>

=head2 die(hash_ref attrs)

=head2 die(scalar message)

Dies in caller with this die code.

=cut

sub die {
    my($self, $attrs) = @_;
    $attrs = {message => $attrs} unless ref($attrs) eq 'HASH';
    Bivio::Die->die($self, $attrs, caller);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
