# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::MiscIncomeAndDeductions;
use strict;
$Bivio::UI::HTML::Club::MiscIncomeAndDeductions::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::MiscIncomeAndDeductions - lists portfolio income/expense

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::MiscIncomeAndDeductions;
    Bivio::UI::HTML::Club::MiscIncomeAndDeductions->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Club::MiscIncomeAndDeductions::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::MiscIncomeAndDeductions> lists portfolio income
and deductions.

=cut

#=IMPORTS
use Bivio::UI::HTML::Club::ReportPage;
use Bivio::UI::HTML::Widget::DateTime;
use Bivio::Societas::UI::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::Societas::UI::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::MiscIncomeAndDeductions

Creates a new Misc. Income and Deductions report.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    my($msg1) = $_VS->vs_string(
	    'No miscellaneous income to report within the date range.',
	    'page_text');
    my($msg2) = $_VS->vs_string(
	    'No deductions to report within the date range.',
	    'page_text');

    $fields->{content} = $_VS->vs_join(
	'<table border=0 cellspacing=0 cellpadding=5>',
	$_VS->vs_table('PortfolioIncomeList', [
	    # showing date_time as date
	    ['RealmTransaction.date_time', {
		column_widget => Bivio::UI::HTML::Widget::DateTime->new({
		    mode => 'DATE',
		    column_align => 'E',
		    value => ['RealmTransaction.date_time'],
		}),
	    }],
	    'RealmTransaction.remark',
	    'Entry.amount',
	],
	{
	    start_tag => 0,
	    end_tag => 0,
	    summarize => 1,
	    summary_line_type => '=',
	    title => 'Miscellaneous Income',
	    empty_list_widget => $_VS->vs_join(
		    "\n<tr><td colspan=3>",
		    $msg1,
		    "</td></tr>",
	    ),
	}),
	"\n<tr><td><br></td></tr>",
	$_VS->vs_table('PortfolioDeductionList', [
	    # showing date_time as date
	    ['RealmTransaction.date_time', {
		column_widget => Bivio::UI::HTML::Widget::DateTime->new({
		    mode => 'DATE',
		    column_align => 'E',
		    value => ['RealmTransaction.date_time'],
		}),
	    }],
	    'RealmTransaction.remark',
	    'Entry.amount',
	],
	{
	    summarize => 1,
	    start_tag => 0,
	    end_tag => 0,
	    summary_line_type => '=',
	    title => 'Deductions',
	    empty_list_widget => $_VS->vs_join(
		    "\n<tr><td colspan=3>",
		    $msg2,
		    "</td></tr>",
	    ),
	}),
	"\n</table>",
    );
    $fields->{content}->initialize;

    $fields->{heading} = Bivio::UI::HTML::Club::ReportPage
	    ->get_heading_with_two_dates;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Draws the PortfolioIncomeList and PortfolioDeductionList.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->put(page_title_value => $fields->{heading},
	    page_content => $fields->{content});
    Bivio::UI::HTML::Club::ReportPage->execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
