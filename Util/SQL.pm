# Copyright (c) 2001-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Util::SQL;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_REALM_ROLE_CONFIG);
Bivio::IO::Config->register(my $_CFG = {
    export_db_on_upgrade => 1,
});
my($_AR) = b_use('Auth.Realm');
my($_C) = b_use('SQL.Connection');
my($_DT) = b_use('Type.DateTime');
my($_E) = b_use('Type.Email');
my($_F) = b_use('IO.File');
my($_PI) = b_use('Type.PrimaryId');
my($_PS) = b_use('Auth.PermissionSet');
my($_R) = b_use('Auth.Role');
my($_RT) = b_use('Auth.RealmType');
my($_TI) = b_use('Agent.TaskId');
my($_D) = b_use('Bivio.Die');
#TODO: Need to remove some of these
my($_BUNDLE) = [qw(
    realm_mail
    realm_mail_bounce
    calendar_event
    email_alias
    job_lock
    tuple
    motion
    website
    realm_dag
    otp
    site_forum
    file_writer
    bulletin
    row_tag
    motion_vote_comment
    nonunique_email
    !permissions51
    crm_thread
    tuple_tag
    realm_file_lock
    crm_thread_lock_user_id
    !forum_features
    !forum_features_tuple_motion
    !group_concat
    !role_unused_11
    site_admin_forum
    !site_admin_forum_users
    !data_browse
    task_log
    !feature_task_log
    !feature_task_log2
    !tuple_thread_root_id_not_null
    !task_log_remove_foreign_keys
    !feature_group_admin
    !message_id_255
    !mail_want_reply_to
    !index_20091227
    !user_feature_calendar
    !mail_want_reply_to_default
)];
#    crm_mail
my($_AGGREGATES) = [qw(
    group_concat(text)
)];
my($_INITIALIZE_SENTINEL) = [grep(s/!//, @$_BUNDLE)];

sub TEST_PASSWORD {
    return b_use('ShellUtil.TestUser')->DEFAULT_PASSWORD;
}

sub USAGE {
    # Returns usage.
    return <<'EOF';
usage: b-sql [options] command [args...]
commands:
    column_exists table column - returns 1 if column exists in table
    create_db -- initializes database (must be run from ddl directory)
    create_test_db -- destroys, creates, and initializes test database
    destroy_db -- drops all the tables, indexes, and sequences created
    drop -- drops objects which would be created by running input
    destroy_dbms -- drops the database
    drop_and_run -- calls drop then run
    export_db dir -- exports database (only works for pg right now)
    import_db file -- imports database (ditto)
    import_tables_only file -- imports tables and sequences only
    init_dbms [clone_db] -- execute createuser and createdb optionally copying clone_db (only works for pg right now)
    reinitialize_constraints -- creates constraints
    reinitialize_sequences -- recreates to MAX(primary_id) (must be in ddl directory)
    restore_dbms_dump file-dump -- restore a "raw" dump
    run -- executes sql contained in input and dies on error
    tables - list tables of current database
    table_exists table - returns 1 if table exists
    upgrade_db -- upgrade the database
    vacuum_db [args] -- runs vacuumdb command (must be run as postgres)
    vacuum_db_continuously -- run vacuum_db as a daemon
EOF
}

sub add_permissions_to_realm_type {
    my($self, $realm_type, $permissions) = @_;
    $self->model('RealmOwner')->do_iterate(
	sub {
	    my($it) = @_;
	    $it->new_other('RealmRole')->add_permissions(
		$it,
		[$_R->get_non_zero_list],
		$permissions,
	    );
	    return 1;
	},
	'unauth_iterate_start',
	'realm_id',
	{realm_type => $realm_type},
    );
    return;
}

sub assert_ddl {
    my($self) = @_;
    $self->usage_error('must be run in ddl directory')
	unless $_F->pwd =~ m{/ddl$};
    return;
}

sub backup_model {
    my($self, $model, $order_by) = @_;
    $self->print(
	"$model written to ",
	$_F->write(
	    "$model-" . $_DT->local_now_as_file_name . '.pl',
	    $self->use('IO.Ref')->to_string(
		my $rows = $self->model($model)
		    ->map_iterate(undef, 'unauth_iterate_start', $order_by),
	    ),
	),
	"\n",
    );
    return $rows;
}

sub column_exists {
    my($self, $table, $column) = @_;
    return _exists(
        'FROM pg_attribute
        WHERE attname = ?
        AND attisdropped IS FALSE
        AND attrelid = (
            SELECT relfilenode
            FROM pg_class
            WHERE relname = ?
        )',
	[lc($column), lc($table)],
    );
}

sub create_db {
    my($self) = @_;
    # Initializes database.  Must be run from C<files/ddl> directory,
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
    # Subclasses should override L<initialize_test_data|"initialize_test_data">
    # to create the test data.
    $self->initialize_fully;
    my($req) = $self->get_request;
    die('cannot be run on production system')
	if $req->is_production;
    my($ddl_dir) = $self->get_project_root . '/files/ddl';
    $_F->do_in_dir(-d $ddl_dir ? $ddl_dir : '.', sub {
        $self->destroy_db;
        $self->create_db;
        $self->delete_realm_files;
        $self->initialize_test_data;
    });
    return;
}

sub create_test_user {
    return shift->new_other('TestUser')->create(@_);
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
    my($self) = @_;
    $_F->rm_children(
	$self->use('UI.Facade')->get_local_file_name(
	    $self->use('UI.LocalFileType')->REALM_DATA, ''));
    return;
}

sub destroy_db {
    my($self) = @_;
    # Undoes the operations of L<create_db|"create_db">.
    $self->usage_error('You cannot destroy a production database.')
	if $self->get_request->is_production;
    $self->are_you_sure('DROP THE ENTIRE '
	. $_C->get_dbi_config->{database}
	. ' DATABASE?');
    # We drop in opposite order.  Some constraint drops will
    # fail, but that's ok.  We need to drop the FOREIGN KEY
    # constraints so we can drop the tables.
    foreach my $file (reverse(@{_ddl_files($self)})) {
	$self->print('Dropping ', $file, "\n");
	$self->put(input => $file);
	$self->drop;
    }
    foreach my $agg (@$_AGGREGATES) {
	$_D->catch_quietly(sub {$self->run("DROP AGGREGATE $agg\n/\n");});
	$_C->commit;
    }
    $self->use('Biz.File')->destroy_db;
    return;
}

sub destroy_dbms {
    my($self) = @_;
    $self->usage_error('You cannot destroy a production database.')
	if $self->get_request->is_production;
    my($db) = $_C->get_dbi_config->{database};
    $self->are_you_sure("DROP THE ENTIRE $db DATABASE?");
    $self->piped_exec("dropdb --user=postgres $db", '', 1);
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
	$_D->catch_quietly(sub {
	    $_C->execute(
		$p . 'drop ' . $s . ($s =~ /^table/i ? ' CASCADE' : ''));
	    return;
	});
	$_C->commit;
    }
    return;
}

sub drop_and_run {
    my($self, $sql) = @_;
    $self->drop($sql);
    return $self->run($sql);
}

sub drop_object {
    my($self, $type, @table) = @_;
    foreach my $t (@table) {
	$_D->catch_quietly(sub {$self->run("DROP $type $t\n/\n");});
    }
    return;
}

sub export_db {
    my($self, $dir) = @_;
    my($db) = _assert_postgres($self);
    my($f) = ($dir || '.')
	. '/'
	. $_DT->local_now_as_file_name
	. '-'
	. $db->{database}
	. '.pg_dump';
    $self->piped_exec(
	"pg_dump --user='$db->{user}' --clean --format=c --blobs "
	. " --file='$f' '$db->{database}'");
    return "Exported $db->{database} to $f";
}

sub format_test_email {
    return shift->new_other('TestUser')->format_email(@_);
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
    $_C->commit;

    $self->piped_exec("pg_restore --user='$db->{user}'"
	. " --dbname='$db->{database}' --data-only '$backup_file'");

    $_C->ping_connection;
    return;
}

sub init_dbms {
    my($self, $clone_db) = @_;
    $self->req;
    my($c) = _assert_postgres($self);
    my($db, $user, $pass) = @$c{qw(database user password)};
    my($v) = ${$self->piped_exec("psql --version")} =~ /(\d+)/s;
    my($res) = '';
    _init_template1($self)
	if $v >= 8;
    unless (_user_exists($self)) {
	$self->piped_exec(
	    'createuser --user=postgres'
	    . ($v < 8 ? ' --no-adduser'
		 : ' --no-superuser --no-createdb --no-createrole')
	    . " $user");
	_run_other($self, template1 => "ALTER USER $user WITH PASSWORD '$pass'");
	$res .= " user '$user' and";
    }
    $self->piped_exec(
	'createdb --user=postgres'
	. (defined($clone_db) ? " --template=$clone_db " : '')
	. ($v < 8 ? '' : ' --encoding=SQL_ASCII')
	. " --owner=$user $db",
    );
    $res .= " database '$db'";
    if ($self->table_exists('spatial_ref_sys')) {
	_init_postgis($self, $c);
	$res .= ' with PostGIS';
    }
    return "created$res"
	. (defined($clone_db) ? " copied from '$clone_db'" : '');
}

sub init_realm_role {
    my($self) = @_;
    $self->init_realm_role_with_config($self->realm_role_config);
    $self->internal_upgrade_db_user_feature_calendar;
    $self->req->with_realm(club => sub {
        $self->model('RealmFeatureForm')->process({force_default_values => 1});
	return;
    });
    $self->init_realm_role_forum
	if $_RT->unsafe_from_name('FORUM');
    $self->init_realm_role_calendar_event
	if $_RT->unsafe_from_name('CALENDAR_EVENT');
    $self->init_realm_role_copy_anonymous_permissions;
    return;
}

sub init_realm_role_calendar_event {
    my($self) = @_;
    $self->new_other('RealmRole')->copy_all(forum => 'calendar_event');
    return;
}

sub init_realm_role_copy_anonymous_permissions {
    my($self) = @_;
    $_AR->do_default(sub {
	my($r) = @_;
	my($rr) = $self->model('RealmRole');
	return unless
	    defined(my $anon = $rr->get_permission_map($r)->{$_R->ANONYMOUS});
	$_PS->clear(\$anon, ['ANYBODY']);
        foreach my $role (grep(
	    !$self->internal_role_is_initialized($_),
	    $_R->get_non_zero_list,
	)) {
	    unless ($rr->unsafe_load({role => $role})) {
		$rr->create({
		    realm_id => $self->req('auth_id'),
		    role => $role,
		    permission_set => $anon,
		});
	    }
	}
        return 1;
    }, $self->req);
    return;
}

sub init_realm_role_forum {
    my($self) = @_;
    my($rr) = $self->new_other('RealmRole');
    $rr->copy_all(club => 'forum');
    $rr->main(qw(-realm FORUM -user user edit MEMBER -ADMIN_READ -DATA_WRITE));
    return;
}

sub init_realm_role_with_config {
    my($self, $config) = @_;
    my($rr) = $self->new_other('RealmRole');
    my($cmd);
    foreach my $line (ref($config) ? @$config : split(/\n/, $config)) {
	next if $line =~ /^\s*(#|$)/;
	$cmd .= $line;
	next if $cmd =~ s/\\$/ /;
	my($args) = [split(' ', $cmd)];
	shift(@$args);
	$rr->main(@$args);
        $cmd = '';
    }
    return;
}

sub initialize_db {
    my($self) = @_;
    $self->internal_upgrade_db_group_concat;
    $self->model('RealmOwner')->init_db;
    $self->init_realm_role;
#TODO: Needs to be after subclasses init_realm_role for new realmtypes
    foreach my $x (
	[qw(FORUM_TUPLE_SLOT_TYPE_LIST initialize_tuple_permissions initialize_tuple_slot_types)],
	[qw(GROUP_TASK_LOG initialize_task_log_permissions)],
	[qw(FORUM_MOTION_LIST initialize_motion_permissions)],
    ) {
	next
	    unless $_TI->unsafe_from_name(shift(@$x));
	map($self->$_(), @$x);
    }
    foreach my $x (@$_INITIALIZE_SENTINEL) {
	_default_sentinel($self, $x);
    }
    return;
}

sub initialize_motion_permissions {
    return _enable_group_category(shift, 'open_results_motion');
}

sub initialize_task_log_permissions {
    return _enable_group_category(shift, 'feature_task_log');
}

sub initialize_test_data {
    # Initializes test data.  A hook for the subclasses.
    return;
}

sub initialize_tuple_permissions {
    return _enable_group_category(shift, 'feature_tuple');
}

sub initialize_tuple_slot_types {
    my($self) = @_;
    # Creates default TupleSlotType enteries in general realm.
    my($req) = $self->get_request;
    my($prev) = $req->get('auth_realm');
    $req->set_realm(undef);
    $self->model('TupleSlotType')->create_from_hash({
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

sub internal_db_upgrade_bulletin {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE bulletin_t (
  bulletin_id NUMERIC(18) NOT NULL,
  date_time DATE NOT NULL,
  subject VARCHAR(100) NOT NULL,
  body TEXT64K NOT NULL,
  body_content_type VARCHAR(100) NOT NULL,
  CONSTRAINT bulletin_t1 PRIMARY KEY(bulletin_id)
)
/
CREATE SEQUENCE bulletin_s
  MINVALUE 100016
  CACHE 1 INCREMENT BY 100000
/
EOF
    return;
}

sub internal_upgrade_db_user_feature_calendar {
    my($self) = @_;
    $self->req->with_realm(user => sub {
	$self->new_other('RealmRole')->edit_categories('+feature_calendar');
        return;
    });
    return;
}

sub internal_role_is_initialized {
    my($self, $role) = @_;
    return $role->eq_anonymous;
}

sub internal_upgrade_db_task_log_remove_foreign_keys {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE task_log_t
    DROP CONSTRAINT task_log_t2
/
ALTER TABLE task_log_t
    DROP CONSTRAINT task_log_t4
/
EOF
    return;
}

sub internal_upgrade_db_bundle {
    my($self) = @_;
    _assert_postgres($self);
    $self->initialize_ui;
    my($tables) = {map(($_ => 1), @{$self->tables})};
    foreach my $type (@$_BUNDLE) {
	my($sentinel) = \&{"_sentinel_$type"};
	next
	    if defined(&$sentinel) ? $sentinel->($self, $type)
	    : ($tables->{"${type}_t"} || _default_sentinel($self, $type));
	$self->print("Running: $type\n");
	my($m) = "internal_upgrade_db_$type";
	$self->$m;
    }
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
    $self->model('RealmOwner')
        ->init_realm_type($_RT->CALENDAR_EVENT);
    $self->new_other('RealmRole')->copy_all(forum => 'calendar_event');
    return;
}

sub internal_upgrade_db_crm_mail {
    my($self) = @_;
$self->run(<<'EOF');
ALTER TABLE crm_thread_t
  DROP CONSTRAINT crm_thread_t6
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t6
  FOREIGN KEY (thread_root_id)
  REFERENCES realm_mail_t(realm_file_id)
/
EOF
    return;
}

sub internal_upgrade_db_crm_thread {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE crm_thread_t (
  realm_id NUMERIC(18) NOT NULL,
  crm_thread_num NUMERIC(9) NOT NULL,
  modified_date_time DATE NOT NULL,
  modified_by_user_id NUMERIC(18),
  thread_root_id NUMERIC(18) NOT NULL,
  crm_thread_status NUMERIC(2) NOT NULL,
  subject VARCHAR(100) NOT NULL,
  subject_lc VARCHAR(100) NOT NULL,
  owner_user_id NUMERIC(18),
  CONSTRAINT crm_thread_t1 PRIMARY KEY(realm_id, crm_thread_num)
)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX crm_thread_t3 ON crm_thread_t (
  realm_id
)
/
CREATE INDEX crm_thread_t4 ON crm_thread_t (
  modified_date_time
)
/
CREATE INDEX crm_thread_t5 ON crm_thread_t (
  thread_root_id
)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t6
  FOREIGN KEY (thread_root_id)
  REFERENCES realm_file_t(realm_file_id)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t7
  CHECK (crm_thread_status > 0)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t8
  FOREIGN KEY (owner_user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX crm_thread_t9 ON crm_thread_t (
  owner_user_id
)
/
CREATE INDEX crm_thread_t10 ON crm_thread_t (
  subject_lc
)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t11
  FOREIGN KEY (modified_by_user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX crm_thread_t12 ON crm_thread_t (
  modified_by_user_id
)
/
EOF
    return;
}

sub internal_upgrade_db_crm_thread_lock_user_id {
    my($self) = @_;
    $self->run(<<'EOF');
DROP INDEX crm_thread_t5
/
CREATE UNIQUE INDEX crm_thread_t5 ON crm_thread_t (
  thread_root_id
)
/
ALTER TABLE crm_thread_t
  ADD COLUMN lock_user_id NUMERIC(18)
/
ALTER TABLE crm_thread_t
  ADD COLUMN customer_realm_id NUMERIC(18)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t13
  FOREIGN KEY (lock_user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX crm_thread_t14 ON crm_thread_t (
  lock_user_id
)
/
ALTER TABLE crm_thread_t
  ADD CONSTRAINT crm_thread_t15
  FOREIGN KEY (customer_realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX crm_thread_t16 ON crm_thread_t (
  customer_realm_id
)
/
EOF
    return;
}

sub internal_upgrade_db_data_browse {
    my($self) = @_;
    $self->model('RealmRole')->do_iterate(
	sub {
	    my($it) = @_;
	    my($ps) = $it->get('permission_set');
	    $_PS->set(\$ps, 'DATA_BROWSE')
		if $_PS->is_set(\$ps, 'DATA_WRITE');
	    $it->update({permission_set => $ps});
	    return 1;
	},
	'unauth_iterate_start',
	'realm_id',
    );
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

sub internal_upgrade_db_feature_group_admin {
    my($self) = @_;
    _add_permissions_to_all_forums($self, ['FEATURE_GROUP_ADMIN']);
    return;
}

sub internal_upgrade_db_feature_task_log {
    my($self) = @_;
    $self->initialize_task_log_permissions;
    return;
}

sub internal_upgrade_db_feature_task_log2 {
    my($self) = @_;
    _add_permissions_to_all_forums($self, ['FEATURE_TASK_LOG']);
    return;
}

sub internal_upgrade_db_forum_features {
    my($self) = @_;
    _add_permissions_to_all_forums($self, [qw(
	FEATURE_BLOG
	FEATURE_CALENDAR
	FEATURE_DAV
	FEATURE_FILE
	FEATURE_MAIL
	FEATURE_WIKI
    )]);
}

sub internal_upgrade_db_forum_features_tuple_motion {
    my($self) = @_;
    $self->model('RealmOwner')->do_iterate(
	sub {
	    my($it) = @_;
	    my($rr) = $it->new_other('RealmRole');
	    my($ps) = $rr->get_permission_map($it)->{$_R->ADMINISTRATOR};
	    my($perms) = [];
	    foreach my $x (qw(TUPLE MOTION)) {
		push(@$perms, "FEATURE_$x")
		    if $_PS->is_set($ps, $x . '_ADMIN');
	    }
	    $it->new_other('RealmRole')->add_permissions(
		$it,
		[$_R->get_non_zero_list],
		$perms,
	    ) if @$perms;
	    return 1;
	},
	'unauth_iterate_start',
	'realm_id',
	{realm_type => $_RT->FORUM},
    );
    return;
}

sub internal_upgrade_db_file_writer {
    my($self) = @_;
    my($req) = $self->initialize_ui;
    $self->model('RealmUser')->do_iterate(
	sub {
	    my($it) = @_;
            return 1 if $it->get('realm_id')
                eq $_RT->GENERAL->as_int;
	    $it->new->create({
		%{$it->get_shallow_copy},
		role => $_R->FILE_WRITER,
	    });
	    return 1;
	},
	unauth_iterate_start => 'user_id',
	{role => $_R->ADMINISTRATOR},
    );
    my($p) = ${$_PS->from_array(['DATA_WRITE'])};
    $self->model('RealmRole')->do_iterate(
	sub {
	    my($it) = @_;
	    my($rid) = $it->get('realm_id');
	    $it->update({
		permission_set => ($it->get('permission_set') & ~$p),
	    }) if $it->new_other('RealmOwner')
		->unauth_load_or_die({realm_id => $rid})
		->get('realm_type')->eq_forum;
	    $it->new->unauth_create_or_update({
		realm_id => $rid,
		role => $_R->FILE_WRITER,
		permission_set => $p,
	    });
	    return 1;
	},
	unauth_iterate_start => 'realm_id',
	{role => $_R->MEMBER},
    );
    return;
}

sub internal_upgrade_db_group_concat {
    my($self) = @_;
    if (b_use('ShellUtil.SQL')->is_oracle) {
        $self->run(<<'EOF');
CREATE OR REPLACE TYPE t_string_list
    AS TABLE OF VARCHAR2(4000)
/
CREATE OR REPLACE FUNCTION group_concat
   (lst IN t_string_list)
   RETURN  VARCHAR2 IS
   ret VARCHAR2(4000);
BEGIN
   FOR j IN 1..lst.last  LOOP
      ret := ret || lst(j) || ',';
   END LOOP;
   RETURN ret;
END;
/
EOF
    }
    else {
	$self->run(<<'EOF');
CREATE OR REPLACE FUNCTION _group_concat(text, text)
RETURNS text AS '
SELECT CASE
WHEN $2 IS NULL THEN $1
WHEN $1 IS NULL THEN $2
ELSE $1 operator(pg_catalog.||) '','' operator(pg_catalog.||) $2
END
' IMMUTABLE LANGUAGE SQL
/
CREATE AGGREGATE group_concat (
BASETYPE = text,
SFUNC = _group_concat,
STYPE = text
)
/
EOF
    }
    return;
}

sub internal_upgrade_db_index_20091227 {
    my($self) = @_;
$self->run(<<'EOF');
CREATE INDEX task_log_t6 ON task_log_t (
  super_user_id
)
/
CREATE INDEX task_log_t7 ON task_log_t (
  date_time
)
/
CREATE INDEX row_tag_t2 ON row_tag_t (
  value
)
/
EOF
    return;
}

sub internal_upgrade_db_job_lock {
    my($self) = @_;
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

sub internal_upgrade_db_mail_want_reply_to {
    my($self) = @_;
    $_C->do_execute_rows(sub {
        my($row) = @_;
        $self->model('RowTag')->replace_value(
	    $row->{forum_id}, MAIL_WANT_REPLY_TO => 1
	) if $row->{want_reply_to};
	return 1;
    }, 'SELECT forum_id, want_reply_to FROM forum_t');
    $self->run(<<'EOF');
ALTER TABLE forum_t
  DROP COLUMN want_reply_to
/
ALTER TABLE forum_t
  DROP COLUMN is_public_email
/
EOF
    return;
}

sub internal_upgrade_db_mail_want_reply_to_default {
    my($self) = @_;
    my($map) = {@{$self->model('RowTag')->map_iterate(
	sub {shift->get(qw(primary_id value))},
	'unauth_iterate_start',
	'primary_id',
	{key => b_use('Type.RowTagKey')->MAIL_WANT_REPLY_TO},
    )}};
    $self->model('Forum')->do_iterate(
	sub {
	    my($fid) = shift->get('forum_id');
	    b_use('Type.MailWantReplyTo')->row_tag_replace(
		$fid,
		$map->{$fid} || 0,
		$self->req,
	    );
	    return 1;
	},
	'unauth_iterate_start',
	'forum_id',
    );
    return;
}

sub internal_upgrade_db_message_id_255 {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE realm_mail_t
  ALTER COLUMN message_id
  TYPE VARCHAR(255)
/
EOF
    return;
}

sub internal_upgrade_db_nonunique_email {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE nonunique_email_t (
  realm_id NUMERIC(18) NOT NULL,
  location NUMERIC(2) NOT NULL,
  email VARCHAR(100),
  CONSTRAINT nonunique_email_t1 PRIMARY KEY(realm_id, location)
)
/
ALTER TABLE nonunique_email_t
  ADD CONSTRAINT nonunique_email_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX nonunique_email_t3 ON nonunique_email_t (
  realm_id
)
/
CREATE INDEX nonunique_email_t5 ON nonunique_email_t (
  email
)
/
EOF
    return;
}

sub internal_upgrade_db_realm_mail {
    my($self) = @_;
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
    return;
}

sub internal_upgrade_db_realm_mail_bounce {
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

sub internal_upgrade_db_motion_vote_comment {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE motion_vote_t
    ADD COLUMN comment VARCHAR(500)
/
EOF
    return;
}

sub internal_upgrade_db_otp {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE forum_t ADD COLUMN require_otp NUMERIC(1)
/
UPDATE forum_t SET require_otp = 0
/
ALTER TABLE forum_t ALTER COLUMN require_otp SET NOT NULL
/
ALTER TABLE forum_t
  ADD CONSTRAINT forum_t6
  CHECK (require_otp BETWEEN 0 AND 1)
/
CREATE TABLE otp_t (
  user_id NUMERIC(18) NOT NULL,
  otp_md5 VARCHAR(16) NOT NULL,
  seed VARCHAR(8) NOT NULL,
  sequence NUMERIC(3) NOT NULL,
  last_login DATE NOT NULL,
  CONSTRAINT otp_t1 primary key(user_id)
)
/
ALTER TABLE otp_t
  ADD CONSTRAINT otp_t2
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX otp_t3 ON otp_t (
  user_id
)
/
EOF
    return;
}

sub internal_upgrade_db_permissions51 {
    my($self) = @_;
    my($ap) = $self->use('Auth.Permission');
    my($aps) = $self->use('Auth.PermissionSet');
    $self->model('RealmRole')->do_iterate(
	sub {
	    my($it) = @_;
	    my($ps) = $it->get('permission_set');
	    my($write);
	    foreach my $bit (reverse(21 .. 69)) {
		next unless vec($ps, $bit, 1);
		vec($ps, $bit, 1) = 0;
		vec($ps, $bit + 30, 1) = 1;
		$write++;
	    }
	    foreach my $name (qw(MOTION TUPLE)) {
		next unless $aps->is_set(\$ps, $ap->from_name($name . '_READ'));
		$aps->set(\$ps, $ap->from_name('FEATURE_' . $name));
		$write++;
	    }
	    $it->update({permission_set => $ps})
		if $write;
	    return 1;
	},
	'unauth_iterate_start',
	'realm_id',
    );
    return;
}

sub internal_upgrade_db_realm_dag {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE realm_dag_t (
  parent_id NUMERIC(18) NOT NULL,
  child_id NUMERIC(18) NOT NULL,
  realm_dag_type NUMERIC(2) NOT NULL,
  constraint realm_dag_t1 primary key (parent_id, child_id, realm_dag_type)
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

sub internal_upgrade_db_realm_file_lock {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE SEQUENCE realm_file_lock_s
  MINVALUE 100009
  CACHE 1 INCREMENT BY 100000
/
CREATE TABLE realm_file_lock_t (
  realm_file_lock_id NUMERIC(18),
  realm_file_id NUMERIC(18) NOT NULL,
  modified_date_time DATE NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18) NOT NULL,
  comment VARCHAR(500),
  CONSTRAINT realm_file_lock_t1 PRIMARY KEY(realm_file_lock_id)
)
/
ALTER TABLE realm_file_lock_t
  ADD CONSTRAINT realm_file_lock_t2
  FOREIGN KEY (realm_file_id)
  REFERENCES realm_file_t(realm_file_id)
/
CREATE INDEX realm_file_lock_t3 ON realm_file_lock_t (
  realm_file_id
)
/
ALTER TABLE realm_file_lock_t
  ADD CONSTRAINT realm_file_lock_t4
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_file_lock_t5 ON realm_file_lock_t (
  realm_id
)
/
ALTER TABLE realm_file_lock_t
  ADD CONSTRAINT realm_file_lock_t6
  FOREIGN KEY (user_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX realm_file_lock_t7 ON realm_file_lock_t (
  user_id
)
/
EOF
    return;
}

sub internal_upgrade_db_role_unused_11 {
    my($self) = @_;
    $self->run(<<'EOF');
DELETE FROM realm_user_t
   WHERE role = 11
/
DELETE FROM realm_role_t
   WHERE role = 11
/
EOF
    return;
}

sub internal_upgrade_db_row_tag {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE row_tag_t (
  primary_id NUMERIC(18) NOT NULL,
  key NUMERIC(3) NOT NULL,
  value VARCHAR(500) NOT NULL,
  CONSTRAINT row_tag_t1 primary key(primary_id, key)
)
/
EOF
    return;
}

sub internal_upgrade_db_site_admin_forum {
    my($self) = @_;
    $self->initialize_fully;
    my($f) = $self->req('Bivio::UI::Facade')->get_default;
    $self->req->with_realm($f->SITE_REALM_NAME, sub {
	$self->set_user_to_any_online_admin;
	$self->new_other('RealmRole')->edit_categories('-feature_site_admin');
        $self->model('ForumForm', {
	   'RealmOwner.display_name' => 'User Admin',
	   'RealmOwner.name' => $f->SITE_ADMIN_REALM_NAME,
	   mail_want_reply_to => 0,
	   mail_send_access => b_use('Type.MailSendAccess')->EVERYBODY,
	});
	$self->new_other('RealmRole')->edit_categories('+feature_site_admin');
	return;
    });
    return;
}

sub internal_upgrade_db_site_admin_forum_users {
    my($self) = @_;
    $self->initialize_fully;
    my($f) = $self->req('Bivio::UI::Facade')->get_default;
    $self->req->with_realm($f->SITE_REALM_NAME, sub {
	b_info("Adding users to site-admin");
	my($users) = {
	    @{$self->model('SiteAdminUserList')->map_iterate(
		sub {(shift->get('User.user_id') => [$_R->USER])},
	    )},
	    @{$self->model('GroupUserList')->map_iterate(
		sub {return shift->get(qw(RealmUser.user_id roles))},
	    )},
	};
	$self->req->set_realm($f->SITE_ADMIN_REALM_NAME);
	while (my($uid, $roles) = each(%$users)) {
	    foreach my $role (@$roles) {
		$self->model('RealmUser')->create_or_update({
		    role => $role,
		    user_id => $uid,
		});
	    }
	}
	return;
    });
    return;
}

sub internal_upgrade_db_site_forum {
    my($self) = @_;
    $self->initialize_fully;
    my($req) = $self->req;
    $req->with_realm(undef, sub {
	$req->with_user($self->model('RealmUser')->get_any_online_admin, sub {
	    $self->new_other('SiteForum')->init;
	});
	return;
    });
    return;
}

sub internal_upgrade_db_task_log {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE task_log_t (
  task_log_id NUMERIC(18) NOT NULL,
  realm_id NUMERIC(18) NOT NULL,
  user_id NUMERIC(18),
  super_user_id NUMERIC(18),
  date_time DATE NOT NULL,
  task_id NUMERIC(9) NOT NULL,
  method VARCHAR(30),
  uri VARCHAR(500) NOT NULL,
  CONSTRAINT task_log_t1 primary key (task_log_id)
)
/
ALTER TABLE task_log_t
  ADD CONSTRAINT task_log_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX task_log_t3 ON task_log_t (
  realm_id
)
/
ALTER TABLE task_log_t
  ADD CONSTRAINT task_log_t4
  FOREIGN KEY (user_id)
  REFERENCES user_t(user_id)
/
CREATE INDEX task_log_t5 ON task_log_t (
  user_id
)
/
CREATE SEQUENCE task_log_s
  MINVALUE 100010
  CACHE 1 INCREMENT BY 100000
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
  thread_root_id NUMERIC(18) NOT NULL,
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

sub internal_upgrade_db_tuple_tag {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE tuple_tag_t  (
  realm_id NUMERIC(18) NOT NULL,
  tuple_def_id NUMERIC(18) NOT NULL,
  primary_id NUMERIC(18) NOT NULL,
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
  CONSTRAINT tuple_tag_t1 PRIMARY KEY(realm_id, tuple_def_id, primary_id)
)
/
--
-- tuple_tag_t
--
ALTER TABLE tuple_tag_t
  ADD CONSTRAINT tuple_tag_t2
  FOREIGN KEY (realm_id)
  REFERENCES realm_owner_t(realm_id)
/
CREATE INDEX tuple_tag_t3 on tuple_tag_t (
  realm_id
)
/
ALTER TABLE tuple_tag_t
  ADD CONSTRAINT tuple_tag_t4
  FOREIGN KEY (tuple_def_id)
  REFERENCES tuple_def_t(tuple_def_id)
/
CREATE INDEX tuple_tag_t5 on tuple_tag_t (
  tuple_def_id
)
/
CREATE INDEX tuple_tag_t6 on tuple_tag_t (
  primary_id
)
/
ALTER TABLE tuple_tag_t
  ADD CONSTRAINT tuple_tag_t7
  FOREIGN KEY (realm_id, tuple_def_id)
  REFERENCES tuple_use_t(realm_id, tuple_def_id)
/
CREATE INDEX tuple_tag_t8 on tuple_tag_t (
  realm_id,
  tuple_def_id
)
/
EOF
    return;
}

sub internal_upgrade_db_tuple_thread_root_id_not_null {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE tuple_t
    ALTER COLUMN thread_root_id SET NOT NULL
/
EOF
    return;
}

sub is_oracle {
    my($self) = @_;
    # May not have a database at this point to connect to.
    return b_use('SQL.Connection')->get_dbi_config->{connection} =~ /oracle/i
	? 1 : 0;
}

sub realm_role_config {
    my($proto) = @_;
    return $_REALM_ROLE_CONFIG ||= [
	map(split(/\n/, $_),
	    __PACKAGE__->internal_data_section,
	    $proto->can('internal_realm_role_config_data')
		? $proto->internal_realm_role_config_data : (),
	),
    ];
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
                    ${$_F->read($_)}));
	} @{$self->ddl_files})
    ) {
	$cmd =~ s,/.*,,s;
	my($base) = $cmd =~ /sequence\s+(\w+)_s/si
	    or die('bad sequence name: ', $cmd);
	my($max) = $_C->execute_one_row(
	    "select max(${base}_id) from ${base}_t");
	next unless $max && $max->[0];
	my($inc) = $cmd =~ /increment\s+by\s+(\d+)/si
	    or die('bad sequence increment by: ', $cmd);
	# Increment by two to be sure
	$inc = $_PI->add($max->[0], $_PI->mul($inc, 2, 0), 0);
	# Number puts in '+'
	$inc =~ s/\D//g;
	$cmd =~ s/minvalue\s+(\d+)/minvalue $inc/i
	    or die('bad minvalue: ', $cmd);
	$res .= "${base}_s => $inc\n";
	next if $self->unsafe_get('noexecute');
	$_C->execute("drop sequence ${base}_s");
	$_C->execute($cmd);
    }
    return $res;
}

sub restore_dbms_dump {
    my($self, $dump) = @_;
    $self->destroy_dbms;
    $self->commit_or_rollback;
    $self->init_dbms;
    $self->commit_or_rollback;
    my($db, $u) = @{$_C->get_dbi_config}{qw(database user)};
    return ${$self->piped_exec("pg_restore --dbname='$db' -U '$u' '$dump'")};
}

sub restore_model {
    my($self, $model, $file_or_rows) = @_;
    my($m) = $self->model($model);
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
	$_C->execute($s);
    }
    return;
}

sub table_exists {
    my(undef, $table) = @_;
    # Different from tables(), which is checking owner
    _exists(
        'FROM pg_tables
        WHERE tablename = ?',
	[lc($table)],
    );
}

sub tables {
    return $_C->map_execute(
	'SELECT tablename
        FROM pg_tables
        WHERE tableowner = ?
        ORDER by tablename',
	[shift->use('Ext.DBI')->get_config->{user}],
    );
}

sub upgrade_db {
    my($self, $type) = @_;
    my($req) = $self->req;
    my($method) = $type ? "internal_upgrade_db_$type" : 'internal_upgrade_db';
    my($upgrade) = $self->model('DbUpgrade');
    my($v) = $type ? ($type eq 'bundle' ? $VERSION : '') . $type
	: $self->package_version;
    $self->usage_error(
	$v,
	': ran on ',
	$_DT->to_local_string($upgrade->get('run_date_time')),
    ) if $upgrade->unauth_load({version => $v});
    $self->are_you_sure(
	qq{Upgrade the database@{[$type ? " with $type" : '']}?});
    $self->print($self->export_db . "\n")
	if $_CFG->{export_db_on_upgrade};
    # After an export, you need to rollback or there will be errors.
    $_D->eval(sub {$_C->rollback});
    # re-establish connection
    $_C->ping_connection;
    $self->$method();
    $upgrade->create({
	version => $v,
	run_date_time => $upgrade->get_field_type('run_date_time')->now,
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
        $self->use('IO.Alert')->print_literally(${
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
	        : ("--user=$c->{user}", "--dbname=$c->{database}"),
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
    my($c) = $_C->get_dbi_config;
    $self->usage_error($c->{connection}, ': connection type not supported')
	unless $c->{connection} =~ /postgres/i;
    return $c;
}

sub _ddl_files {
    my($self) = @_;
    # Initializes self and calls ddl_files(), checking result.
    $self->get_request;
    $self->assert_ddl;
    my($f) = $self->ddl_files;
    # Some files should exist; Need more than just bOP
    $self->usage('no DDL files found in ', $_F->pwd)
	unless grep(-f $_, @$f);
    # Just write the files every time
    $self->use('SQL.DDL')->write_files;
    return $f;
}

sub _default_sentinel {
    my($self, $feature) = @_;
    my($u) = $self->model('DbUpgrade');
    return 1
	if $u->unauth_load({version => $feature});
    $u->create({
	version => $feature,
	run_date_time => $u->get_field_type('run_date_time')->now,
    });
    return 0;
}

sub _enable_group_category {
    my($self, $category) = @_;
    my($req) = $self->get_request;
    my($rr) = $self->new_other('RealmRole');
    $_AR->do_any_group_default(sub {
        $rr->edit_categories("+$category");
	return 1;
    }, $req);
    return;
}


#TODO: This should be groups, but need to check RealmRole has changed
sub _add_permissions_to_all_forums {
    return shift->add_permissions_to_realm_type($_RT->FORUM, @_);
}

sub _exists {
    return $_C->execute_one_row(
	'SELECT COUNT(*) ' . shift(@_),
	@_,
    )->[0] ? 1 : 0;
}

sub _init_postgis {
    my($self, $c) = @_;
    foreach my $sql (
	map((
	    "ALTER TABLE $_ OWNER TO $c->{user}",
	    "GRANT ALL ON $_ to $c->{user}",
	), qw(geometry_columns spatial_ref_sys)),
    ) {
	_run_other($self, dbms => $sql);
    }
    return;
}

sub _init_template1 {
    my($self) = @_;
    return if @{_run_other(
	$self,
	template1 => 'select lanname from pg_language where lanname = ?',
	['plpgsql'],
    )};
    $self->piped_exec('createlang --user=postgres plpgsql template1');
    foreach my $dir (qw(/usr/share/pgsql/contrib /usr/local/share)) {
	next unless -d $dir;
	$_F->do_in_dir($dir, sub {
	    foreach my $file (qw(lwpostgis.sql spatial_ref_sys.sql)) {
		last unless -f $file;
		$self->piped_exec(
		    "psql --user=postgres --dbname=template1 --file=$file");
	    }
	    return;
	});
	last;
    }
    return;
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

sub _run_other {
    my($self) = shift;
    my($c) = $_C->get_instance(shift);
    my($res) = $c->map_execute(@_);
    $self->commit_or_rollback;
    $c->disconnect;
    return $res;
}

sub _sentinel_crm_thread_lock_user_id {
    return shift->column_exists(qw(crm_thread_t lock_user_id));
}

sub _sentinel_file_writer {
    my($self) = @_;
    # Don't add it unless FILE_WRITER is a role in this app
    return 1
	unless $self->use('Auth.Role')->unsafe_from_name('FILE_WRITER');
    my($ok) = 0;
    $self->model('RealmRole')->do_iterate(
	sub {
	    $ok = 1;
	    return 0;
	},
	'unauth_iterate_start',
	'realm_id',
	{role => $_R->FILE_WRITER},
    );
    return $ok;
}

sub _sentinel_motion_vote_comment {
    return shift->column_exists(qw(motion_vote_t comment));
}

sub _sentinel_permissions51 {
    my($self) = @_;
    # Don't upgrade unless FEATURE_PERMISSIONS51 is a role in this app
    return 1
	unless $self->use('Auth.Permission')
	->unsafe_from_name('FEATURE_PERMISSIONS51');
    return _default_sentinel($self, 'permissions51');
}

sub _sentinel_site_admin_forum {
    my($self, $type) = @_;
    $self->initialize_fully;
    my($f) = $self->req('Bivio::UI::Facade')->get_default;
    return 1
	unless $self->model('RealmOwner')->unauth_load({name => 'site'});
    (my $forum = $type) =~ s/_forum$//;
    $forum =~ s/_/-/g;
    return $self->model('RealmOwner')->unauth_load({name => $forum});
}

sub _sentinel_site_admin_forum_users {
    my($self, @args) = @_;
    $self->initialize_fully;
    return b_use('Model.UserCreateForm')->if_unapproved_applicant_mode(
	sub {_default_sentinel($self, @args)}, sub {1});
}

sub _sentinel_site_forum {
    my($self, $type) = @_;
    $self->initialize_fully;
    my($f) = $self->req('Bivio::UI::Facade')->get_default;
    return 1
	unless $f->can('HELP_WIKI_REALM_NAME')
	&& $f->HELP_WIKI_REALM_NAME eq 'site-help';
    (my $forum = $type) =~ s/_forum$//;
    $forum =~ s/_/-/g;
    return $self->model('RealmOwner')->unauth_load({name => $forum});
}

sub _user_exists {
    my($self) = @_;
    return scalar(@{_run_other(
	$self,
	template1 =>
	'SELECT usename
        FROM pg_user
        WHERE usename = ?',
	[_assert_postgres($self)->{user}],
    )});
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
    +USER
b-realm-role -realm GENERAL -user user edit MEMBER - \
    +GUEST
b-realm-role -realm GENERAL -user user edit ACCOUNTANT - \
    +MEMBER
b-realm-role -realm GENERAL -user user edit ADMINISTRATOR - \
    +ACCOUNTANT \
    +ADMIN_READ \
    +ADMIN_WRITE \
    +DATA_BROWSE \
    +DATA_WRITE \
    +MAIL_READ
b-realm-role -realm GENERAL -user user edit MAIL_RECIPIENT -
b-realm-role -realm GENERAL -user user edit FILE_WRITER - \
    +DATA_WRITE
b-realm-role -realm GENERAL -user user edit UNAPPROVED_APPLICANT - \
    +USER

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
    +USER
b-realm-role -realm USER -user user edit MEMBER - \
    +GUEST \
    +ADMIN_READ \
    +DATA_READ \
    +DATA_BROWSE \
    +DATA_WRITE
b-realm-role -realm USER -user user edit ACCOUNTANT - \
    +MEMBER \
    +ADMIN_WRITE
b-realm-role -realm USER -user user edit ADMINISTRATOR - \
    +ACCOUNTANT
b-realm-role -realm USER -user user edit MAIL_RECIPIENT -
b-realm-role -realm USER -user user edit FILE_WRITER - \
    +DATA_WRITE
b-realm-role -realm USER -user user edit UNAPPROVED_APPLICANT - \
    +USER

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
    +USER
b-realm-role -realm CLUB -user user edit MEMBER - \
    +GUEST \
    +ADMIN_READ \
    +DATA_BROWSE \
    +DATA_READ \
    +DATA_WRITE \
    +MAIL_READ
b-realm-role -realm CLUB -user user edit ACCOUNTANT - \
    +MEMBER \
    +ADMIN_WRITE
b-realm-role -realm CLUB -user user edit ADMINISTRATOR - \
    +ACCOUNTANT
b-realm-role -realm CLUB -user user edit UNAPPROVED_APPLICANT - \
    +USER
b-realm-role -realm CLUB -user user edit MAIL_RECIPIENT -
b-realm-role -realm CLUB -user user edit FILE_WRITER - \
    +DATA_WRITE
