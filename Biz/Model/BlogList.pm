# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BlogList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_ARF) = b_use('Action.RealmFile');
my($_BC) = b_use('Type.BlogContent');
my($_BFN) = b_use('Type.BlogFileName');
my($_DT) = b_use('Type.DateTime');
my($_FP) = b_use('Type.FilePath');
my($_RF) = b_use('Model.RealmFile');
my($_S) = b_use('Bivio.Search');

sub PAGE_SIZE {
    return 5;
}

sub execute_load_this {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    my($query) = $self->parse_query_from_request;
    unless ($query->unsafe_get('this')) {
	my($t) = $_BFN->from_literal($req->unsafe_get('path_info'));
	return 'DEFAULT_ERROR_REDIRECT_NOT_FOUND'
	    unless $t;
	$query->put(this => [$t]);
    }
    $self->load_this($query);
    return 0;
}

sub get_creation_date_time {
    return $_DT->from_literal_or_die(shift->get('path_info'));
}

sub get_modified_date_time {
    return shift->get('RealmFile.modified_date_time');
}

sub get_rss_author {
    my($self) = @_;
    return $self->new_other('RealmOwner')->unauth_load_by_id_or_name_or_die(
        $self->get('RealmFile.realm_id'),
    )->get('display_name');
}

sub get_rss_summary {
    my($self) = @_;
    return $_S->get_excerpt_for_primary_id(
	$self->get('RealmFile.realm_file_id'),
	$self->new_other('RealmFile'),
    );
}

sub get_rss_title {
    return shift->get('title');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        auth_id => 'RealmFile.realm_id',
	as_string_fields => [qw(RealmFile.realm_id RealmFile.path)],
        primary_key => [{
	    name => 'path_info',
	    type => 'BlogFileName',
	    in_select => 1,
	    # Handles PUBLIC/PRIVATE sorting by blog creation date
	    select_value =>
		qq{SUBSTRING(path_lc FROM '\%#"@{[$_BFN->SQL_LIKE_BASE]}#"' FOR '#') as path_info},
	    sort_order => 0,
	}],
	order_by => [qw(
	    path_info
	    RealmFile.modified_date_time
            RealmFile.path
	)],
	other => [qw(
	    RealmFile.is_public
	    RealmFile.realm_file_id
        ),
	    [qw(RealmFile.user_id RealmOwner.realm_id Email.realm_id)],
	    'Email.email',
	    'RealmOwner.display_name',
	    'RealmOwner.name',
	    {
		name => 'title',
		type => 'BlogTitle',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'content',
		type => 'BlogBody',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'text',
		type => 'Text64K',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'query',
		type => 'Line',
		constraint => 'NONE',
	    },
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{path_info} = $_BFN->from_literal_or_die($row->{path_info});
    $row->{text} = ${$_RF->get_content($self, 'RealmFile.', $row)};
    my($res) = [$_BC->split(\$row->{text})];
    if (grep(ref($_), @$res)) {
	b_warn(
	    $row->{'RealmFile.realm_id'},
	    ',',
	    $row->{'RealmFile.path'},
	    ': BlogContent->split error: ',
	    $res,
	);
	$self->req->if_test(sub {b_die('file format error')});
	return 0;
    }
    ($row->{title}, $row->{content}) = @$res;
    $row->{query} = undef;
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $self->new_other('RealmFileList')
	->prepare_statement_for_access_mode($stmt, $_BFN);
    $stmt->where(['Email.location', [b_use('Model.Email')->DEFAULT_LOCATION]]);
    return shift->SUPER::internal_prepare_statement(@_);
}

sub unsafe_get_author_image_uri {
    my($self) = @_;
#TODO: should come from the user's file area, user avatar
    my($file) = 'avatar_' . $self->get('RealmOwner.name') . '.png';
    my($path) = $_FP->join($_FP->WIKI_DATA_FOLDER, $file);
    my($uri) = $self->req->format_uri('FORUM_WIKI_VIEW', undef, undef, $file);
    my($die_code);
    if ($_ARF->access_controlled_load(
	$self->req('auth_id'),
	$path,
	$self->req,
	\$die_code,
    )) {
	return $uri;
    }
    return undef;
}

1;
