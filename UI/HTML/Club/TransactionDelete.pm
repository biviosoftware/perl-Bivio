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

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::TransactionDelete::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::TransactionDelete> transaction delete form UI.
Shows a table of all transaction entries.

=cut

#=IMPORTS
use Bivio::Biz::Model::EntryList;
use Bivio::Biz::Model::RealmTransaction;
use Bivio::UI::HTML::Widget::ClearDot;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::DateTime;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::Widget

Create widgets.

=cut

sub create_content {
    my($self) = @_;

    # list of entries
    my($entry_table) = $_VS->vs_table(
	'EntryList',
	[
	    ['', {
		column_widget => Bivio::UI::HTML::Widget::TaxType->new({}),
		column_heading => 'Entry.entry_type',
	    }],
	    {
		field => 'remark',
		column_heading => 'CATEGORY_HEADING',
	    },
	    'Entry.amount',
	],
    );

    # super table with transaction info
    # followed by the entry table for that transaction
    return Bivio::UI::HTML::Widget::Grid->new({pad => 5, values => [
	[
	    $_VS->vs_string('Date', 'table_heading'),
	    $_VS->vs_string('Created By', 'table_heading'),
	    $_VS->vs_string('Remark', 'table_heading'),
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
		value => ['Bivio::Biz::Model::RealmTransaction', 'date_time'],
		string_font => 'table_cell',
	    }),
	    $_VS->vs_string(['RealmTransaction.user_name'], 'table_cell'),
	    $_VS->vs_string(['Bivio::Biz::Model::RealmTransaction', 'remark'],
		   'table_cell'),
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
	    $_VS->vs_join('&nbsp;'),
	],
	[
	    Bivio::UI::HTML::Widget::String->new({
		cell_colspan => 3,
		value => 'Delete this transaction?',
		string_font => 'table_cell',
	    }),
	],
	[
	    $_VS->vs_form('Bivio::Biz::Model::TransactionDeleteForm', []),
	],
    ]});
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Draws the transaction and its entries.

=cut

sub execute {
    my($self, $req) = @_;
    my($entry) = $req->get('Bivio::Biz::Model::Entry');
    my($entry_list) = Bivio::Biz::Model::EntryList->new($req);
    $entry_list->load_all({
	p => $entry->get('realm_transaction_id'),
    });

    my($txn) = Bivio::Biz::Model::RealmTransaction->new($req);
    $txn->load(realm_transaction_id => $entry->get('realm_transaction_id'));
    my($txn_user_realm) = Bivio::Biz::Model::RealmOwner->new($req);
    # need to unauth_load so the current club realm isn't used instead
    $txn_user_realm->unauth_load(realm_id =>
	    $txn->get_model('User')->get('user_id'));
    $req->put('RealmTransaction.user_name' =>
	    $txn_user_realm->get('display_name'));

    $self->SUPER::execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
