# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::TransactionSummaryDateForm;
use strict;
$Bivio::Biz::Model::TransactionSummaryDateForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::TransactionSummaryDateForm::VERSION;

=head1 NAME

Bivio::Biz::Model::TransactionSummaryDateForm - date fields for txn report

=head1 SYNOPSIS

    use Bivio::Biz::Model::TransactionSummaryDateForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::TransactionSummaryDateForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::TransactionSummaryDateForm> date fields for txn report

=cut

#=IMPORTS
use Bivio::TypeError;
use Bivio::Type::Date;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Sets default dates, using one month span.

=cut

sub execute_empty {
    my($self) = @_;

    my($end_date) = $self->get_request->get('report_date');
    $self->internal_put_field(end_date => $end_date);
    $self->internal_put_field(start_date =>
	    Bivio::Type::Date->get_previous_month($end_date));

    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Sets the start and end date values.

=cut

sub execute_ok {
    my($self) = @_;
    $self->internal_stay_on_page;
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 2,
	visible => [
            {
               name => 'start_date',
	       type => 'Date',
	       constraint => 'NOT_NULL',
	    },
            {
               name => 'end_date',
	       type => 'Date',
	       constraint => 'NOT_NULL',
	    },
	    {
		name => 'generate',
		type => 'OKButton',
		constraint => 'NONE',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="validate"></a>

=head2 validate()

Ensures the date fields are acceptable.

=cut

sub validate {
    my($self) = @_;

    my($start_date, $end_date) = $self->get(qw(start_date end_date));
    if ($start_date && $end_date) {

	if (Bivio::Type::Date->compare($start_date, $end_date) > 0) {
	    $self->internal_put_error('start_date',
		    Bivio::TypeError::START_DATE_GREATER_THAN_REPORT_DATE());
	}

	my($prev_year) = Bivio::Type::Date->get_previous_year($end_date);
	if (Bivio::Type::Date->compare($start_date, $prev_year) < 0) {
	    $self->internal_put_error('start_date',
		    Bivio::TypeError::DATE_RANGE_GREATER_THAN_ONE_YEAR());
	}
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
