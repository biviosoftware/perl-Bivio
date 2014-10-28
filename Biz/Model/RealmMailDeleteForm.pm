# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmMailDeleteForm;
use strict;
use Bivio::Base 'Biz.FormModel';


sub execute_ok {
    my($self) = @_;
    my($res) = shift->SUPER::execute_ok(@_);
    $self->get('realm_mail')->delete_message;
    return $res
        if defined($res);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	other => [
	    {
		name => 'realm_mail',
		type => 'Model.RealmMail',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_pre_execute {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(
	realm_mail => $self->new_other('RealmMail')
	    ->set_ephemeral
	    ->load_this_from_request,
    );
    return @res;
}

1;
