# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::Connection;
use strict;
$Bivio::SQL::Connection::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::Connection - a database connection manager

=head1 SYNOPSIS

    use Bivio::SQL::Connection;
    Bivio::SQL::Connection->execute('update user_t set name=?', ['foo']);

=cut

use Bivio::UNIVERSAL;
@Bivio::SQL::Connection::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::SQL::Connection> is a collection of static methods used
to transact with the database. This module maintains one connection
to the database at all times.  It will reset the connection if the
database the connection is lost.

B<Bivio::Agent::Task depends on the fact that this the only module
which modifies the database.>

=cut


=head1 CONSTANTS

=cut

=for html <a name="MAX_BLOB"></a>

=head2 MAX_BLOB : int

Maximum length of a blob.  You cannot retrieve blobs larger than this.
You can only have one blob per record.

=cut

sub MAX_BLOB {
    return 0x400_000;
}

=for html <a name="MAX_PARAMETERS"></a>

=head2 MAX_PARAMETERS : int

Maximum number of '?' parameters on a single statement.

=cut

sub MAX_PARAMETERS {
    # This value is somewhat arbitrary, but we've tested this up to
    # 230.  The problem is it depends on the statement complexity...
    # Deleting 100 at a time seems like it gets the biggest impact.
    return 100;
}

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Ext::DBI;
use Bivio::IO::Trace;
use Bivio::Util;
use Bivio::TypeError;
use DBD::Oracle qw(:ora_types);
use Carp ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_CONNECTION);
# Set to the pid that creates the connection.  Ensures all children
# use a different connection.
my($_CONNECTION_PID) = 0;
# If there is an error, this will be true.  _get_connection checks the
# connection with a ping to make sure it is still alive.
my($_NEED_PING) = 0;
my($_NEED_COMMIT) = 0;
my($_DB_TIME) = 0;
my(%_ERR_TO_DIE_CODE) = (
# Why bother?
#	1400 => Bivio::DieCode::ALREADY_EXISTS,
#	die('required value missing') if $err == 1400;
#    die('invalid number') if $err == 1722;
);
# Allow for a bit larger space than maximum blob
my($_MAX_BLOB) = int(MAX_BLOB() * 1.1);


=head1 METHODS

=cut

=for html <a name="commit"></a>

=head2 commit()

Commits all open transactions.

=cut

sub commit {
    return unless $_NEED_COMMIT;
    &_trace('commit') if $_TRACE;
    _get_connection()->commit();
    $_NEED_COMMIT = 0;
    return;
}

=for html <a name="execute"></a>

=head2 execute(string sql)

=head2 execute(string sql, array_ref params)

=head2 execute(string sql, array_ref params, ref die)

=head2 execute(string sql, array_ref params, ref die, boolean has_blob)

Executes the specified statement and dies with an appropriate error
if it fails.

B<NOTE: All calls must go through this

I<die> must implement L<Bivio::Die::die|Bivio::Die/"die">.

I<has_blob> is specified, the arguments are scanned for a scalar_ref.
If found, the positional parameter is bound properly.  If no scalar_ref
is found, then the BLOB is assumed to be an output parameter and
I<LongReadLen> and I<LongTruncOk> are set accordingly.

=cut

sub execute {
    my($self, $sql, $params, $die, $has_blob) = @_;

    my($statement);
    Bivio::Die->eval(sub {
	_trace_sql($sql, $params) if $_TRACE;
	my($start_time) = Bivio::Util::gettimeofday();
#TODO: Need to investigate problems and performance of cached statements
#TODO: If do cache, then make sure not "active" when making call.
	$statement = _get_connection()->prepare($sql);
	# Only need a commit if there has been data modification language
	my($is_select) = $sql =~ /^\s*select/i;
	$_NEED_COMMIT = 1 unless $is_select;
	if ($has_blob) {
	    if ($is_select) {
		# Returns a value
		$statement->{LongReadLen} = $_MAX_BLOB;
		$statement->{LongTruncOk} = 0;
	    }
	    else {
		# Passing a value, possibly
		my($i) = 1;
		foreach my $p (@$params) {
		    $statement->bind_param($i++, $p), next unless ref($p);
		    # I wonder if it stores a reference or a copy?
		    $statement->bind_param($i++,  $$p, {ora_type => ORA_BLOB});
		}
		# Parameters are bound, so don't pass below
		$params = undef;
	    }
	}
	ref($params) ? $statement->execute(@$params)
		: $statement->execute();
#TODO: need to inc when a failure
	$self->increment_db_time($start_time);
    });
    return $statement unless $@;

    # If we get an error, it may be a timed-out connection.  We'll
    # check the connection the next time through.
    $_NEED_PING = 1;
    my($err) = $statement && $statement->err ? $statement->err + 0 : 0;
    my($errstr) = $statement && $statement->errstr ? $statement->errstr : '';
    my($attrs) = {
	message => $@,
	dbi_err => $err,
	dbi_errstr => $errstr,
	sql => $sql,
	sql_params => $params,
    };
    my($die_code);
    if ($errstr =~ /constraint \((\w+)\.(\w+)\) violated/i) {
	$die_code = _intrepret_constraint_violation($attrs, uc($1), uc($2));
    }
    Bivio::Die->eval(sub {
	# Clean up just in case statement is cached
	$statement->finish if $statement;
    });
#TODO: add more application error processing here
#TODO: Add reply processingn
    unless ($die_code) {
	if (defined($err) && defined($_ERR_TO_DIE_CODE{$err})) {
	    $die_code = $_ERR_TO_DIE_CODE{$err};
	}
	else {
	    $attrs->{program_error} = 1;
	    # Unexpected oracle error is treated as an assertion fault
	    $die_code = Bivio::DieCode::DIE();
	}
    }
    $die ||= 'Bivio::Die';
    $die->die($die_code, $attrs, caller);
}

