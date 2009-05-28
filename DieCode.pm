# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::DieCode;
use strict;
use base 'Bivio::Type::Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    UNKNOWN => [
   	0,
	undef,
	'unexpected error',
    ],
    NOT_FOUND => [
    	1,
	undef,
	'entity was not found',
    ],
    ALREADY_EXISTS => [
    	2,
	undef,
	'attempt to create an entity which already exists',
    ],
    FORBIDDEN => [
    	3,
	undef,
	'operation is not allowed on entity',
    ],
    CATCH_WITHIN_DIE => [
    	4,
	undef,
	'internal program error (4)',
    ],
    INVALID_DIE_CODE => [
    	5,
        undef,
	'internal program error (5)',
    ],
    DIE => [
    	6,
	'internal program error (6)',
    ],
    DIE_WITHIN_HANDLE_DIE => [
    	7,
	undef,
	'internal program error (7)',
    ],
    MISSING_COOKIES => [
	8,
	undef,
	'browser did not return all necessary cookies',
    ],
    VERSION_MISMATCH => [
    	9,
	undef,
	'user request using invalid or old form, query, or uri',
    ],
    CORRUPT_QUERY => [
    	10,
	undef,
	'user request contains invalid query value',
    ],
    SERVER_REDIRECT_TASK => [
	11,
	undef,
	'direct dispatcher to switch to new task',
    ],
    CORRUPT_FORM => [
    	12,
	undef,
	'user request contains invalid form',
    ],
    CLIENT_REDIRECT_TASK => [
	13,
	undef,
	'direct user agent to new task',
    ],
    TOO_MANY => [
	14,
	undef,
	'the request returned too much data or too many records',
    ],
    NO_RESOURCES => [
	15,
	undef,
	'insufficient resources to satisfy the request',
    ],
    IO_ERROR => [
	16,
	undef,
	'file system error',
    ],
    CLIENT_ERROR => [
	17,
	undef,
	'error reading or writing to the client',
    ],
    UPDATE_COLLISION => [
	18,
	undef,
	'two or more people are trying to update your records simultaneously',
    ],
    DB_ERROR => [
	19,
	undef,
	'unexpected error while communicating with database',
    ],
    MAIL_LOOP => [
	20,
	undef,
	'avoid a mail loop',
    ],
    UNEXPECTED_EOF => [
	21,
	undef,
	'unexpected end of file',
    ],
    CONFIG_ERROR => [
	22,
	undef,
	'missing or incorrect configuration.  Please check your bconf file.',
    ],
    DB_CONSTRAINT => [
	23,
	undef,
	'unexpected database constraint violation',
    ],
    MODEL_NOT_FOUND => [
    	24,
	undef,
	'model was not found',
    ],
    INVALID_OP => [
    	25,
	undef,
	'invalid operation',
    ],
    INPUT_TOO_LARGE => [
    	26,
	undef,
	'input too large',
    ],
]);

sub throw_die {
    # (self, hash_ref) : undef
    # (self, scalar) : undef
    # Dies in caller with this die code.
    my($self, $attrs) = @_;
    Bivio::Die->throw($self,
	ref($attrs) eq 'HASH' ? $attrs : {message => $attrs},
	caller);
}

1;
