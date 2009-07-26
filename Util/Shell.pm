# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Shell;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD, $_UTIL);
my($_CL) = b_use('IO.ClassLoader');

sub USAGE {
    return <<'EOF';
usage: b-shell [options] command [args...]
commands:
    batch -- execute a list of command line operations
EOF
}

sub AUTOLOAD {
    return $_CL->call_autoload(
	$AUTOLOAD,
	\@_,
	sub {
	    my($func, $args) = @_;
	    if ($func =~ /^[A-Z]/) {
		$_UTIL = b_use('ShellUtil', $func);
		return @$args ? $_UTIL->main(@$args) : $_UTIL;
	    }
	    b_die('call a ShellUtil class first, e.g. RealmAdmin();')
		unless $_UTIL;
	    return $_UTIL->main($func, @_);
	},
    );
}

sub batch {
    my($self) = @_;
    local($_UTIL);
    return Bivio::Die->eval_or_die(
	'use strict;' . ${$self->read_input()},
    );
}

1;
