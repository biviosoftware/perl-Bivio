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
	    ["insert into $_TABLE (f1, f2) values (1, 1)"]
	        => Bivio::DieCode->DB_CONSTRAINT,
	],
	execute => [
	    ["update $_TABLE set f2 = 2 where f2 = 1"] => \&_expect_one_row,
	    ["select f2 from $_TABLE where f2 = 13"] => sub {
		my($proto, $method, $params, $result) = @_;
		return 0 unless _expect_statement(@_);
		return $result->[0]->fetchrow_arrayref->[0] eq 13 ? 1 : 0;
	    },
	    ["delete from $_TABLE where f1 = 1"] => \&_expect_one_row,
	],
    ],
]);

sub _expect_statement {
    my($proto, $method, $params, $result) = @_;
    return 0 unless ref($result) eq 'ARRAY';
    my($st) = $result->[0];
    return ref($st) && UNIVERSAL::isa($st, 'DBI::st') ? 1 : 0;
}

sub _expect_one_row {
    my($proto, $method, $params, $result) = @_;
    return 0 unless _expect_statement(@_);
    return $result->[0]->rows == 1 ? 1 : 0;
}
