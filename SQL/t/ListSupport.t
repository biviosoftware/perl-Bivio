# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..16\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::SQL::ListSupport;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use Bivio::IO::Config;
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

@Bivio::Biz::Model::TListT1::ISA = ('Bivio::Biz::PropertyModel');

sub internal_initialize {
    return {
	version => 1,
	table_name => 't_list1_t',
	columns => {
	    date_time => ['Bivio::Type::DateTime',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    toggle => ['Bivio::Type::Boolean',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    auth_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint::NOT_NULL()],
	    name => ['Bivio::Type::Name',
		Bivio::SQL::Constraint::NOT_NULL()],
	    gender => ['Bivio::Type::Gender',
		Bivio::SQL::Constraint::NOT_NULL()],
	},
    };
}

package Bivio::Biz::Model::TListT2;

@Bivio::Biz::Model::TListT2::ISA = ('Bivio::Biz::PropertyModel');

sub internal_initialize {
    return {
	version => 1,
	table_name => 't_list2_t',
	columns => {
	    date_time => ['Bivio::Type::DateTime',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    toggle => ['Bivio::Type::Boolean',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    auth_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint::NOT_NULL()],
	    name => ['Bivio::Type::Name',
		Bivio::SQL::Constraint::NOT_NULL()],
	    gender => ['Bivio::Type::Gender',
		Bivio::SQL::Constraint::NOT_NULL()],
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
	foreach $name ('name00'..'name09') {
	    foreach $gender ('FEMALE', 'MALE') {
		$model->create({
		    date_time => $date_time,
		    toggle => ($toggle = !$toggle),
		    auth_id => $auth_id,
		    name => $name,
		    value => undef,
		    gender => $gender,
		});
		$date_time = Bivio::Type::DateTime->add_seconds($date_time, 1);
	    }
	}
    }
}
Bivio::SQL::Connection->commit;
my($support) = Bivio::SQL::ListSupport->new({
    version => 1,
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

my($rows) = $support->load($query, '', []);
t(int(@$rows), 5);
# Make sure both primary keys are returned, even though we only listed one.
t($rows->[0]->{'TListT1.date_time'}, $rows->[0]->{'TListT2.date_time'});

# Check all rows returned
$query = Bivio::SQL::ListQuery->new({
    auth_id => 2,
    count => 100,
}, $support);
$rows = $support->load($query, '', []);
t(int(@$rows), 20);

$query = Bivio::SQL::ListQuery->new({
    auth_id => 2,
    count => 100,
    o => '0d',
}, $support);
$rows = $support->load($query, '', []);
t($rows->[0]->{'TListT1.name'}, 'name09');
t($rows->[3]->{'TListT1.name'}, 'name08');

# Check order of second sort by (also type conversions)
$query = Bivio::SQL::ListQuery->new({
    auth_id => 2,
    count => 100,
    o => '0d1d',
}, $support);
$rows = $support->load($query, '', []);
t($rows->[0]->{'TListT1.gender'}, Bivio::Type::Gender::MALE());
t($rows->[1]->{'TListT1.gender'}, Bivio::Type::Gender::FEMALE());


# Check internal fields which shouldn't be defined
my($local_columns) = $support->get('local_columns');
t(int(@$local_columns), 1);
t($local_columns->[0]->{name}, 'local_field');
t($local_columns->[0]->{type}, 'Bivio::Type::Integer');
t($local_columns->[0]->{constraint}, Bivio::SQL::Constraint::NONE());

# Check loading "this"
$query = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 1,
    t => $now."\177".0,
}, $support);
$rows = $support->load($query, '', []);
t(int(@$rows), 1);
t($rows->[0]->{'TListT1.name'}, 'name00');
t($rows->[0]->{'TListT1.toggle'}, 0);

# Check missing "this"
$query = Bivio::SQL::ListQuery->new({
    auth_id => 1,
    count => 1,
    t => Bivio::Type::DateTime->add_seconds($now, 10000)."\177".0,
}, $support);
$rows = $support->load($query, '', []);
t(int(@$rows), 0);


