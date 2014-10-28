# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::None;
use strict;
use Bivio::Base 'Collection.Attributes';

my($_P) = b_use('Search.Parser');

sub acquire_lock {
    return;
}

sub delete_model {
    return;
}

sub destroy_db {
    return;
}

sub excerpt_model {
    my(undef, $model) = @_;
    return $_P->new_excerpt($model);
}

sub execute {
    return 0;
}

sub get_excerpt_for_primary_id {
    my($p) = shift->get_values_for_primary_id(@_);
    return $p && $p->{excerpt} || '';
}

sub get_values_for_primary_id {
    my($proto, $primary_id, $model) = @_;
    my($req) = $model->req;
    return $req->perf_time_op(__PACKAGE__, sub {
	return _parse_values(
	    $model->is_loaded ? $model
		: $model->unauth_load_or_die({
		    $model->get_info('primary_key_names')->[0] => $primary_id,
		}),
	);
    });
}

sub query {
    return [];
}

sub query_list_model_initialize {
    my(undef, $list_model, $parent_info) = @_;
    return $list_model->merge_initialize_info($parent_info, {
	version => 1,
	$list_model->field_decl(
	    primary_key => [[qw(primary_id PrimaryId)]],
	    other => [
		qw(rank percent collapse_count),
		[qw(author DisplayName NONE)],
		[qw(author_email Email NONE)],
		[qw(author_user_id User.user_id NONE)],
		[qw(excerpt Text NONE)],
		[qw(title Text NONE)],
		[simple_class => 'Name'],
	    ],
	    qw(Integer NOT_NULL),
	),
	auth_id => 'RealmOwner.realm_id',
    });
}

sub update_model {
    return;
}

sub _parse_values {
    my($model) = @_;
    my($p) = $_P->new_excerpt($model);
    return $p ? $p->get_shallow_copy : undef;
}

1;
