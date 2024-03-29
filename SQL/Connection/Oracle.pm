# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::Connection::Oracle;
use strict;
=head1 NAME

Bivio::SQL::Connection::Oracle - connection to an oracle database

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::SQL::Connection::Oracle;

=cut

=head1 EXTENDS

L<Bivio::SQL::Connection>

=cut

use Bivio::SQL::Connection;
@Bivio::SQL::Connection::Oracle::ISA = ('Bivio::SQL::Connection');

=head1 DESCRIPTION

C<Bivio::SQL::Connection::Oracle>

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Trace;
use Bivio::TypeError;
# See reference to ORA_BLOB below
# use DBD::Oracle qw(:ora_types);

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_ERR_TO_DIE) = {
    # ORA-00060: deadlock detected
    60 => {
        code => Bivio::DieCode->UPDATE_COLLISION,
    },
    # ORA-12154: TNS:could not resolve service name
    12154 => {
        code => Bivio::DieCode->CONFIG_ERROR,
        message => 'Invalid database configuration. Oracle not configured?',
        program_error => 1,
    },
};

#
# We need to retry connections in the event of certain failures.  These
# are outlined in:
# http://www.oracle.com/nt/clusters/failsafe/html/fs_30_cawp.html
#
# We have seen ORA-03113 as the result of a oracle slave crash.
# See:
# http://www.oracle.com/support/bulletins/net/net2/html/1523.html
#
# Always sleep between oracle errors and retries.  We saw ORA-00020 at
# one point on the test system when we were having a spate of 3113
# errors.  This led to defunct processes.
#
# Key=ora-#, value=sleep_seconds
my($_ERR_RETRY_SLEEP) = {
    # ORA-01012: not logged on to Oracle
    1012 => 2,
    # ORA-01033: Oracle initialization or shutdown in progress
    1033 => 15,
    # ORA-01034: ORACLE not available
    1034 => 5,
    # ORA-01089: immediate shutdown in progress - no operations are permitted
    1089 => 5,
    # ORA-03113: end-of-file on communication channel
    3113 => 2,
    # ORA-03114: not connected to ORACLE
    3114 => 2,
    # ORA-12203: TNS: unable to connect to destination
    12203 => 5,
    # ORA-12500: TNS: listener failed to start a dedicated server process
    12500 => 5,
    # ORA-12537: TNS connection closed
    12537 => 5,
    # ORA-12571: TNS: packet writer failure
    12571 => 2,
};

=head1 METHODS

=cut

=for html <a name="get_dbi_prefix"></a>

=head2 get_dbi_prefix(hash_ref cfg) : string

Returns the Oracle DBI connection prefix.

=cut

sub get_dbi_prefix {
    return 'dbi:Oracle:';
}

=for html <a name="internal_dbi_connect"></a>

=head2 static internal_dbi_connect(string dbi_name) : Bivio::Ext::DBI

Adds Oracle parameters to dbh.

=cut

sub internal_dbi_connect {
    my($dbh) = shift->SUPER::internal_dbi_connect(@_);
    # In later DBD::Oracle versions, this parameter is set here, not on
    # the $statement
    $dbh->{LongReadLen} = __PACKAGE__->MAX_BLOB;
    $dbh->{LongTruncOk} = 0;
    return $dbh;
}

=for html <a name="internal_fixup_sql"></a>

=head2 internal_fixup_sql(string sql) : string

Fixes up definition to match Oracle ddl.

=cut

