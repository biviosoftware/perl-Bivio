# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::SingleDeposit;
use strict;
$Bivio::UI::HTML::Club::SingleDeposit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::SingleDeposit - a single member deposit form

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::SingleDeposit;
    Bivio::UI::HTML::Club::SingleDeposit->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::PageForm>

=cut

use Bivio::UI::HTML::PageForm;
@Bivio::UI::HTML::Club::SingleDeposit::ISA = ('Bivio::UI::HTML::PageForm');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::SingleDeposit>

=cut

#=IMPORTS
use Bivio::Type::EntryType;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::Currency;
use Bivio::UI::HTML::Widget::DateField;
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::FormFieldLabel;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Select;
use Bivio::UI::HTML::Widget::String;
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

    # need this to get error messages to display label
    $self->map_field('MemberEntry.valuation_date', 'Valuation Date');

    my($empty_cell) = Bivio::UI::HTML::Widget::String->new({
	value => ''});
    return [
	[
	    $self->create_caption('Date',
		    Bivio::UI::HTML::Widget::DateField->new({
			field => 'RealmTransaction.date_time',
		    })),
	],
	[
	    Bivio::UI::HTML::Widget::Director->new({
		control => ['show_valuation_date'],
		values => {
		    1 => Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Valuation Date',
			field => 'MemberEntry.valuation_date',
		    }),
		    0 => $empty_cell,
		},
	    }),
	    Bivio::UI::HTML::Widget::Director->new({
		control => ['show_valuation_date'],
		values => {
		    1 => Bivio::UI::HTML::Widget::DateField->new({
			field => 'MemberEntry.valuation_date',
		    }),
		    0 => $empty_cell,
		},
	    }),
	],
	[
	    $self->create_caption('Account',
		    Bivio::UI::HTML::Widget::Select->new({
			field => 'RealmAccountEntry.realm_account_id',
			choices => ['/AccountList$/'],
			list_display_field => 'RealmAccount.name',
			list_id_field => 'RealmAccount.realm_account_id',
		    })),
	],
	[
	    $self->create_caption('Amount',
		    Bivio::UI::HTML::Widget::Currency->new({
			field => 'Entry.amount',
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

    # get the selected user and load them
    my($owner) = $req->get('target_realm_owner');

    my($heading, $show_valuation_date);
    my($entry_type) = $req->get('Bivio::Type::EntryType');
    if ($entry_type == Bivio::Type::EntryType::MEMBER_PAYMENT()) {
	$heading = 'Payment: ';
	$show_valuation_date = 1;
    }
    elsif ($entry_type == Bivio::Type::EntryType::MEMBER_PAYMENT_FEE()) {
	$heading = 'Fee: ';
	# fees only can be applied to a valuation account
	$show_valuation_date = 0;
    }
    else {
	$req->throw_die('DIE', {message => 'unhandled entry_type',
	    entity => $entry_type});
    }
    $req->put(show_valuation_date => $show_valuation_date);

    # set the account to broker
    $req->put(page_title_value => $heading.$owner->get('display_name'),
	    page_subtopic => undef,
	    page_content => $self,
	   );
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Sets attributes on self used by SUPER.

=cut

sub initialize {
    my($self) = @_;
    $self->put(form_model => ['Bivio::Biz::Model::SingleDepositForm']);
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
