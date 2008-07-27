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
my($_C) = b_use('FacadeComponent.Constant');

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
    return $proto->execute($req, $_C->get_value('help_wiki_realm_id', $req));
}

sub execute_not_found {
    my($proto, $req) = @_;
    my($t) = $req->get('task')->unsafe_get_attr_as_id('edit_task');
    return
	unless $t && $req->can_user_execute_task($t)
	&& $req->unsafe_get('path_info');
    $proto->get_instance('Acknowledgement')
        ->save_label('FORUM_WIKI_NOT_FOUND', $req);
    return 'edit_task';
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
	return {
# should be able to handle realm_id and convert automatically
	    realm => $req->with_realm($realm_id, sub {$req->get_nested(qw(auth_realm owner_name))}),
	    task_id => $task_id,
	    query => undef,
	    carry_path_info => 1,
	};
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
    return 'not_found_task'
	unless my $wa = $proto->use('XHTMLWidget.WikiText')
	->prepare_html($realm_id, $name, $task_id, $req);
    my($author) = '';
    my($author_name) = '';
    if ($req->unsafe_get_nested(qw(task want_author))) {
	my($e) = $_E->new($req)
	    ->unauth_load_or_die({realm_id => $wa->{user_id}});
	$author = $e->get('email');
	$author_name = $_RO->new($req)
	    ->unauth_load_or_die({realm_id => $e->get('realm_id')})
	    ->get('display_name');
    }
    $self->put(
	wiki_args => $wa,
	title => $wa->{title},
	modified_date_time => $wa->{modified_date_time},
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

sub render_html {
    return $_WT->render_html(shift->get('wiki_args'));
}

1;
