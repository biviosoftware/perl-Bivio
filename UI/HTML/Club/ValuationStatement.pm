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
    $fields->{table} = Bivio::UI::HTML::Widget::Table->new({
	source => ['Bivio::Biz::ListModel::InstrumentValuationList'],
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
	    ['name'],
	    ['first_buy_date'],
	    ['shares'],
	    ['cost_per_share'],
	    ['total_cost'],
	    ['share_price'],
	    ['total_value'],
	    ['percent'],
	],
	cell_attrs => {
	    string_font => 'table_cell',
	    column_nowrap => 1,
	    },
    });
    $fields->{table}->initialize;
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
	   page_content => $fields->{table});
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
