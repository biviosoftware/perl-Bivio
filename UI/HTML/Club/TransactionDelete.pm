# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::TransactionDelete;
use strict;
$Bivio::UI::HTML::Club::TransactionDelete::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::TransactionDelete - transaction delete form UI

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::TransactionDelete;
    Bivio::UI::HTML::Club::TransactionDelete->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::PageForm>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::Club::TransactionDelete::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::TransactionDelete> transaction delete form UI.
Shows a table of all transaction entries and OK and Cancel to really do it.

=cut

#=IMPORTS
use Bivio::Biz::Model::EntryList;
use Bivio::Biz::Model::RealmTransaction;
use Bivio::Type::TaxCategory;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::AmountCell;
use Bivio::UI::HTML::Widget::ClearDot;
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Table;
use Bivio::UI::HTML::Widget::DateTime;

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

    # list of entries
    my($entry_table) = Bivio::UI::HTML::Widget::Table->new({
	source => ['Bivio::Biz::Model::EntryList'],
	headings => [
	    'Category',
	    'Type',
	    'Tax',
	    'Amount',
	    'Remark',
	],
	cells => [
	    Bivio::UI::HTML::Widget::String->new({
		value => ['Entry.class', '->get_short_desc']
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['Entry.entry_type', '->get_short_desc'],
	    }),
	    Bivio::UI::HTML::Widget::Director->new({
		control => ['Entry.tax_category'],
		default_value => Bivio::UI::HTML::Widget::String->new({
		    value => ['Entry.tax_category', '->get_short_desc'],
		}),
		values => {
		    Bivio::Type::TaxCategory::NOT_TAXABLE() =>
		        Bivio::UI::HTML::Widget::Join->new({
			    values => ['&nbsp;']
			}),
		},
	    }),
	    Bivio::UI::HTML::Widget::AmountCell->new({
		field => 'Entry.amount',
	    }),
	    Bivio::UI::HTML::Widget::Director->new({
		control => ['Entry.remark'],
		values => {},
		default_value => Bivio::UI::HTML::Widget::String->new({
		    value => ['Entry.remark'],
		}),
		undef_value => Bivio::UI::HTML::Widget::Join->new({
		    values => ['&nbsp;']
		}),
	    }),
	],
    });

    # super table with transaction info
    # followed by the entry table for that transaction
    return [
	[
	    Bivio::UI::HTML::Widget::String->new({
		value => 'Date',
		string_font => 'table_heading',
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => 'Created By',
		string_font => 'table_heading',
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => 'Remark',
		string_font => 'table_heading',
	    }),
	],
	[
	    Bivio::UI::HTML::Widget::LineCell->new({
		cell_colspan => 3,
		color => 'table_separator',
	    }),
	],
	[
	    Bivio::UI::HTML::Widget::DateTime->new({
		mode => 'DATE',
		value => ['RealmTransaction.date_time'],
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['RealmTransaction.user_name',],
	    }),
	    Bivio::UI::HTML::Widget::String->new({
		value => ['RealmTransaction.remark'],
	    }),
	],
	[
	    Bivio::UI::HTML::Widget::Grid->new({
		cell_colspan => 3,
		values => [
		    [
			Bivio::UI::HTML::Widget::ClearDot->new({
			    width => 30,
			}),
			$entry_table,
		    ],
		],
	    }),
	],
	[
	    Bivio::UI::HTML::Widget::Join->new({
		values => ['&nbsp;']
	    }),
	],
	[
	    Bivio::UI::HTML::Widget::String->new({
		cell_colspan => 3,
		value => 'Delete this transaction?',
	    }),
	],
    ];
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Draws the transaction and its entries.

=cut

sub execute {
    my($self, $req) = @_;
    my($entry) = $req->get('Bivio::Biz::Model::Entry');
    my($entry_list) = Bivio::Biz::Model::EntryList->new($req);
    $entry_list->load({p => $entry->get('realm_transaction_id')});

    my($tran) = Bivio::Biz::Model::RealmTransaction->new($req);
    $tran->load(realm_transaction_id => $entry->get('realm_transaction_id'));
    $req->put('RealmTransaction.date_time' => $tran->get('date_time'),
	   'RealmTransaction.user_name' =>
	    $tran->get_model('User')->format_full_name,
	    'RealmTransaction.remark' => $tran->get('remark'));

    $req->put(page_content => $self);
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Sets attributes on self used by SUPER.

=cut

sub initialize {
    my($self) = @_;
    $self->put(form_model => ['Bivio::Biz::Model::TransactionDeleteForm']);
    $self->SUPER::initialize;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
