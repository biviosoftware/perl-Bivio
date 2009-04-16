# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::TaskLogQueryForm;
use strict;
use Bivio::Base 'Model.ListQueryForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CLEAR_ON_FOCUS_HINT {
    return 'Filter name, >date, @email, or /link';
}

sub execute_empty {
    my($self) = @_;
    shift->SUPER::execute_empty(@_);
    $self->set_filter($self->CLEAR_ON_FOCUS_HINT)
	unless defined($self->unsafe_get('x_filter'));
    return;
}

sub get_filter_value {
    my($self) = @_;
    return
	defined(my $f = $self->unsafe_get('x_filter'));
    return $f =~ /\S/ && $f ne $self->CLEAR_ON_FOCUS_HINT ? $f : undef;
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
