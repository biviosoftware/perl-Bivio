# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmlessRedirect;
use strict;
use Bivio::Base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($proto, $req) = @_;
    # Always returns false.
    my($us, $t) = $req->get(qw(user_state task));
    return $us->equals_by_name('JUST_VISITOR')
	? 'visitor_task'
	: $req->get('auth_user')
	? _set_realm($req, Bivio::Agent::Task->get_by_id($t->get('home_task')))
	|| 'unauth_task'
	: Bivio::Agent::TaskId->LOGIN;
}

sub _set_realm {
    my($req, $t) = @_;
    return unless my $l = Bivio::Biz::Model->new($req, 'UserRealmList')
	->unauth_load_all({auth_id => $req->get('auth_user_id')})
	->find_row_by_type($t->get('realm_type'));
    $req->set_realm($l->get('RealmUser.realm_id'));
    return $t->get('id');
}

1;
