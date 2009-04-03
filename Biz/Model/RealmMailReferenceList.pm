# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMailReferenceList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_MI) = b_use('Type.MessageId');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        primary_key => ['RealmMail.realm_file_id'],
	order_by => [
	    {
		name => 'RealmMail.realm_file_id',
		sort_order => 0,
	    },
	],
	other => [
	    'RealmMail.thread_root_id',
	    'RealmMail.subject_lc',
	],
	auth_id => 'RealmMail.realm_id',
    });
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    $stmt->where($stmt->IN('RealmMail.message_id', $self->[$_IDI]));
    return shift->SUPER::internal_prepare_statement(@_);
}

sub load_first_from_incoming {
    my($self, $mail_incoming) = @_;
    my(@r) = map($_MI->clean_and_trim($_), @{$mail_incoming->get_references});
    return
	unless @r;
    $self->[$_IDI] = \@r;
    $self->load_all;
    return $self->get_result_set_size ? $self->set_cursor_or_die(0) : undef;
}

1;
