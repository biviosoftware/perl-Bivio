# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Forum;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FN) = b_use('Type.ForumName');

sub USAGE {
    return <<'EOF';
usage: bivio Forum [options] command [args..]
commands
   reparent child-forum new-parent -- updates child-forum to point at new-parent
EOF
}

sub reparent {
    my($self, $child, $new_parent) = shift->name_args([
	[qw(child ForumName)],
	[qw(new_parent ForumName)],
    ], \@_);
    # child can't be a top level forum; can't change change top-level
    $self->usage_error($child, ': cannot change top-level forum name')
	unless $_FN->extract_top($child) eq $_FN->extract_top($new_parent);
    $self->unauth_model(Forum => {
	forum_id => $self->unauth_model('RealmOwner', {name => $child})
	->get('realm_id'),
    })->update({
	parent_realm_id => $self->unauth_model(RealmOwner => {
	    name => $new_parent,
	    realm_type => b_use('Auth.RealmType')->FORUM,
	})->get('realm_id'),
    });
    return;
}

1;
