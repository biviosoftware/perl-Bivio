# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::WikiView;
use strict;
use Bivio::Base 'Biz.Action';
use Bivio::UI::ViewLanguageAUTOLOAD;

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
my($_T) = b_use('FacadeComponent.Text');
my($_NOT_FOUND) = b_use('Bivio.DieCode')->NOT_FOUND;
b_use('IO.Config')->register(my $_CFG = {
    use_default_start_page => 0,
    default_start_page_realm => undef,
});

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
    return 'FORUM_WIKI_VIEW'
        if $_CFG->{use_default_start_page}
        && _create_default_start_page($proto, $req);
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
            b_use('FacadeComponent.Text')->get_value('WikiView.start_page', $req)));
        return {
# should be able to handle realm_id and convert automatically
            realm => $req->with_realm($realm_id, sub {$req->get_nested(qw(auth_realm owner_name))}),
            task_id => $task_id,
            query => undef,
            carry_path_info => 1,
        };
    }
    unless (_is_valid(\$name)) {
        $req->put(path_info => $_WDN->to_absolute($name));
        return $_ARF->access_controlled_execute($req);
#TODO: Test this thoroughly with all apps
#         my($die_code);
#         my($rf) = $proto->unsafe_load_wiki_data(
#             $req->get('auth_id'),
#             $_MRF->parse_path($req->get('path_info')),
#             $req,
#             \$die_code,
#         );
#         $req->throw_die($die_code || 'DIE' => {
#             entity => $req->get('path_info'),
#             realm_id => $req->get('auth_id'),
#         }) unless $rf;
#         return $_ARF->set_output_for_get($rf);
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

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub render_html {
    return $_WT->render_html(shift->get('wiki_args'));
}

sub unsafe_load_wiki_data {
    my($self, $path, $wiki_args, $die_code) = @_;
    $path = $_WDN->to_absolute($path, $wiki_args->{is_public});
    if (my $res = $_ARF->access_controlled_load(
        $wiki_args->{realm_id},
        $path,
        $wiki_args->{req},
        $die_code,
    )) {
        return $res;
    }
    my($sid) = $_C->get_value('site_realm_id', $wiki_args->{req});
    return
        if $sid eq $wiki_args->{realm_id};
    my($rf) = $_MRF->new($wiki_args->{req});
    return $rf
        if $rf->unauth_load({
            realm_id => $sid,
            path => $_FP->to_public($path),
            is_public => 1,
        });
    $$die_code ||= $_NOT_FOUND;
    return undef;
}

sub _create_default_start_page {
    my($proto, $req) = @_;
    my($path) = $req->unsafe_get('path_info');
    return 0
        unless $path && _is_valid(\$path) && _is_start_page($req, $path);
    my($rid) = b_use('Model.RealmOwner')->new($req)
        ->unauth_load_or_die({
            name => $_CFG->{default_start_page_realm}
            || b_use('FacadeComponent.Constant') ->get_value('site_realm_name', $req),
        })->get('realm_id');
    $path = $_WN->DEFAULT_START_PAGE_PATH;
    my($rf) = b_use('Model.RealmFile')->new($req);
    unless (
        $rf->unauth_load({
            path => $path,
            realm_id => $rid,
        })
    ) {
        $_A->warn_exactly_once($path, ': missing from realm: ', $rid);
        return 0;
    }
    $rf->create_with_content(
        {
            path => $_WN->to_absolute($_WN->START_PAGE),
            user_id => $rf->get('user_id'),
        },
        $rf->get_content,
    );
    return 1;
}

sub _is_start_page {
    my($req, $name) = @_;
    return lc($_T->get_value('WikiView.start_page', $req)) eq lc($name) ? 1 : 0;
}

sub _is_valid {
    my($name) = @_;
    $$name =~ s{^/+}{};
    return $_WN->is_valid($$name);
}

1;
