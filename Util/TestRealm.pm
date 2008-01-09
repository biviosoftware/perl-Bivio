# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::TestRealm;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-testrealm [options] command [args..]
commands
  delete_by_regexp regexp -- delete realms matching regexp
EOF
}

sub delete_by_regexp {
    my($self, $regexp) = shift->arg_list(\@_, [['Regexp']]);
    $self->model('RealmOwner')->do_iterate(sub {
        my($it) = @_;
	$it->unauth_delete
	    if !$it->is_default && $it->get('name') =~ $regexp;
	return 1;
    }, 'name');
    return;
}

1;
