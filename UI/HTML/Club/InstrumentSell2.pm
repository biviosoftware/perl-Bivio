# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::InstrumentSell2;
use strict;
$Bivio::UI::HTML::Club::InstrumentSell2::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::InstrumentSell2 - sell an instrument

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::InstrumentSell2;
    Bivio::UI::HTML::Club::InstrumentSell2->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::PageForm>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::Club::InstrumentSell2::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::InstrumentSell2>

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmInstrument;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Format::Amount;
use Bivio::UI::HTML::Format::Date;
use Bivio::UI::HTML::Format::Printf;
use Bivio::UI::HTML::Widget::Currency;
use Bivio::UI::HTML::Widget::DateField;
use Bivio::UI::HTML::Widget::FormFieldLabel;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::TextArea;

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
    # have to create fields here, this is called in super class ctor
    $self->{$_PACKAGE} = {};
    my($fields) = $self->{$_PACKAGE};
    $fields->{indirect} = Bivio::UI::HTML::Widget::Indirect->new({
	value => 0,
	cell_expand => 1,
    });

    return [
	[
	    Bivio::UI::HTML::Widget::DateTime->new({
		mode => 'DATE',
		value => ['Bivio::Biz::Model::InstrumentSellForm2',
		    'RealmTransaction.date_time',
		],
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['Bivio::Biz::Model::InstrumentSellForm2',
		    'RealmInstrumentEntry.count',
		       'Bivio::UI::HTML::Format::Printf', 'Selling %s Shares',
		],
	    }),
	],
	[
	    $fields->{indirect},
	],
    ];
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Loads the target member, processes any form errors and renders the page.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($realm_inst) = $req->get('Bivio::Biz::Model::RealmInstrument');

#TODO: need a generalized editable list
    $fields->{indirect}->put(value => _create_sell_table($req));

    $req->put(page_heading => 'Record Sale: '.$realm_inst->get_name
	    .' (page 2 / 2)',
	    page_subtopic => undef,
	    page_content => $self);
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Sets attributes on self used by SUPER.

=cut

sub initialize {
    my($self) = @_;
    $self->put(form_model => ['Bivio::Biz::Model::InstrumentSellForm2']);
    $self->SUPER::initialize;
    return;
}

#=PRIVATE METHODS

# _create_sell_table(Bivio::Biz::Model::RealmInstrument realm_inst) : Bivio::UI::HTML::Widget::Grid
#
# Creates an editable list of realm instrument lots.
#
sub _create_sell_table {
    my($req) = @_;

    my($rows) = [];
    my($count) = 0;
    my($lot_list) = $req->get('Bivio::Biz::Model::RealmInstrumentLotList');
    while ($lot_list->next_row) {
	my($row) = [
		Bivio::UI::HTML::Format::Date->get_widget_value(
			$lot_list->get('purchase_date')),
		Bivio::UI::HTML::Format::Amount->get_widget_value(
			$lot_list->get('quantity'), 7),
		Bivio::UI::HTML::Format::Amount->get_widget_value(
			$lot_list->get('cost_per_share'), 4),
		Bivio::UI::HTML::Widget::Text->new({
		    field => 'lot'.$count++,
		    size => 15,
		}),
	   ];
	push(@$rows, $row);
    }

    my($grid) = Bivio::UI::HTML::Widget::Grid->new({
	pad => 2,
	form_model => ['Bivio::Biz::Model::InstrumentSellForm2'],
	values => [
	     [
		 Bivio::UI::HTML::Widget::String->new({
		     value => 'Purchase Date',
		     string_font => 'table_heading',
		 }),
		 Bivio::UI::HTML::Widget::String->new({
		     value => 'Quantity',
		     string_font => 'table_heading',
		 }),
		 Bivio::UI::HTML::Widget::String->new({
		     value => 'Cost/Share',
		     string_font => 'table_heading',
		 }),
		 Bivio::UI::HTML::Widget::String->new({
		     value => 'Sold',
		     string_font => 'table_heading',
		 }),
	    ],
	    @$rows,
	],
    });
    $grid->initialize;
    return $grid;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
