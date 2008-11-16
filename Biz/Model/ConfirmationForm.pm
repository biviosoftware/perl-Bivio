# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ConfirmationForm;
use strict;
use base 'Bivio::Biz::FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_cancel {
    my($self) = @_;
    return $self->internal_redirect_next;
}

sub execute_ok {
    my($self) = @_;
    $self->put_context_fields(is_confirmed => 1);
    return;
}
sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
        require_context => 1,
    });
}

1;
