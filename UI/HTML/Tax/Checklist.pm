# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Tax::Checklist;
use strict;
$Bivio::UI::HTML::Tax::Checklist::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
use Bivio::Type::Location;
use Bivio::UI::PageType;
use Bivio::UI::HTML::Widget::ChecklistItem;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::MultiColumnedList;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Creates a tax 99 page contents.

=cut

sub create_content {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE} = {};
    $self->put(page_heading => 'Tax Checklist');

    $fields->{large_club_warning} = Bivio::UI::HTML::Widget::Indirect->new({
	value => 0,
    });
    $fields->{warning_message} = $self->join(
	$self->string('Warning: ', 'warning'),
	$self->string(<<'EOF'));

Your club's receipts for the tax year were greater that $250,000 or the club's assets at the end of the year were greater than $600,000. As a result you will be required to manually complete Schedules L, M-1, and M-2; Item F on page 1 of Form 1065; and Item J and Schedule K-1.

EOF

    $fields->{warning_message}->initialize;

    my($create_anyway) = $self->director(['task_id'], {
	Bivio::Agent::TaskId::CLUB_ACCOUNTING_TAX99_MISSING_FIELDS()
	=> Bivio::UI::HTML::Widget::Link->new({
	    href => ['->format_uri',
		Bivio::Agent::TaskId::CLUB_ACCOUNTING_TAX99_F1065(),
		Bivio::Biz::Accounting::Tax::CHECK_OVERRIDE().'=1',
	    ],
	    value => $self->string(<<'EOF'),

Create tax form with missing fields

EOF
	}),
    },
    $self->join('&nbsp;'));

    return Bivio::UI::HTML::Widget::Grid->new({
	values => [
	    [
		$self->string(<<'EOF'),

Below are a list of required items for the 1065 and K-1 forms.

EOF
	    ],
	    [
		Bivio::UI::HTML::Widget::ChecklistItem->new({
		    title => 'Club Tax ID',
		    checked => ['Bivio::Biz::Model::TaxId', 'tax_id'],
		    checked_body => $self->string(
			['Bivio::Biz::Model::TaxId', 'tax_id',
				'Bivio::UI::HTML::Format::EIN']),
		    unchecked_body => $self->join(
			$self->string('Missing club tax ID. '),
			$self->link('Edit', 'CLUB_ADMIN_TAX_ID_EDIT'),
		    ),
		}),
	    ],
	    [
		Bivio::UI::HTML::Widget::ChecklistItem->new({
		    title => 'Club Address',
		    checked => ['Bivio::Biz::Model::Address', '->format'],
		    checked_body => $self->string(
			['Bivio::Biz::Model::Address', '->format']),
		    unchecked_body => $self->join(
			$self->string('Missing club address. '),
			$self->link('Edit', 'CLUB_ADMIN_ADDRESS_EDIT'),
		    ),
		}),
	    ],
	    [
		Bivio::UI::HTML::Widget::ChecklistItem->new({
		    title => "Member Tax IDs and Addresses",
		    checked => ['all_valid_members'],
		    checked_body => $self->string(
			'All member tax IDs and addresses are set.'),
		    unchecked_body => $self->join(
			$self->string(<<'EOF'),
The following members are missing their tax ID and/or address. Select the member to edit their personal information.
EOF
			$self->join('<p>'),
			Bivio::UI::HTML::Widget::MultiColumnedList->new({
			    source => ['Bivio::Biz::Model::MemberTaxList'],
			    columns => 3,
			    widget => Bivio::UI::HTML::Widget::Link->new({
				href => ['->format_uri_for_this'],
				value => $self->string(['last_first_middle']),
			    }),
			}),
		    ),
		}),
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
	        $fields->{large_club_warning},
	    ],
	    [
		$self->string(<<'EOF'),
Don't forget to sign and date the printed return and give each member a printed copy of their K-1.
EOF
	    ],
	    [
		$create_anyway,
	    ],
	    [
		Bivio::UI::HTML::Widget::Link->new({
		    href => ['->format_stateless_uri',
			Bivio::Agent::TaskId::CLUB_ACCOUNTING_TAX99(),
		    ],
		    value => $self->string('Return to the taxes page'),
		}),
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

    my($address) = Bivio::Biz::Model::Address->new($req);
    $address->load(location => Bivio::Type::Location::HOME());

    $fields->{large_club_warning}->put(value =>
	    Bivio::Biz::Accounting::Tax->meets_three_requirements(
		    $req->get('auth_realm')->get('owner'),
		    $req->get('report_date'))

	    ? 0 : $fields->{warning_message});

    my($list) = $req->get('Bivio::Biz::Model::MemberTaxList');

    $req->put(
	    all_valid_members => $list->get_result_set_size == 0,
	    page_type => Bivio::UI::PageType::LIST(),
	    list_model => $list,
	    list_uri => $req->format_stateless_uri($req->get('task_id')),
	    detail_uri => $req->format_stateless_uri(
		    Bivio::Agent::TaskId::CLUB_ADMIN_USER_DETAIL())
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
