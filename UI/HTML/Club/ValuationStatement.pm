# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ValuationStatement;
use strict;
$Bivio::UI::HTML::Club::ValuationStatement::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::ValuationStatement - a valuation report

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ValuationStatement;
    Bivio::UI::HTML::Club::ValuationStatement->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::ValuationStatement::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ValuationStatement>

=cut

#=IMPORTS
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Format::Amount;
use Bivio::UI::HTML::Format::Date;
use Bivio::UI::HTML::Format::Printf;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Table;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::ValuationStatement



=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{securities_table} = Bivio::UI::HTML::Widget::Table->new({
	source => ['Bivio::Biz::ListModel::InstrumentValuationList'],
	pad => 3,
	no_end_tag => 1,
	headings => [
	    'Security',
	    'First Buy or Valuation Date',
	    'Shares Owned',
	    'Cost per Share',
	    'Total Cost',
	    'Price per Share',
	    'Total Value',
	    'Percent of Total',
	],
	heading_attrs => {
	    column_align => 'S',
	    string_font => 'table_heading',
	    },
	cells => [
	    Bivio::UI::HTML::Widget::String->new({
		value => ['name'],
		string_font => 'table_cell',
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['first_buy_date',
		    'Bivio::UI::HTML::Format::Date', 2],
		column_align => 'E',
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['shares',
		    'Bivio::UI::HTML::Format::Amount', 3],
		column_align => 'E',
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['cost_per_share',
		    'Bivio::UI::HTML::Format::Amount', 4],
		column_align => 'E',
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['total_cost',
		    'Bivio::UI::HTML::Format::Amount', 2],
		column_align => 'E',
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['share_price',
		    'Bivio::UI::HTML::Format::Amount', 4],
		column_align => 'E',
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['total_value',
		    'Bivio::UI::HTML::Format::Amount', 2],
		column_align => 'E',
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['percent',
		    'Bivio::UI::HTML::Format::Printf', "%.1f%%"],
		column_align => 'E',
	    }),
	],
	cell_attrs => {
	    string_font => 'monospaced',
	    column_nowrap => 1,
	    },
    });
    $fields->{securities_table}->initialize;
    $fields->{account_table} = Bivio::UI::HTML::Widget::Table->new({
	source => ['Bivio::Biz::ListModel::AccountValuationList'],
	no_start_tag => 1,
	headings => [
	    'Cash Account',
#TODO: need a better way to insert space
	    Bivio::UI::HTML::Widget::Join->new({
		values => ['&nbsp;']
	    }),
	    Bivio::UI::HTML::Widget::Join->new({
		values => ['&nbsp;']
	    }),
	    Bivio::UI::HTML::Widget::Join->new({
		values => ['&nbsp;']
	    }),
	    'Total Cost',
	    Bivio::UI::HTML::Widget::Join->new({
		values => ['&nbsp;']
	    }),
	    'Total Value',
	    'Percent of Total',
	],
	heading_attrs => {
	    column_align => 'S',
	    string_font => 'table_heading',
	    },
	cells => [
	    Bivio::UI::HTML::Widget::String->new({
		value => ['name'],
		string_font => 'table_cell',
	    }),
	    Bivio::UI::HTML::Widget::Join->new({
		values => ['&nbsp;']
	    }),
	    Bivio::UI::HTML::Widget::Join->new({
		values => ['&nbsp;']
	    }),
	    Bivio::UI::HTML::Widget::Join->new({
		values => ['&nbsp;']
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['total_cost',
		    'Bivio::UI::HTML::Format::Amount', 2],
		column_align => 'E',
	    }),
	    Bivio::UI::HTML::Widget::Join->new({
		values => ['&nbsp;']
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['total_value',
		    'Bivio::UI::HTML::Format::Amount', 2],
		column_align => 'E',
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['percent',
		    'Bivio::UI::HTML::Format::Printf', "%.1f%%"],
		column_align => 'E',
	    }),
	],
	cell_attrs => {
	    string_font => 'monospaced',
	    column_nowrap => 1,
	    },
    });
    $fields->{account_table}->initialize;

    $fields->{report} = Bivio::UI::HTML::Widget::Join->new({
	       values => [
		       Bivio::UI::HTML::Widget::Join->new({
			   values => ['<br>']
		       }),
		       $fields->{securities_table},
		       $fields->{account_table}]});
    $fields->{report}->initialize;

    return $self;
}

=head1 METHODS


=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)


=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->put(page_subtopic => undef, page_heading => 'Valuation Statement',
	    page_content => $fields->{report});
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
