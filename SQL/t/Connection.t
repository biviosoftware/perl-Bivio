# -*-perl-*-
#
# $Id$
#
use strict;

BEGIN { $| = 1; print "1..2\n"; }
my($loaded) = 0;
END {print "not ok 1\n" unless $loaded;}
use Bivio::SQL::Connection;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use Bivio::Die;
use Bivio::DieCode;
use Bivio::TypeError;
use Bivio::IO::Config;


my($_TABLE) = 't_connection_t';
Bivio::Die->eval(sub {
    Bivio::SQL::Connection->execute("drop table $_TABLE");
});
Bivio::SQL::Connection->execute(<<"EOF");
create table $_TABLE (
   f1 number,
   f2 number,
   unique(f1, f2)
)
EOF
Bivio::SQL::Connection->execute("insert into $_TABLE (f1, f2) values (1, 1)");
my($die) = Bivio::Die->catch(sub {
    Bivio::SQL::Connection->execute(
    "insert into $_TABLE (f1, f2) values (1, 1)");
});
if ($die) {
    if ($die->get('code') == Bivio::TypeError::EXISTS()) {
	my($table) = $die->get('attrs')->{table};
	my($cols) = $die->get('attrs')->{columns};
	if ($table) {
	    if ($table eq $_TABLE) {
		my(@c) = sort(@$cols);
		if ("@c" eq "f1 f2") {
		    # Whew!  We got there!  Yow baby!
		    print "ok 2\n";
		}
		else {
		    print "not ok 2 (cols=@c)\n";
		}
	    }
	    else {
		print "not ok 2 (table=$table)\n";
	    }
	}
	else {
	    print "not ok 2 (no table)\n";
	}
    }
    else {
	print "not ok 2 (code=", $die->get('code')->get_name, ")\n";
    }
}
else {
    print "not ok 2 (no die)\n";
}
