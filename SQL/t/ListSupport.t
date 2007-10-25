# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..39\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::SQL::ListSupport;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use Bivio::IO::Config;
use Bivio::IO::Ref;
use Bivio::SQL::Constraint;
use Bivio::Type::Amount;
use Bivio::Type::Boolean;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::Gender;
use Bivio::Type::Integer;
use Bivio::Type::Line;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
use Bivio::Type::Text;
use Bivio::Type::Time;
use Bivio::Biz::PropertyModel;
use Bivio::SQL::ListQuery;
use Bivio::SQL::Support;


package Bivio::Biz::Model::TListT1;
use Bivio::Base 'Bivio::Biz::PropertyModel';

sub internal_initialize {
    return {
	version => 1,
	table_name => 't_list1_t',
	columns => {
	    date_time => ['Bivio::Type::DateTime',
		Bivio::SQL::Constraint->PRIMARY_KEY],
	    toggle => ['Bivio::Type::Boolean',
		Bivio::SQL::Constraint->PRIMARY_KEY],
	    auth_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint->NOT_NULL],
	    name => ['Bivio::Type::Name',
		Bivio::SQL::Constraint->NOT_NULL],
	    gender => ['Bivio::Type::Gender',
		Bivio::SQL::Constraint->NOT_NULL],
	},
    };
}

package Bivio::Biz::Model::TListT2;
use Bivio::Base 'Bivio::Biz::PropertyModel';

sub internal_initialize {
    return {
	version => 1,
	table_name => 't_list2_t',
	columns => {
	    date_time => ['Bivio::Type::DateTime',
		Bivio::SQL::Constraint->PRIMARY_KEY],
	    toggle => ['Bivio::Type::Boolean',
		Bivio::SQL::Constraint->PRIMARY_KEY],
	    auth_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint->NOT_NULL],
	    name => ['Bivio::Type::Name',
		Bivio::SQL::Constraint->NOT_NULL],
	    gender => ['Bivio::Type::Gender',
		Bivio::SQL::Constraint->NOT_NULL],
	},
    };
}

package main;

my($T) = 2;
sub t {
    my($actual, $expected) = @_;
    print $actual eq $expected
	    ? "ok $T\n" : ("not ok $T ($actual != $expected)",
		    ' at ', __FILE__, " line ", (caller)[2], "\n");
    $T++;
}
my($m);
my($req) = Bivio::Collection::Attributes->new;
my($now) = Bivio::Type::DateTime->from_literal('2001/12/31 17:00:00');
my($names) = ['name00'..'name09'];
foreach $m ('TListT1', 'TListT2') {
    my($pkg) = "Bivio::Biz::Model::$m";
    my($table) = $pkg->get_instance->get_info('table_name');
    Bivio::Die->catch(sub {
	Bivio::SQL::Connection->execute("drop table $table");
    });
    Bivio::SQL::Connection->commit;
    Bivio::SQL::Connection->execute(<<"EOF");
	create table $table (
	    date_time DATE,
            toggle NUMERIC(1) not null,
	    auth_id NUMERIC(18) not null,
	    name VARCHAR(30) not null,
            value VARCHAR(30),
	    gender NUMERIC(1) NOT NULL,
            primary key(date_time, toggle)
	)
EOF
    Bivio::SQL::Connection->execute(
	"alter table $table add constraint ${table}_c1
             check (toggle between 0 and 1)");
    Bivio::SQL::Connection->execute(
	"alter table $table add constraint ${table}_c2
            CHECK (gender BETWEEN 0 AND 2)");
    my($gender, $name, $auth_id);
    my($date_time) = $now;
    my($model) = $pkg->new($req);
    my($toggle) = 1;
    foreach $auth_id (1..2) {
	foreach $name (@$names) {
	    foreach $gender ('FEMALE', 'MALE') {
		$model->create({
		    date_time => $date_time,
		    toggle => ($toggle = !$toggle),
		    auth_id => $auth_id,
		    name => $name,
		    value => undef,
		    gender => Bivio::Type::Gender->$gender(),
		});
		$date_time = Bivio::Type::DateTime->add_seconds($date_time, 1);
	    }
	}
    }
}
Bivio::SQL::Connection->commit;
my($support) = Bivio::SQL::ListSupport->new({
    version => 1,
    can_iterate => 1,
    other => [
	{
	    name => 'local_field',
	    type => 'Bivio::Type::Integer',
	    constraint => Bivio::SQL::Constraint::NONE(),
	},
    ],
    order_by => [
	[qw(TListT1.name TListT2.name)],
	[qw(TListT1.gender TListT2.gender)],
    ],
    primary_key => [
	'TListT1.date_time',
	'TListT1.toggle',
    ],
    auth_id => [qw(TListT1.auth_id TListT2.auth_id)],
});

my($query) = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 5,
}, $support);

my($rows) = $support->load($query, undef, '', []);
t(scalar(@$rows), 5);
# Make sure both primary keys are returned, even though we only listed one.
t($rows->[0]->{'TListT1.date_time'}, $rows->[0]->{'TListT2.date_time'});

# Check all rows returned
$query = Bivio::SQL::ListQuery->new({
    auth_id => 2,
    count => 100,
}, $support);
$rows = $support->load($query, undef, '', []);
t(scalar(@$rows), 20);

