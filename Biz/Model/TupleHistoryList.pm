# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleHistoryList;
use strict;
use base 'Bivio::Biz::Model::MailThreadList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other => [
	    map(+{
		name => $_,
		type => 'Text64K',
		constraint => 'NONE',
	    }, qw(slot_headers comment)),
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    @$row{qw(slot_headers comment)} = $self->get_instance('Tuple')
	->split_rfc822($self->new_other('RealmFile')->unauth_load_or_die({
	    realm_id => $row->{'RealmMail.realm_id'},
	    realm_file_id => $row->{'RealmMail.realm_file_id'},
	})->get_content);
    return $row->{slot_headers} ? 1 : 0;
}

1;
