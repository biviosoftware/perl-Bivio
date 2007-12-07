# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmCSSList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = __PACKAGE__->use('Type.FilePath');
my($_ARF) = __PACKAGE__->use('Action.RealmFile');
my($_RF) = __PACKAGE__->use('Model.RealmFile');
my($_MY_LC) = lc($_FP->to_absolute(
    __PACKAGE__->use('Type.RealmName')->SPECIAL_PLACEHOLDER . '.css'));
my($_SITE_LC) = lc($_FP->to_public($_MY_LC));
my($_WIKI_LC) = lc(__PACKAGE__->use('Type.WikiName')->to_absolute('base.css'));

sub get_content {
    return $_RF->get_content(shift, 'RealmFile.');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
        primary_key => ['RealmFile.realm_file_id'],
	order_by => [
	    {
		name => 'RealmFile.is_public',
		sort_order => 0,
	    },
	    {
		# A bit odd, but the site_realm is likely to be before
		# any other realm as far as realm_id goes.
		name => 'RealmFile.realm_id',
		sort_order => 1,
	    },
	    'RealmFile.path_lc',
	],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($req) = $self->req;
    my($auth_id, $tid) = $req->get(qw(auth_id task_id));
    my($site_id) = $req->get_nested(qw(Bivio::UI::Facade Constant))
	->get_value('site_realm_id');
    my($general) = $req->get('auth_realm')->is_general;
    my($public) = $general || $_ARF->access_is_public_only($req);
    $stmt->where(
	$stmt->OR(
	    $stmt->AND(
		$stmt->EQ('RealmFile.path_lc', [$_SITE_LC]),
		$stmt->EQ('RealmFile.realm_id', [$site_id]),
	    ),
	    $general ? () : (
		_auth_path($stmt, $auth_id, $public, $_MY_LC),
		$tid->get_name !~ /^(?:HELP|FORUM_WIKI_VIEW)$/ ? ()
		    : _auth_path($stmt, $auth_id, $public, $_WIKI_LC),
	    ),
	),
	$public ? $stmt->EQ('RealmFile.is_public', [1]) : (),
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub _auth_path {
    my($stmt, $auth_id, $public, $path) = @_;
    return $stmt->AND(
	$stmt->EQ('RealmFile.realm_id', [$auth_id]),
	$stmt->OR(
	    $stmt->EQ('RealmFile.path_lc', [lc($_FP->to_public($path))]),
	    $public ? ()
		: $stmt->EQ('RealmFile.path_lc', [$path]),
	),
    );
}

1;
