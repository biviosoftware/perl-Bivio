# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Forum;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_FN) = b_use('Type.ForumName');
my($_FP) = b_use('Type.FilePath');
my($_FM) = b_use('Biz.FormModel');
my($_R) = b_use('Auth.Role');
my($_M) = b_use('Biz.Model');

sub USAGE {
    return <<'EOF';
usage: bivio Forum [options] command [args..]
commands
   cascade_forum_activity -- most recent forum and subforum activity
   delete_forum -- deletes the forum
   forum_activity -- most recent forum activity
   make_admin_of_forum -- make user admin of forum (and subforums)
   reparent child-forum new-parent -- updates child-forum to point at new-parent
EOF
}

sub cascade_forum_activity {
    return _activity(shift, '_cascade');
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

sub forum_activity {
    return _activity(shift);
}

sub make_admin_of_forum {
    my($self) = @_;
    $self->assert_have_user;
    $self->assert_not_general;
    my($req) = $self->get_request;
    my($uid) = $req->get('auth_user_id');
    my($fid) = $req->get('auth_id');
    $self->usage_error('-realm must be specified')
	unless defined($fid);
    $self->usage_error('-realm must be a forum')
	unless $req->get_nested(qw(auth_realm type))->eq_forum;
    $_M->new($req, 'RealmUser')->delete_main_roles($fid, $uid);
    $_FM->new($req, 'ForumUserAddForm')->process({
	administrator => 1,
	# Won't add MAIL_RECIPIENT role, but also
	# won't remove existing MAIL_RECIPIENT roles.
	not_mail_recipient => 1,
	'RealmUser.realm_id' => $fid,
	'User.user_id' => $uid,
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

sub _activity {
    my($self, $prefix) = @_;
    $prefix ||= '';
    my($method) = $prefix . '_forum_activity';
    my($activity) = {};
    $self->$method($activity);
    my($buf) = "- Most recent activity -\n";
    foreach my $f (keys(%$activity)) {
	$buf .= "$f: ";
	$buf .= $_DT->to_local_string(
	    $activity->{$f}->{'modified_date_time'});
	$buf .= ' in ' . $activity->{$f}->{'forum_name'};
	$buf .= "\n";
    }
    return $buf;
}

sub _cascade_forum_activity {
    my($self, $activity) = @_;
    my($req) = $self->req;
    $_M->new_other('Forum')->set_ephemeral->do_iterate(sub {
        my($forum) = @_;
	my($fid) = $forum->get('forum_id');
	$req->with_realm(
	    $fid,
	    sub {
		_forum_activity($self, $activity);
		_cascade_forum_activity($self, $activity)
		    unless $forum->is_leaf;
	    },
	);
	return 1;
    }, 'unauth_iterate_start', {
	parent_realm_id => $req->get('auth_id'),
    });
    _forum_activity($self, $activity);
    return;
}

sub _forum_activity {
    my($self, $activity) = @_;
    my($fn) = $self->req->get_nested(qw(auth_realm owner_name));
    foreach my $m (qw(RealmOwner Forum)) {
	foreach my $r (@{$_M->new_other($m)->set_ephemeral
			     ->internal_get_sql_support->get_children}) {
	    my($spn) = $r->[0]->simple_package_name;
	    next
		unless grep(/modified_date_time/,
			@{$_M->new_other($spn)->set_ephemeral->get_keys});
	    $_M->new($self->req, $spn)->set_ephemeral->do_iterate(
		sub {
		    my($it) = @_;
		    $activity->{$spn} = {
			forum_name => $fn,
			modified_date_time => $it->get('modified_date_time'),
		    } if $_DT->is_greater_than($it->get('modified_date_time'),
			$activity->{$spn}->{modified_date_time});
		    return 0;
		}, 'iterate_start', 'modified_date_time desc',
	    );
	}
    }
    return;
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
