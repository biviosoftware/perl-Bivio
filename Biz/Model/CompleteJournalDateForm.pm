# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CompleteJournalDateForm;
use strict;
$Bivio::Biz::Model::CompleteJournalDateForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::CompleteJournalDateForm::VERSION;

=head1 NAME

Bivio::Biz::Model::CompleteJournalDateForm - date range for complete journal

=head1 SYNOPSIS

    use Bivio::Biz::Model::CompleteJournalDateForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::CompleteJournalDateForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CompleteJournalDateForm> date range for complete journal

=cut

#=IMPORTS
use Bivio::Biz::Accounting::Tax;
use Bivio::Biz::Action::ReportDate;
use Bivio::Type::Date;
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Sets default dates, using the date boundaries for the existing report_date.

=cut

sub execute_empty {
    my($self) = @_;

    my($start_date, $end_date) = Bivio::Biz::Accounting::Tax
	    ->get_date_boundary_for_year(
		    $self->get_request->get('report_date'));
    $self->internal_put_field(start_date => $start_date);
    $self->internal_put_field(end_date => $end_date);
    Bivio::Biz::Action::ReportDate->set_report_date(
	    $end_date, $self->get_request);
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Sets the start and end date values.

=cut

sub execute_ok {
    my($self) = @_;
    my($fiscal_end) = Bivio::Biz::Accounting::Tax->get_end_of_fiscal_year(
	    $self->get('start_date'));

    # coerce end date to year boundary
    if (Bivio::Type::Date->compare($self->get('end_date'), $fiscal_end)
	    > 0) {
	$self->internal_put_field(end_date => $fiscal_end);
    }

    Bivio::Biz::Action::ReportDate->set_report_date(
	    $fiscal_end, $self->get_request);
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
	else {
	    # check that dates are in same year
	    my($fiscal_end) = Bivio::Biz::Accounting::Tax
		    ->get_end_of_fiscal_year($start_date);
	    if (Bivio::Type::Date->compare($end_date, $fiscal_end) > 0) {
		$self->internal_put_error('end_date',
			Bivio::TypeError::DATE_RANGE_OUTSIDE_OF_FISCAL_YEAR());
	    }
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
