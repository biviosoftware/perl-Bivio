# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::WikiView;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = __PACKAGE__->use('IO.Alert');
my($_ARF) = __PACKAGE__->use('Action.RealmFile');
my($_E) = __PACKAGE__->use('Model.Email');
my($_FN) = __PACKAGE__->use('Type.FileName');
my($_RO) = __PACKAGE__->use('Model.RealmOwner');
my($_WDN) = __PACKAGE__->use('Type.WikiDataName');
my($_WN) = __PACKAGE__->use('Type.WikiName');
my($_WT) = __PACKAGE__->use('XHTMLWidget.WikiText');

sub execute {
    my($proto) = shift;
    return $proto->execute_prepare_html(@_) || do {
	my($req) = @_;
	my($self) = $req->get($proto->package_name);
	$self->put(html => $self->render_html($req));
	0;
    };
}

sub execute_help {
    my($proto, $req) = @_;
    return $proto->execute(
	$req,
	Bivio::UI::Constant->get_from_source($req)->get_value('help_wiki_realm_id'),
    );
}

sub execute_prepare_html {
    my($proto, $req, $realm_id, $task_id) = @_;
    $realm_id ||= $req->get('auth_id');
    $task_id ||= $req->get('task_id');
    my($name) = $req->unsafe_get('path_info');
    my($sp) = Bivio::UI::Text->get_value('WikiView.start_page', $req);
    unless ($name) {
	# To avoid name space issues, there always needs to be a path_info
	$req->put(path_info => $_FN->to_absolute($sp));
	return $task_id;
    }
    $name =~ s{^/+}{};
    unless ($_WN->is_valid($name)) {
	$req->put(path_info => $_WDN->to_absolute($name));
	return $_ARF->access_controlled_execute($req);
    }
    my($self) = $proto->new->put_on_request($req)->put(
	name => $name,
	exists => 0,
    );
    my($wa, $dt, $uid) = $proto->use('XHTMLWidget.WikiStyle')
	->prepare_html($realm_id, $name, $task_id, $req);
    return $self->internal_model_not_found($req, $realm_id)
	unless $wa;
    my($author) = '';
    my($author_name) = '';
    if ($req->unsafe_get_nested(qw(task want_author))) {
	my($e) = $_E->new($req)->unauth_load_or_die({realm_id => $uid});
	$author = $e->get('email');
	$author_name = $_RO->new($req)
	    ->unauth_load_or_die({realm_id => $e->get('realm_id')})
	    ->get('display_name');
    }
    $self->put(
	wiki_args => $wa,
	title => $wa->{title},
	modified_date_time => $dt,
	author => $author,
	author_email => $author,
	author_name => $author_name,
	exists => 1,
	is_start_page => lc($name) eq lc($sp) ? 1 : 0,
    );
    return 0;
}

sub get {
    my($self, @keys) = @_;
    $_A->warn_deprecated('use author_email in place of author')
        if grep($_ eq 'author', @keys);
    return shift->SUPER::get(@_);
}

sub internal_model_not_found {
    my($self, $req, $realm_id) = @_;
    my($name) = $self->get('name');
    my($t) = $req->unsafe_get_nested(qw(task edit_task));
    Bivio::Die->throw_quietly(MODEL_NOT_FOUND => {entity => $name})
	unless $t && $req->can_user_execute_task($t);
    Bivio::Biz::Action->get_instance('Acknowledgement')
        ->save_label('FORUM_WIKI_NOT_FOUND', $req);
    return 'edit_task';
}

sub render_html {
    return $_WT->render_html(shift->get('wiki_args'));
}

1;
