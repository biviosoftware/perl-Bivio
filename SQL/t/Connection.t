#!/usr/bin/perl -w
use strict;
use Bivio::Test;
use Bivio::SQL::Connection;

my($_TABLE) = 't_connection_t';
Bivio::Test->unit([
    Bivio::SQL::Connection->create => [
	execute => [
	    # Drop the table first, we don't care about the result
	    ["drop table $_TABLE"] => undef,
	],
	commit => undef,
	{
	    method => 'execute',
	    result_ok => \&_expect_statement,
	} => [
	    # We expect to get a statement back.
	    [<<"EOF"] => [],
		create table $_TABLE (
		    f1 numeric(8),
		    f2 numeric(8),
		    unique(f1, f2)
		)
EOF
	    ["insert into $_TABLE (f1, f2) values (1, 1)"] => [],
	],
	commit => undef,
	execute => [
	    ["insert into $_TABLE (f1, f2) values (1, 1)"]
	        => Bivio::DieCode->DB_CONSTRAINT,
	],
	{
	    method => 'execute',
	    result_ok => \&_expect_one_row,
	} => [
	    ["update $_TABLE set f2 = 13 where f2 = 1"] => [],
	],
	execute_one_row => [
	    ["select f2 from $_TABLE where f2 = 13"] => [[13]]
	],
	{
	    method => 'execute',
	    result_ok => \&_expect_one_row,
	} => [
	    ["delete from $_TABLE where f1 = 1"] => [],
	],
    ],
]);

# sub _expect_statement(any proto, string method, array_ref params, array_ref expected, array_ref actual) : boolean
#
# Returns true if $expected->[0] is a DBI::st.
#
sub _expect_statement {
    my($proto, $method, $params, $expected, $actual) = @_;
    return 0 unless ref($actual) eq 'ARRAY';
    my($st) = $actual->[0];
    return ref($st) && UNIVERSAL::isa($st, 'DBI::st') ? 1 : 0;
}

# sub _expect_one_row(any proto, string method, array_ref params, array_ref expected, array_ref actual) : boolean
#
# Returns true if $actual->[0] is a DBI::st and we processed one row.
#
sub _expect_one_row {
    my($proto, $method, $params, $expected, $actual) = @_;
    return 0 unless _expect_statement(@_);
    return $actual->[0]->rows == 1 ? 1 : 0;
}
