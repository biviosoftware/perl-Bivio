# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Connection::Postgres;
use strict;
$Bivio::SQL::Connection::Postgres::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::SQL::Connection::Postgres::VERSION;

=head1 NAME

Bivio::SQL::Connection::Postgres - connection to a PostgreSQL database

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::SQL::Connection::Postgres;

=cut

=head1 EXTENDS

L<Bivio::SQL::Connection>

=cut

use Bivio::SQL::Connection;
@Bivio::SQL::Connection::Postgres::ISA = ('Bivio::SQL::Connection');

=head1 DESCRIPTION

C<Bivio::SQL::Connection::Postgres>

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Trace;
use Bivio::TypeError;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_dbi_prefix"></a>

=head2 static get_dbi_prefix(hash_ref cfg) : string

Returns the PostgreSQL DBI connection prefix.

=cut

sub get_dbi_prefix {
#TODO: add host & port to prefix using cfg
    return 'dbi:Pg:dbname=';
}

=for html <a name="internal_fixup_sql"></a>

=head2 internal_fixup_sql(string sql) : string

Fixes the Oracle SQL to conform to Postgres's requirements.

=cut

sub internal_fixup_sql {
    my($self, $sql) = @_;

    # Julian date format is 'J SSSS'
    $sql =~ s/(J SSSS)S/$1/ig;

    # Timestamp instead of date
    $sql =~ s/(\W)DATE(\W)/$1TIMESTAMP$2/ig;
    $sql =~ s/TO_DATE\(/TO_TIMESTAMP\(/ig;

    # No 'by' on sequence increments
    $sql =~ s/( INCREMENT )BY /$1/ig;
    return $sql;
}

=for html <a name="internal_get_error_code"></a>

=head2 internal_get_error_code(string die_attrs) : Bivio::Type::Enum

Converts the database error message into an appropriate error code. Returns
undef if the message is not translatable.

=cut

sub internal_get_error_code {
    my($self, $die_attrs) = @_;

    # Constraint violation?
    if ($die_attrs->{dbi_errstr} =~
	    /Cannot insert a duplicate key into unique index (\w+)/i) {
	return _interpret_constraint_violation($self, $die_attrs, $1);
    }
    return $self->SUPER::internal_get_error_code($die_attrs);
}

=for html <a name="internal_get_retry_sleep"></a>

=head2 internal_get_retry_sleep(int error, string message) : int

Returns the number of seconds to sleep for the specified transient
error code. 0 indicates retry immediately, undef indicates don't
retry.

=cut

sub internal_get_retry_sleep {
    my($self, $error, $message) = @_;
    # retry in 15 seconds if database is gone. may have rebooted database
    return 15 if $error == -1 && $message =~ /backend closed the channel/;
    return undef;
}

=for html <a name="next_primary_id"></a>

=head2 next_primary_id(string table_name, ref die) : string

Returns the next primary id sequence number for the specified table.

=cut

sub next_primary_id {
    my($self, $table_name, $die) = @_;

    my($sql) = "select nextval('".substr($table_name, 0, -2)."_s')";
    return $self->execute($sql, [], $die)->fetchrow_array;
}

#=PRIVATE METHODS

# _interpret_constraint_violation(self, hash_ref attrs, string constraint) : Bivio::Type::Enum
#
# Will set "columns" and "table" in attrs.  Returns die code that is
# appropriate for the constraint violation.
#
sub _interpret_constraint_violation {
    my($self, $attrs, $constraint) = @_;
    my($die_code);

    # Ignore errors, die_code will be undef in this case and result in a
    # server error
    Bivio::Die->eval(sub {

	# rollback because Postgres won't let other queries on this txn
	$self->rollback;

	# Try to find the constraint columns (assumes it is an index)
	my($statement) = $self->internal_get_dbi_connection()
		->prepare(<<"EOF");
            SELECT class2.relname, attname
            FROM pg_class class1, pg_class class2, pg_index, pg_attribute
            WHERE class1.relfilenode=pg_attribute.attrelid
            AND class1.relfilenode=pg_index.indexrelid
            AND pg_index.indrelid=class2.relfilenode
            AND class1.relname=?
EOF
	$statement->execute($constraint);

	my($cols) = [];
	my($table);
	while (my $row = $statement->fetchrow_arrayref) {
	    $table = lc($row->[0]);
	    push(@$cols, lc($row->[1]));
	}

	# This is an operation error, not db error.  Don't need to ping.
	$self->internal_clear_ping;

	# Found the constraint?
	if ($table) {
	    # Save the state for the die message
	    $attrs->{columns} = $cols, $attrs->{table} = $table;
	    _trace($constraint, ': found ', $table, '.', $cols)
		    if $_TRACE;
	    if (7 == $attrs->{dbi_err}) {
		# duplicate key
		$attrs->{type_error} = Bivio::TypeError->EXISTS;
		$die_code = Bivio::DieCode->DB_CONSTRAINT;
	    }
	}
	else {
	    # returns undef for die_code
	    _trace($constraint,
		    ': constraint query returned nothing') if $_TRACE;
	}
	return 1;
    });

    _trace($constraint, ':', $@) if $_TRACE && $@;
    return $die_code;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