sub internal_fixup_sql {
    my($self, $sql) = @_;
    $sql = $self->SUPER::internal_fixup_sql($sql);
    $sql =~ s/\bTEXT64K\b/CLOB/igs;
    $sql =~ s/\bSTRPOS\(/INSTR\(/igs;
    # remove work-around for Postgres bug, Oracle doesn't allow CACHE of 1
    $sql =~ s/\bCACHE 1 (INCREMENT BY)\b/$1/igs;
    return $sql;
}

=for html <a name="internal_get_blob_type"></a>

=head2 internal_get_blob_type() : hash_ref

Returns the bind_param() value for a BLOB.

=cut

sub internal_get_blob_type {
    # DBD::Oracle::ORA_BLOB is 113.  Saves importing DBD::Oracle explicitly.
    return {ora_type => 113};
}

=for html <a name="internal_get_error_code"></a>

=head2 internal_get_error_code(string die_attrs) : Bivio::Type::Enum

Converts the database error message into an appropriate error code. Returns
undef if the message is not translatable.

=cut

sub internal_get_error_code {
    my($self, $die_attrs) = @_;
    if ($die_attrs->{dbi_errstr} =~ /constraint \((\w+)\.(\w+)\) violated/i) {
        return _interpret_constraint_violation($self,
                $die_attrs, uc($1), uc($2));
    }
    my($err) = $die_attrs->{dbi_err};
    # If we don't have a die_code, map it simply
    unless ($err) {
#TODO: This maybe should get moved up top.  I didn't want to change too much
#      now, since we don't know what types of errors Oracle reports.
        # Some errors have to be parsed out.
        ($err) = $die_attrs->{message} =~ /ORA-0*(\d+):/;
        $err ||= 0;
    }
    if (defined($_ERR_TO_DIE->{$err})) {
        # These may be program manageable errors;  See my($_ERR_TO_DIE).
        my($map) = $_ERR_TO_DIE->{$err};
        foreach my $attr (keys(%$map)) {
            $die_attrs->{$attr} = $map->{$attr};
        }
        my($result) = $die_attrs->{code};
        delete($die_attrs->{code});
        return $result;
    }
    return shift->SUPER::internal_get_error_code(@_);
}

=for html <a name="internal_get_retry_sleep"></a>

=head2 internal_get_retry_sleep(int error, string message) : int

Returns the number of seconds to sleep for the specified transient
error code. 0 indicates retry immediately, undef indicates don't
retury.

=cut

sub internal_get_retry_sleep {
    my($self, $error, $message) = @_;
    return $_ERR_RETRY_SLEEP->{$error};
}

=for html <a name="next_primary_id"></a>

=head2 next_primary_id(string table_name, ref die) : string

Returns the next primary id sequence number for the specified table.

=cut

sub next_primary_id {
    my($self, $table_name, $die) = @_;
    my($sql) = 'select '.substr($table_name, 0, -2).'_s.nextval from dual';
    return $self->execute($sql, [], $die)->fetchrow_array;
}

#=PRIVATE METHODS

# _interpret_constraint_violation(self, hash_ref attrs, string owner, string constraint) : Bivio::Type::Enum
#
# Will set "columns" and "table" in attrs.  Returns die code that is
# appropriate for the constraint violation.
#
sub _interpret_constraint_violation {
    my($self, $attrs, $owner, $constraint) = @_;
    my($die_code);

    # Ignore errors, die_code will be undef in this case and result in a
    # server error
    Bivio::Die->eval(sub {
        my($statement) = $self->internal_get_dbi_connection()->prepare(<<"EOF");
            SELECT all_cons_columns.table_name,
                    all_cons_columns.column_name
            FROM all_cons_columns
            WHERE all_cons_columns.owner = ?
            AND all_cons_columns.constraint_name = ?
            UNION
            SELECT all_ind_columns.table_name,
                    all_ind_columns.column_name
            FROM all_ind_columns
            WHERE all_ind_columns.index_owner = ?
            AND all_ind_columns.index_name = ?
EOF
        $statement->execute($owner, $constraint, $owner, $constraint);

        my($cols) = [];
        my($table);
        while (my $row = $statement->fetchrow_arrayref) {
# TODO: table must always be the same(?)
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
            _trace($owner, '.', $constraint, ': found ', $table, '.', $cols)
                    if $_TRACE;
            if (1 == $attrs->{dbi_err}) {
                # unique constraint violated (ORA-00001)
                $attrs->{type_error} = Bivio::TypeError->EXISTS;
                $die_code = Bivio::DieCode->DB_CONSTRAINT;
            }
            elsif (2290 == $attrs->{dbi_err}) {
                # check constraint violated (ORA-02290)
                # We understand only one type of check constraint:
                # max_* exceeded.  This will back all the way to
                # the Task level and it will map to a different
                # task.
                if (int(@$cols) == 2 && grep(/max_/, @$cols)) {
                    $die_code = Bivio::DieCode->NO_RESOURCES;
                }
            }
            elsif (2292 == $attrs->{dbi_err}) {
                # integrity constraint violated (ORA-02292)
                # child record not found
                if (int(@$cols) == 2 && grep(/max_/, @$cols)) {
                    $die_code = Bivio::DieCode->NO_RESOURCES;
                }
            }
        }
        else {
            # returns undef for die_code
            _trace($owner, '.', $constraint,
                    ': constraint query returned nothing') if $_TRACE;
        }
        1;
    });

    _trace($owner, '.', $constraint, ':', $@) if $_TRACE && $@;
    return $die_code;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
