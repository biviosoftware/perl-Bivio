# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::AccountingImportIdentify;
use strict;
$Bivio::UI::HTML::Club::AccountingImportIdentify::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Club::AccountingImportIdentify::VERSION;

=head1 NAME

Bivio::UI::HTML::Club::AccountingImportIdentify - classify imported txns

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::AccountingImportIdentify;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::AccountingImportIdentify::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::AccountingImportIdentify> classify imported txns

=cut

#=IMPORTS
use Bivio::Biz::Model::ImportedTransactionForm;
use Bivio::TypeValue;
use Bivio::Type::EntryTypeSet;
use Bivio::UI::HTML::WidgetFactory;
use Bivio::UI::HTML::Widget::ActionBar;
use Bivio::UI::HTML::Widget::EditRowTable;
use Bivio::UI::HTML::Widget::Enum;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::FormFieldError;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::StandardSubmit;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_ENTRY_CREDIT_SET) = Bivio::Type::EntryTypeSet::CREDIT();
my($_ENTRY_CREDIT) = Bivio::TypeValue->new(
	'Bivio::Type::EntryTypeSet', \$_ENTRY_CREDIT_SET);

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Create widgets.

=cut

sub create_content {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE} = {};

    $self->put_heading('CLUB_ACCOUNTING_SYNC_IDENTIFY');

    my($wf) = 'Bivio::UI::HTML::WidgetFactory';
    my($edit_type_form) = Bivio::UI::HTML::Widget::Form->new({
	form_class => 'Bivio::Biz::Model::ImportedTransactionTypeForm',
	value => Bivio::UI::HTML::Widget::EditRowTable->new({
	    list_class => 'ImportedTransactionList',
	    columns => [
		['Entry.entry_type', {
		    column_edit_widget => $self->join(
			    $wf->create(
			      'ImportedTransactionTypeForm.Entry.entry_type', {
				  column_selectable => 1,
				  auto_submit => 1,
				  choices => $_ENTRY_CREDIT,
			      }),
			    '<noscript>',
			    $wf->create(
				    'ImportedTransactionTypeForm.ok_button'),
			    '</noscript>',
			),
		}],
		'RealmTransaction.date_time',
		'Entry.amount',
		['RealmTransaction.remark', {
		    column_heading => 'description_heading',
		}],
		$self->list_actions([
		    ['delete', 'CLUB_ACCOUNTING_ACCOUNT_TRANSACTION_DELETE'],
		    ['edit', 'CLUB_ACCOUNTING_TRANSACTION_EDIT', undef,
			['->can_edit']],
		]),
	    ],
	    empty_list_widget => $self->string('No remaining transactions.',
		    'page_text'),
	}),
    });

    my($edit_txn_form) = Bivio::UI::HTML::Widget::Form->new({
	form_class => 'Bivio::Biz::Model::ImportedTransactionForm',
	value => Bivio::UI::HTML::Widget::EditRowTable->new({
	    list_class => 'ImportedTransactionList',
	    columns => [
		['Entry.entry_type', {
		    column_selectable => 1,
		    wf_want_display => 1,
		}],
		'RealmTransaction.date_time',
		['Entry.amount', {column_selectable => 1}],
		['RealmTransaction.remark', {
		    column_heading => 'description_heading',
		    column_selectable => 1,
		    column_edit_widget => _create_description_widget($self),
		}],
		{
		    column_heading => 'list_actions',
		    column_widget => $self->blank_cell,
		    column_edit_widget =>
		    Bivio::UI::HTML::Widget::StandardSubmit->new({}),
		},
	    ],
	}),
    });

    return $self->join(
	    $self->string('
Use this page to classify data imported from your brokerage account. Many transactions are automatically classified, and can can be reviewed on the ',
		    'page_text'),
	    $self->link('AccountSync Review', 'CLUB_ACCOUNTING_SYNC_REVIEW'),
	    $self->string(' page.

To classify the data, first describe the type of transaction using the drop down list, then enter any extra information about the entry. One transaction can be subdivided into multiple entries by changing the amount to a lesser value when editing the data',
		    'page_text'),
	    $self->director(
		    [['->get_request'],	'->unsafe_get',
			'Bivio::Biz::Model::ImportedTransactionForm'],
		    {}, $edit_txn_form, $edit_type_form),
	   );
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Prepares for rendering.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->put(
	    page_type => Bivio::UI::PageType::LIST(),
	    list_uri => $req->format_stateless_uri($req->get('task_id')),
	   );

    return $self->SUPER::execute($req);
}

#=PRIVATE METHODS

# _create_description_widget() : Bivio::UI::HTML::Widget
#
# Returns the widget used to edit the selected row description.
#
sub _create_description_widget {
    my($self) = @_;
    my($wf) = 'Bivio::UI::HTML::WidgetFactory';
    my($type) = 'Bivio::Type::EntryType';

    return $self->director(
	    [[['->get_request'], 'Bivio::Biz::Model::ImportedTransactionForm',
		'Entry.entry_type'], '->as_int'],
	    {
		$type->MEMBER_PAYMENT->as_int => _create_payment_widget($self),
		$type->MEMBER_PAYMENT_FEE->as_int => _create_member_widget(
			$self),
		$type->CASH_TRANSFER->as_int => $wf->create(
		     'ImportedTransactionForm.target_account_id', {
			 choices => ['Bivio::Biz::Model::RealmAccountList'],
			 list_display_field => 'RealmAccount.name',
			 list_id_field => 'RealmAccount.realm_account_id',
		     }),
	    },

	    # default is remark field
	    $wf->create('ImportedTransactionForm.RealmTransaction.remark'),
	   );
}

# _create_member_widget() : Bivio::UI::HTML::Widget
#
# Returns a widget which renders the member list.
#
sub _create_member_widget {
    my($self) = @_;
    my($wf) = 'Bivio::UI::HTML::WidgetFactory';
    return $wf->create(
	    'ImportedTransactionForm.MemberEntry.user_id', {
		choices => ['Bivio::Biz::Model::AllMemberList'],
		list_display_field => 'last_first_middle',
		list_id_field => 'RealmUser.user_id',
	    });
}

# _create_payment_widget() : Bivio::UI::HTML::Widget
#
# Returns the widget used when editing a single member payment.
#
sub _create_payment_widget {
    my($self) = @_;

    my($wf) = 'Bivio::UI::HTML::WidgetFactory';
    return Bivio::UI::HTML::Widget::Grid->new({
	values => [
	    [
		$self->string("Member: "),
		_create_member_widget($self),
	    ],
	    [
		$self->string("Valuation Date: "),
		$self->join(
			Bivio::UI::HTML::Widget::FormFieldError->new({
			    field => 'MemberEntry.valuation_date',
			    label => 'Valuation Date',
			}),
			$wf->create(
			 'ImportedTransactionForm.MemberEntry.valuation_date'),
		       ),
	    ],
	],
    });
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
