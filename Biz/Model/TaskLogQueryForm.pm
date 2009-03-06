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
    my($self) = shift;
    $self->SUPER::execute_empty(@_);
    $self->internal_put_field(x_filter => $self->X_FILTER_HINT)
	unless defined($self->unsafe_get('x_filter'));
    return;
}

sub get_list_for_field {
    my($proto, $field) = @_;
    return _owner_name_list($proto) if $field
	eq 'x_owner_name';
    return shift->SUPER::get_list_for_field(@_);
}

sub internal_query_fields {
    my($self) = @_;
    return [
	[qw(x_filter Text)],
    ];
}


1;
