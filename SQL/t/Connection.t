#!/usr/bin/perl -w
use strict;
use Bivio::Test;
use Bivio::SQL::Connection;

my($_TABLE) = 't_connection_t';
Bivio::Test->unit([
    Bivio::SQL::Connection->connect('dev') => [
	execute => [
	    # Drop the table first, we don't care about the result
	    ["drop table $_TABLE"] => sub {1},
	],
	commit => [
	    [] => [],
	],
	execute => [
	    # We expect to get a statement back.
	    [<<"EOF"] => \&_expect_statement,
		create table $_TABLE (
		    f1 numeric(8),
		    f2 numeric(8),
		    unique(f1, f2)
		)
EOF
	    ["insert into $_TABLE (f1, f2) values (1, 1)"]
	    	=> \&_expect_statement,
	],
	commit => [
	    [] => [],
	],
	execute => [
	    ["insert into $_TABLE (f1, f2) values (1, 1)"]
	        => Bivio::DieCode->DB_CONSTRAINT,
	    ["update $_TABLE set f2 = 13 where f2 = 1"] => \&_expect_one_row,
	],
	execute_one_row => [
	    ["select f2 from $_TABLE where f2 = 13"] => [[13]]
	],
	execute => [
	    ["delete from $_TABLE where f1 = 1"] => \&_expect_one_row,
	],
    ],
]);

# sub _expect_statement(any proto, string method, array_ref params, array_ref result) : boolean
#
# Returns true if $result->[0] is a DBI::st.
#
sub _expect_statement {
    my($proto, $method, $params, $result) = @_;
    return 0 unless ref($result) eq 'ARRAY';
    my($st) = $result->[0];
    return ref($st) && UNIVERSAL::isa($st, 'DBI::st') ? 1 : 0;
}

# sub _expect_one_row(any proto, string method, array_ref params, array_ref result) : boolean
#
# Returns true if $result->[0] is a DBI::st and we processed one row.
#
sub _expect_one_row {
    my($proto, $method, $params, $result) = @_;
    return 0 unless _expect_statement(@_);
    return $result->[0]->rows == 1 ? 1 : 0;
}
