# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::WikiView;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = b_use('IO.Alert');
my($_ARF) = b_use('Action.RealmFile');
my($_C) = b_use('FacadeComponent.Constant');
my($_E) = b_use('Model.Email');
my($_FP) = b_use('Type.FilePath');
my($_MRF) = b_use('Model.RealmFile');
my($_RO) = b_use('Model.RealmOwner');
my($_WDN) = b_use('Type.WikiDataName');
my($_WN) = b_use('Type.WikiName');
my($_WT) = b_use('XHTMLWidget.WikiText');
my($_NOT_FOUND) = b_use('Bivio.DieCode')->NOT_FOUND;

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

sub execute_load_history {
    my($proto, $req, $realm_id, $task_id) = @_;
    my($path) = $req->get('path_info');
    $path =~ s{^@{[$_FP->VERSIONS_FOLDER]}}{};
    $path =~ s{@{[$_FP->VERSION_REGEX]}}{};
    $req->put(path_info => $path);
    my($name) = $_FP->get_tail($path);
    $proto->new()->put_on_request($req)->put(
	title => $name,
	is_start_page => _is_start_page($req, $name),
    );
    return;
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
    my($proto, $req, $realm_id, $task_id, $name) = @_;
    $realm_id ||= $req->get('auth_id');
    $task_id ||= $req->get('task_id');
    $name ||= $req->unsafe_get('path_info');
    unless ($name) {
	# To avoid name space issues, there always needs to be a path_info
	$req->put(path_info => $_FP->to_absolute(
	    Bivio::UI::Text->get_value('WikiView.start_page', $req)));
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
    #XXX: URIs like '/wiki/bogus.txt' redirect to a error page with URI like
    # '/edit-wiki/WikiData/bogus.txt?ack=FORUM_WIKI_NOT_FOUND' -- is this a bug?
	$req->put(path_info => $_WDN->to_absolute($name));
	return $_ARF->access_controlled_execute($req);
#TODO: Test this thoroughly with all apps
# 	my($die_code);
# 	my($rf) = $proto->unsafe_load_wiki_data(
# 	    $req->get('auth_id'),
# 	    $_MRF->parse_path($req->get('path_info')),
# 	    $req,
# 	    \$die_code,
# 	);
# 	$req->throw_die($die_code || 'DIE' => {
# 	    entity => $req->get('path_info'),
# 	    realm_id => $req->get('auth_id'),
# 	}) unless $rf;
# 	return $_ARF->set_output_for_get($rf);
    }
    my($self) = $proto->new->put_on_request($req)->put(
	name => $name,
#TODO: Use is_versioned
	can_edit => ($name !~ /;/),
	exists => 0,
    );
    my($wa) = $_WT->prepare_html($realm_id, $name, $task_id, $req);
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
	is_start_page => _is_start_page($req, $name),
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

sub unsafe_load_wiki_data {
    my($self) = shift;
    if (my $res = $_ARF->access_controlled_load(@_)) {
	return $res;
    }
    my($realm_id, $path, $req, $die_code) = @_;
    my($sid) = $_C->get_value('site_realm_id', $req);
    return
	if $sid eq $realm_id;
    my($rf) = $_MRF->new($req);
    return $rf
	if $rf->unauth_load({
	    realm_id => $sid,
	    path => $_FP->to_public($path),
	    is_public => 1,
	});
    $$die_code ||= $_NOT_FOUND;
    return undef;
}

sub _is_start_page {
    my($req, $name) = @_;
    return lc(Bivio::UI::Text->get_value('WikiView.start_page', $req))
	eq lc($name) ? 1 : 0,
}

1;
