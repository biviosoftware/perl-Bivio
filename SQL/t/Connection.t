#!/usr/bin/perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::SQL::Connection;

my($_TABLE) = 't_connection_t';
Bivio::Die->eval(
    sub {
	Bivio::SQL::Connection->execute("drop table $_TABLE");
	Bivio::SQL::Connection->commit;
    },
);
Bivio::Test->unit([
    Bivio::SQL::Connection->get_instance => [
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
	commit => undef,
	execute => [
	    ["insert into $_TABLE (f1, f2) values (1, 1)"]
	        => Bivio::DieCode->DB_CONSTRAINT,
	],
	execute => [
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

# _expect_statement(Bivio::Test::Case case, array_ref return) : boolean
#
# Returns true if $expect->[0] is a DBI::st.
#
sub _expect_statement {
    my(undef, $return) = @_;
    my($st) = $return->[0];
    return ref($st) && UNIVERSAL::isa($st, 'DBI::st') ? 1 : 0;
}

# _expect_one_row(Bivio::Test::Case case, array_ref return) : boolean
#
# Returns true if $return->[0] is a DBI::st and we processed one row.
#
sub _expect_one_row {
    my(undef, $return) = @_;
    return 0 unless _expect_statement(@_);
    return $return->[0]->rows == 1 ? 1 : 0;
}
