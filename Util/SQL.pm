# Copyright (c) 2001-2005 bivio Software, Inc.  All rights reserved.
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
    create_test_db -- destroys, creates, and initializes test database
    destroy_db -- drops all the tables, indexes, and sequences created
    drop -- drops objects which would be created by running input
    drop_and_run -- calls drop then run
    export_db dir -- exports database (only works for pg right now)
    import_db file -- imports database (ditto)
    import_tables_only file -- imports tables and sequences only
    reinitialize_constraints -- creates constraints
    reinitialize_sequences -- recreates to MAX(primary_id) (must be in ddl directory)
    run -- executes sql contained in input and dies on error
    run_command sql -- executes sql in command line interpreter (shell)
    upgrade_db -- upgrade the database
    vacuum_db [args] -- runs vacuumdb command (must be run as postgres)
    vacuum_db_continuously -- run vacuum_db as a daemon
EOF
}

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::File;
use Bivio::IO::Ref;
use Bivio::SQL::Connection;
use Bivio::Type::PrimaryId;

#=VARIABLES
my($_REALM_ROLE_CONFIG);
Bivio::IO::Config->register(my $_CFG = {
    export_db_on_upgrade => 1,
});

=head1 METHODS

=cut

=for html <a name="backup_model"></a>

=head2 backup_model(string model, string order_by)

Backs up the model, and prints a message stating where it was backed up to.

=cut

sub backup_model {
    my($self, $model, $order_by) = @_;
    $self->print(
	"$model written to ",
	Bivio::IO::File->write(
	    "$model-" . Bivio::Type::DateTime->local_now_as_file_name . '.pl',
	    Bivio::IO::Ref->to_string(
		Bivio::Biz::Model->new($self->get_request, $model)
		    ->map_iterate(undef, 'unauth_iterate_start', $order_by),
	    ),
	),
	"\n",
    );
    return;
}

=for html <a name="create_db"></a>

=head2 create_db()

Initializes database.  Must be un from from C<files/ddl> directory,
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

=for html <a name="create_test_db"></a>

=head2 create_test_db()

Destroys old database, creates new database, populates with test data.
Subclasses should override L<initialize_test_data|"initialize_test_data"> to
create the test data.

=cut

