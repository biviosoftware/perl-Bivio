# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..12\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::SQL::Support;
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
use Bivio::Type::Line;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
use Bivio::Type::Text;
use Bivio::Type::Time;

Bivio::IO::Config->initialize(\@ARGV);

my($T) = 2;
sub t {
    print shift(@_) ? "ok $T\n" : ("not ok $T at line ", (caller)[2], "\n");
    $T++;
}
my($_TABLE) = 't_support_t';
my($_SEQUENCE) = 't_support_s';
my($_ID) = 't_support_id';
my($_MIN_ID) = '100099';
eval {
    Bivio::SQL::Connection->execute("drop table $_TABLE");
    Bivio::SQL::Connection->execute("drop sequence $_SEQUENCE");
};
Bivio::SQL::Connection->execute(<<"EOF");
create table $_TABLE (
    $_ID NUMBER(18) primary key,
    name VARCHAR(30),
    line VARCHAR(100),
    text VARCHAR(500),
    amount NUMBER(20,7),
    boolean NUMBER(1) CHECK (boolean BETWEEN 0 AND 1) NOT NULL,
    dttm DATE,
    dt DATE,
    tm DATE,
    gender NUMBER(1) CHECK (gender BETWEEN 0 AND 2) NOT NULL
)
EOF
Bivio::SQL::Connection->execute(<<"EOF");
create sequence $_SEQUENCE minvalue $_MIN_ID increment by 100000
EOF
Bivio::SQL::Connection->commit;
my($support) = Bivio::SQL::Support->new($_TABLE, {
    $_ID => ['Bivio::Type::PrimaryId',
	    Bivio::SQL::Constraint::PRIMARY_KEY()],
    name => ['Bivio::Type::Name',
	    Bivio::SQL::Constraint::NONE()],
    line => ['Bivio::Type::Line',
	    Bivio::SQL::Constraint::NONE()],
    text => ['Bivio::Type::Text',
	    Bivio::SQL::Constraint::NONE()],
    amount => ['Bivio::Type::Amount',
	    Bivio::SQL::Constraint::NONE()],
    boolean => ['Bivio::Type::Boolean',
	    Bivio::SQL::Constraint::NOT_NULL()],
    dttm => ['Bivio::Type::DateTime',
	    Bivio::SQL::Constraint::NONE()],
    dt => ['Bivio::Type::Date',
	    Bivio::SQL::Constraint::NONE()],
    tm => ['Bivio::Type::Time',
	    Bivio::SQL::Constraint::NONE()],
    gender => ['Bivio::Type::Gender',
	    Bivio::SQL::Constraint::NOT_NULL()],
});
my($load) = $support->unsafe_load({$_ID => $_MIN_ID});
t(!defined($load));
my($values) = {gender => Bivio::Type::Gender::FEMALE()};
$support->create($values);
$load = $support->unsafe_load({$_ID => $_MIN_ID});
t(defined($load));
t(!defined($load->{name}) && !defined($load->{line})
	&& !defined($load->{text}) && !defined($load->{amount}));
t($load->{boolean} == 0);
t(!defined($load->{dttm}));
t(!defined($load->{tm}));
t(!defined($load->{dt}));
t($load->{gender} == Bivio::Type::Gender::FEMALE);
t($values->{$_ID} eq $_MIN_ID);
$values->{dttm} = time;
my($time) = time;
$support->update($load, {
    name => 'name',
    line => 'line',
    text => 'text',
    amount => '20.7',
    boolean => 99,
    dttm => $time,
    dt => int($time / 86400) * 86400,
    tm => 60 * 60,
    gender => Bivio::Type::Gender::MALE(),
});
Bivio::SQL::Connection->commit;
$load = $support->unsafe_load({$_ID => $_MIN_ID});
t(defined($load));
t($load->{name} eq 'name' && $load->{line} eq 'line'
	&& $load->{text} eq 'text' && $load->{amount} eq '20.7');
t($load->{boolean} == 1);
t($load->{dttm} == $time);
t($load->{tm} == 3600);
t($load->{dt} == int($time / 86400) * 86400);
t($load->{gender} == Bivio::Type::Gender::MALE);
$support->delete($load);
Bivio::SQL::Connection->commit;
$load = $support->unsafe_load({$_ID => $_MIN_ID});
t(!defined($load));
