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
use Bivio::Biz::Model::RealmUser;
use Bivio::Biz::Model::RealmAccountList;
use Bivio::Biz::Model::RealmValuationAccountList;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::Currency;
use Bivio::UI::HTML::Widget::DateField;
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::FormFieldLabel;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Select;
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
			field => 'valuation_date_time',
		    }),
		    0 => $empty_cell,
		},
	    }),
	    Bivio::UI::HTML::Widget::Director->new({
		control => ['show_valuation_date'],
		values => {
		    1 => Bivio::UI::HTML::Widget::DateField->new({
			field => 'valuation_date_time',
		    }),
		    0 => $empty_cell,
		},
	    }),
	],
	[
	    $self->create_caption('Account',
		    Bivio::UI::HTML::Widget::Select->new({
			field => 'RealmAccountEntry.realm_account_id',
			choices => ['account_list'],
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
			cols => 25,
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
    my($owner) = $req->get('Bivio::Biz::Model::RealmUser')
	    ->get_model('RealmOwner_2');

    my($task_id) = $req->get('task_id');
    my($heading, $account_list, $show_valuation_date);
    if ($task_id
	    == Bivio::Agent::TaskId::CLUB_ACCOUNTING_MEMBER_PAYMENT()) {
	$heading = 'Payment: ';
	$account_list = Bivio::Biz::Model::RealmAccountList->new($req);
	$show_valuation_date = 1;
    }
    elsif ($task_id
	    == Bivio::Agent::TaskId::CLUB_ACCOUNTING_MEMBER_FEE()) {
	$heading = 'Fee: ';

	# fees only can be applied to a valuation account
	$account_list = Bivio::Biz::Model::RealmValuationAccountList
		->new($req);
	$show_valuation_date = 0;
    }
    else {
	die("unhandled task_id $task_id");
    }
    $req->put(show_valuation_date => $show_valuation_date);
    $account_list->load();

    $req->put(page_heading => $heading.$owner->get('display_name'),
	    page_subtopic => undef,
	    page_content => $self,
	    account_list => $account_list,
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
