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

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

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
    $fields->{action_bar} = Bivio::UI::HTML::Widget::ActionBar->new({
	values => [],
    });
    $fields->{action_bar}->initialize;

    $self->put_heading('CLUB_ACCOUNTING_SYNC_REVIEW');

    return $self->join(
	    $self->string('
This page lists all transactions which have been successfully imported from your brokerage account.  Unclassified transactions can be reconciled using ',
		    'page_text'),
	    $self->link('AccountSync Identify Unassigned Transactions',
		    'CLUB_ACCOUNTING_SYNC_IDENTIFY'),
	    $self->string('.', 'page_text'),
	    '<p>&nbsp',
	    $self->table('ImportedTransactionList', [
		'RealmTransaction.date_time',
		['', {
		    column_widget => Bivio::UI::HTML::Widget::TaxType->new({}),
		    column_heading => 'Entry.entry_type',
		}],
		'Entry.amount',
		['RealmTransaction.remark', {
		    column_heading => 'description_heading',
		}],
		$self->list_actions([
		    ['delete', 'CLUB_ACCOUNTING_ACCOUNT_TRANSACTION_DELETE'],
		    ['edit', 'CLUB_ACCOUNTING_TRANSACTION_EDIT', undef,
			['->can_edit']],
		]),
	    ]),
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
	    page_action_bar => $fields->{action_bar},
	    list_uri => $req->format_stateless_uri($req->get('task_id')),
	   );

    return $self->SUPER::execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
