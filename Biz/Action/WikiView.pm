# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::WikiView;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = Bivio::Type->get_instance('WikiName');
my($_FN) = Bivio::Type->get_instance('FileName');

sub execute {
    my($proto, $req, $realm_id) = @_;
    $realm_id ||= $req->get('auth_id');
    my($name) = $req->unsafe_get('path_info');
    unless ($name) {
	# To avoid name space issues, there always needs to be a path_info
	$req->put(path_info => '/' . $_WN->START_PAGE);
	return $req->get('task_id');
    }
    $name =~ s{^/+}{};
    unless ($_WN->is_valid($name)) {
	# SECURITY: It's ok to get $name, because it will be in the wiki
	# folder or below, which means it's anything in the wiki directory.
	$req->put(path_info => $_WN->to_absolute($name));
	$proto->get_instance('RealmFile')->unauth_execute(
	    $req, undef, $realm_id);
	return 1;
    }
    my($title) = $_FN->get_base($name);
    $title =~ s/_/ /g;
    my($self) = $proto->new->put_on_request($req, 1)->put(
	name => $name,
	title => $title,
	exists => 0,
    );
    my($html, $dt, $uid) = $proto->use('XHTMLWidget.WikiStyle')->render_html(
	$name, $req, $req->get('task_id'), $realm_id,
    );
    return $self->internal_model_not_found($req, $realm_id)
	unless $html;
    $self->put(
	html => $$html,
	modified_date_time => $dt,
	author => $req->unsafe_get_nested(qw(task want_author))
	    ? Bivio::Biz::Model->new($req, 'Email')
		->unauth_load_or_die({realm_id => $uid})->get('email')
	    : '',
	exists => 1,
	is_start_page => $name eq $_WN->START_PAGE ? 1 : 0,
    );
    return 0;
}

sub execute_help {
    my($proto, $req) = @_;
    return $proto->execute(
	$req,
	Bivio::UI::Constant->get_from_source($req)->get_value('help_wiki_realm_id'),
    );
}

sub internal_model_not_found {
    my($self, $req, $realm_id) = @_;
    my($name) = $self->get('name');
    my($t) = $req->unsafe_get_nested(qw(task edit_task));
    Bivio::Die->throw(MODEL_NOT_FOUND => {entity => $name})
	unless $t && $req->can_user_execute_task($t);
    Bivio::Biz::Action->get_instance('Acknowledgement')
        ->save_label('FORUM_WIKI_NOT_FOUND', $req);
    return 'edit_task';
}

1;
