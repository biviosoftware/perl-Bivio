# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Tax::Checklist;
use strict;
$Bivio::UI::HTML::Tax::Checklist::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Tax::Checklist::VERSION;

=head1 NAME

Bivio::UI::HTML::Tax::Checklist - displays missing tax field

=head1 SYNOPSIS

    use Bivio::UI::HTML::Tax::Checklist;
    Bivio::UI::HTML::Tax::Checklist->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Tax::Checklist::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Tax::Checklist> displays missing tax field

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Accounting::Tax;
use Bivio::Biz::Model::Address;
use Bivio::UI::HTML::Tax::AttachmentPage;
use Bivio::UI::HTML::Widget::MultiColumnedList;
use Bivio::UI::HTML::Widget::ChecklistItem;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::PageType;
use Bivio::Type::Location;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::Widget

Creates a tax 99 page contents.

=cut

sub create_content {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE} = {};
    $self->put(page_heading => Bivio::UI::HTML::Club::ReportPage
	    ->get_heading_with_one_date('page_heading'));

    $fields->{large_club_warning} = $_VS->vs_indirect(0);
    $fields->{warning_message} = $_VS->vs_join(
	$_VS->vs_string('Warning: ', 'warning'),
	'<p>',
	$_VS->vs_string(<<'EOF', 'page_text'));
Your club's receipts for the tax year were greater that $250,000 or the club's assets at the end of the year were greater than $600,000. As a result you will be required to manually complete Schedules L, M-1, and M-2; Item F on page 1 of Form 1065; and Item J and Schedule K-1.

EOF

    $fields->{warning_message}->initialize;

    $fields->{over_100_members} = $_VS->vs_indirect(0);
    $fields->{over_100_members_warning} = $_VS->vs_join(
	    $_VS->vs_string('Warning: ', 'warning'),
	    '<p>',
	    $_VS->vs_string(<<'EOF', 'page_text'));
Your club has greater than 100 members and may be required to file electronically. Please refer to the Electronic Filing section of the IRS Instructions for Form 1065 for more information.

EOF

    $fields->{over_100_members_warning}->initialize;

    return Bivio::UI::HTML::Widget::Grid->new({
	values => [
	    [
		$_VS->vs_string(<<'EOF'),

Below are a list of required items for the 1065 and K-1 forms.

EOF
	    ],
	    [
		Bivio::UI::HTML::Widget::ChecklistItem->new({
		    title => 'Club Tax ID',
		    checked => ['Bivio::Biz::Model::TaxId', 'tax_id'],
		    checked_body => $_VS->vs_string(
			['Bivio::Biz::Model::TaxId', 'tax_id',
				'Bivio::UI::HTML::Format::EIN']),
		    unchecked_body => $_VS->vs_join(
			$_VS->vs_string('Missing club tax ID. '),
			$_VS->vs_link('Edit', 'CLUB_ADMIN_TAX_ID_EDIT'),
		    ),
		}),
	    ],
	    [
		Bivio::UI::HTML::Widget::ChecklistItem->new({
		    title => 'Club Address',
		    checked => ['Bivio::Biz::Model::Address', '->format'],
		    checked_body => $_VS->vs_string(
			['Bivio::Biz::Model::Address', '->format']),
		    unchecked_body => $_VS->vs_join(
			$_VS->vs_string('Missing club address. '),
			$_VS->vs_link('Edit', 'CLUB_ADMIN_ADDRESS_EDIT'),
		    ),
		}),
	    ],
	    [
		Bivio::UI::HTML::Widget::ChecklistItem->new({
		    title => "Member Tax IDs and Addresses",
		    checked => ['all_valid_members'],
		    checked_body => $_VS->vs_string(
			'All member tax IDs and addresses are set.'),
		    unchecked_body => $_VS->vs_join(
			$_VS->vs_string(<<'EOF'),
The following members are missing their tax ID and/or address. Select the member to edit their personal information. If you do not specify a member's address and tax ID, then they must be filled in by hand on the generated tax forms.
EOF
			$_VS->vs_join('<p>'),
			Bivio::UI::HTML::Widget::MultiColumnedList->new({
			    source => ['Bivio::Biz::Model::MemberTaxList'],
			    columns => 3,
			    widget => $_VS->vs_link(['last_first_middle'],
				    ['->format_uri_for_this']),
			}),
		    ),
		}),
	    ],
	    [
		$_VS->vs_join('&nbsp;'),
	    ],
	    [
	        $fields->{large_club_warning},
	    ],
	    [
		$fields->{over_100_members},
	    ],
	    [
		$_VS->vs_string(<<'EOF'),
Don't forget to sign and date the printed return and give each member a printed copy of their K-1.
EOF
	    ],
	    [
		$_VS->vs_join('&nbsp;'),
	    ],
	    [
		$_VS->vs_director(['task_id'], {
		    Bivio::Agent::TaskId::CLUB_ACCOUNTING_TAXES_MISSING_FIELDS()
		    => Bivio::UI::HTML::Club::Taxes->link_club_1065_pdf(
			    'Create tax form with missing fields', 1),
		},
			$_VS->vs_join('&nbsp;')),
	    ],
	    [
		$_VS->vs_join('&nbsp;'),
	    ],
	    [
		Bivio::UI::HTML::Tax::AttachmentPage->get_tax_page_link(),
	    ],
	],
    });
}

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Draws the links.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    Bivio::Biz::Model::Address->new($req)->load(
	    location => Bivio::Type::Location::HOME());

#TODO: This should be part of the request, not fields
    $fields->{large_club_warning}->put(value =>
	    Bivio::Biz::Accounting::Tax->meets_three_requirements(
		    $req, $req->get('report_date'))
	    ? 0 : $fields->{warning_message});

    $fields->{over_100_members}->put(value =>
	    $req->get('Bivio::Biz::Model::MemberAllocationList')
	    ->get_result_set_size <= 100
	    ? 0 : $fields->{over_100_members_warning});

    my($list) = $req->get('Bivio::Biz::Model::MemberTaxList');

    $req->put(
	    all_valid_members => $list->get_result_set_size == 0,
	    page_type => Bivio::UI::PageType::LIST_ALL(),
	    list_model => $list,
	    list_uri => $req->format_stateless_uri($req->get('task_id')),
	    detail_uri => $req->format_stateless_uri(
		    Bivio::Agent::TaskId::CLUB_ADMIN_USER_DETAIL()),
	   );
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
