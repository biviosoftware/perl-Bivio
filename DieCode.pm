# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::DieCode;
use strict;
$Bivio::DieCode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::DieCode::VERSION;

=head1 NAME

Bivio::DieCode - generic error codes

=head1 RELEASE SCOPE

bOP

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
where appropriate.

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

=item CATCH_WITHIN_DIE: program_error

catch called within die: Bivio::Die::catch was called within a call to die

=item INVALID_DIE_CODE: code, attrs, program_error

invalid die code: code passed to Bivio::Die->throw is not an Bivio::Type::Enum.
I<code> is the invalid code and I<attrs> are the original attributes.

=item DIE: message, program_error

internal error: CORE::die was caught by Bivio::Die->catch

=item DIE_WITHIN_HANDLE_DIE: message, proto, program_error

die within handle_die: CORE::die was called while handling an existing die
I<proto> is either the instance or class passed to C<handle_die>.

=item MISSING_COOKIES: client_addr

browser did not return all necessary cookies

=item VERSION_MISMATCH: entity, class

version mismatch: user request using invalid or old form, query, or uri.
This might be due to an old link, corrupted user input, or an error
on the server.

=item CORRUPT_QUERY: entity, class

corrupt query: user request contains invalid query value.  This is
not the same as invalid input.  The query has been corrupted.  It
might be due to an error on the server.

=item SERVER_REDIRECT_TASK: task_id

server redirect task: direct dispatcher to switch to the specified task.
Transactions, messages, etc. SHOULD NOT be rolled back.

=item CORRUPT_FORM: message, entity, class

corrupt form: user request contains invalid form value.  This is
not the same as invalid input.  The form has been corrupted.  It
might be due to an error on the server.

=item CLIENT_REDIRECT_TASK: task_id

redirects the user agent to the specified task. As with server redirects,
transactions, messages, etc. SHOULD NOT be rolled back.

=item TOO_MANY: model

Too many records were returned.

=item NO_RESOURCES: model

Insufficient resources to satisfy your request.

=item IO_ERROR: entity, message

file system error

=item CLIENT_ERROR: request

error reading or writing to the client.

=item UPDATE_COLLISION: entity, class

two or more people are trying to update your records simultaneously

=item DB_ERROR: entity, class, error

unexpected error while communicating with database

=item MAIL_LOOP: entity, class, error

avoid a mail loop by not forwarding a message a second time

=item UNEXPECTED_EOF

unexpected end of file

=item CONFIG_ERROR: entity, class

missing or bad configuration

=item DB_CONSTRAINT : type_error, table, columns

unexpected database constraint violation

=back

=cut

#=IMPORTS
# Don't import, because would be circular reference.
# use Bivio::Die;

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [
	#
   	0,
	undef,
	'unexpected error',
    ],
    NOT_FOUND => [
	# entity, class
    	1,
	undef,
	'entity was not found',
    ],
    ALREADY_EXISTS => [
	# entity, class
    	2,
	undef,
	'attempt to create an entity which already exists',
    ],
    FORBIDDEN => [
	# operation, user, entity
    	3,
	undef,
	'operation is not allowed on entity',
    ],
    CATCH_WITHIN_DIE => [
	# program_error
    	4,
	undef,
	'Bivio::Die::catch was called within a call to die',
    ],
    INVALID_DIE_CODE => [
	# code, attrs, program_error
    	5,
        undef,
	'code passed to Bivio::Die->throw is not an Bivio::Type::Enum',
    ],
    DIE => [
	# message, program_error
    	6,
	'internal error',
	'CORE::die was caught by Bivio::Die->catch',
    ],
    DIE_WITHIN_HANDLE_DIE => [
	# message, proto, program_error
    	7,
	undef,
	'CORE::die was called while handling an existing die',
    ],
    MISSING_COOKIES => [
	# client_addr
	8,
	undef,
	'browser did not return all necessary cookies',
    ],
    VERSION_MISMATCH => [
	# entity, class
    	9,
	undef,
	'user request using invalid or old form, query, or uri',
    ],
    CORRUPT_QUERY => [
	# entity, class
    	10,
	undef,
	'user request contains invalid query value',
    ],
    SERVER_REDIRECT_TASK => [
	# task_id
	11,
	undef,
	'direct dispatcher to switch to new task',
    ],
    CORRUPT_FORM => [
	# message, entity, class
    	12,
	undef,
	'user request contains invalid form',
    ],
    CLIENT_REDIRECT_TASK => [
	# task_id
	13,
	undef,
	'direct user agent to new task',
    ],
    TOO_MANY => [
	# model
	14,
	undef,
	'the request returned too much data or too many records',
    ],
    NO_RESOURCES => [
	# model
	15,
	undef,
	'insufficient resources to satisfy the request',
    ],
    IO_ERROR => [
	# entity, message
	16,
	undef,
	'file system error',
    ],
    CLIENT_ERROR => [
	# request
	17,
	undef,
	'error reading or writing to the client',
    ],
    UPDATE_COLLISION => [
	# entity, class
	18,
	undef,
	'two or more people are trying to update your records simultaneously',
    ],
    DB_ERROR => [
	# entity, class, error
	19,
	undef,
	'unexpected error while communicating with database',
    ],
    MAIL_LOOP => [
	# entity, class, error
	20,
	undef,
	'avoid a mail loop',
    ],
    UNEXPECTED_EOF => [
	#
	21,
	undef,
	'unexpected end of file',
    ],
    CONFIG_ERROR => [
	# entity, class
	22,
	undef,
	'missing or incorrect configuration.  Please check your bconf file.',
    ],
    DB_CONSTRAINT => [
	# type_error, table, columns
	23,
	undef,
	'unexpected database constraint violation',
    ],
]);

=head1 METHODS

=cut

=for html <a name="throw_die"></a>

=head2 die(hash_ref attrs)

=head2 die(scalar message)

Dies in caller with this die code.

=cut

sub throw_die {
    my($self, $attrs) = @_;
    $attrs = {message => $attrs} unless ref($attrs) eq 'HASH';
    Bivio::Die->throw($self, $attrs, caller);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
