# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ReportList;
use strict;
$Bivio::UI::HTML::Club::ReportList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::ReportList - a list of report links

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ReportList;
    Bivio::UI::HTML::Club::ReportList->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::ReportList::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ReportList>

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Agent::HTTP::Location;
use Bivio::Agent::HTTP::Request;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::ReportList

Creates a new report listing.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Draws the report list within a Bivio::UI::HTML::Club::Page.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $fields->{report_links} = _create_report_links(),

    $req->put(page_subtopic => undef, page_heading => 'Report List',
	    page_content => $self);
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the report list onto the buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= $fields->{report_links};
    return;
}

#TODO: want to only show reports which the current user has authority
# to see. Need to check task id.

#TODO: use Widget::Link.

#=PRIVATE METHODS

# _create_bullet_link(Bivio::Agent::TaskId task_id, string text) : string
#
# Creates a link with the specified text.
#
sub _create_bullet_link {
    my($task_id, $text) = @_;

    return '<li><a href="'.Bivio::Agent::HTTP::Location->format($task_id,
	    Bivio::Agent::Request->get_current()->get('auth_realm'))
	    .'">'.$text."</a></li>\n";
}

# _create_report_links() : string
#
# Returns the report links ready for rendering
#
sub _create_report_links {

    my($html) = '<table width="100%" border=0><tr><td valign="top">';

    $html .= 'General<ul>';
    $html .= _create_bullet_link(
     Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_VALUATION_STATEMENT_PARAMS(),
	    "Valuation Statement");

=begin comment

    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_COMPLETE_JOURNAL(),
	    "Complete Journal");
    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_TRANSACTION_SUMMARY(),
	    "Transaction Summary");

=cut

    $html .= '</ul>Investment<ul>';

    $html .= _create_bullet_link(
      Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_INVESTMENT_SUMMARY_PARAMS(),
	    "Investment Summary");

=begin comment

    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_INVESTMENT_HISTORY(),
	    "Individual Investment History");

=cut

    $html .= '</ul>Member<ul>';
    $html .= _create_bullet_link(
	  Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_MEMBER_SUMMARY_PARAMS(),
	    "Member Summary");

=begin comment

    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_MEMBER_STATUS(),
	    "Member Status");
    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_MEMBER_VALUE(),
	    "Individual Valuation Units Ledger");
    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_WITHDRAWAL_EARNINGS(),
	    "Withdrawal Earnings Report");

=cut

    $html .= '</td><td>&nbsp;</td><td valign="top">';

    $html .= '</ul>Cash Account<ul>';
    $html .= _create_bullet_link(
    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_CASH_ACCOUNT_SUMMARY_PARAMS(),
	    "Cash Account Summary");

=begin

    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_CASH_JOURNAL(),
	    "Cash Journal Listing");
    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_CASH_CONTRIBUTIONS(),
	    "Cash Contribution Report");
    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_PETTY_CASH_CONTRIBUTIONS(),
	    "Petty Cash Contribution Report");
    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_PETTY_CASH_JOURNAL(),
	    "Petty Cash Journal Listing");

    $html .= '</ul>Year End<ul>';
    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_DISTRIBUTIONS(),
	    "Distribution of Earnings Statement");
    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_INCOME_STATEMENT(),
	    "Income/Expense Statement");
    $html .= _create_bullet_link(
	    Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_BALANCE_SHEET(),
	    "Balance Sheet");

=cut

    $html .= '</ul></td></tr></table>';

    return $html;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
