# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::InstrumentSell;
use strict;
$Bivio::UI::HTML::Club::InstrumentSell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::InstrumentSell - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::InstrumentSell;
    Bivio::UI::HTML::Club::InstrumentSell->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::PageForm>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::Club::InstrumentSell::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::InstrumentSell>

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmInstrument;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::Currency;
use Bivio::UI::HTML::Widget::DateField;
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::FormFieldLabel;
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

    my($blank_cell) = Bivio::UI::HTML::Widget::Join->new({
	values => ['&nbsp;']});
    return [
	[
	    $self->create_caption('Date',
		    Bivio::UI::HTML::Widget::DateField->new({
			field => 'RealmTransaction.date_time',
		    })),
	    $blank_cell,
	    $self->create_caption('Account',
		    Bivio::UI::HTML::Widget::Select->new({
			field => 'RealmAccountEntry.realm_account_id',
			choices => [
				'Bivio::Biz::Model::RealmValuationAccountList',
			       ],
			list_display_field => 'RealmAccount.name',
			list_id_field => 'RealmAccount.realm_account_id',
		    })),
	],
	[
	    $self->create_caption('# of Shares',
		    Bivio::UI::HTML::Widget::Currency->new({
			field => 'RealmInstrumentEntry.count',
			size => 10,
		    })),
	    $blank_cell,
	    $self->create_caption('Price/Share',
		    Bivio::UI::HTML::Widget::Currency->new({
			field => 'RealmInstrumentValuation.price_per_share',
			size => 10,
		    })),
	],
	[
	    $self->create_caption('Commission',
		    Bivio::UI::HTML::Widget::Currency->new({
			field => 'commission',
			size => 10,
		    })),
	],
	[
	    Bivio::UI::HTML::Widget::Join->new({
		cell_expand => 1,
		values => [
			Bivio::UI::HTML::Widget::FormFieldLabel->new({
			    label => 'Remark',
			    field => 'RealmTransaction.remark',
			}),
			'<br>',
			Bivio::UI::HTML::Widget::TextArea->new({
			    cell_expand => 1,
			    field => 'RealmTransaction.remark',
			    rows => 3,
			    cols => 40,
			}),
		],
	    }),
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

    # hack to redirect to sell form 2
    if ($req->get('form_model')->in_error) {
	my($errors) = $req->get('form_model')->get_errors;
	if ($errors->{redirect}) {
	    $req->server_redirect($req->get('task')->get('next'),
		    $req->get('auth_realm'),
		    $req->get('query'),
		    $req->get('form'));
	    # does not return
	}
    }

    my($realm_inst) = $req->get('Bivio::Biz::Model::RealmInstrument');

    $req->put(page_heading => 'Sell: '.$realm_inst
	    ->get_model('Instrument')->get('name').' (page 1 / 2)',
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
    $self->put(form_model => ['Bivio::Biz::Model::InstrumentSellForm']);
    $self->SUPER::initialize;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
