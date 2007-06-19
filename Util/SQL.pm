# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Util::SQL;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::Config;
use Bivio::IO::File;
use Bivio::IO::Ref;
use Bivio::SQL::Connection;
use Bivio::Type::PrimaryId;
use Bivio::UI::LocalFileType;

# C<Bivio::Util::SQL> executes SQL using the configured db.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_REALM_ROLE_CONFIG);
Bivio::IO::Config->register(my $_CFG = {
    export_db_on_upgrade => 1,
});

sub TEST_PASSWORD {
    # Returns password for test data.
    return 'password';
}

sub USAGE {
    # Returns usage.
    return <<'EOF';
usage: b-sql [options] command [args...]
commands:
    create_db -- initializes database (must be run from ddl directory)
    create_test_db -- destroys, creates, and initializes test database
    create_test_user user-id [password] -- creates a test user with local email
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

sub backup_model {
    my($self, $model, $order_by) = @_;
    $self->print(
	"$model written to ",
	Bivio::IO::File->write(
	    "$model-" . Bivio::Type::DateTime->local_now_as_file_name . '.pl',
	    Bivio::IO::Ref->to_string(
		my $rows = Bivio::Biz::Model->new($self->get_request, $model)
		    ->map_iterate(undef, 'unauth_iterate_start', $order_by),
	    ),
	),
	"\n",
    );
    return $rows;
}

sub create_db {
    my($self) = @_;
    # Initializes database.  Must be un from from C<files/ddl> directory,
    # which contains C<*-tables.sql>, C<*-constraints.sql>, etc.
    #
    # See L<destroy_db|"destroy_db"> to see how you'd undo this operation.
    $self->setup;
    foreach my $file (@{_ddl_files($self)}){
	# Set up new file so read_input returns new value each time
	$self->print('Executing ', $file, "\n");
	$self->put(input => $file);
	$self->run;
    }
    $self->initialize_db();
    return;
}

sub create_test_db {
    my($self) = @_;
    # Destroys old database, creates new database, populates with test data.
    # Subclasses should override L<initialize_test_data|"initialize_test_data"> to
    # create the test data.
    $self->initialize_ui;
    my($req) = $self->get_request;
    die('cannot be run on production system')
	if $req->is_production;
    $self->destroy_db;
    $self->create_db;
    $self->delete_realm_files;
    return $self->initialize_test_data;
}

sub create_test_user {
    my($self, $user_or_email, $password) = @_;
    # Creates I<user_or_email> with I<password> (default: password).
    # Email is generated by Bivio::Test::Language::HTTP, if I<user_or_email> is
    # not an email address.
    $self->initialize_ui;
    my($display_name);
    my($email) = $user_or_email =~ /\@/ ? $user_or_email
	: $self->format_test_email($display_name = $user_or_email);
    $display_name ||= ($email =~ /(.*)@/)[0];
    (my $user_name = substr(
	$display_name, 0, Bivio::Type->get_instance('RealmName')->get_width
    )) =~ s/\W+//g;
    $self->new_other('RealmAdmin')->create_user(
	$email,
	$display_name,
	$password || $self->TEST_PASSWORD,
	$user_name,
    );
    return;
}

sub ddl_files {
    my(undef, $base_names) = @_;
    # Returns list of SQL data files used by L<create_db|"create_db"> and
    # L<destroy_db|"destroy_db">.
    #
    # Subclasses must overrided.  Call this method with a list of
    # I<base_names>, e.g. ['bOP'], and it will return a list of
    # constraints.
    return [map {
	my($base) = $_;
	map {
	    $base.'-'.$_.'.sql';
	} qw(tables constraints sequences);
    } @$base_names];
}

sub delete_realm_files {
    # Delete realm data files.
    Bivio::IO::File->rm_rf(
	Bivio::UI::Facade->get_local_file_name(
	    Bivio::UI::LocalFileType->REALM_DATA, ''));
    return;
}

sub destroy_db {
    my($self) = @_;
    # Undoes the operations of L<create_db|"create_db">.
    $self->usage_error('You cannot destroy a production database.')
	if $self->get_request->is_production;
    $self->are_you_sure('DROP THE ENTIRE '
	. Bivio::SQL::Connection->get_dbi_config->{database}
	. ' DATABASE?');
    # We drop in opposite order.  Some constraint drops will
    # fail, but that's ok.  We need to drop the FOREIGN KEY
    # constraints so we can drop the tables.
    foreach my $file (reverse(@{_ddl_files($self)})) {
	$self->print('Dropping ', $file, "\n");
	$self->put(input => $file);
	$self->drop;
    }
    $self->use('Bivio::Biz::File')->destroy_db;
    return;
}

sub drop {
    my($self, $sql) = @_;
    # Parses I<sql> (default: reads I<input>) and executes "drop I<object>" where
    # I<object> may be a table, index, sequence, etc.  The values are parsed from
    # I<input> which must be of the form:
    #
    #    create table ....
    #    create [unique] index ...
    #    create sequence
    #    ALTER TABLE realm_role_t
    #       ADD CONSTRAINT realm_role_t1
    #       PRIMARY KEY(realm_id, role)
    #    create function ...
    #
    # and so on.
    #
    # Ignores "does not exist" errors.
    foreach my $s (_parse($self, $sql)) {
	next unless $s =~ /^(\s*)create(?:\s+unique)?\s+(\w+\s+\w+)\s+/is
            || $s =~ /^\s*(alter\s+table\s*\w+\s*)add\s+(constraint\s+\w+)\s+/is
            || $s =~ /^(\s*)create(\s+function\s[\S]+)/is;
	my($p, $s) = ($1, $2);
	Bivio::Die->eval(sub {
#TODO: don't want to ignore all errors - ex. db doesn't exist
	    Bivio::SQL::Connection->execute(
		$p . 'drop ' . $s . ($s =~ /^table/i ? ' CASCADE' : ''));
	    return;
	});
	Bivio::SQL::Connection->commit;
    }
    return;
}

sub drop_and_run {
    my($self, $sql) = @_;
    # Executes L<drop|"drop"> and then L<run|"run"> with same input.
    $self->drop($sql);
    return $self->run($sql);
}

sub export_db {
    my($self, $dir) = @_;
    # Dumps the current database to I<dir> (or '.') to a file of the form:
    #
    #    <db>-<datetime>.pg_dump
    my($db) = _assert_postgres($self);
    my($f) = ($dir || '.') . '/' . $db->{database} . '-'
	. Bivio::Type::DateTime->local_now_as_file_name . '.pg_dump';
    $self->piped_exec(
	"pg_dump --username '$db->{user}' --clean --format=c --blobs "
	. " --file='$f' '$db->{database}'");
    return "Exported $db->{database} to $f\n";
}

sub format_test_email {
    my(undef, $base) = @_;
    # Returns 
    #
    #     Bivio::Test::Language::HTTP->generate_local_email($base)
    return (Bivio::IO::ClassLoader->simple_require(
	'Bivio::Test::Language::HTTP')->generate_local_email($base))[0],
}

sub handle_config {
    my(undef, $cfg) = @_;
    # export_db_on_upgrade : boolean [1]
    #
    # Call L<export_db|"export_db"> before upgrading database.  You need to
    # set this to false if you are using Oracle as L<export_db|"export_db"> doesn't
    # support Oracle at this time.
    $_CFG = $cfg;
    return;
}

sub import_db {
    my($self, $backup_file) = @_;
    # Restores the database from file.
    $self->import_tables_only($backup_file);
    return $self->reinitialize_constraints
	. "You need to copy external files and run: b-search rebuild_db\n";
}

sub import_tables_only {
    my($self, $backup_file) = @_;
    # Destroys database, then imports data only from a backup file. Constraints
    # are not restored.
    $self->usage_error('missing file')
	unless $backup_file;
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

sub init_realm_role {
    my($self) = @_;
    # Initializes the database with the values from
    # L<realm_role_config|"realm_role_config">.
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
	$rr->main(qw(-realm FORUM -user user edit MEMBER -ADMIN_READ -DATA_WRITE));
    }
    $rr->copy_all(forum => 'calendar_event')
	if Bivio::Auth::RealmType->unsafe_from_name('CALENDAR_EVENT');
    return;
}

sub initialize_db {
    my($self) = @_;
    # Initializes default data.
    Bivio::Biz::Model->new($self->get_request, 'RealmOwner')->init_db;
    $self->init_realm_role;
#TODO: Needs to be after subclasses init_realm_role for new realmtypes
    if (Bivio::Agent::TaskId->unsafe_from_name('FORUM_TUPLE_SLOT_TYPE_LIST')) {
	$self->initialize_tuple_permissions;
	$self->initialize_tuple_slot_types;
    }
    return;
}

sub initialize_test_data {
    # Initializes test data.  A hook for the subclasses.
    return;
}

sub initialize_tuple_permissions {
    my($self) = @_;
    # Sets up default permissions of tuples.
    my($req) = $self->get_request;
    my($rr) = $self->new_other('Bivio::Biz::Util::RealmRole');
    Bivio::Auth::Realm->do_default(sub {
        $rr->edit_categories('+tuple');
	return 1;
    }, $req);
    return;
}

sub initialize_tuple_slot_types {
    my($self) = @_;
    # Creates default TupleSlotType enteries in general realm.
    my($req) = $self->get_request;
    my($prev) = $req->get('auth_realm');
    $req->set_realm(undef);
    Bivio::Biz::Model->new($req, 'TupleSlotType')->create_from_hash({
	Integer => {
	    type_class => 'Integer',
	    default_value => undef,
	    choices => undef,
	    is_required => 0,
	},
	Date => {
	    type_class => 'Date',
	    default_value => undef,
	    choices => undef,
	    is_required => 0,
	},
	String => {
	    type_class => 'String',
	    default_value => undef,
	    choices => undef,
	    is_required => 0,
	},
	Email => {
	    type_class => 'Email',
	    default_value => undef,
	    choices => undef,
	    is_required => 0,
	},
    });
    $req->set_realm($prev);
    return;
}

sub internal_upgrade_db_bundle {
    my($self) = @_;
    my($req) = $self->get_request;
    foreach my $realm (qw(forum calendar_event)) {
	$req->with_realm($realm, sub {
	    $req->get_nested('auth_realm', 'owner')->cascade_delete;
        })
	    if $self->model('RealmOwner')->unauth_load({name => $realm});
    }
    $self->internal_upgrade_db_forum;
    $self->internal_upgrade_db_mail;
    $self->internal_upgrade_db_mail_bounce;
    $self->internal_upgrade_db_calendar_event;
    $self->internal_upgrade_db_email_alias;
    $self->internal_upgrade_db_job_lock;
    $self->internal_upgrade_db_tuple;
    $self->internal_upgrade_db_motion;
    $self->internal_upgrade_db_website;
    $self->internal_upgrade_db_realm_dag;
    return;
}

sub internal_upgrade_db_calendar_event {
    my($self) = @_;
    # Adds CalendarEvent table.
    $self->run(<<'EOF');
CREATE TABLE calendar_event_t (
  calendar_event_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  dtstart DATE NOT NULL,
  dtend DATE NOT NULL,
  location VARCHAR(500),
  description VARCHAR(4000),
  url VARCHAR(255),
  time_zone NUMERIC(4),
  CONSTRAINT calendar_event_t1 PRIMARY KEY(calendar_event_id)
)
/
ALTER TABLE calendar_event_t
  ADD CONSTRAINT calendar_event_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX calendar_event_t3 ON calendar_event_t (
  realm_id
)
/
CREATE INDEX calendar_event_t4 ON calendar_event_t (
  modified_date_time
)
/
CREATE INDEX calendar_event_t5 ON calendar_event_t (
  dtstart
)
/
CREATE INDEX calendar_event_t6 ON calendar_event_t (
  dtend
)
/
CREATE SEQUENCE calendar_event_s
  MINVALUE 100005
  CACHE 1 INCREMENT BY 100000
/
EOF
    Bivio::Biz::Model->new($self->get_request, 'RealmOwner')
        ->init_realm_type(Bivio::Auth::RealmType->CALENDAR_EVENT);
    $self->new_other('Bivio::Biz::Util::RealmRole')
	->copy_all(forum => 'calendar_event');
    return;
}

sub internal_upgrade_db_email_alias {
    my($self) = @_;
    # Adds EmailAlias table.
    $self->run(<<'EOF');
CREATE TABLE email_alias_t (
  incoming VARCHAR(100) NOT NULL,
  outgoing VARCHAR(100) NOT NULL,
  CONSTRAINT email_alias_t1 PRIMARY KEY(incoming)
)
/
CREATE INDEX email_alias_t2 ON email_alias_t (
  outgoing
)
/
EOF
    return;
}

sub internal_upgrade_db_file_writer {
    my($self) = @_;
    my($req) = $self->initialize_ui;
    Bivio::Biz::Model->new($req, 'RealmUser')->do_iterate(
	sub {
	    my($it) = @_;
            return 1 if $it->get('realm_id')
                eq Bivio::Auth::RealmType->GENERAL->as_int;
	    $it->new->create({
		%{$it->get_shallow_copy},
		role => Bivio::Auth::Role->FILE_WRITER,
	    });
	    return 1;
	},
	unauth_iterate_start => 'user_id',
	{role => Bivio::Auth::Role->ADMINISTRATOR},
    );
    my($p) = ${Bivio::Auth::PermissionSet->from_array(['DATA_WRITE'])};
    Bivio::Biz::Model->new($req, 'RealmRole')->do_iterate(
	sub {
	    my($it) = @_;
	    my($rid) = $it->get('realm_id');
	    $it->update({
		permission_set => ($it->get('permission_set') & ~$p),
	    }) if $it->new_other('RealmOwner')
		->unauth_load_or_die({realm_id => $rid})
		->get('realm_type')->eq_forum;
	    $it->new->create({
		realm_id => $rid,
		role => Bivio::Auth::Role->FILE_WRITER,
		permission_set => $p,
	    });
	    return 1;
	},
	unauth_iterate_start => 'realm_id',
	{role => Bivio::Auth::Role->MEMBER},
    );
    return;
}

sub internal_upgrade_db_folder_id {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE realm_file_t
    ADD COLUMN folder_id NUMERIC(18)
/
CREATE INDEX realm_file_t12 ON realm_file_t (
  folder_id
)
/
EOF
    my($fid) = {};
    Bivio::Biz::Model->new($self->get_request, 'RealmFile')->do_iterate(
	sub {
	    my($it) = @_;
	    my($r, $p) = $it->get(qw(realm_id path_lc));
	    unless ($p eq '/') {
		$it->update({
		    folder_id => $fid->{$r . ($p =~ m{(.*/)})[0]}
			|| $it->die($p, ': no folder'),
		    override_is_read_only => 1,
		});
		$p .= '/';
	    }
	    $fid->{"$r$p"} = $it->get('realm_file_id')
		if $it->get('is_folder');
	    return 1;
	},
	'unauth_iterate_start',
	'realm_id asc, path_lc asc',
    );
    return;
}

sub internal_upgrade_db_forum {
    my($self) = @_;
    # Adds Forum and RealmFile tables.  Don't forget to add the following
    # to your BConf.pm after running this.
    #
    #    'Bivio::SQL::PropertySupport' => {
    #         unused_classes => [],
    #    },
    $self->run(<<'EOF');
CREATE TABLE forum_t (
  forum_id NUMERIC(18) NOT NULL,
  parent_realm_id NUMERIC(18) NOT NULL,
  want_reply_to NUMERIC(1) NOT NULL,
  is_public_email NUMERIC(1) NOT NULL,
  CONSTRAINT forum_t1 PRIMARY KEY(forum_id)
)
/
CREATE TABLE realm_file_t (
  realm_file_id NUMERIC(18),
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  folder_id NUMERIC(18),
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
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
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
  FOREIGN KEY (user_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_file_t11 ON realm_file_t (
  user_id
)
/
CREATE INDEX realm_file_t12 ON realm_file_t (
  folder_id
)
/
ALTER TABLE forum_t
  ADD CONSTRAINT forum_t2
  FOREIGN KEY (parent_realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX forum_t3 on forum_t (
  parent_realm_id
)
/
ALTER TABLE forum_t
  ADD CONSTRAINT forum_t4
  CHECK (want_reply_to BETWEEN 0 AND 1)
/
ALTER TABLE forum_t
  ADD CONSTRAINT forum_t5
  CHECK (is_public_email BETWEEN 0 AND 1)
/
EOF
    $self->model('RealmOwner')
        ->init_realm_type(Bivio::Auth::RealmType->FORUM);
    my($rr) = $self->new_other('Bivio::Biz::Util::RealmRole');
    $rr->copy_all(club => 'forum');
    $rr->main(qw(-realm FORUM -user user edit MEMBER -ADMIN_READ -DATA_WRITE));
    return;
}

sub internal_upgrade_db_forum_bits {
    my($self) = @_;
    # Adds Forum.is_public_email and want_reply_to
    $self->run(<<'EOF');
ALTER TABLE forum_t
    ADD COLUMN want_reply_to NUMERIC(1)
/
ALTER TABLE forum_t
    ADD COLUMN is_public_email NUMERIC(1)
/
UPDATE forum_t
    SET want_reply_to = 0, is_public_email = 0;
/
ALTER TABLE forum_t
    ALTER COLUMN want_reply_to SET NOT NULL
/
ALTER TABLE forum_t
    ALTER COLUMN is_public_email SET NOT NULL
/
ALTER TABLE forum_t
  ADD CONSTRAINT forum_t4
  CHECK (want_reply_to BETWEEN 0 AND 1)
/
ALTER TABLE forum_t
  ADD CONSTRAINT forum_t5
  CHECK (is_public_email BETWEEN 0 AND 1)
/
EOF
    return;
}

sub internal_upgrade_db_job_lock {
    my($self) = @_;
    # Adds Forum.is_public_email and want_reply_to
    $self->run(<<'EOF');
CREATE TABLE job_lock_t (
  realm_id NUMERIC(18) NOT NULL,
  task_id NUMERIC(9) NOT NULL,
  modified_date_time DATE NOT NULL,
  hostname VARCHAR(100) NOT NULL,
  pid NUMERIC(9) NOT NULL,
  percent_complete NUMERIC(20,6),
  message VARCHAR(500),
  die_code NUMERIC(9),
  constraint job_lock_t1 PRIMARY key(realm_id, task_id)
)
/
ALTER TABLE job_lock_t
  add constraint job_lock_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX job_lock_t3 on job_lock_t (
  realm_id
)
/
EOF
    return;
}

sub internal_upgrade_db_mail {
    my($self) = @_;
    my($req) = $self->initialize_ui;
    $self->run(<<'EOF');
CREATE TABLE realm_mail_t (
  realm_file_id NUMERIC(18),
  realm_id NUMERIC(18) NOT NULL,
  message_id VARCHAR(100) NOT NULL,
  thread_root_id NUMERIC(18) NOT NULL,
  thread_parent_id NUMERIC(18),
  from_email VARCHAR(100) NOT NULL,
  subject VARCHAR(100) NOT NULL,
  subject_lc VARCHAR(100) NOT NULL,
  CONSTRAINT realm_mail_t1 PRIMARY KEY(realm_file_id)
)
/
--
-- realm_mail_t
--
ALTER TABLE realm_mail_t
  ADD CONSTRAINT realm_mail_t2
  FOREIGN KEY (realm_file_id)
  REFERENCES realm_file_t(realm_file_id)
/
ALTER TABLE realm_mail_t
  ADD CONSTRAINT realm_mail_t3
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_mail_t4 ON realm_mail_t (
  realm_id
)
/
CREATE INDEX realm_mail_t5 ON realm_mail_t (
  message_id
)
/
ALTER TABLE realm_mail_t
  ADD CONSTRAINT realm_mail_t6
  FOREIGN KEY (thread_root_id)
  REFERENCES realm_file_t(realm_file_id)
/
CREATE INDEX realm_mail_t7 ON realm_mail_t (
  thread_root_id
)
/
ALTER TABLE realm_mail_t
  ADD CONSTRAINT realm_mail_t8
  FOREIGN KEY (thread_parent_id)
  REFERENCES realm_file_t(realm_file_id)
/
CREATE INDEX realm_mail_t9 ON realm_mail_t (
  thread_parent_id
)
/
CREATE INDEX realm_mail_t10 ON realm_mail_t (
  from_email
)
/
CREATE INDEX realm_mail_t11 ON realm_mail_t (
  subject_lc
)
/
EOF
    my($mf) = Bivio::Biz::Model->get_instance('RealmFile')->MAIL_FOLDER;
    Bivio::Biz::Model->new($req, 'RealmFile')->do_iterate(
	sub {
	    my($it) = @_;
	    $req->set_realm($it->get('realm_id'));
	    $it->new_other('RealmFile')->do_iterate(
		sub {
		    my($it) = @_;
		    $it->new_other('RealmMail')->create_from_file($it)
			if !$it->get('is_folder')
			&& $it->get('path') =~ m{^\Q$mf/}o;
		    return 1;
		},
		'realm_file_id asc',
	    );
	    return 1;
	},
	unauth_iterate_start => 'realm_id',
	{path => $mf},
    );
    return;
}

sub internal_upgrade_db_mail_bounce {
    my($self) = @_;
    # Adds EmailAlias table.
    $self->run(<<'EOF');
CREATE TABLE realm_mail_bounce_t (
  realm_file_id NUMERIC(18) NOT NULL,
  email VARCHAR(100) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  reason VARCHAR(100) NOT NULL,
  CONSTRAINT realm_mail_bounce_t1 PRIMARY KEY(realm_file_id, email)
)
/
--
-- realm_mail_bounce_t
--
ALTER TABLE realm_mail_bounce_t
  ADD CONSTRAINT realm_mail_bounce_t2
  FOREIGN KEY (realm_file_id)
  REFERENCES realm_file_t(realm_file_id)
/
CREATE INDEX realm_mail_bounce_t3 ON realm_mail_bounce_t (
  realm_file_id
)
/
ALTER TABLE realm_mail_bounce_t
  ADD CONSTRAINT realm_mail_bounce_t4
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_mail_bounce_t5 ON realm_mail_bounce_t (
  realm_id
)
/
ALTER TABLE realm_mail_bounce_t
  ADD CONSTRAINT realm_mail_bounce_t6
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX realm_mail_bounce_t7 ON realm_mail_bounce_t (
  user_id
)
/
CREATE INDEX realm_mail_bounce_t8 ON realm_mail_bounce_t (
  modified_date_time
)
/
CREATE INDEX realm_mail_bounce_t9 ON realm_mail_bounce_t (
  reason
)
/
CREATE INDEX realm_mail_bounce_t10 ON realm_mail_bounce_t (
  email
)
/
EOF
    return;
}

sub internal_upgrade_db_motion {
    my($self) = @_;
    # Adds Motion tables, etc.
    $self->run(<<'EOF');
CREATE TABLE motion_t (
  motion_id NUMERIC(18),
  realm_id NUMERIC(18) NOT NULL,
  name VARCHAR(100) NOT NULL,
  name_lc VARCHAR(100) NOT NULL,
  question VARCHAR(500) NOT NULL,
  status NUMERIC(2) NOT NULL,
  type NUMERIC(2) NOT NULL,
  CONSTRAINT motion_t1 PRIMARY KEY(motion_id)
)
/

CREATE TABLE motion_vote_t (
  motion_id NUMERIC(18),
  user_id NUMERIC(18) NOT NULL,
  affiliated_realm_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  vote NUMERIC(2) NOT NULL,
  creation_date_time DATE NOT NULL,
  CONSTRAINT motion_vote_t1 PRIMARY KEY(motion_id, user_id)
)
/

--
-- motion_t
--
ALTER TABLE motion_t
  add constraint motion_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX motion_t3 on motion_t (
  realm_id
)
/
CREATE UNIQUE INDEX motion_t4 ON motion_t (
  realm_id,
  name_lc
)
/

--
-- motion_vote_t
--
ALTER TABLE motion_vote_t
  add constraint motion_vote_t2
  FOREIGN KEY (motion_id)
  REFERENCES motion_t(motion_id)
/
CREATE INDEX motion_vote_t3 on motion_vote_t (
  motion_id
)
/
ALTER TABLE motion_vote_t
  add constraint motion_vote_t4
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX motion_vote_t5 on motion_vote_t (
  user_id
)
/
ALTER TABLE motion_vote_t
  add constraint motion_vote_t6
  FOREIGN KEY (affiliated_realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX motion_vote_t7 on motion_vote_t (
  affiliated_realm_id
)
/
ALTER TABLE motion_vote_t
  add constraint motion_vote_t8
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX motion_vote_t9 on motion_vote_t (
  realm_id
)
/

CREATE SEQUENCE motion_s
  MINVALUE 100008
  CACHE 1 INCREMENT BY 100000
/

EOF
    return;
}

sub internal_upgrade_db_multiple_realm_roles {
    my($self) = @_;
    # Changes schema to upgrade multiple realm roles and drops honorifics.
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

sub internal_upgrade_db_realm_dag {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE realm_dag_t (
  parent_id NUMERIC(18) NOT NULL,
  child_id NUMERIC(18) NOT NULL,
  constraint realm_dag_t1 primary key (parent_id, child_id)
)
/
ALTER TABLE realm_dag_t
  ADD CONSTRAINT realm_dag_t2
  FOREIGN KEY (parent_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_dag_t3 ON realm_dag_t (
  parent_id
)
/
ALTER TABLE realm_dag_t
  ADD CONSTRAINT realm_dag_t4
  FOREIGN KEY (child_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_dag_t5 ON realm_dag_t (
  child_id
)
/
EOF
    return;
}

sub internal_upgrade_db_tuple {
    my($self) = @_;
    # Adds Tuple tables, etc.
    $self->run(<<'EOF');
CREATE TABLE tuple_t (
  realm_id NUMERIC(18) NOT NULL,
  tuple_def_id NUMERIC(18) NOT NULL,
  tuple_num NUMERIC(9) NOT NULL,
  modified_date_time DATE NOT NULL,
  thread_root_id NUMERIC(18),
  slot1 VARCHAR(500),
  slot2 VARCHAR(500),
  slot3 VARCHAR(500),
  slot4 VARCHAR(500),
  slot5 VARCHAR(500),
  slot6 VARCHAR(500),
  slot7 VARCHAR(500),
  slot8 VARCHAR(500),
  slot9 VARCHAR(500),
  slot10 VARCHAR(500),
  slot11 VARCHAR(500),
  slot12 VARCHAR(500),
  slot13 VARCHAR(500),
  slot14 VARCHAR(500),
  slot15 VARCHAR(500),
  slot16 VARCHAR(500),
  slot17 VARCHAR(500),
  slot18 VARCHAR(500),
  slot19 VARCHAR(500),
  slot20 VARCHAR(500),
  CONSTRAINT tuple_t1 PRIMARY KEY(realm_id, tuple_def_id, tuple_num)
)
/

CREATE TABLE tuple_def_t (
  tuple_def_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  label VARCHAR(100) NOT NULL,
  moniker VARCHAR(100) NOT NULL,
  CONSTRAINT tuple_def_t1 PRIMARY KEY(tuple_def_id)
)
/

CREATE TABLE tuple_slot_def_t (
  tuple_def_id NUMERIC(18) NOT NULL,
  tuple_slot_num NUMERIC(2) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  label VARCHAR(100) NOT NULL,
  tuple_slot_type_id NUMERIC(18) NOT NULL,
  is_required NUMERIC(1) NOT NULL,
  CONSTRAINT tuple_slot_t1 PRIMARY KEY(tuple_def_id, tuple_slot_num)
)
/

CREATE TABLE tuple_slot_type_t (
  tuple_slot_type_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  label VARCHAR(100) NOT NULL,
  type_class VARCHAR(100) NOT NULL,
  choices VARCHAR(65535),
  default_value VARCHAR(500),
  CONSTRAINT tuple_slot_type_t1 PRIMARY KEY(tuple_slot_type_id)
)
/

CREATE TABLE tuple_use_t  (
  realm_id NUMERIC(18) NOT NULL,
  tuple_def_id NUMERIC(18) NOT NULL,
  label VARCHAR(100) NOT NULL,
  moniker VARCHAR(100) NOT NULL,
  CONSTRAINT tuple_use_t1 PRIMARY KEY(realm_id, tuple_def_id)
)
/
--
-- tuple_t
--
ALTER TABLE tuple_t
  ADD CONSTRAINT tuple_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_t3 on tuple_t (
  realm_id
)
/
ALTER TABLE tuple_t
  ADD CONSTRAINT tuple_t4
  FOREIGN KEY (tuple_def_id)
  REFERENCES tuple_def_t(tuple_def_id)
/
CREATE INDEX tuple_t5 on tuple_t (
  tuple_def_id
)
/
CREATE INDEX tuple_t6 on tuple_t (
  modified_date_time
)
/
ALTER TABLE tuple_t
  ADD CONSTRAINT tuple_t7
  FOREIGN KEY (thread_root_id)
  REFERENCES realm_mail_t(realm_file_id)
/
CREATE INDEX tuple_t8 on tuple_t (
  thread_root_id
)
/
ALTER TABLE tuple_t
  ADD CONSTRAINT tuple_t9
  FOREIGN KEY (realm_id, tuple_def_id)
  REFERENCES tuple_use_t(realm_id, tuple_def_id)
/
CREATE INDEX tuple_t10 on tuple_t (
  realm_id,
  tuple_def_id
)
/

--
-- tuple_def_t
--
ALTER TABLE tuple_def_t
  ADD CONSTRAINT tuple_def_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_def_t3 on tuple_def_t (
  realm_id
)
/
CREATE UNIQUE INDEX tuple_def_t4 on tuple_def_t (
  realm_id,
  label
)
/
CREATE UNIQUE INDEX tuple_def_t5 on tuple_def_t (
  realm_id,
  moniker
)
/

--
-- tuple_slot_def_t
--
ALTER TABLE tuple_slot_def_t
  ADD CONSTRAINT tuple_slot_def_t2
  FOREIGN KEY (tuple_def_id)
  REFERENCES tuple_def_t(tuple_def_id)
/
CREATE INDEX tuple_slot_def_t3 on tuple_slot_def_t (
  tuple_def_id
)
/
ALTER TABLE tuple_slot_def_t
  ADD CONSTRAINT tuple_slot_def_t4
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_slot_def_t5 on tuple_slot_def_t (
  realm_id
)
/
CREATE UNIQUE INDEX tuple_slot_def_t6 on tuple_slot_def_t (
  tuple_def_id,
  label
)
/
ALTER TABLE tuple_slot_def_t
  ADD CONSTRAINT tuple_slot_def_t7
  FOREIGN KEY (tuple_slot_type_id)
  REFERENCES tuple_slot_type_t(tuple_slot_type_id)
/
CREATE INDEX tuple_slot_def_t8 on tuple_slot_def_t (
  tuple_slot_type_id
)
/
ALTER TABLE tuple_slot_def_t
  ADD CONSTRAINT tuple_slot_def_t9
  CHECK (is_required BETWEEN 0 AND 1)
/

--
-- tuple_slot_type_t
--
ALTER TABLE tuple_slot_type_t
  ADD CONSTRAINT tuple_slot_type_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_slot_type_t3 on tuple_slot_type_t (
  realm_id
)
/
CREATE UNIQUE INDEX tuple_slot_type_t4 on tuple_slot_type_t (
  realm_id,
  label
)
/

--
-- tuple_use_t
--
ALTER TABLE tuple_use_t
  ADD CONSTRAINT tuple_use_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_use_t3 on tuple_use_t (
  realm_id
)
/
ALTER TABLE tuple_use_t
  ADD CONSTRAINT tuple_use_t4
  FOREIGN KEY (tuple_def_id)
  REFERENCES tuple_def_t(tuple_def_id)
/
CREATE INDEX tuple_use_t5 on tuple_use_t (
  tuple_def_id
)
/
CREATE UNIQUE INDEX tuple_use_t6 on tuple_use_t (
  realm_id,
  label
)
/
CREATE UNIQUE INDEX tuple_use_t7 on tuple_use_t (
  realm_id,
  moniker
)
/

CREATE SEQUENCE tuple_def_s
  MINVALUE 100006
  CACHE 1 INCREMENT BY 100000
/

CREATE SEQUENCE tuple_slot_type_s
  MINVALUE 100007
  CACHE 1 INCREMENT BY 100000
/

EOF
    return;
}

sub internal_upgrade_db_website {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE website_t (
  realm_id NUMERIC(18) NOT NULL,
  location NUMERIC(2) NOT NULL,
  url VARCHAR(255),
  CONSTRAINT website_t1 primary key(realm_id, location)
)
/
--
-- website_t
--
ALTER TABLE website_t
  ADD CONSTRAINT website_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX website_t3 on website_t (
  realm_id
)
/
EOF
    return;
}

sub realm_role_config {
    my($self) = @_;
    # Returns the realm role configuration.
    unless ($_REALM_ROLE_CONFIG) {
	# Cache so the command is idempotent.
	$_REALM_ROLE_CONFIG = [<DATA>];
	chomp(@$_REALM_ROLE_CONFIG);
	# Avoids error messages which point to <DATA>.
	close(DATA);
    }
    return $_REALM_ROLE_CONFIG;
}

sub reinitialize_constraints {
    my($self) = @_;
    # Applies constraint files and reinitializes sequences.

    foreach my $file (@{_ddl_files($self)}) {
        next unless $file =~ /constraints/;
  	$self->put(input => $file)->run;
    }
    return $self->reinitialize_sequences;
}

sub reinitialize_sequences {
    my($self) = @_;
    # Reinitializes all sequences in L<ddl_files|"ddl_files"> to be max value +
    # increment in table.
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

sub restore_model {
    my($self, $model, $file_or_rows) = @_;
    my($m) = Bivio::Biz::Model->new($self->get_request, $model);
    foreach my $r (ref($file_or_rows) ? @$file_or_rows : @{do($file_or_rows)}) {
	$m->create($r);
    }
    $self->print("Restored $model\n");
    return;
}

sub run {
    my($self, $sql) = @_;
    # Parses I<sql> (default: reads I<input>), terminating on errors.  Any query
    # results are thrown away.
    foreach my $s (_parse($self, $sql)) {
	Bivio::SQL::Connection->execute($s);
    }
    return;
}

sub run_command {
    my($self, $commands) = @_;
    # Runs command line interpreter (e.g. psql or sqlplus) on the current database.
    # I<commands> may be a string_ref.  Aborts on errors.
    #
    # Currently only supports postgres.
    my($c) = _assert_postgres($self);
    return $self->piped_exec(
	"psql --username '$c->{user}' --dbname '$c->{database}' 2>&1",
	# Ensures commit happens
	(ref($commands) ? $$commands : $commands)
	. ($self->unsafe_get('noexecute') ? "\n;rollback;\n" : "\n;commit;\n"),
    );
}

sub upgrade_db {
    my($self, $method) = @_;
    # Handles common setup for database upgrades.  Calls
    # L<internal_upgrade_db|"internal_upgrade_db">.
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

sub vacuum_db {
    my($self, @arg) = @_;
    # Runs I<vacuumdb> with I<args> with a lock.  Prints output using
    # L<Bivio::IO::Alert::print_literally|Bivio::IO::Alert/"print_literally">
    # so will appear in log when called by
    # L<vacuum_db_continuously|"vacuum_db_continuously">.
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

sub vacuum_db_continuously {
    my($self, $period_minutes) = @_;
    # Runs L<vacuum_db|"vacuum_db"> as a daemon.  You need to set the configuration
    # I<vacuum_db_continuously> in L<Bivio::ShellUtil|Bivio::ShellUtil>.
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

sub _assert_postgres {
    my($self) = @_;
    # Returns DBI config.  Asserts postgres is connection type.
    $self->setup;
    my($c) = Bivio::SQL::Connection->get_dbi_config;
    $self->usage_error($c->{connection}, ': connection type not supported')
	unless $c->{connection} =~ /postgres/i;
    return $c;
}

sub _ddl_files {
    my($self) = @_;
    # Initializes self and calls ddl_files(), checking result.
    $self->get_request;
    my($f) = $self->ddl_files;
    $self->usage('must be run in files/ddl directory')
	unless -r $f->[0];
    return $f;
}

sub _parse {
    my($self, $sql) = @_;
    # Parses input into SQL statements.  Dies if there as an extra statement.
    # If $sql not supplied, calls I<read_input>
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

1;

__DATA__
# The following is returned by realm_role_config().
#
# GENERAL Permissions
#
b-realm-role -realm GENERAL -user user edit ANONYMOUS - \
    +ANYBODY \
    +DATA_READ \
    +MAIL_POST \
    +MAIL_SEND
b-realm-role -realm GENERAL -user user edit USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role -realm GENERAL -user user edit WITHDRAWN - \
    +USER
b-realm-role -realm GENERAL -user user edit GUEST - \
    +WITHDRAWN
b-realm-role -realm GENERAL -user user edit MEMBER - \
    +GUEST \
    +DATA_WRITE
b-realm-role -realm GENERAL -user user edit ACCOUNTANT - \
    +MEMBER
b-realm-role -realm GENERAL -user user edit ADMINISTRATOR - \
    +ACCOUNTANT \
    +ADMIN_READ \
    +ADMIN_WRITE \
    +DATA_WRITE \
    +MAIL_READ \
    +MAIL_WRITE
b-realm-role -realm GENERAL -user user edit MAIL_RECIPIENT -
b-realm-role -realm GENERAL -user user edit FILE_WRITER - \
    +DATA_WRITE

#
# USER Permissions
#
b-realm-role -realm USER -user user edit ANONYMOUS - \
    +ANYBODY
b-realm-role -realm USER -user user edit USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role -realm USER -user user edit WITHDRAWN - \
    +USER
b-realm-role -realm USER -user user edit GUEST - \
    +WITHDRAWN
b-realm-role -realm USER -user user edit MEMBER - \
    +GUEST \
    +ADMIN_READ \
    +DATA_READ \
    +DATA_WRITE \
    +MAIL_POST \
    +MAIL_READ \
    +MAIL_SEND \
    +MAIL_WRITE
b-realm-role -realm USER -user user edit ACCOUNTANT - \
    +MEMBER \
    +ADMIN_WRITE
b-realm-role -realm USER -user user edit ADMINISTRATOR - \
    +ACCOUNTANT
b-realm-role -realm USER -user user edit MAIL_RECIPIENT -
b-realm-role -realm USER -user user edit FILE_WRITER - \
    +DATA_WRITE

#
# CLUB Permissions
#
b-realm-role -realm CLUB -user user edit ANONYMOUS - \
    +ANYBODY
b-realm-role -realm CLUB -user user edit USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role -realm CLUB -user user edit WITHDRAWN - \
    +USER
b-realm-role -realm CLUB -user user edit GUEST - \
    +WITHDRAWN
b-realm-role -realm CLUB -user user edit MEMBER - \
    +GUEST \
    +ADMIN_READ \
    +DATA_READ \
    +DATA_WRITE \
    +MAIL_POST \
    +MAIL_READ \
    +MAIL_SEND \
    +MAIL_WRITE
b-realm-role -realm CLUB -user user edit ACCOUNTANT - \
    +MEMBER \
    +ADMIN_WRITE
b-realm-role -realm CLUB -user user edit ADMINISTRATOR - \
    +ACCOUNTANT
b-realm-role -realm CLUB -user user edit MAIL_RECIPIENT -
b-realm-role -realm CLUB -user user edit FILE_WRITER - \
    +DATA_WRITE
