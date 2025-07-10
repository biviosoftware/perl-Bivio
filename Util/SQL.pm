# Copyright (c) 2001-2023 bivio Software, Inc.  All rights reserved.
package Bivio::Util::SQL;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.ClassLoaderAUTOLOAD');

my($_REALM_ROLE_CONFIG);
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
my($_IC) = b_use('IO.Config');
my($_BUNDLE) = [qw(
    ec_credit_card_gb_eu
)];
my($_AGGREGATES) = [qw(
    group_concat(text)
)];
my($_INITIALIZE_SENTINEL) = [grep(s/!//, @$_BUNDLE)];
$_IC->register(my $_CFG = {
    export_db_on_upgrade => 1,
});

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
    write_bop_ddl_files -- call SQL.DDL->write_files in current directory
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
        unless $self->is_oracle || $_F->pwd =~ m{/ddl$};
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
        $self->is_oracle ? (
            'FROM user_tab_columns
            WHERE column_name = ?
            AND table_name = ?',
            [uc($column), uc($table)],
        ) : (
            'FROM pg_class c, pg_attribute a
            WHERE a.attrelid = c.oid
            AND a.attnum > 0
            AND a.attname = ?
            AND c.relname = ?',
            [lc($column), lc($table)],
        ),
    );
}

sub create_db {
    my($self) = @_;
    # Initializes database.  Must be run from C<files/ddl> directory,
    # which contains C<*-tables.sql>, C<*-constraints.sql>, etc.
    #
    # See L<destroy_db|"destroy_db"> to see how you'd undo this operation.
    $self->initialize_fully;
    $_C->rollback;
    foreach my $file (@{_ddl_files($self)}){
        # Set up new file so read_input returns new value each time
        $self->print('Executing ', $file, "\n");
        $self->put(input => $file);
        $self->run;
    }
    $self->initialize_db;
    return;
}

sub create_test_db {
    my($self) = @_;
    # Destroys old database, creates new database, populates with test data.
    # Subclasses should override L<initialize_test_data|"initialize_test_data">
    # to create the test data.
    my($req) = $self->initialize_fully;
    b_die('cannot be run on production system')
        if $req->is_production;
    $_F->do_in_dir(
        $self->ddl_dir,
        sub {
            $self->destroy_db;
            $self->create_db;
            $self->initialize_test_data;
            return;
        },
    );
    return;
}

sub create_test_user {
    return shift->new_other('TestUser')->create(@_);
}

