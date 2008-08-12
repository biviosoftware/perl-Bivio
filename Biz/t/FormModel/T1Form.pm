# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::FormModel::T1Form;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_ok {
    shift->get('validate');
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        require_validate => 1,
    });
}

sub internal_pre_execute {
    my($self, $method) = @_;
    b_die($method, ': not validate_and_execute_ok')
	unless $method =~ /^(validate_and_execute_ok|execute_empty)$/;
    $self->internal_put_field(internal_pre_execute => 1);
    return;
}

sub validate {
    shift->internal_put_field(validate => 1);
    return;
}

1;
