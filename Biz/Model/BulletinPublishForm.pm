# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BulletinPublishForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    my($self) = @_;
    my($out) = b_use('Bivio::Mail::Outgoing')
	->new($self->req('Model.RealmMail')->get_rfc822);
    $out->set_header(To => $self->internal_get_target_email);
    $out->set_recipients($self->internal_get_target_email);
    $out->enqueue_send($self->req);
    return {
	method => 'server_redirect',
	query => $self->req('query'),
    };
}

sub internal_get_target_email {
    my($self) = @_;
    return $self->new_other('RealmOwner')->unauth_load_or_die({
	name => b_use('ShellUtil.SiteForum')->BULLETIN_REALM,
    })->format_email;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
    });
}

1;