sub create_test_db {
    my($self) = @_;
    $self->initialize_ui;
    my($req) = $self->get_request;
    die('cannot be run on production system')
	if $req->is_production;
    $self->destroy_db;
    $self->create_db;
    Bivio::IO::File->rm_rf(
	Bivio::UI::Facade->get_local_file_name(
	    Bivio::UI::LocalFileType->REALM_DATA, ''));
    return $self->initialize_test_data;
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

=head2 drop(string sql)

Parses I<sql> (default: reads I<input>) and executes "drop I<object>" where
I<object> may be a table, index, sequence, etc.  The values are parsed from
I<input> which must be of the form:

   create table ....
   create [unique] index ...
   create sequence
   ALTER TABLE realm_role_t
      ADD CONSTRAINT realm_role_t1
      PRIMARY KEY(realm_id, role)
   create function ...

and so on.

Ignores "does not exist" errors.

=cut

sub drop {
    my($self, $sql) = @_;
    foreach my $s (_parse($self, $sql)) {
	next unless $s =~ /^(\s*)create(?:\s+unique)?\s+(\w+\s+\w+)\s+/is
            || $s =~ /^\s*(alter\s+table\s*\w+\s*)add\s+(constraint\s+\w+)\s+/is
            || $s =~ /^(\s*)create(\s+function\s[\S]+)/is;
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

=head2 drop_and_run(string sql)

Executes L<drop|"drop"> and then L<run|"run"> with same input.

=cut

sub drop_and_run {
    my($self, $sql) = @_;
    $self->drop($sql);
    return $self->run($sql);
}

=for html <a name="export_db"></a>

=head2 export_db(string dir) : string

Dumps the current database to I<dir> (or '.') to a file of the form:

   <db>-<datetime>.pg_dump

=cut

sub export_db {
    my($self, $dir) = @_;
    my($db) = _assert_postgres($self);
    my($f) = ($dir || '.') . '/' . $db->{database} . '-'
	. Bivio::Type::DateTime->local_now_as_file_name . '.pg_dump';
    $self->piped_exec(
	"pg_dump --username '$db->{user}' --clean --format=c --blobs "
	. " --file='$f' '$db->{database}'");
    return "Exported $db->{database} to $f\n";
}

=for html <a name="format_test_email"></a>

=head2 static format_test_email(string base) : string

Returns 

    Bivio::Test::Language::HTTP->generate_local_email($base)

=cut

sub format_test_email {
    my(undef, $base) = @_;
    return (Bivio::IO::ClassLoader->simple_require(
	'Bivio::Test::Language::HTTP')->generate_local_email($base))[0],
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item export_db_on_upgrade : boolean [1]

Call L<export_db|"export_db"> before upgrading database.  You need to
set this to false if you are using Oracle as L<export_db|"export_db"> doesn't
support Oracle at this time.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}


=for html <a name="import_db"></a>

=head2 import_db(string backup_file) : string

Restores the database from file.

=cut

sub import_db {
    my($self, $backup_file) = @_;
    $self->import_tables_only($backup_file);
    return $self->reinitialize_constraints;
}

=for html <a name="import_tables_only"></a>

=head2 import_tables_only(string backup_file)

Destroys database, then imports data only from a backup file. Constraints
are not restored.

=cut

sub import_tables_only {
    my($self, $backup_file) = @_;
    $self->usage_error('missing file') unless $backup_file;
    my($db) = _assert_postgres($self);
    $self->destroy_db;

    foreach my $file (@{_ddl_files($self)}) {
        next if $file =~ /constraints/;
	$self->put(input => $file)->run;
    }
    # need to commit so pg_restore can access the tables
    Bivio::SQL::Connection->commit;

    $self->piped_exec("pg_restore --username='$db->{user}'"
	. " --dbname='$db->{database}' --data-only '$backup_file'");

    Bivio::SQL::Connection->ping_connection;
    return;
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
    if (Bivio::Auth::RealmType->unsafe_from_name('FORUM')) {
	$rr->copy_all(club => 'forum');
	$rr->main(qw(-r FORUM -u user edit MEMBER -ADMIN_READ -DATA_WRITE));
    }
    return;
}

=for html <a name="initialize_test_data"></a>

=head2 initialize_test_data()

Initializes test data.  A hook for the subclasses.

=cut

sub initialize_test_data {
    return;
}

=for html <a name="internal_upgrade_db"></a>

=head2 abstract internal_upgrade_db()

Subclass should implement.

=cut

$_ = <<'}'; # emacs
sub internal_upgrade_db {
}

=for html <a name="internal_upgrade_db_forum"></a>

=head2 internal_upgrade_db_forum()

Adds Forum and RealmFile tables.  Don't forget to add the following
to your BConf.pm after running this.

   'Bivio::SQL::PropertySupport' => {
        unused_classes => [],
   },

=cut

sub internal_upgrade_db_forum {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE forum_t (
  forum_id NUMERIC(18) NOT NULL,
  parent_realm_id NUMERIC(18) NOT NULL,
  CONSTRAINT forum_t1 PRIMARY KEY(forum_id)
)
/
CREATE TABLE realm_file_t (
  realm_file_id NUMERIC(18),
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  path VARCHAR(500) NOT NULL,
  path_lc VARCHAR(500) NOT NULL,
  is_folder NUMERIC(1) NOT NULL,
  is_public NUMERIC(1) NOT NULL,
  is_read_only NUMERIC(1) NOT NULL,
  CONSTRAINT realm_file_t1 PRIMARY KEY(realm_file_id)
)
/
CREATE SEQUENCE realm_file_s
  MINVALUE 100003
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE forum_s
  MINVALUE 100004
  CACHE 1 INCREMENT BY 100000
/
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t2
  foreign key (realm_id)
  references realm_owner_t(realm_id)
/
CREATE INDEX realm_file_t3 ON realm_file_t (
  realm_id
)
/
CREATE INDEX realm_file_t4 ON realm_file_t (
  modified_date_time
)
/
CREATE INDEX realm_file_t5 ON realm_file_t (
  path_lc
)
/
CREATE UNIQUE INDEX realm_file_t6 ON realm_file_t (
  realm_id,
  path_lc
)
/
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t7
  CHECK (is_folder BETWEEN 0 AND 1)
/
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t8
  CHECK (is_public BETWEEN 0 AND 1)
/
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t9
  CHECK (is_read_only BETWEEN 0 AND 1)
/
ALTER TABLE realm_file_t
  ADD CONSTRAINT realm_file_t10
  foreign key (user_id)
  references realm_owner_t(realm_id)
/
CREATE INDEX realm_file_t11 ON realm_file_t (
  user_id
)
/
ALTER TABLE forum_t
  add constraint forum_t2
  foreign key (parent_realm_id)
  references realm_owner_t(realm_id)
/
CREATE INDEX forum_t3 on forum_t (
  parent_realm_id
)
/
EOF
    return;
}

=for html <a name="internal_upgrade_db_multiple_realm_roles"></a>

=head2 internal_upgrade_db_multiple_realm_roles()

Changes schema to upgrade multiple realm roles and drops honorifics.

=cut

sub internal_upgrade_db_multiple_realm_roles {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE realm_role_t
  DROP CONSTRAINT realm_role_t4
;
ALTER TABLE realm_user_t
  DROP CONSTRAINT realm_user_t6
;
ALTER TABLE realm_user_t
  DROP CONSTRAINT realm_user_t1
;
ALTER TABLE realm_user_t
  ADD CONSTRAINT realm_user_t1
  PRIMARY KEY(realm_id, user_id, role)
;
ALTER TABLE realm_owner_t
  DROP CONSTRAINT realm_owner_t4
;
ALTER TABLE realm_user_t
  DROP CONSTRAINT realm_user_t7
;
ALTER TABLE realm_user_t
  DROP COLUMN honorific
;
EOF
    return;
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

=for html <a name="reinitialize_constraints"></a>

=head2 reinitialize_constraints() : string

Applies constraint files and reinitializes sequences.

=cut

sub reinitialize_constraints {
    my($self) = @_;

    foreach my $file (@{_ddl_files($self)}) {
        next unless $file =~ /constraints/;
  	$self->put(input => $file)->run;
    }
    return $self->reinitialize_sequences;
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
	$inc = Bivio::Type::PrimaryId->add($max->[0],
	    Bivio::Type::PrimaryId->mul($inc, 2, 0), 0);
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

=for html <a name="restore_model"></a>

=head2 restore_model(string model, string filename)

Restores I<model> table with I<filename>.  Rows are not deleted first.

=cut

sub restore_model {
    my($self, $model, $filename) = @_;
    my($m) = Bivio::Biz::Model->new($self->get_request, $model);
    foreach my $r (@{do($filename)}) {
	$m->create($r);
    }
    $self->print("Restored $model\n");
    return;
}

=for html <a name="run"></a>

=head2 run(string sql)

Parses I<sql> (default: reads I<input>), terminating on errors.  Any query
results are thrown away.

=cut

sub run {
    my($self, $sql) = @_;
    foreach my $s (_parse($self, $sql)) {
	Bivio::SQL::Connection->execute($s);
    }
    return;
}

=for html <a name="run_command"></a>

=head2 run_command(string commands) : string_ref

Runs command line interpreter (e.g. psql or sqlplus) on the current database.
I<commands> may be a string_ref.  Aborts on errors.

Currently only supports postgres.

=cut

sub run_command {
    my($self, $commands) = @_;
    my($c) = _assert_postgres($self);
    return $self->piped_exec(
	"psql --username '$c->{user}' --dbname '$c->{database}' 2>&1",
	# Ensures commit happens
	(ref($commands) ? $$commands : $commands)
	. ($self->unsafe_get('noexecute') ? "\n;rollback;\n" : "\n;commit;\n"),
    );
}

=for html <a name="upgrade_db"></a>

=head2 upgrade_db()

Handles common setup for database upgrades.  Calls
L<internal_upgrade_db|"internal_upgrade_db">.

=cut

sub upgrade_db {
    my($self, $method) = @_;
    my($req) = $self->get_request();

    # want to avoid accidentally running this script
    $self->are_you_sure('Upgrade the database?');

    # Must be first, because pg_dump closes all db connections.
    $self->main('export_db')
	if $_CFG->{export_db_on_upgrade};

    my($upgrade) = Bivio::Biz::Model->new($req, 'DbUpgrade');
    $self->usage_error($self->package_version(), ': already ran.')
	if $upgrade->unauth_load({version => $self->package_version});

    $self->internal_upgrade_db();

    $upgrade->create({
	version => $self->package_version,
	run_date_time => Bivio::Type::DateTime->now
    });

    return;
}

=for html <a name="vacuum_db"></a>

=head2 vacuum_db(string arg, ...)

Runs I<vacuumdb> with I<args> with a lock.  Prints output using
L<Bivio::IO::Alert::print_literally|Bivio::IO::Alert/"print_literally">
so will appear in log when called by
L<vacuum_db_continuously|"vacuum_db_continuously">.

=cut

sub vacuum_db {
    my($self, @arg) = @_;
    _assert_postgres($self);
    $self->lock_action(sub {
        Bivio::IO::Alert->print_literally(${
	    $self->piped_exec(
		join(' ', 'vacuumdb ', map("'$_'", @arg), '2>&1'),
		'',
		1,
	    ),
	});
    });
    return;
}

=for html <a name="vacuum_db_continuously"></a>

=head2 vacuum_db_continuously()

Runs L<vacuum_db|"vacuum_db"> as a daemon.  You need to set the configuration
I<vacuum_db_continuously> in L<Bivio::ShellUtil|Bivio::ShellUtil>.

=cut

sub vacuum_db_continuously {
    my($self, $period_minutes) = @_;
    my($c) = _assert_postgres($self);
    $self->run_daemon(sub {
#TODO: See how often --analyze should be run
#TODO: Configure separately for each database?
        return [
	    __PACKAGE__,
	    'vacuum_db',
	    '--verbose',
	    $ENV{USER} eq 'postgres'
	        ? '--all'
	        : ('--username', $c->{user}, '--dbname', $c->{database}),
	],
    },
       'vacuum_db_continuously',
    );
    return;
}

#=PRIVATE SUBROUTINES

# _assert_postgres(self) : hash_ref
#
# Returns DBI config.  Asserts postgres is connection type.
#
sub _assert_postgres {
    my($self) = @_;
    $self->setup;
    my($c) = Bivio::SQL::Connection->get_dbi_config;
    $self->usage_error($c->{connection}, ': connection type not supported')
	unless $c->{connection} =~ /postgres/i;
    return $c;
}

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

# _parse(self, string sql) : array
#
# Parses input into SQL statements.  Dies if there as an extra statement.
# If $sql not supplied, calls I<read_input>
#
sub _parse {
    my($self, $sql) = @_;
    $self->setup;
    my(@res);
    my($s) = '';
    foreach my $line (split(/\n/, $sql || ${$self->read_input})) {
	# Skip comments and blank lines
	next if $line =~ /^\s*--|^\s*$/s;

	# Execute statement if '/' or ';' found
	if ($line =~ /^\s*[\/;]\s*$/s) {
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

Copyright (c) 2001-2005 bivio Software, Inc.  All rights reserved.

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
    +DATA_READ \
    +MAIL_POST \
    +MAIL_SEND
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
    +DATA_WRITE \
    +MAIL_READ \
    +MAIL_WRITE
b-realm-role -r GENERAL -u user edit MAIL_RECIPIENT -
b-realm-role -r GENERAL -u user edit FILE_WRITER - \
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
    +DATA_WRITE \
    +MAIL_POST \
    +MAIL_READ \
    +MAIL_SEND \
    +MAIL_WRITE
b-realm-role -r USER -u user edit ACCOUNTANT - \
    +MEMBER \
    +ADMIN_WRITE
b-realm-role -r USER -u user edit ADMINISTRATOR - \
    +ACCOUNTANT
b-realm-role -r USER -u user edit MAIL_RECIPIENT -
b-realm-role -r USER -u user edit FILE_WRITER - \
    +DATA_WRITE

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
    +DATA_WRITE \
    +MAIL_POST \
    +MAIL_READ \
    +MAIL_SEND \
    +MAIL_WRITE
b-realm-role -r CLUB -u user edit ACCOUNTANT - \
    +MEMBER \
    +ADMIN_WRITE
b-realm-role -r CLUB -u user edit ADMINISTRATOR - \
    +ACCOUNTANT
b-realm-role -r CLUB -u user edit MAIL_RECIPIENT -
b-realm-role -r CLUB -u user edit FILE_WRITER - \
    +DATA_WRITE
