# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ComparisonPerformanceReport;
use strict;
$Bivio::UI::HTML::Club::ComparisonPerformanceReport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::ComparisonPerformanceReport - performance comparison

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ComparisonPerformanceReport;
    Bivio::UI::HTML::Club::ComparisonPerformanceReport->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::ComparisonPerformanceReport::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ComparisonPerformanceReport> performance comparison

=cut

#=IMPORTS
use Bivio::UI::HTML::Club::ReportPage;
use Bivio::UI::HTML::WidgetFactory;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::IRRCell;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::SimpleFormError;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Table;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::InstrumentPerformanceReport

Creates an club performance comparison report.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    my($club_perf) = Bivio::UI::HTML::Widget::Table->new({
	list_class => 'RealmPerformanceList',
	columns => [
	    ['month', {column_align => 'right'}],
	    ['description', {column_nowrap => 1}],
	    'Entry.amount',
	    ['quantity', {column_heading => 'units'}],
	],
    });

    my($compare_perf) = Bivio::UI::HTML::Widget::Table->new({
	list_class => 'ComparisonPerformanceList',
	columns => [
	    'Entry.amount',
	    ['quantity', {column_heading => 'RealmInstrumentEntry.count'}],
	],
    });

    my($factory) = 'Bivio::UI::HTML::WidgetFactory';
    $fields->{report} = Bivio::UI::HTML::Widget::Form->new({
	form_class => 'Bivio::Biz::Model::ComparisonDateSpanForm',
	value => $self->join(
	    Bivio::UI::HTML::Widget::SimpleFormError->new({}),
	    ' ',
	    $factory->create('ComparisonDateSpanForm.start_date'),
	    ' to ',
	    $factory->create('ComparisonDateSpanForm.report_date'),
	    '&nbsp;&nbsp;&nbsp; Compare to Ticker: ',
	    $factory->create('ComparisonDateSpanForm.MGFSInstrument.symbol',
		   {size => 5}),
	    ' ',
	    $factory->create('ComparisonDateSpanForm.generate'),
	    '<p>',
	    Bivio::UI::HTML::Widget::Grid->new({
		values => [
		    [
			$self->string(['comparison_heading'], 'table_heading'),
		    ],
		    [
			$self->join('&nbsp;'),
		    ],
		    [
			$self->join(
			    $club_perf, '<p>&nbsp;',
			    $self->string('Average Annual Return = ',
				    'table_cell'),
			    Bivio::UI::HTML::Widget::IRRCell->new({
				field => 'realm_irr',
			    }),
			),
			$self->join(

			    $compare_perf, '<p>&nbsp;',
			    $self->string('Average Annual Return = ',
				    'table_cell'),
			    Bivio::UI::HTML::Widget::IRRCell->new({
				field => 'comparison_irr',
			    }),
			),
		    ]
		],
	    }),
	    '<p>&nbsp;',
	),
    });
    $fields->{report}->initialize;

    $fields->{heading} = Bivio::UI::HTML::Club::ReportPage
	    ->get_heading_with_no_dates;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Draws the comparison performance report.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($realm_list, $compare_list) = $req->get(
	    'Bivio::Biz::Model::RealmPerformanceList',
	    'Bivio::Biz::Model::ComparisonPerformanceList');

    my($comparison_heading) = '';
    my($mgfs_inst) = $req->unsafe_get('Bivio::Biz::Model::MGFSInstrument');
    if ($mgfs_inst) {
	my($realm_name) = $req->get('auth_realm')->get('owner')->get(
		'display_name');
	my($inst_name) = $mgfs_inst->get('name');
	$comparison_heading = "Comparing $realm_name with $inst_name";
    }

    $req->put(page_title_value => $fields->{heading},
	    page_content => $fields->{report},
	    realm_irr => $realm_list->get_irr,
	    comparison_irr => $compare_list->get_irr,
	    comparison_heading => $comparison_heading,
	   );
    Bivio::UI::HTML::Club::ReportPage->execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
