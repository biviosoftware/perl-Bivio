# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SearchList;
use strict;
use base 'Bivio::Biz::ListModel';
use Bivio::Search::Xapian;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	@{$self->internal_initialize_local_fields(
	    primary_key => [[qw(primary_id PrimaryId)]],
	    other => [
		qw(rank percent collapse_count),
		[simple_class => 'Name'],
	    ],
	    qw(Integer NOT_NULL),
	)},
	auth_id => 'RealmOwner.realm_id',
    });
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($s, $pn, $c, $rid) = $query->unsafe_get(
	qw(search page_number count auth_id));
    return []
	unless defined((Bivio::Type::String->from_literal($s))[0]);
#have_next, have_prev
    return Bivio::Search::Xapian->query(
	$s, ($pn - 1) * $c, $c, # + 1,
	$rid ? [$rid] : (),
	$self->get_request->get('Type.AccessMode')->eq_public,
    );
}

1;
