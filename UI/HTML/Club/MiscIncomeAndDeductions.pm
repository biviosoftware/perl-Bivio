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

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::MiscIncomeAndDeductions::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::MiscIncomeAndDeductions> lists portfolio income
and deductions.

=cut

#=IMPORTS
use Bivio::UI::HTML::Club::ReportPage;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Table2;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::MiscIncomeAndDeductions

Creates a new Misc. Income and Deductions report.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    my($msg1) = 'No miscellaneous income to report within the date range.';
    my($msg2) = 'No deductions to report within the date range.';

    $fields->{content} = Bivio::UI::HTML::Widget::Join->new({
	values => [
	    Bivio::UI::HTML::Widget::Table2->new({
		list_class => 'MiscIncomeList',
		end_tag => 0,
		columns => [
		    # showing date_time as date
		    ['RealmTransaction.date_time', {
			column_widget => Bivio::UI::HTML::Widget::DateTime
			->new({
			    mode => 'DATE',
			    column_align => 'E',
			    value => ['RealmTransaction.date_time'],
			}),
		    }],
		    'RealmTransaction.remark',
		    'Entry.amount',
		],
		summarize => 1,
		summary_line_type => '=',
		title => 'Miscellaneous Income',
		empty_list_widget => Bivio::UI::HTML::Widget::Join->new({
		    values => [
			"\n<table border=0 cellspacing=0 cellpadding=5 ".
			    "align=center>\n<tr><td colspan=3>$msg1</td></tr>",
		    ],
		}),
	    }),
	    "\n<tr><td><br></td></tr>",
	    Bivio::UI::HTML::Widget::Table2->new({
		list_class => 'MiscExpenseList',
		start_tag => 0,
		columns => [
		    # showing date_time as date
		    ['RealmTransaction.date_time', {
			column_widget => Bivio::UI::HTML::Widget::DateTime
			->new({
			    mode => 'DATE',
			    column_align => 'E',
			    value => ['RealmTransaction.date_time'],
			}),
		    }],
		    'RealmTransaction.remark',
		    'Entry.amount',
		],
		summarize => 1,
		summary_line_type => '=',
		title => 'Deductions',
		empty_list_widget => Bivio::UI::HTML::Widget::Join->new({
		    values => [
			"\n<tr><td colspan=3>$msg2</td></tr>\n</table>",
		    ],
		}),
	    }),
	    "\n</table>",
	],
    });
    $fields->{content}->initialize;

    $fields->{heading} = Bivio::UI::HTML::Club::ReportPage
	    ->get_fiscal_heading_widget('Misc. Income and Deductions, ');
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Draws the MiscIncomeList and MiscExpenseList.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->put(page_heading => $fields->{heading},
	    page_subtopic => 'Misc. Income and Deductions',
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
