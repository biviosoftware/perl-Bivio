# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchList;
use strict;
use base 'Bivio::Biz::ListModel';
use Bivio::Search::Xapian;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_BFN) = __PACKAGE__->use('Type.BlogFileName');
my($_MFN) = __PACKAGE__->use('Type.MailFileName');
my($_P) = __PACKAGE__->use('Search.Parseable');
my($_RF) = __PACKAGE__->use('SearchParser.RealmFile');
my($_WN) = __PACKAGE__->use('Type.WikiName');
my($_FP) = __PACKAGE__->use('Type.FilePath');
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
my($_A) = __PACKAGE__->use('Mail.Address');

sub RESULT_EXCERPT_LENGTH {
    return 250;
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
		    [qw(result_uri result_title result_excerpt result_who)],
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
    my($proto, $row, $model) = @_;
    foreach my $f (@$_REALM_FILE_FIELDS) {
	$row->{"RealmFile.$f"} = $model->get($f);
    }
#TODO: realm_ids are a security issue.  Need to cache the realms, and then
#      verify they are here.  Can save the info above in
#      internal_get_realm_ids
#TODO: Optimize by caching realms
    my($ro) = $model->new_other('RealmOwner')
	->unauth_load_or_die({realm_id => $model->get('realm_id')});
    foreach my $f (@$_REALM_OWNER_FIELDS) {
	$row->{"RealmOwner.$f"} = $ro->get($f);
    }
    $row->{result_who}
	= $ro->unauth_load_or_die({realm_id => $row->{'RealmFile.user_id'}})
	->get('display_name');
    my($req) = $model->req;
    my($other);
    $row->{result_uri} = $req->format_uri(
	$_BFN->is_absolute($row->{'RealmFile.path'}) ? {
	    task_id => 'FORUM_BLOG_DETAIL',
	    realm => $row->{'RealmOwner.name'},
	    query => undef,
	    path_info => $_BFN->from_absolute($row->{'RealmFile.path'}),
	} : $_WN->is_absolute($row->{'RealmFile.path'}) ? {
	    task_id => 'FORUM_WIKI_VIEW',
	    realm => $row->{'RealmOwner.name'},
	    query => undef,
	    path_info => $_WN->from_absolute($row->{'RealmFile.path'}),
	} : $_MFN->is_absolute($row->{'RealmFile.path'}) ? $req->with_realm(
	    $row->{'RealmOwner.name'},
	    sub {
		return {
		    task_id => $req->get('auth_realm')
			->does_user_have_permissions(['FEATURE_CRM'], $req)
		        ? 'FORUM_CRM_THREAD_LIST' : 'FORUM_MAIL_THREAD_LIST',
		    realm => $row->{'RealmOwner.name'},
		    query => {
			'ListQuery.parent_id' => ($other = $model
			    ->new_other('RealmMail')
			    ->load({
				realm_file_id =>
				$row->{'RealmFile.realm_file_id'},
			    }))->get('thread_root_id'),
		    },
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
    _excerpt($proto, $row, $model, $other);
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
    my($proto, $row, $model, $other_model) = @_;
    my($x) = $_RF->parse($_P->new($model));
    $row->{result_title} = $_FP->get_tail($model->get('path'));
    return $row->{result_excerpt} = ''
	unless $x;
    $row->{result_title} = $x->{title}
	if length($x->{title});
    my($max) = $proto->RESULT_EXCERPT_LENGTH;
    my($num_words) = $max/6;
    my($words) = [grep(
	length($_),
	split(
	    ' ',
	    ref($other_model) =~ /RealmMail/
		? _trim_mail_header($x->{text}, $row)
		: ${$x->{text}},
	    $num_words,
	),
    )];
    pop(@$words)
	if @$words >= $num_words;
    $max *= 1.5;
    my($trimmed_text) = 0;

    while (1) {
	last if length($row->{result_excerpt} = join(' ', @$words)) < $max;
	pop(@$words);
	$trimmed_text = 1;
    }
    $row->{result_excerpt} .= '...'
	if $trimmed_text;
    return;
}

sub _trim_mail_header {
    my($v, $row) = @_;
    my($h, $b) = split(/\n\n/, $$v, 2);
    if ($h =~ /^from:\s+(.+)/mi) {
	my($a, $n) = $_A->parse($1);
	$row->{'result_who'} = $n
	    if $n ||= ($a =~ /(.+?)\@/)[0];
    }
    return $b;
}

1;
