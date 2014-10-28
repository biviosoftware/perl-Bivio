# Copyright (c) 2006-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchList;
use strict;
use Bivio::Base 'Biz.ListModel';
b_use('IO.ClassLoaderAUTOLOAD');

my($_MTL) = b_use('Model.MailThreadList');
my($_BFN) = b_use('Type.BlogFileName');
my($_MFN) = b_use('Type.MailFileName');
my($_TS) = b_use('Type.String');
my($_WDN) = b_use('Type.WikiDataName');
my($_WN) = b_use('Type.WikiName');
my($_S) = b_use('Bivio.Search');
my($_REALM_FILE_FIELDS) = [qw(
    realm_file_id
    path
    path_lc
    realm_id
    modified_date_time
    is_public
    is_read_only
    user_id
)];
my($_REALM_OWNER_FIELDS) = [qw(
    name
    display_name
    realm_type
)];
my($_FP) = b_use('Type.FilePath');
my($_R) = b_use('Auth.Realm');
my($_IDI) = __PACKAGE__->instance_data_index;
my($_D) = b_use('Bivio.Die');

sub format_uri_params_with_row {
    my($self, $row) = @_;
    my($req) = $self->req;
    my($type) = _type_for_path($row->{'RealmFile.path'});
    # Order needs to be clear.  Possibly by registration order or dependencies?
    return Type_BlogFileName()->is_super_of($type)
	? {
# What if I removed realm from the task?  What would happen?
	    task_id => 'FORUM_BLOG_DETAIL',
	    realm => $row->{'RealmOwner.name'},
	    query => undef,
	    path_info => Type_BlogFileName()
		->from_absolute($row->{'RealmFile.path'}),
	}
	: Type_WikiName()->is_super_of($type)
	? Type_WikiName()->uri_hash_for_realm_and_path(
	    $row->{'RealmOwner.name'},
	    $row->{'RealmFile.path'})
	: Type_WikiDataName()->is_super_of($type)
	? Type_WikiDataName()->uri_hash_for_realm_and_path(
	    $row->{'RealmOwner.name'},
	    $row->{'RealmFile.path'})
	: Type_MailFileName()->is_super_of($type)
	? $req->with_realm(
	    $row->{'RealmOwner.name'},
	    sub {
		my($crm) = $req->get('auth_realm')
		    ->does_user_have_permissions(['FEATURE_CRM'], $req);
		my($realm_mail) = $self->new_other('RealmMail');
		return undef
		    unless $realm_mail->unsafe_load({
			realm_file_id => $row->{'RealmFile.realm_file_id'},
		    });
		my($pid) = $realm_mail->get('thread_root_id');
		#TODO: Is this necessary now that we're caching?
		#	    $row->{result_title} = $realm_mail->get('subject');
		if ($crm) {
		    my($m) = $self->new_other('CRMThread');
		    # Remote possibility that the message isn't a CRMThread
		    # due to switchover after realm had mail.
		    $pid = $m->get('crm_thread_num')
			if $m->unsafe_load({thread_root_id => $pid});
		}
		return {
		    task_id => $crm ? 'FORUM_CRM_THREAD_LIST'
			: 'FORUM_MAIL_THREAD_LIST',
		    realm => $row->{'RealmOwner.name'},
		    query => {'ListQuery.parent_id' => $pid},
		    #TODO: Integrate with View.Mail->internal_part_list (need <a name=>)
		    anchor => Model_MailThreadList()
			->get_message_anchor($row->{'RealmFile.realm_file_id'}),
		};
	    },
	)
	: {
	    task_id => 'FORUM_FILE',
	    realm => $row->{'RealmOwner.name'},
	    query => undef,
	    path_info => $row->{'RealmFile.path'},
	};
}

