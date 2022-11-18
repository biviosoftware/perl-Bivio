# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmlessRedirect;
use strict;
use Bivio::Base 'Biz.Action';

my($_DT) = b_use('Type.DateTime');

sub execute {
    my($proto, $req) = @_;
    # Always returns false.
    my($us, $t) = $req->get(qw(user_state task));
    return $us->equals_by_name('JUST_VISITOR')
        ? 'visitor_task'
        : $req->get('auth_user')
        ? _set_realm($proto, $req, $t->get_attr_as_id('home_task'))
        || 'unauth_task'
        : b_use('Agent.TaskId')->LOGIN;
}

sub _choose_realm {
    my($proto, $req, $task) = @_;
    my($res) = sort {
        $_DT->compare(
            $a->{'RealmUser.creation_date_time'},
            $b->{'RealmUser.creation_date_time'})
        || $a->{'RealmOwner.name'} cmp $b->{'RealmOwner.name'};
    } @{$req->map_user_realms(
        sub {shift},
        {'RealmOwner.realm_type' => $task->get('realm_type')->self_or_any_group},
    )};
    return $res && $res->{'RealmUser.realm_id'};
}

sub _set_realm {
    my($proto, $req, $task) = @_;
    $task = b_use('Agent.Task')->get_by_id($task);
    $req->set_realm(_choose_realm($proto, $req, $task) || return);
    return $task->get('id');
}

1;
