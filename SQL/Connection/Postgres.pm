# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Connection::Postgres;
use strict;
use Bivio::Base 'Bivio::SQL::Connection';
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Trace;
use Bivio::TypeError;
use DBI ();

# C<Bivio::SQL::Connection::Postgres>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);

sub CAN_LIMIT_AND_OFFSET {
    # : boolean
    # Postgres supports C<LIMIT> and C<OFFSET>.
    return 1;
}

sub REQUIRE_COMMIT_OR_ROLLBACK {
    # : boolean
    # Returns true.
    return 1;
}

sub get_dbi_prefix {
    # (proto, hash_ref) : string
    # Returns the PostgreSQL DBI connection prefix.
#TODO: add host & port to prefix using cfg
    return 'dbi:Pg:dbname=';
}

sub internal_execute {
    # (self) : undef
    # Ignores annoying warnings.
    my($prev) = $SIG{__WARN__};
    local($SIG{__WARN__}) = sub {
	my($msg) = @_;
	return
	    if $msg =~ /NOTICE:\s+CREATE TABLE . PRIMARY KEY will create implicit index/;
	return $prev && $prev->(@_);
    };
    return shift->SUPER::internal_execute(@_);
}

sub internal_fixup_sql {
    # (self, string) : string
    # Fixes the Oracle SQL to conform to Postgres's requirements.
    my($self, $sql) = @_;
    $sql = $self->SUPER::internal_fixup_sql($sql);

    # Julian date format is 'J SSSS'
    $sql =~ s/('J SSSS)S'/$1'/igs;

    # Timestamp instead of date
    $sql =~ s/\bDATE\b/TIMESTAMP/igs;
    $sql =~ s/\bTO_DATE\(/TO_TIMESTAMP\(/igs;

    # No 'by' on sequence increments
    $sql =~ s/(\sINCREMENT\s+)BY\b/$1/igs;

    # blobs
    $sql =~ s/\bBLOB\b/BYTEA/igs;

    $sql =~ s/\bTEXT64K\b/TEXT/igs;

    $sql = _fixup_outer_join($sql)
	if $sql =~ /\(\+\)/;
    _trace($sql) if $_TRACE;
    return $sql;
}

sub internal_get_blob_type {
    # (self) : hash_ref
    # Returns the bind_param() value for a BLOB.
    return DBI::SQL_BINARY();
}

sub internal_get_error_code {
    # (self, string) : Type.Enum
    # Converts the database error message into an appropriate error code. Returns
    # undef if the message is not translatable.
    my($self, $die_attrs) = @_;
    if ($die_attrs->{dbi_errstr} =~
	    /Cannot insert a duplicate key into unique index (\w+)/i
        # Relaxed since they seem to change it often
        || $die_attrs->{dbi_errstr} =~
            /duplicate key.*? unique .*?"(\w+)"/i) {
	return _interpret_constraint_violation($self, $die_attrs, $1);
    }
    $die_attrs->{dbi_errstr} =~
	s/(Unterminated quoted string)/$1; There is a null character in one of the parameters/;
    return shift->SUPER::internal_get_error_code(@_);
}

sub internal_get_retry_sleep {
    # (self, int, string) : int
    # Returns the number of seconds to sleep for the specified transient
    # error code. 0 indicates retry immediately, undef indicates don't
    # retry.
    my($self, $error, $message) = @_;
    # retry in 15 seconds if database is gone. may have rebooted database
    return 15 if $error == -1 && $message =~ /backend closed the channel/;
    return 1 if $error == -1
        && $message =~ /server closed the connection unexpectedly/;
    return undef;
}

sub next_primary_id {
    # (self, string, ref) : string
    # Returns the next primary id sequence number for the specified table.
    my($self, $table_name, $die) = @_;

    my($sql) = "select nextval('".substr($table_name, 0, -2)."_s')";
    return $self->execute($sql, [], $die)->fetchrow_array;
}

sub _fixup_outer_join {
    # (string) : string
    # Replaces Oracle style outer joins (+) with Postgres syntax LEFT JOIN.
    my($sql) = @_;

    # find the outer join expression, remove it from the WHERE clause
    # and add it to the FROM section with the LEFT JOIN . ON . syntax

    # example:
    #
    # select * from ec_payment_t, ec_subscription_t, realm_owner_t
    # where ec_payment_id.realm_id=realm_owner_t.realm_id
    # and ec_payment_t.ec_payment_id=ec_subscription_t.ec_payment_id(+)
    #
    # becomes:
    #
    # select * from ec_payment_t LEFT JOIN ec_subscription_t ON
    # ec_payment_t.ec_payment_id=ec_subscription_t.ec_payment_id, realm_owner_t
    # where ec_payment_id.realm_id=realm_owner_t.realm_id
    #
    # Another case is:
    #     SELECT (SELECT
    #         SUM(policy_t.state_tax)
    #             FROM policy_t, filing_event_t
    #             WHERE policy_t.broker_user_id=broker_t.user_id
    #         ) AS state_tax_due
    #     FROM tax_deposit_t,broker_t,user_t,broker_tax_payment_t
    #     WHERE broker_t.user_id=broker_tax_payment_t.broker_user_id(+)
    # becomes:
    #     SELECT (SELECT
    #         SUM(policy_t.state_tax)
    #             FROM policy_t, filing_event_t
    #             WHERE policy_t.broker_user_id=broker_t.user_id
    #         ) AS state_tax_due
    #     FROM tax_deposit_t,broker_t
    #         LEFT JOIN broker_tax_payment_t
    #	      ON (broker_t.user_id = broker_tax_payment_t.broker_user_id),
    #          user_t
    #     WHERE broker_t.user_id=broker_tax_payment_t.broker_user_id
    #
    my($relations) = [];
    my($prefix, $from_where)
	# This only handles two levels of parens in SELECTs with AS clauses
	= $sql =~ /^(
           (?:
              [^()]+
              | \([^()]+\)+
              | \((?:
                  [^()]+
                  |\([^()]+\)
                )+\)
           )+
        )(\sFROM\s.*)/six;
    Bivio::Die->die('could not find FROM in: ', $sql)
	unless $from_where;
    _trace('prefix=', $prefix, '; from_where=', $from_where) if $_TRACE;
    while ($from_where =~ /\(\+\)/) {
	$from_where =~ s/\b(FROM)(?:POSTGRES-FIXME)?\b(.+?)([\w\.]+)\s*\=\s*([\w\.]+)\(\+\)(?:\s+AND\b)?/FROMPOSTGRES-FIXME$2/is
	    || Bivio::Die->die('failed to find outer join: ', $from_where);
	push(@$relations, [$3, $4]);
    }
    return unless @$relations;
    Bivio::Die->die('too weird outer join: ', $from_where)
	if $from_where =~ /POSTGRES-FIXME.*POSTGRES-FIXME/s;
    _trace('from_where=', $from_where, '; relations=', $relations) if $_TRACE;
    my($joins) = {};
    foreach my $r (@$relations) {
	my($left, $right) = @$r;
	my($source_table) = lc(_parse_table_name($left));
	my($target_table) = lc(_parse_table_name($right));
	if ($joins->{$source_table}) {
	    # We already added the LEFT JOIN $target_table in $joins
	    next if $joins->{$source_table}
		=~ s/(?<=LEFT JOIN $target_table ON \()/$left = $right AND /is;
	}
	# Remove target_table from FROM, and save LEFT JOIN in $joins
	$from_where =~ s/(\sFROMPOSTGRES-FIXME\s.*?)\b((?:\w+\s+)?$target_table)\b,?/$1/s
	    || Bivio::Die->die('failed to remove ', $target_table, ': ', $from_where);
	$joins->{$source_table} .= " LEFT JOIN $2 ON ($left = $right)";
    }
    # Remove target table(s) from FROM and add $joins to FROM
    foreach my $source_table (sort(keys(%$joins))) {
	$from_where =~ s/(?=FROMPOSTGRES-FIXME)(.*?\b$source_table\b)(?=\s*,|\s+WHERE\b|\s+ON\b|\s+LEFT JOIN\b)/$1$joins->{$source_table}/is
	    || Bivio::Die->die('failed to insert outer join: ',
	        $source_table, ' "',
		$joins->{$source_table}, '" into ', $from_where);
    }
    # remove extra commas, trailing where, trailing and
    $from_where =~ s/\bFROMPOSTGRES-FIXME\b/FROM/sg;
    $from_where =~ s/,\s*(?=\sWHERE\s)//is;
    $from_where =~ s/\s+AND\s+OFFSET/ OFFSET/is;
    $from_where =~ s/\s+WHERE\s+OFFSET/ OFFSET/is;
    # Really should have an SQL lexicon...
    $from_where =~ s/\s(?:WHERE|AND)(?=\s*$|\s*\)|\s*(?:HAVING|GROUP|ORDER|UNION|INTERSECT)\b)//is;
    return $prefix . $from_where;
}

sub _interpret_constraint_violation {
    # (self, hash_ref, string) : Type.Enum
    # Will set "columns" and "table" in attrs.  Returns die code that is
    # appropriate for the constraint violation.
    my($self, $attrs, $constraint) = @_;
    my($die_code);
    # Ignore errors, die_code will be undef in this case and result in a
    # server error
    Bivio::Die->eval(sub {
        # rollback because Postgres won't let other queries on this txn
	$self->rollback;

	# Try to find the constraint columns (assumes it is an index)
	my($statement) = $self->internal_get_dbi_connection()->prepare(<<"EOF");
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
	    $attrs->{columns} = $cols;
            $attrs->{table} = $table;
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

sub _parse_table_name {
    # (string) : string
    # Parses the table name from a table_name.field string.
    my($str) = @_;

    $str =~ /^(\w+)\./
	|| Bivio::Die->die("didn't find table: ", $str);
    return $1;
}

1;
