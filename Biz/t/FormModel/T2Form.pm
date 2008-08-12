# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::FormModel::T2Form;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
    });
}

sub internal_pre_execute {
    my($self, $method) = @_;
    b_die($method, ': not execute_ok')
	unless $method =~ /^(execute_ok|execute_empty)$/;
    $self->internal_put_field(internal_pre_execute => 1);
    return;
}

sub validate {
    b_die('validate should not be called');
    return;
}

1;
