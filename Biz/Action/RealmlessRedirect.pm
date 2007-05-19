# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmlessRedirect;
use strict;
use Bivio::Base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

sub execute {
    my($proto, $req) = @_;
    # Always returns false.
    my($us, $t) = $req->get(qw(user_state task));
    return $us->equals_by_name('JUST_VISITOR')
	? 'visitor_task'
	: $req->get('auth_user')
	? _set_realm($proto, $req, $t->get('home_task'))
	|| 'unauth_task'
	: Bivio::Agent::TaskId->LOGIN;
}

sub internal_choose_realm {
    my($proto, $user_realms, $task) = @_;
    my($res);
    my($rt) = $task->get('realm_type');
    $user_realms->do_rows(sub {
        my($row) = shift->get_shallow_copy;
	$res = $row
	    if $rt->equals($row->{'RealmOwner.realm_type'})
	    && (!$res
	    || $_DT->compare(
		$res->{'RealmUser.creation_date_time'},
		$row->{'RealmUser.creation_date_time'},
	    ) < 0
	    || ($res->{'RealmOwner.name'} cmp $row->{'RealmOwner.name'}) < 0);
        return 1;
    });
    return $res && $res->{'RealmUser.realm_id'};
}

sub _set_realm {
    my($proto, $req, $task) = @_;
    $task = Bivio::Agent::Task->get_by_id($task);
    $req->set_realm(
	$proto->internal_choose_realm(
	    Bivio::Biz::Model->new($req, 'UserRealmList')
	        ->unauth_load_all({auth_id => $req->get('auth_user_id')}),
	    $task,
	) || return
    );
    return $task->get('id');
}

1;
