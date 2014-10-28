# Copyright (c) 2006-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TupleHistoryList;
use strict;
use Bivio::Base 'Model.MailThreadList';

my($_T) = b_use('Model.Tuple');

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
	$self->req, $row->{'RealmMail.realm_file_id'});
    $self->req('Model.MailPartList')->do_rows(
	sub {
	    my($list) = @_;
	    $body = $list->get_body
		if $list->get('mime_type') eq 'text/plain';
	    return 1;
	}
    );
    my($slot_headers, $comment) = $_T->split_body($body);
    $slot_headers =~ s/[_-]/ /g
	if $slot_headers;
    @$row{qw(slot_headers comment)} = ($slot_headers, $comment);
    return 1;
}

1;
