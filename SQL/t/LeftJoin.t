# Copyright (c) 2003 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
#
# NOTE: May only work with Postgres
#
use Bivio::Test;
use Bivio::SQL::Connection;

map({
    my($n) = $_;
    Bivio::Die->eval(sub {
	Bivio::SQL::Connection->execute("drop table t_leftjoin_t$n");
	Bivio::SQL::Connection->commit;
    });
    Bivio::Die->eval(sub {Bivio::SQL::Connection->rollback;});
} 1..4);
Bivio::Test->unit([
    'Bivio::SQL::Connection' => [
	execute => [
	    # We expect to get a statement back.
	    map({
		("create table t_leftjoin_t$_ (
		    f1 numeric(8),
		    f2 numeric(8)
		)" => undef);
	    } 1..4),
	],
	commit => undef,
	execute => [
	    'insert into t_leftjoin_t1 (f1, f2) values (1, 1)' => undef,
	    'insert into t_leftjoin_t1 (f1, f2) values (2, 2)' => undef,
	    'insert into t_leftjoin_t1 (f1, f2) values (3, 3)' => undef,
	    'insert into t_leftjoin_t2 (f1, f2) values (2, 2)' => undef,
	    'insert into t_leftjoin_t3 (f1, f2) values (3, 3)' => undef,
	    'insert into t_leftjoin_t4 (f1, f2) values (1, 1)' => undef,
	    'insert into t_leftjoin_t4 (f1, f2) values (2, 2)' => undef,
	    'insert into t_leftjoin_t4 (f1, f2) values (3, 3)' => undef,
	],
	commit => undef,
	execute_one_row => [
	    # Verify # rows
	    'select count(*) from t_leftjoin_t1' => [[3]],
	    # Simple join
	    'select count(*) from t_leftjoin_t1, t_leftjoin_t2 where t_leftjoin_t1.f1 = t_leftjoin_t2.f1' => [[1]],
	    # Left join
	    'select count(*) from t_leftjoin_t1, t_leftjoin_t2 where t_leftjoin_t1.f1 = t_leftjoin_t2.f1(+)' => [[3]],
	    # Left and simple
	    'select count(*) from t_leftjoin_t1, t_leftjoin_t2, t_leftjoin_t3 where t_leftjoin_t1.f1 = t_leftjoin_t2.f1(+) and t_leftjoin_t1.f1 = t_leftjoin_t3.f1' => [[1]],
	    # Simple and left
	    'select count(*) from t_leftjoin_t1, t_leftjoin_t2, t_leftjoin_t3 where t_leftjoin_t1.f1 = t_leftjoin_t3.f1 and t_leftjoin_t1.f1 = t_leftjoin_t2.f1(+)' => [[1]],
	    # Two left with one table
	    'select count(*) from t_leftjoin_t1, t_leftjoin_t2, t_leftjoin_t3 where t_leftjoin_t1.f1 = t_leftjoin_t2.f1(+) and t_leftjoin_t1.f1 = t_leftjoin_t2.f1(+)' => [[3]],
	    # Two left with two tables
	    'select count(*) from t_leftjoin_t1, t_leftjoin_t2, t_leftjoin_t3 where t_leftjoin_t1.f1 = t_leftjoin_t2.f1(+) and t_leftjoin_t1.f1 = t_leftjoin_t3.f1(+)' => [[3]],
	    # Count cross product
	    'select count(*) from t_leftjoin_t1, t_leftjoin_t4' => [[9]],
	    # Two left with two different sets of tables
	    'select count(*) from t_leftjoin_t1, t_leftjoin_t2, t_leftjoin_t3, t_leftjoin_t4 where t_leftjoin_t1.f1 = t_leftjoin_t2.f1(+) and t_leftjoin_t4.f1 = t_leftjoin_t3.f1(+)' => [[9]],
	    'select count(*) from t_leftjoin_t1, t_leftjoin_t2, t_leftjoin_t3, t_leftjoin_t4 where t_leftjoin_t1.f1 = t_leftjoin_t2.f1(+) and t_leftjoin_t4.f1 = t_leftjoin_t3.f1(+) order by t_leftjoin_t1.f1' => [[9]],
	    'select count(*), (select sum(f1) from t_leftjoin_t4
			       where t_leftjoin_t4.f2 > 1) as f3
	     from t_leftjoin_t1, t_leftjoin_t2
	     where t_leftjoin_t1.f1 = t_leftjoin_t2.f1(+)' => [[3,5]],
	     'select count(*),
		   (select sum(t_leftjoin_t3.f2) from t_leftjoin_t3
		    where t_leftjoin_t3.f1=t_leftjoin_t1.f1) as f3
	      from t_leftjoin_t1, t_leftjoin_t2
	      where t_leftjoin_t1.f1=t_leftjoin_t2.f1(+)' => [[3,3]],
       ],
    ],
]);
