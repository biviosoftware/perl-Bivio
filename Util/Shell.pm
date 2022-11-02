# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Shell;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

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
            return $_UTIL->main($func, @$args);
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

sub u_prefix_path_env {
    sub U_PREFIX_PATH_ENV {[
        [qw(var Name)],
        [qw(+dir FilePath)]
    ]}
    my($self, $bp) = shift->parameters(\@_);
    my($res) = $ENV{$bp->{var}} ||= '';
    foreach my $d (@{$bp->{dir}}) {
        next
            unless $d
            && -d $d
            && !grep($_ =~ m{^\Q$d\E$}s, split(/:/, $res));
        $res = ":$res"
            if $res;
        $res = $d . $res;
    }
    return $res ne $ENV{$bp->{var}}
        ? qq{export $bp->{var}='$res'} : ();
}

1;
