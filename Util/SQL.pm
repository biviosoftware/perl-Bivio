# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Util::SQL;
use strict;
$Bivio::Util::SQL::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::SQL::VERSION;

=head1 NAME

Bivio::Util::SQL - execute SQL from the command line using configured db

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::SQL;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::SQL::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::SQL> executes SQL using the configured db.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns usage.

=cut

sub USAGE {
    return <<'EOF';
usage: b-sql [options] command [args...]
commands:
    create_db -- initializes database (must be run from ddl directory)
    destroy_db -- drops all the tables, indexes, and sequences created
    drop -- drops objects which would be created by running input
    drop_and_run -- calls drop then run
    export_db file -- exports database (only works for pg right now)
    import_db file -- imports database (ditto)
    reinitialize_sequences -- recreates to MAX(primary_id) (must be in ddl directory)
    run -- executes sql contained in input and dies on error
EOF
}

#=IMPORTS
use Bivio::SQL::Connection;
use Bivio::Type::Number;

#=VARIABLES
my($_REALM_ROLE_CONFIG);

=head1 METHODS

=cut

=for html <a name="create_db"></a>

=head2 create_db()

Initializes petshop database.  Must be un from from C<files/ddl> directory,
which contains C<*-tables.sql>, C<*-constraints.sql>, etc.

See L<destroy_db|"destroy_db"> to see how you'd undo this operation.

=cut

sub create_db {
    my($self) = @_;
    $self->setup;
    foreach my $file (@{_ddl_files($self)}){
	# Set up new file so read_input returns new value each time
	$self->print('Executing ', $file, "\n");
	$self->put(input => $file);
	$self->run;
    }
    Bivio::Biz::Model->new($self->get_request, 'RealmOwner')->init_db;
    $self->init_realm_role;
    return;
}

=for html <a name="ddl_files"></a>

=head2 static ddl_files(array_ref base_names) : array_ref

Returns list of SQL data files used by L<create_db|"create_db"> and
L<destroy_db|"destroy_db">.

Subclasses must overrided.  Call this method with a list of
I<base_names>, e.g. ['bOP'], and it will return a list of
constraints.

=cut

sub ddl_files {
    my(undef, $base_names) = @_;
    return [map {
	my($base) = $_;
	map {
	    $base.'-'.$_.'.sql';
	} qw(tables constraints sequences);
    } @$base_names];
}

=for html <a name="destroy_db"></a>

=head2 destroy_db()

Undoes the operations of L<create_db|"create_db">.

=cut

sub destroy_db {
    my($self) = @_;
    $self->get_request;
    $self->are_you_sure('DROP THE ENTIRE '
	. Bivio::SQL::Connection->get_dbi_config->{database}
	. ' DATABASE?');
    # We drop in opposite order.  Some constraint drops will
    # fail, but that's ok.  We need to drop the foreign key
    # constraints so we can drop the tables.
    foreach my $file (reverse(@{_ddl_files($self)})) {
	$self->print('Dropping ', $file, "\n");
	$self->put(input => $file);
	$self->drop;
    }
    return;
}

=for html <a name="drop"></a>

=head2 drop()

Reads I<input> and executes "drop I<object>" where I<object> may
be a table, index, sequence, etc.  The values are parsed from
I<input> which must be of the form:

   create table ....
   create [unique] index ...
   create sequence
   ALTER TABLE realm_role_t
      ADD CONSTRAINT realm_role_t1
      PRIMARY KEY(realm_id, role)

and so on.

Ignores "does not exist" errors.

=cut

sub drop {
    my($self) = @_;
    foreach my $s (_parse($self)) {
	next unless $s =~ /^(\s*)create(?:\s+unique)?\s+(\w+\s+\w+)\s+/is
		|| $s =~ /^\s*(alter\s+table\s*\w+\s*)add\s+(constraint\s+\w+)\s+/is;
	Bivio::Die->eval(sub {
#TODO: don't want to ignore all errors - ex. db doesn't exist
	    Bivio::SQL::Connection->execute($1.'drop '.$2);
	    return;
	});
	Bivio::SQL::Connection->commit;
    }
    return;
}