sub internal_initialize {
    my($self) = @_;
    return Bivio_Search()->query_list_model_initialize(
	$self,
	$self->merge_initialize_info($self->SUPER::internal_initialize, {
	    other => [
		$self->field_decl(
		    [
			qw(
                            result_uri
                            result_title
                            result_excerpt
                            result_author
                            result_realm_uri
			    result_type
                        ),
			[qw(show_byline Boolean)],
		    ],
		    'Text', 'NOT_NULL',
		),
		$self->field_decl(
		    [map("RealmOwner.$_", @$_REALM_OWNER_FIELDS)],
		    {in_select => 0},
		),
		{
		    name => 'model',
		    constraint => 'NOT_NULL',
		    type => 'Biz.PropertyModel',
		},
	    ],
	    other_query_keys => [qw(b_realm_only)],
        }),
    );
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($s, $pn, $c) = $query->unsafe_get(qw(search page_number count));
    return []
	unless defined(($_TS->from_literal($s))[0]);
    my($x) = _b_realm_only($self, $query);
    $self->[$_IDI] = {map(($_ => 1), @{$x->{private_realm_ids}})};
    my($rows);
    my($die) = $_D->catch_quietly(
	sub {
	    $rows = $_S->query({
		phrase => $s,
		offset => ($pn - 1) * $c,
		length => $c + 1,
		req => $self->req,
		%$x,
	    });
	    return;
	},
    );
    if ($die) {
	$self->req->put('search_error', $die);
	return [];
    }
    if (@$rows > $c) {
	$query->put(
	    has_next => 1,
	    next_page => $pn + 1,
	);
	pop(@$rows);
    };
    $query->put(
	has_prev => 1,
	prev_page => $pn - 1,
    ) if $pn > $query->FIRST_PAGE;
    return $rows;
}

sub internal_post_load_row {
    my($self, $row) = @_;
    return 0
	unless $self->load_row_with_model($row, $row->{model});
    $row->{show_byline} = $self->[$_IDI]->{$row->{'RealmOwner.realm_id'}}
	|| 0;
    return 1;
}

sub internal_post_load_row_with_model {
    Bivio::IO::Alert->warn_deprecated('use load_row_with_model');
    return shift->load_row_with_model(@_);
}

sub internal_private_realm_ids {
    my($self, $query) = @_;
    my($req) = $self->req;
    return $req->map_user_realms(
	sub {
	    my($rid) = shift->{'RealmUser.realm_id'};
#TODO-SECURITY: This needs to be more selective
	    return $_R->new($rid, $req)
		->does_user_have_permissions(['DATA_READ'], $req)
		? $rid : ();
	},
    );
}

sub internal_public_realm_ids {
    return [];
}

sub internal_want_all_public {
    return 1;
}

sub load_row_with_model {
    my($self, $row, $model) = @_;
    foreach my $f (@$_REALM_FILE_FIELDS) {
	$row->{"RealmFile.$f"} = $model->get($f);
    }
#TODO: realm_ids are a security issue.  Need to cache the realms, and then
#      verify they are here.  Can save the info above in
#      internal_get_realm_ids
#TODO: Optimize by caching realms
    my($ro) = $model->new_other('RealmOwner')
	->unauth_load_or_die({realm_id => $model->get_auth_id});
    foreach my $f (@$_REALM_OWNER_FIELDS) {
	$row->{"RealmOwner.$f"} = $ro->get($f);
    }
    $row->{result_realm_uri} = $ro->format_uri;
    $row->{result_title} = length($row->{title}) ? $row->{title}
	: $_FP->get_tail($model->unsafe_get('path') || '');
    $row->{result_author} = length($row->{author}) ? $row->{author}
	: $ro->unauth_load_or_die({realm_id => $row->{'RealmFile.user_id'}})
	->get('display_name');
    $row->{result_excerpt} = length($row->{excerpt}) ? $row->{excerpt}
	: '<No excerpt>';
    my($params) = $self->format_uri_params_with_row($row);
    return 0
	unless $params;
    $row->{result_uri} = $self->req->format_uri($params);
    $row->{result_type}
	= _type_for_path($row->{'RealmFile.path'})->simple_package_name;
    return 1;
}

sub _b_realm_only {
    my($self, $query) = @_;
    return {
	private_realm_ids => $self->internal_private_realm_ids($query),
	public_realm_ids => $self->internal_public_realm_ids($query),
	want_all_public => $self->internal_want_all_public($query),
    } unless $query->unsafe_get('b_realm_only');
    my($aid) = $self->req('auth_id');
    return {
	private_realm_ids => [grep($aid eq $_, @{$self->internal_private_realm_ids($query)})],
	public_realm_ids => [$aid],
	want_all_public => 0,
    };
}

sub _type_for_path {
    my($path) = @_;
    map({
	return $_
	    if $_->is_absolute($path);
    } (
	Type_BlogFileName(),
	Type_WikiName(),
	Type_WikiDataName(),
	Type_MailFileName(),
    ));
    return Type_FileName();
}

1;
