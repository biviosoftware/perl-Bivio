# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::TestRealm;
use strict;
use Bivio::Base 'Bivio::ShellUtil';


sub USAGE {
    return <<'EOF';
usage: b-testrealm [options] command [args..]
commands
  delete_by_regexp regexp [realm_type] -- delete realms matching regexp
EOF
}

sub delete_by_regexp {
    my($self, $regexp, $realm_type) = shift->name_args([
	'Regexp',
	['Auth.RealmType', undef, undef],
    ], \@_);
    $self->model('RealmOwner')->do_iterate(sub {
        my($it) = @_;
	$it->unauth_delete
	    if !$it->is_default
	    && (!$realm_type || $it->get('realm_type') == $realm_type)
	    && $it->get('name') =~ $regexp;
	return 1;
    }, 'name');
    return;
}

1;
