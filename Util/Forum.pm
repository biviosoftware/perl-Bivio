# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Forum;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FN) = b_use('Type.ForumName');
my($_FP) = b_use('Type.FilePath');

sub USAGE {
    return <<'EOF';
usage: bivio Forum [options] command [args..]
commands
   delete_forum -- deletes the forum
   reparent child-forum new-parent -- updates child-forum to point at new-parent
EOF
}

sub delete_forum {
    my($self) = @_;
    my($id) = $self->model('Forum', {})->get('forum_id');
    # cascade delete doesn't pick up DAGs correctly
    $self->model('RealmDAG')->delete_all({
	child_id => $id,
    });
    $self->model('RealmOwner')->unauth_delete_realm({
	realm_id => $id,
    });
    return;
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

sub tree_paths {
    my($self, $top) = shift->name_args([[qw(child ForumName)]], \@_);
    return [_tree_paths($self, $self->unauth_realm_id($top), '/')];
}

sub _tree_paths {
    my($self, $pid, $path) = @_;
    $path = $_FP->join($path, $self->unauth_model(RealmOwner => {realm_id => $pid})->get('name'));
    return (
	$path,
	sort(
	    @{$self->model('Forum')->map_iterate(
		sub {_tree_paths($self, shift->get('forum_id'), $path)},
		'unauth_iterate_start',
		'forum_id',
		{parent_realm_id => $pid},
	    )},
        ),
    );
}

1;
