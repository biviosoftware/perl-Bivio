# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TaskLogQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub X_FILTER_HINT {
    return 'Filter on name, @email, or /link';
}

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field(x_filter => $self->X_FILTER_HINT)
	unless defined($self->unsafe_get('x_filter'));
    return shift->SUPER::execute_empty(@_);
}

sub internal_query_fields {
    return [
	[qw(x_filter Text)],
    ];
}

sub set_filter {
    my($self, $filter) = @_;
    $self->internal_put_field(x_filter => $filter);
    return;
}

1;