$query = Bivio::SQL::ListQuery->new({
    auth_id => 2,
    count => 100,
    o => '0d',
}, $support);
$rows = $support->load($query, undef, '', []);
t($rows->[0]->{'TListT1.name'}, 'name09');
t($rows->[3]->{'TListT1.name'}, 'name08');

# Check order of second sort by (also type conversions)
$query = Bivio::SQL::ListQuery->new({
    auth_id => 2,
    count => 100,
    o => '0d1d',
}, $support);
$rows = $support->load($query, undef, '', []);
t($rows->[0]->{'TListT1.gender'}, Bivio::Type::Gender::MALE());
t($rows->[1]->{'TListT1.gender'}, Bivio::Type::Gender::FEMALE());


# Check internal fields which shouldn't be defined
my($local_columns) = $support->get('local_columns');
t(scalar(@$local_columns), 1);
t($local_columns->[0]->{name}, 'local_field');
t($local_columns->[0]->{type}, 'Bivio::Type::Integer');
t($local_columns->[0]->{constraint}, Bivio::SQL::Constraint::NONE());

# Check loading "this"
$query = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 1,
    t => $now."\177".0,
}, $support);
$rows = $support->load($query, undef, '', []);
t(scalar(@$rows), 1);
t($rows->[0]->{'TListT1.name'}, 'name00');
t($rows->[0]->{'TListT1.toggle'}, 0);

# Check missing "this"
$query = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 1,
    t => Bivio::Type::DateTime->add_seconds($now, 10000)."\177".0,
}, $support);
$rows = $support->load($query, undef, '', []);
t(scalar(@$rows), 0);

# Check paging
$query = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 2,
    o => '0a',
}, $support);
$rows = $support->load($query, undef, '', []);
t(scalar(@$rows), 2);
t('name00', $rows->[1]->{'TListT1.name'});
t($rows->[0]->{'TListT1.name'}, $rows->[1]->{'TListT1.name'});
t($query->get('has_next'), 1);
t($query->get('next_page') || 0, 2);
t($query->get('has_prev'), 0);

# Page 2
$query = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 2,
    o => '0a',
    page_number => 2,
}, $support);
$rows = $support->load($query, undef, '', []);
t(scalar(@$rows), 2);
t('name01', $rows->[1]->{'TListT1.name'});
t($rows->[0]->{'TListT1.name'}, $rows->[1]->{'TListT1.name'});
t($query->get('has_next'), 1);
t($query->get('next_page') || 0, 3);
t($query->get('has_prev'), 1);
t($query->get('prev_page'), 1);

# Past last page with want_page_count
$query = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 2,
    o => '0a',
    page_number => 999999,
}, $support);
$rows = $support->load($query, undef, '', []);
t(scalar(@$rows), 2);
t('name09', $rows->[1]->{'TListT1.name'});
t($rows->[0]->{'TListT1.name'}, $rows->[1]->{'TListT1.name'});

$query = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 2,
    o => '0a',
    page_number => 999999,
    want_page_count => 0,
}, $support);
$rows = $support->load($query, undef, '', []);
t(scalar(@$rows), 2);
t('name09', $rows->[1]->{'TListT1.name'});
t($rows->[0]->{'TListT1.name'}, $rows->[1]->{'TListT1.name'});
# 20 rows, 10 pages
t($query->get('page_number'), 10);

# want_only_one_order_by
# First get rows with full order_by, descending in second param
$query = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 99999,
    o => '1d0d',
}, $support);
$rows = $support->load($query, undef, '', []);
# Now get with only one order by
$query = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 99999,
    o => '1d0d',
    want_only_one_order_by => 1,
}, $support);
my($rows2) = $support->load($query, undef, '', []);
# Shouldn't be the same
t(Bivio::IO::Ref->nested_equals($rows, $rows2), 0);

# can_iterate
t($support->get('can_iterate'), 1);

$support = Bivio::SQL::ListSupport->new({
    version => 1,
    can_iterate => 1,
    order_by => [
	map(+{
	    name => "count$_",
	    constraint => 'NOT_NULL',
	    type => 'Integer',
	    in_select => 1,
	    select_value => "COUNT(t_list${_}_t.date_time) AS count$_",
	}, 1, 2),
    ],
    group_by => [
	[qw(TListT1.gender TListT2.gender)],
    ],
    primary_key => [
	'TListT1.gender',
    ],
    auth_id => [qw(TListT1.auth_id TListT2.auth_id)],
    other => [
	[qw(TListT1.name TListT2.name)],
	map({
	    my($f) = $_;
	    map(+{
		name => "TListT$_.$f",
		in_select => 0,
	    }, 1, 2);
	} qw(toggle date_time name)),
    ],
});
$rows = $support->load(Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 99999,
    o => '0d',
}, $support), undef, '', []);
t(Bivio::IO::Ref->nested_equals($rows, [
    map({
	'TListT1.auth_id' => 1,
	count1 => scalar(@$names),
	count2 => scalar(@$names),
	'TListT1.gender' => Bivio::Type::Gender->from_int($_)
    }, 1, 2),
]), 1);
Bivio::SQL::ListSupport->new({
    version => 1,
    date => 'TListT1.date_time',
    want_select => 0,
    order_by => [
	{
	    name => 'TListT1.date_time',
	    sort_order => 1,
	},
    ],
    primary_key => [
	'TListT1.date_time',
    ],
});
