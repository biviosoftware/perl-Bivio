# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::AccountingImportReview;
use strict;
$Bivio::UI::HTML::Club::AccountingImportReview::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Club::AccountingImportReview::VERSION;

=head1 NAME

Bivio::UI::HTML::Club::AccountingImportReview - review imported txns

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::AccountingImportReview;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::AccountingImportReview::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::AccountingImportReview> review imported txns

=cut

#=IMPORTS
use Bivio::TypeValue;
use Bivio::Type::EntryTypeSet;
use Bivio::UI::HTML::WidgetFactory;
use Bivio::UI::HTML::Widget::ActionBar;
use Bivio::UI::HTML::Widget::EditRowTable;
use Bivio::UI::HTML::Widget::Enum;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::StandardSubmit;

use Bivio::Biz::Model::ImportedTransactionForm;

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

    # empty action bar, allows paging
#    $fields->{action_bar} = Bivio::UI::HTML::Widget::ActionBar->new({
#	values => [],
#    });
#    $fields->{action_bar}->initialize;

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
		    column_edit_widget =>
		    _create_description_widget($self),
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

    return $self->director(
	    [['->get_request'],	'->unsafe_get',
		'Bivio::Biz::Model::ImportedTransactionForm'],
	    {}, $edit_txn_form, $edit_type_form);
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
	    page_action_bar => $fields->{action_bar},
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

    my($user_list) = $wf->create(
	    'ImportedTransactionForm.MemberEntry.user_id', {
		choices => ['Bivio::Biz::Model::RealmUserList'],
		list_display_field => 'last_first_middle',
		list_id_field => 'RealmUser.user_id',
	    });
    return $self->director(
	    [[['->get_request'], 'Bivio::Biz::Model::ImportedTransactionForm',
		'Entry.entry_type'], '->as_int'],
	    {
		$type->MEMBER_PAYMENT->as_int => $user_list,
		$type->MEMBER_PAYMENT_FEE->as_int => $user_list,
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

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
