# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::WikiView;
use strict;
use base 'Bivio::Biz::Action';
use Bivio::UI::XHTML::Widget::WikiStyle;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = Bivio::Type->get_instance('WikiName');
my($_FN) = Bivio::Type->get_instance('FileName');

sub execute {
    my($proto, $req, $realm_id) = @_;
    $realm_id ||= $req->get('auth_id');
    my($name) = $req->unsafe_get('path_info');
    unless ($name) {
	# To avoid name space issues, there always needs to be a path_info
	$req->put(path_info => '/StartPage');
	return $req->get('task_id');
    }
    $name =~ s{^/+}{};
    unless ($_WN->is_valid($name)) {
#TODO: AccessMode
	$req->put(path_info => $_WN->to_absolute($name));
	$proto->get_instance('RealmFile')->unauth_execute(
	    $req, undef, $realm_id);
	return 1;
    }
    my($self) = $proto->new->put_on_request($req, 1)->put(
	name => $name,
	exists => 0,
    );
    my($html, $dt, $uid) = Bivio::UI::XHTML::Widget::WikiStyle->render_html(
	$name, $req, $req->get('task_id'), $realm_id,
    );
    unless ($html) {
	if ($name eq 'StartPage') {
	    my($rf) = Bivio::Biz::Model->new($req, 'RealmFile');
	    $rf->unauth_load({
#TODO: AccessMode
		path => $_WN->to_absolute('defaultstartpage'),
		realm_id => Bivio::UI::Constant
		    ->get_from_source($req)->get_value('help_wiki_realm_id'),
	    });
	    if ($rf->is_loaded) {
		$rf->copy_deep({
#TODO: AccessMode
		    path => $_WN->to_absolute($name),
		    realm_id => $realm_id,
		});
		return $req->get('task_id');
	    }
	}
	my($t) = $req->unsafe_get_nested(qw(task edit_task));
	Bivio::Die->throw(MODEL_NOT_FOUND => {entity => $name})
	    unless $t && $req->can_user_execute_task($t);
	Bivio::Biz::Action->get_instance('Acknowledgement')
	    ->save_label('FORUM_WIKI_NOT_FOUND', $req);
	return 'edit_task';
    }
    $self->put(
	html => $$html,
	modified_date_time => $dt,
	author => $req->unsafe_get_nested(qw(task want_author))
	    ? Bivio::Biz::Model->new($req, 'Email')
		->unauth_load_or_die({realm_id => $uid})->get('email')
	    : '',
	exists => 1,
	is_start_page => $name eq 'StartPage' ? 1 : 0,
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

1;
