# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::DateTest;
use strict;
$Bivio::UI::HTML::DateTest::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::DateTest - tests the report date

=head1 SYNOPSIS

    use Bivio::UI::HTML::DateTest;
    Bivio::UI::HTML::DateTest->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::PageForm>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::DateTest::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::DateTest>

=cut

#=IMPORTS
use Bivio::Biz::Accounting::Tax;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::DateField;
use Bivio::UI::HTML::Widget::Indirect;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Radio;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_fields"></a>

=head2 create_fields() : array_ref

Create Grid I<values> for this form.

=cut

sub create_fields {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE} = {};

    $self->put(form_model => ['Bivio::Biz::Model::AccountingReportForm']);

    $fields->{message} = Bivio::UI::HTML::Widget::Indirect->new({
	value => 0,
	cell_colspan => 3,
    });
    $fields->{message}->initialize;

    return [
	[
	    'Report Date: ',
	    Bivio::UI::HTML::Widget::DateField->new({
		field => 'date'
	    }),
	    Bivio::UI::HTML::Widget::Radio->new({
		field => 'task_id',
		value =>
		Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_DATE_TEST(),
		label => 'test',
	    }),
	],
	[
	    $fields->{message},
	],
    ];
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Draws the current date settings previously submitted.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($message) = Bivio::UI::HTML::Widget::Join->new({
	values => [_create_message($req)],
    });
    $message->initialize;
    $fields->{message}->put(value => $message);

    # set the account to broker
    $req->put(page_heading => 'Date Test',
	    page_content => $self,
	   );
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

#=PRIVATE METHODS

# _create_message(Bivio::Agent::Request req) : string
#
# Returns report date info.
#
sub _create_message {
    my($req) = @_;
    return "report_date not set" unless $req->has_keys('report_date');

    my($message) = "\n<table border=0 cellpadding=5>";

    my($report_date) = $req->get('report_date');
    my($local_report_date) = Bivio::Type::Date->to_local_date($report_date);

    my($dates) = {
	local_report_date => $local_report_date,
	local_report_date_fiscal_start =>
	Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year(
		$local_report_date),

	now => Bivio::Type::Date->now,

	other_last_tax_year_end =>
	Bivio::Biz::Accounting::Tax->get_last_tax_year,
	other_this_tax_year_start =>
	Bivio::Biz::Accounting::Tax->get_this_fiscal_year,

	report_date => $report_date,
	report_date_fiscal_start =>
	Bivio::Biz::Accounting::Tax->get_start_of_fiscal_year($report_date),
    };

    foreach my $field (sort(keys(%$dates))) {
	my($date) = $dates->{$field};
	$message .= "\n<tr><td>$field</td><td>$date</td>";
	$message .= '<td>'.Bivio::Type::Date->to_literal($date).'</td>';
	$message .= "\n</tr>";
    }
    $message .= "\n</table>";

    return $message;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