=for html <a name="drop_and_run"></a>

=head2 drop_and_run()

Executes L<drop|"drop"> and then L<run|"run"> with same input.

=cut

sub drop_and_run {
    my($self) = @_;
    $self->drop;
    return $self->run;
}

=for html <a name="export_db"></a>

=head2 export_db(string dir) : string

Dumps the current database to I<dir> (or '.') to a file of the form:

   <db>-<datetime>.pg_dump

=cut

sub export_db {
    my($self, $dir) = @_;
    $self->get_request;
    my($db) = Bivio::SQL::Connection->get_dbi_config;
    my($f) = ($dir || '.') . '/' . $db->{database} . '-'
	. Bivio::Type::DateTime->local_now_as_file_name . '.pg_dump';
    $self->piped_exec(
	"env PGUSER=$db->{user} pg_dump --clean --format=c --blobs "
	. " --file='$f' $db->{database}");
    return "Exported $db->{database} to $f\n";
}

=for html <a name="init_realm_role"></a>

=head2 init_realm_role()

Initializes the database with the values from
L<realm_role_config|"realm_role_config">.

=cut

sub init_realm_role {
    my($self) = @_;
    my($cmd);
    my($rr) = $self->new_other('Bivio::Biz::Util::RealmRole');
    foreach my $line (@{$self->realm_role_config}) {
	next if $line =~ /^\s*(#|$)/;
	$cmd .= $line;
	next if $cmd =~ s/\\$/ /;
	my(@args) = split(' ', $cmd);
	shift(@args);
	$rr->main(@args);
        $cmd = '';
    }
    return;
}

=for html <a name="import_db"></a>

=head2 import_db(string file) : string

Restores the database from file.

=cut

sub import_db {
    my($self, $file) = @_;
    $self->get_request;
    my($db) = Bivio::SQL::Connection->get_dbi_config;
    $self->are_you_sure("DROP DATABASE $db->{database} AND RESTORE?");
    $self->piped_exec(
	"env PGUSER=$db->{user} pg_restore --clean --format=c "
	. " -d $db->{database} $file");
    return "Imported $file into $db->{database}\n";
}

=for html <a name="realm_role_config"></a>

=head2 realm_role_config() : array_ref

Returns the realm role configuration.

=cut

sub realm_role_config {
    my($self) = @_;
    unless ($_REALM_ROLE_CONFIG) {
	# Cache so the command is idempotent.
	$_REALM_ROLE_CONFIG = [<DATA>];
	chomp(@$_REALM_ROLE_CONFIG);
	# Avoids error messages which point to <DATA>.
	close(DATA);
    }
    return $_REALM_ROLE_CONFIG;
}

=for html <a name="reinitialize_sequences"></a>

=head2 reinitialize_sequences() : string

Reinitializes all sequences in L<ddl_files|"ddl_files"> to be max value +
increment in table.

=cut

sub reinitialize_sequences {
    my($self) = @_;
    $self->setup;
    my($res) = $self->unsafe_get('noexecute') ? "Would have executed:\n" : '';
    foreach my $cmd (
	map({
	    grep(/^\s*create\s+sequence/im,
		split(/^(?=\s*create\s+sequence)/im,
                    ${Bivio::IO::File->read($_)}));
	} @{$self->ddl_files})
    ) {
	$cmd =~ s,/.*,,s;
	my($base) = $cmd =~ /sequence\s+(\w+)_s/si
	    or die('bad sequence name: ', $cmd);
	my($max) = Bivio::SQL::Connection->execute_one_row(
	    "select max(${base}_id) from ${base}_t");
	next unless $max && $max->[0];
	my($inc) = $cmd =~ /increment\s+by\s+(\d+)/si
	    or die('bad sequence increment by: ', $cmd);
	# Increment by two to be sure
	$inc = Bivio::Type::Number->add($max->[0],
	    Bivio::Type::Number->mul($inc, 2, 0), 0);
	# Number puts in '+'
	$inc =~ s/\D//g;
	$cmd =~ s/minvalue\s+(\d+)/minvalue $inc/i
	    or die('bad minvalue: ', $cmd);
	$res .= "${base}_s => $inc\n";
	next if $self->unsafe_get('noexecute');
	Bivio::SQL::Connection->execute("drop sequence ${base}_s");
	Bivio::SQL::Connection->execute($cmd);
    }
    return $res;
}

=for html <a name="run"></a>

=head2 run()

Runs I<input>, terminating on errors.  Any query results are thrown
away.

=cut

sub run {
    my($self) = @_;
    foreach my $s (_parse($self)) {
	Bivio::SQL::Connection->execute($s);
    }
    return;
}

#=PRIVATE METHODS

# _ddl_files(self) : array_ref
#
# Initializes self and calls ddl_files(), checking result.
#
sub _ddl_files {
    my($self) = @_;
    $self->get_request;
    my($f) = $self->ddl_files;
    $self->usage('must be run in files/ddl directory')
	    unless -r $f->[0];
    return $f;
}

# _parse(self) : array
#
# Parses input into SQL statements.  Dies if there as an extra statement.
#
sub _parse {
    my($self) = @_;
    $self->setup;
    my(@res);
    my($s) = '';
    foreach my $line (split(/\n/, ${$self->read_input})) {
	# Skip comments and blank lines
	next if $line =~ /^\s*--|^\s*$/s;

	# Execute statement if '/' found
	if ($line =~ /^\s*\/\s*$/s) {
	    push(@res, $s);
	    $s = '';
	    next;
	}

	# Build up statement
	$s .= $line."\n";
    }
    $self->usage($s, ': left over statement') if $s;
    return @res;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
__DATA__
# The following is returned by realm_role_config().
#
# GENERAL Permissions
#
b-realm-role -r GENERAL -u user edit ANONYMOUS - \
    +ANYBODY \
    +DATA_READ
b-realm-role -r GENERAL -u user edit USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role -r GENERAL -u user edit WITHDRAWN - \
    +USER
b-realm-role -r GENERAL -u user edit GUEST - \
    +WITHDRAWN
b-realm-role -r GENERAL -u user edit MEMBER - \
    +GUEST \
    +DATA_WRITE
b-realm-role -r GENERAL -u user edit ACCOUNTANT - \
    +MEMBER
b-realm-role -r GENERAL -u user edit ADMINISTRATOR - \
    +ACCOUNTANT \
    +ADMIN_READ \
    +ADMIN_WRITE \
    +DATA_WRITE

#
# USER Permissions
#
b-realm-role -r USER -u user edit ANONYMOUS - \
    +ANYBODY
b-realm-role -r USER -u user edit USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role -r USER -u user edit WITHDRAWN - \
    +USER
b-realm-role -r USER -u user edit GUEST - \
    +WITHDRAWN
b-realm-role -r USER -u user edit MEMBER - \
    +GUEST \
    +ADMIN_READ \
    +DATA_READ \
    +DATA_WRITE
b-realm-role -r USER -u user edit ACCOUNTANT - \
    +MEMBER \
    +ADMIN_WRITE
b-realm-role -r USER -u user edit ADMINISTRATOR - \
    +ACCOUNTANT

#
# CLUB Permissions
#
b-realm-role -r CLUB -u user edit ANONYMOUS - \
    +ANYBODY
b-realm-role -r CLUB -u user edit USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role -r CLUB -u user edit WITHDRAWN - \
    +USER
b-realm-role -r CLUB -u user edit GUEST - \
    +WITHDRAWN
b-realm-role -r CLUB -u user edit MEMBER - \
    +GUEST \
    +ADMIN_READ \
    +DATA_READ \
    +DATA_WRITE
b-realm-role -r CLUB -u user edit ACCOUNTANT - \
    +MEMBER \
    +ADMIN_WRITE
b-realm-role -r CLUB -u user edit ADMINISTRATOR - \
    +ACCOUNTANT
