# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SelectMonthForm;
use strict;
use Bivio::Base 'Model.QuerySearchBaseForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = __PACKAGE__->use('Type.Date');
my($_LQ) = __PACKAGE__->use('SQL.ListQuery');

sub OMIT_DEFAULT_VALUES_FROM_QUERY {
    return 0;
}

sub execute_empty {
    my($self) = @_;
    shift->SUPER::execute_empty(@_);
    $self->execute_ok
        unless ($self->get_request->get('query') || {})
            ->{$_LQ->to_char('begin_date')};
    return;
}

sub execute_ok {
    my($self) = @_;
    $self->internal_put_field(end_date =>
        $_D->set_end_of_month($self->get('begin_date')))
        unless $self->get('end_date');
    return shift->SUPER::execute_ok(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [
            {
                name => 'begin_date',
                form_name => $_LQ->to_char('begin_date'),
                type => 'Date',
                constraint => 'NOT_NULL',
                default_value => $_D->date_from_parts(
		    1, $_D->get_parts($_D->now, qw(month year)))
            },
            {
                name => 'end_date',
                form_name => $_LQ->to_char('date'),
                type => 'Date',
                constraint => 'NONE',
            },
        ],
    });
}

1;
