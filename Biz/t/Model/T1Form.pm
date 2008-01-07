# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::Model::T1Form;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_empty {
    my($self) = @_;
    $self->new_other('NumberedList')->load_page;
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
    });
}

1;
