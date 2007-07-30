# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
BEGIN {
    use Bivio::IO::Config;
    Bivio::IO::Config->introduce_values({
	'Bivio::IO::ClassLoader' => {
	    maps => {
		Model => ['Bivio::Biz::t::PropertyModel', 'Bivio::Biz::Model'],
	    },
	},
    });
}
use Bivio::Test::Request;
my($req) = Bivio::Test::Request->get_instance;
my($depth) = 4;
foreach my $n (1..$depth) {
    my($model) = Bivio::Biz::Model->new($req, "Cascade$n");
    my($table) = $model->get_instance->get_info('table_name');
    Bivio::Die->catch(sub {
	Bivio::SQL::Connection->execute("drop table $table");
    });
    Bivio::SQL::Connection->commit;
    Bivio::SQL::Connection->execute(
	join("\n",
	     "create table $table (",
	     map("k$_ NUMERIC(1),", 1..$n),
	     "primary key(" . join(',', map("k$_", 1..$n)) . ")",
	     ")",
	),
    );
    Bivio::SQL::Connection->commit;
}
Bivio::Test->new->unit([
    map({
	my($n) = $_;
	(sub {Bivio::Biz::Model->new($req, "Cascade$n")} => [
	    create => [
		[{map(("k$_" => $_), 1..$n)}] => undef,
	    ],
	]),
    } 1..$depth),
    sub {Bivio::Biz::Model->new($req, "Cascade1")} => [
	unsafe_load => [
	    [{k1 => 1}] => 1,
	],
	cascade_delete => undef,
    ],
    sub {Bivio::Biz::Model->new($req, "Cascade$depth")} => [
	unsafe_load => [
	    [{map(("k$_" => $_), 1..$depth)}] => 1,
	],
    ],
    sub {Bivio::Biz::Model->new($req, 'Cascade' . ($depth - 1))} => [
	unsafe_load => [
	    [{map(("k$_" => $_), 1..($depth - 1))}] => 0,
	],
    ],
]);

