# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchList;
use strict;
use base 'Bivio::Biz::ListModel';
use Bivio::Search::Xapian;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_auth_realm_ids {
    my($self, $query) = @_;
    return $query->unsafe_get('auth_id') ? [$query->get('auth_id')] : []
}

sub internal_initialize {
    my($self) = @_;
    return Bivio::Search::Xapian->query_list_model_initialize(
	$self,
	$self->SUPER::internal_initialize,
    );
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($s, $pn, $c) = $query->unsafe_get(qw(search page_number count));
    return []
	unless defined((Bivio::Type::String->from_literal($s))[0]);
    my($rows) = Bivio::Search::Xapian->query(
	$s, ($pn - 1) * $c, $c + 1,
	$self->internal_auth_realm_ids($query),
	$self->get_request->get('Type.AccessMode')->eq_public,
    );
    if (@$rows > $c) {
	$query->put(has_next => 1);
	pop(@$rows);
    };
    $query->put(has_prev => 1)
	if $pn > 1;
    return $rows;
}

1;
