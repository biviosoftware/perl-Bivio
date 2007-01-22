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
    my($body);
    $self->new_other('MailPartList')->execute_from_realm_file_id(
	$self->get_request, $row->{'RealmMail.realm_file_id'});
    $self->get_request->get('Model.MailPartList')->do_rows(
	sub {
	    my($list) = @_;
	    $body = $list->get_body
		if $list->get('mime_type') eq 'text/plain';
	    return 1;
	}
    );
    my($slot_headers, $comment) = $self->get_instance('Tuple')
	->split_body($body);
    $slot_headers =~ s/[_-]/ /g;
    @$row{qw(slot_headers comment)} = ($slot_headers, $comment);
    return 1;
}

1;
