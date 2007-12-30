# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchList;
use strict;
use base 'Bivio::Biz::ListModel';
use Bivio::Search::Xapian;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_BFN) = Bivio::Type->get_instance('BlogFileName');
my($_BT) = Bivio::Type->get_instance('BlogTitle');
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

sub RESULT_EXCERPT_LENGTH {
    return 500;
}

sub internal_realm_ids {
    my($self, $query) = @_;
    return (
	$self->get_request->map_user_realms(
	    sub {shift->{'RealmUser.realm_id'}}),
        1,
    );
}

sub internal_initialize {
    my($self) = @_;
    return Bivio::Search::Xapian->query_list_model_initialize(
	$self,
	$self->merge_initialize_info($self->SUPER::internal_initialize, {
	    other => [
		@{$self->internal_initialize_local_fields(
		    [qw(result_uri result_category result_class result_excerpt)],
		    'Text', 'NOT_NULL',
		)},
		map(+{name => $_, in_select => 0},
		    map("RealmOwner.$_", @$_REALM_OWNER_FIELDS),
	            map("RealmFile.$_", @$_REALM_FILE_FIELDS),
		),
	    ],
        }),
    );
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($s, $pn, $c) = $query->unsafe_get(qw(search page_number count));
    return []
	unless defined((Bivio::Type::String->from_literal($s))[0]);
    my($rows) = Bivio::Search::Xapian->query(
	$s, ($pn - 1) * $c, $c + 1,
	$self->internal_realm_ids($query),
    );
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
    my($rf) = $self->new_other('RealmFile');
    # There's a possibility that the the search db is out of sync with db
    return $rf->unauth_load({realm_file_id => $row->{primary_id}})
	? $self->internal_post_load_row_with_model($row, $rf)
	: 0;
}

sub internal_post_load_row_with_model {
    my($self, $row, $model) = @_;
    foreach my $f (@$_REALM_FILE_FIELDS) {
	$row->{"RealmFile.$f"} = $model->get($f);
    }
#TODO: Optimize by caching realms
    my($ro) = $model->new_other('RealmOwner')
	->unauth_load_or_die({realm_id => $model->get('realm_id')});
    foreach my $f (@$_REALM_OWNER_FIELDS) {
	$row->{"RealmOwner.$f"} = $ro->get($f);
    }
    if ($_BFN->is_absolute($row->{'RealmFile.path'})) {
	$row->{result_uri} = $self->get_request->format_uri({
	    task_id => 'FORUM_BLOG_DETAIL',
	    realm => $row->{'RealmOwner.name'},
	    query => undef,
	    path_info => $_BFN->from_absolute($row->{'RealmFile.path'}),
	});
	$row->{result_excerpt} = $_BT->from_content($model->get_content);
    }
    else {
	$row->{result_uri} = $self->get_request->format_uri({
	    task_id => 'FORUM_FILE',
	    realm => $row->{'RealmOwner.name'},
	    query => undef,
	    path_info => $row->{'RealmFile.path'},
	});
	$row->{result_excerpt} = substr(
	    ${$model->get_content},
	    0, $self->RESULT_EXCERPT_LENGTH,
	);
    }
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

1;
