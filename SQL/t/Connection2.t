# Copyright (c) 2003 bivio Software Artisans, Inc. All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;

use Bivio::SQL::Connection;

sub _is_postgres {
    return Bivio::SQL::Connection->get_instance->isa(
        'Bivio::SQL::Connection::Postgres') ? 1 : 0;
};

foreach my $table (qw(2 1)) {
    Bivio::Die->catch(sub {
        Bivio::SQL::Connection->execute("drop table t_$table");
        Bivio::SQL::Connection->commit;
    });
    Bivio::SQL::Connection->rollback;
}

Bivio::Test->new('Bivio::SQL::Connection')->unit([
    'Bivio::SQL::Connection' => [
        execute => [map({
            $_ => undef;
        }
            'create table t_1 (f1 numeric not null)',
            'alter table t_1 add constraint t_1_1 primary key (f1)',
            'create table t_2 (f1 numeric not null)',
            'alter table t_2 add constraint t_2_1 primary key (f1)',
            'alter table t_2 add constraint t_2_2 foreign key (f1)'
            . ' references t_1(f1)',
            'alter table t_2 add constraint t_2_3 check (f1 > 0)',
        )],
        commit => undef,
        (_is_postgres()
            ? (execute_one_row => [
                'select tgconstrname from pg_trigger'
                . " where tgconstrname='t_2_2'" => [['t_2_2']],
                'select conname from pg_constraint'
                . " where conname='t_2_3'" => [['t_2_3']],
            ])
            : ()),
        execute => [map({
            $_ => undef;
        }
            'alter table t_2 drop constraint t_2_2',
            'alter table t_2 drop constraint t_2_3',
        )],
    ],
]);