=for html <a name="get_db_time"></a>

=head2 static get_db_time() : int

If tracing is enabled, this returns the amount of time spent processing
database requests. Invoking this method clears the counter.

=cut

sub get_db_time {
    my($result) = $_DB_TIME;
    $_DB_TIME = 0;
    return $result;
}

=for html <a name="increment_db_time"></a>

=head2 static increment_db_time(int start_time) : int

If tracing is enabled, this increments the database time counter and
returns its new value.

=cut

sub increment_db_time {
    my(undef, $start_time) = @_;
    Carp::croak('invalid start_time') unless $start_time;
    $_DB_TIME += Bivio::Util::time_delta_in_seconds($start_time);
    return $_DB_TIME;
}

=for html <a name="rollback"></a>

=head2 rollback()

Rolls back all open transactions.

=cut

sub rollback {
    return unless $_NEED_COMMIT;
    &_trace('rollback') if $_TRACE;
    _get_connection()->rollback();
    $_NEED_COMMIT = 0;
    return;
}

#=PRIVATE METHODS

# _intrepret_constraint_violation(hash_ref attrs, string owner, string constraint) : Bivio::Type::Enum
#
# Will set "columns" and "table" in attrs.  Returns die code that is
# appropriate for the constraint violation.
#
sub _intrepret_constraint_violation {
    my($attrs, $owner, $constraint) = @_;
    my($die_code);

    # Ignore errors, die_code will be undef in this case and result in a
    # server error
    Bivio::Die->eval(sub {

	# Try to find the constraint columns
	my($statement) = _get_connection()->prepare(<<"EOF");
	    SELECT user_cons_columns.table_name,
		    user_cons_columns.column_name
	    FROM user_cons_columns, user_constraints
	    WHERE user_constraints.constraint_name = ?
	    AND user_constraints.owner = ?
	    AND user_constraints.constraint_name
	    = user_cons_columns.constraint_name
EOF
	$statement->execute($constraint, $owner);
	my($row);
	my($cols) = [];
	my($table);
	while ($row = $statement->fetchrow_arrayref) {
# TODO: table must always be the same(?)
	    $table = lc($row->[0]);
	    push(@$cols, lc($row->[1]));
	}

	# This is an operation error, not db error.  Don't need to ping.
	$_NEED_PING = 0;

	# Found the constraint?
	if ($table) {
	    # Save the state for the die message
	    $attrs->{columns} = $cols, $attrs->{table} = $table;
	    _trace($owner, '.', $constraint, ': found ', $table, '.', $cols)
		    if $_TRACE;

	    if (1 == $attrs->{dbi_err}) {
		# unique constraint violated (ORA-00001)
		$die_code = Bivio::TypeError::EXISTS();
	    }
	    elsif (2290 == $attrs->{dbi_err}) {
		# check constraint violated (ORA-02290)
		# We understand only one type of check constraint:
		# max_* exceeded.  This will back all the way to
		# the Task level and it will map to a different
		# task.
		if (int(@$cols) == 2 && grep(/max_/, @$cols)) {
		    $die_code = Bivio::DieCode::NO_RESOURCES();
		}
	    }
	    elsif (2292 == $attrs->{dbi_err}) {
		# integrity constraint violated (ORA-02292)
		# child record not found
		if (int(@$cols) == 2 && grep(/max_/, @$cols)) {
		    $die_code = Bivio::DieCode::NO_RESOURCES();
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

# static _get_connection() : connection
#
# Returns a cached database connection for this process.  Checks the
# connection for validity.
#
sub _get_connection {
    if ($_CONNECTION_PID != $$) {
	if ($_CONNECTION) {
	    # This disconnects the parent process'.  Make sure we rollback
	    # any pending transactions.  By default, disconnect commits
	    Bivio::Die->eval(sub {
		$_CONNECTION->ping && $_CONNECTION->rollback});
	    Bivio::Die->eval(sub {$_CONNECTION->disconnect});
	    # Make sure we don't enter this code again.
	    $_CONNECTION = undef;
	}
	&_trace("creating connection: pid=$$") if $_TRACE;
	$_CONNECTION = Bivio::Ext::DBI->connect();
	# Got a connection which will be reused on next call.  We don't
	# need to ping it (just in case parent process had an error on
	# the connection).
	$_CONNECTION_PID = $$;
	$_NEED_PING = 0;
    }
    elsif ($_NEED_PING) {
	# Got an error on a previous use of this connection.  Make
	# sure is still valid.
	$_NEED_PING = 0;
	unless (Bivio::Die->eval(sub {$_CONNECTION->ping})) {
	    # Just in case, rollback any pending actions
	    # be executed.  Caller will reset $_CONNECTION
	    $_CONNECTION_PID = 0;
	    return _get_connection();
	}
	# Current connection is valid
    }
    return $_CONNECTION;
}

# _trace_sql(string sql, array_ref params)
#
# Traces the specified sql statement with parameters.
#
sub _trace_sql {
    my($sql, $params) = @_;
    my(@args);
    my($sep) = ' [';
    my($p);
    foreach $p (ref($params) ? @$params : ()) {
	push(@args, $sep, $p);
	$sep = ',';
    }
    @args && push(@args, ']');
    # Let trace deal with string truncation and undef
    &_trace($sql, @args);
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
