# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Shell;
use strict;
use base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD, $_UTIL);

sub USAGE {
    return <<'EOF';
usage: b-shell [options] command [args...]
commands:
    batch -- execute a list of command line operations
EOF
}

sub AUTOLOAD {
    my($func) = $AUTOLOAD;
    $func =~ s/.*:://;
    return if $func eq 'DESTROY';
    if ($func =~ /^[A-Z]/) {
	$_UTIL = Bivio::IO::ClassLoader->map_require('ShellUtil', $func);
	return @_ ? $_UTIL->main(@_) : $_UTIL;
    }
    die('you need to call a ShellUtil class first, e.g. RealmAdmin();')
	unless $_UTIL;
    return $_UTIL->main($func, @_);
}

sub batch {
    my($self) = @_;
    local($_UTIL);
    return Bivio::Die->eval_or_die(
	'use strict;' . ${$self->read_input()},
    );
}

1;
