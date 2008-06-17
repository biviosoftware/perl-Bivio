# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_BFN) = b_use('Type.BlogFileName');
my($_MFN) = b_use('Type.MailFileName');
my($_S) = b_use('Type.String');
my($_WDN) = b_use('Type.WikiDataName');
my($_WN) = b_use('Type.WikiName');
my($_X) = b_use('Search.Xapian');
my($_REALM_FILE_FIELDS) = [qw(
    realm_file_id
    path
    realm_id
    modified_date_time
    is_public
    is_read_only
    user_id
)];
my($_REALM_OWNER_FIELDS) = [qw(
    name
    display_name
)];
my($_FP) = b_use('Type.FilePath');

sub internal_initialize {
    my($self) = @_;
    return $_X->query_list_model_initialize(
	$self,
	$self->merge_initialize_info($self->SUPER::internal_initialize, {
	    other => [
		@{$self->internal_initialize_local_fields(
		    [qw(result_uri result_title result_excerpt result_author)],
		    'Text', 'NOT_NULL',
		)},
		map(+{name => $_, in_select => 0},
		    map("RealmOwner.$_", @$_REALM_OWNER_FIELDS),
#	            map("RealmFile.$_", @$_REALM_FILE_FIELDS),
		),
		{
		    name => 'model',
		    constraint => 'NOT_NULL',
		    type => 'Biz.PropertyModel',
		},
	    ],
        }),
    );
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($s, $pn, $c) = $query->unsafe_get(qw(search page_number count));
    return []
	unless defined(($_S->from_literal($s))[0]);
    my($rows) = $_X->query({
	phrase => $s,
	offset => ($pn - 1) * $c,
	length => $c + 1,
	private_realm_ids => $self->internal_private_realm_ids($query),
	public_realm_ids => $self->internal_public_realm_ids($query),
	want_all_public => $self->internal_want_all_public($query),
    });
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
    my($m) = $self->new_other($row->{simple_class});
    # There's a possibility that the the search db is out of sync with db
    return $m->unauth_load({$m->get_primary_id_name => $row->{primary_id}})
	? $self->internal_post_load_row_with_model($row, $m)
	: 0;
}

sub internal_post_load_row_with_model {
    my($proto, $row, $model) = @_;
    foreach my $f (@$_REALM_FILE_FIELDS) {
	$row->{"RealmFile.$f"} = $model->get($f);
    }
#TODO: realm_ids are a security issue.  Need to cache the realms, and then
#      verify they are here.  Can save the info above in
#      internal_get_realm_ids
#TODO: Optimize by caching realms
    my($ro) = $model->new_other('RealmOwner') ->unauth_load_or_die({
	realm_id => $model->get_auth_id,
    });
    foreach my $f (@$_REALM_OWNER_FIELDS) {
	$row->{"RealmOwner.$f"} = $ro->get($f);
    }
    $row->{result_title} = $_FP->get_tail($model->unsafe_get('path') || '');
    $row->{result_author}
	= $ro->unauth_load_or_die({realm_id => $row->{'RealmFile.user_id'}})
	->get('display_name');
    my($req) = $model->req;
    my($realm_mail);
    $row->{result_uri} = $req->format_uri(
# Order needs to be clear.  Possibly by registration order or dependencies?
	$_BFN->is_absolute($row->{'RealmFile.path'}) ? {
# What if I removed realm from the task?  What would happen?
	    task_id => 'FORUM_BLOG_DETAIL',
	    realm => $row->{'RealmOwner.name'},
	    query => undef,
	    path_info => $_BFN->from_absolute($row->{'RealmFile.path'}),
	} : $_WN->is_absolute($row->{'RealmFile.path'}) ?
	    $_WN->uri_hash_for_realm_and_path(
		$row->{'RealmOwner.name'},
		$row->{'RealmFile.path'})
	  : $_WDN->is_absolute($row->{'RealmFile.path'}) ?
	    $_WDN->uri_hash_for_realm_and_path(
		$row->{'RealmOwner.name'},
		$row->{'RealmFile.path'})
	  : $_MFN->is_absolute($row->{'RealmFile.path'}) ? $req->with_realm(
	    $row->{'RealmOwner.name'},
	    sub {
		return {
		    task_id => $req->get('auth_realm')
			->does_user_have_permissions(['FEATURE_CRM'], $req)
		        ? 'FORUM_CRM_THREAD_LIST' : 'FORUM_MAIL_THREAD_LIST',
		    realm => $row->{'RealmOwner.name'},
		    query => {
			'ListQuery.parent_id' => (
			    $realm_mail = $model->new_other('RealmMail')
			    ->load({
				realm_file_id =>
				$row->{'RealmFile.realm_file_id'},
			    }))->get('thread_root_id'),
		    },
#TODO: Integrate with View.Mail->internal_part_list (need <a name=>)
		    anchor => $row->{'RealmFile.realm_file_id'},
		};
	    },
	) : {
	    task_id => 'FORUM_FILE',
	    realm => $row->{'RealmOwner.name'},
	    query => undef,
	    path_info => $row->{'RealmFile.path'},
	},
    );
    _excerpt($model, $realm_mail, $row);
    return 1;
}

sub internal_private_realm_ids {
    my($self, $query) = @_;
    return $self->get_request->map_user_realms(
	sub {shift->{'RealmUser.realm_id'}});
}

sub internal_public_realm_ids {
    return [];
}

sub internal_want_all_public {
    return 1;
}

sub parse_query_from_request {
    my($self) = shift;
    my($q) = $self->SUPER::parse_query_from_request(@_);
    return unless my $f = $self->get_request->unsafe_get('form_model');
    if (defined(my $s = $q->unsafe_get('search'))) {
	$f->put_search_value($s);
    }
    else {
	$q->put(search => $f->unsafe_get('search'));
    }
    return $q;
}

sub _excerpt {
    my($model, $realm_mail, $row) = @_;
    my($p) = $_X->excerpt_model($model);
    foreach my $n (qw(excerpt title author)) {
	my($v) = $p && $p->unsafe_get($n);
	$row->{"result_$n"} = $v
	    if defined($v) && length($v);
    }
    $row->{result_title} = $realm_mail->get('subject')
	if $realm_mail;
    return;

}

1;
