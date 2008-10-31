# Copyright (c) 1999-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ClientRedirect;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub QUERY_TAG {
   return 'x';
}

sub execute_cancel {
    my(undef, $req) = @_;
    return 'cancel';
}

sub execute_home_page_if_site_root {
    my($proto, $req) = @_;
    return {
	uri => _uri($req, Bivio::UI::Text->get_value('home_page_uri', $req)),
	query => undef,
    } if $req->get('uri') =~ m!^/?$!;
    return;
}

sub execute_next {
    return 'next';
}

sub execute_next_stateless {
    my(undef, $req) = @_;
    return {
	task_id => 'next',
	query => undef,
    };
}

sub execute_query {
    my($proto, $req) = @_;
    my($query) = $req->unsafe_get('query');
    return 'next'
	unless $query && defined(my $uri = delete($query->{$proto->QUERY_TAG}));
    $uri =~ s,^(?!\w+:|\/),\/,;
    return {
	uri => _uri($req, $uri),
	query => undef,
    };
}

sub execute_query_or_path_info {
    my($proto, $req) = @_;
    return shift->execute_query(@_)
	if ($req->unsafe_get('query') || {})->{$proto->QUERY_TAG};
    return  $req->get('path_info') ? {
	uri => _uri($req, $req->get('path_info')),
	query => $req->get('query'),
    } : {
	task_id => 'next',
	query => undef,
    };
}

sub execute_unauth_role_in_realm {
    my($proto, $req) = @_;
    my($us) = $req->get('user_state');
    return {
	query => undef,
	path_info => undef,
	task_id => _role_in_realm_user_state($req),
    };
}

sub get_realm_for_task {
    my($proto, $task, $req) = @_;
    my($t) = Bivio::Agent::Task->get_by_id($task);
    my($rt) = $t->get('realm_type');
    my($done);
    return $req->map_user_realms(sub {
	 my($row) = @_;
	 return
	     if $done;
	 my($realm) = Bivio::Auth::Realm->new($row->{'RealmOwner.name'}, $req);
	 return $realm->can_user_execute_task($t, $req) ? $realm : ();
    }, {
	'RealmOwner.realm_type' => $rt,
    })->[0] || $rt->eq_general && Bivio::Auth::Realm->get_general
    || Bivio::Die->throw(NOT_FOUND => {
	entity => $task,
	message => 'no appropriate realm for task',
    });
}

sub _role_in_realm {
    my($req) = @_;
    my($t) = $req->get('task');
    my($r) = [grep(
	$t->unsafe_get_attr_as_id($_),
	map(lc($_->get_name) . '_task', @{$req->get_auth_roles}),
    )];
    return @$r == 0 ? 'next'
	: @$r == 1 ? $r->[0]
        : Bivio::Die->die($r, ': too many roles match task attributes');
}

sub _role_in_realm_user_state {
    my($req) = @_;
    my($us) = $req->get('user_state');
    return $us->eq_just_visitor ? 'just_visitor_task'
	: $us->eq_logged_in ? _role_in_realm($req)
        : $req->with_user(
	    Bivio::Biz::Model->new($req, 'UserLoginForm')
	        ->unsafe_get_cookie_user_id($req),
	    sub {_role_in_realm($req)},
	);
}

sub _uri {
    my($req, $uri) = @_;
    return $req->format_uri({uri => $uri, query => undef, path_info => undef});
}

1;