sub ddl_dir {
    my($self, $shell_util) = @_;
    $self->initialize_fully;
    $shell_util ||= $self;
    return b_use('UI.Facade')->get_local_file_name(
        b_use('UI.LocalFileType')->DDL,
        '',
        $shell_util->req,
    );
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

sub destroy_db {
    my($self) = @_;
    # Undoes the operations of L<create_db|"create_db">.
    $self->usage_error('You cannot destroy a production database.')
        if $self->get_request->is_production;
    $self->are_you_sure(
        'DROP ENTIRE '
        . $_C->get_dbi_config->{database}
        . ' DB and FILES '
        . b_use('Biz.File')->absolute_path('')
        . ' and LOGS '
        . b_use('IO.Log')->file_name('.')
        . '?',
    );
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
    $_C->commit;
    b_use('Biz.File')->destroy_db;
    return;
}

sub destroy_dbms {
    my($self) = @_;
    $self->usage_error('You cannot destroy a production database.')
        if $self->get_request->is_production;
    my($db) = $_C->get_dbi_config->{database};
    $self->are_you_sure("DROP THE ENTIRE $db DATABASE?");
    my($auth) = $_C->get_dbi_config('dbms');
    local($ENV{PGUSER}) = $auth->{user};
    local($ENV{PGPASSWORD}) = $auth->{password};
    $self->piped_exec("dropdb $db", '', 1);
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

sub drop_constraints {
    my($self) = @_;

    foreach my $file (@{_ddl_files($self)}) {
        next unless $file =~ /constraints/;
        $self->put(input => $file);
        $self->drop;
    }
    return;
}

sub drop_object {
    my($self, $type, @object) = @_;
    foreach my $o (@object) {
        $_D->catch_quietly(sub {$self->run("DROP $type $o\n/\n");});
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
    local($ENV{PGPASSWORD}) = $db->{password};
    local($ENV{PGUSER}) = $db->{user};
    $self->piped_exec(
        "pg_dump --clean --format=c --blobs --file='$f' '$db->{database}'");
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
    local($ENV{PGPASSWORD}) = $db->{password};
    local($ENV{PGUSER}) = $db->{user};
    $self->piped_exec("pg_restore --dbname='$db->{database}' --jobs=4 --data-only '$backup_file'");
    $_C->ping_connection;
    return;
}

sub init_dbms {
    my($self, $clone_db) = @_;
    $self->req;
    my($c) = _assert_postgres($self);
    my($db, $user, $pass) = @$c{qw(database user password)};
    my($auth) = $_C->get_dbi_config('dbms');
    local($ENV{PGUSER}) = $auth->{user};
    local($ENV{PGPASSWORD}) = $auth->{password};
    my($res) = '';
    _init_template1($self);
    unless (_user_exists($self)) {
        $self->piped_exec(
            "createuser --no-superuser --no-createdb --no-createrole $user");
        _run_other($self, template1 => "ALTER USER $user WITH PASSWORD '$pass'");
        $res .= " user '$user' and";
    }
    $self->piped_exec(
        'createdb'
        . (defined($clone_db) ? " --template=$clone_db " : '')
        . ' --encoding=SQL_ASCII'
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
    $self->initialize_user_feature_calendar;
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

sub init_task_log_for_forums {
    my($self) = @_;
    $self->model('Forum')->do_iterate(
        sub {
            return $self->req->with_realm(
                shift->get('forum_id'),
                sub {
                    $self->new_other('RealmRole')
                        ->edit_categories('feature_task_log');
                    return 1;
                },
            );
        },
    );
    return;
}

sub initialize_db {
    my($self) = @_;
    $self->initialize_group_concat;
    $self->model('RealmOwner')->init_db;
    $self->initialize_tuple_slot_types;
    $self->initialize_xapian_exec_realm;
    $self->init_realm_role;
    foreach my $x (@$_INITIALIZE_SENTINEL) {
        _default_sentinel($self, $x);
    }
    $self->req->set_realm(undef);
    return;
}

sub initialize_group_concat {
    my($self) = @_;
    if ($self->is_oracle) {
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

sub initialize_test_data {
    # Initializes test data.  A hook for the subclasses.
    return;
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
        Boolean => {
            type_class => 'Boolean',
            default_value => undef,
            choices => undef,
            is_required => 0,
        },
    });
    $req->set_realm($prev);
    return;
}

sub initialize_user_feature_calendar {
    my($self) = @_;
    $self->req->with_realm(user => sub {
        $self->new_other('RealmRole')->edit_categories('+feature_calendar');
        return;
    });
    return;
}

sub initialize_xapian_exec_realm {
    my($self) = @_;
    my($n) = b_use('Search.Xapian')->EXEC_REALM;
    $self->model('User')->create_realm(
        {last_name => $n},
        {name => $n, display_name => $n},
    );
    return;
}

sub internal_role_is_initialized {
    my($self, $role) = @_;
    return $role->eq_anonymous;
}

sub internal_upgrade_db_bundle {
    my($self) = @_;
    _assert_postgres($self);
    $self->initialize_fully;
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

sub internal_upgrade_db_ec_credit_card_gb_eu {
    my($self) = @_;
    $self->run(<<'EOF');
ALTER TABLE ec_credit_card_payment_t
    ADD COLUMN card_first_name VARCHAR(30),
    ADD COLUMN card_last_name VARCHAR(30),
    ADD COLUMN card_address VARCHAR(100),
    ADD COLUMN card_city VARCHAR(30),
    ADD COLUMN card_state VARCHAR(30),
    ADD COLUMN card_country VARCHAR(2),
    ADD COLUMN card_email VARCHAR(100)
/
EOF
    return;
}

sub internal_upgrade_db_totp {
    my($self) = @_;
    $self->run(<<'EOF');
CREATE TABLE totp_t (
  user_id NUMERIC(18) NOT NULL,
  creation_date_time DATE NOT NULL,
  algorithm NUMERIC(1) NOT NULL,
  digits NUMERIC(1) NOT NULL,
  period NUMERIC(2) NOT NULL,
  secret VARCHAR(4000) NOT NULL,
  last_time_step NUMERIC(10),
  CONSTRAINT totp_t1 primary key(user_id)
)
/
CREATE TABLE recovery_code_t (
  user_id NUMERIC(18) NOT NULL,
  code VARCHAR(4000) NOT NULL,
  creation_date_time DATE NOT NULL,
  CONSTRAINT recovery_code_t1 primary key(user_id, code)
)
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

sub psql {
    my($self) = @_;
    my($db, $u, $p) = @{$_C->get_dbi_config}{qw(database user password)};
    local($ENV{PGUSER}) = $u;
    local($ENV{PGPASSWORD}) = $p;
    CORE::exec('psql', $db);
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
    my($self, $dump, $extra_args) = @_;
    $self->usage_error($dump, ': missing or non existent dump file argument')
        unless -r $dump;
    $self->destroy_dbms;
    $self->commit_or_rollback;
    $self->init_dbms;
    $self->commit_or_rollback;
    my($db, $u, $p) = @{$_C->get_dbi_config}{qw(database user password)};
    local($ENV{PGUSER}) = $u;
    local($ENV{PGPASSWORD}) = $p;
    $extra_args ||= '';
    return ${$self->piped_exec("pg_restore --dbname='$db' --jobs=4 $extra_args '$dump'")};
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
    sub UPGRADE_DB {[
        [qw(type Name)],
    ]}
    my($self, $bp) = shift->parameters(\@_);
    my($req) = $self->req;
    my($method) = "internal_upgrade_db_$bp->{type}";
    my($upgrade) = $self->model('DbUpgrade');
    my($v) = $bp->{type};
    $self->usage_error(
        $v,
        ': ran on ',
        $_DT->to_local_string($upgrade->get('run_date_time')),
    ) if $upgrade->unauth_load({version => $v});
    $self->are_you_sure(
        qq{Upgrade the database with $bp->{type}?});
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

sub write_bop_ddl_files() {
    my($self) = @_;
    $self->use('SQL.DDL')->write_files;
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
    # Only write the files in dev mode
    $self->use('SQL.DDL')->write_files
        if $_IC->is_dev;
    my($missing) = [grep(! -f $_, @$f)];
    if (@$missing) {
        $self->usage($missing, ": missing DDL files in ", $_F->pwd);
    }
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

sub _expand_text_size {
    my($self, $names) = @_;
    foreach my $name (@$names) {
        my($table, $col) = split(/\./, $name);
        $self->run(<<"EOF");
ALTER TABLE $table ALTER COLUMN $col TYPE TEXT64K
/
EOF
    }
    return;
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
    $self->piped_exec('createlang plpgsql template1');
    foreach my $dir (qw(/usr/share/pgsql/contrib /usr/local/share)) {
        next unless -d $dir;
        $_F->do_in_dir($dir, sub {
            foreach my $file (qw(lwpostgis.sql spatial_ref_sys.sql)) {
                last unless -f $file;
                $self->piped_exec(
                    "psql --dbname=template1 --file=$file");
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

sub _sentinel_ec_credit_card_gb_eu {
    my($self) = @_;
    return $self->column_exists('ec_credit_card_payment_t', 'card_first_name');
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
    +MEMBER \
    +ADMIN_READ \
    +DATA_BROWSE \
    +MAIL_READ
b-realm-role -realm GENERAL -user user edit ADMINISTRATOR - \
    +ACCOUNTANT \
    +ADMIN_WRITE \
    +DATA_WRITE
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
    +ADMIN_WRITE \
    +MAIL_ADMIN
b-realm-role -realm CLUB -user user edit ADMINISTRATOR - \
    +ACCOUNTANT
b-realm-role -realm CLUB -user user edit UNAPPROVED_APPLICANT - \
    +USER
b-realm-role -realm CLUB -user user edit MAIL_RECIPIENT -
b-realm-role -realm CLUB -user user edit FILE_WRITER - \
    +DATA_WRITE
