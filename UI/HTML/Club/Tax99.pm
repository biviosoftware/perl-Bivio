# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::Tax99;
use strict;
$Bivio::UI::HTML::Club::Tax99::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::Tax99 - 99 tax links

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::Tax99;
    Bivio::UI::HTML::Club::Tax99->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::Tax99::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::Tax99> 99 tax links

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::HorizontalRule;
use Bivio::UI::HTML::Widget::MultiColumnedList;
use Bivio::UI::HTML::Widget::RadioGrid;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::PageType;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="new"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Creates a tax 99 page contents.

=cut

sub create_content {
    my($self) = @_;
    $self->put(page_heading => '1999 Taxes');
    $self->put(page_subtopic => Bivio::UI::Label->get_simple('TAXES'));
    return Bivio::UI::HTML::Widget::Grid->new({
	values => [
	    [
		' ',
	    ],
	    [
		$self->string('Tax Options', 'page_heading'),
	    ],
	    [
		$self->string(<<'EOF'),

Before selecting the reports below, follow the option links to specify extra information about your partnership and members.

EOF
	    ],
	    [
		$self->join(
		    '<ul><li>',
		    $self->link('IRS 1065 Options',
			    'CLUB_ACCOUNTING_TAX99_F1065_PARAMETERS'),
		    '</li><li>',
		    $self->link('IRS K-1 Options',
			    'CLUB_ACCOUNTING_TAX99_F1065K1_PARAMETERS'),
		    '</li><li>',
		    $self->link('Tax Checklist',
			    'CLUB_ACCOUNTING_TAX99_CHECKLIST'),
		    '</li></ul>',
		),
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		$self->join(
		    $self->string('Allocation Method.', 'description_label'),
		    $self->string(<<'EOF')),
 Determines the manner in which taxable entries are allocated to each member. The time based method allocates each taxable entry according to each member's ownership in the club at the time of the entry. The snapshot method allocates taxable entries according to the member ownership at the time of withdrawal, and at the end of the year. Most clubs use the "Time Based" method.
EOF
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		Bivio::UI::HTML::Widget::Form->new({
		    form_model => ['Bivio::Biz::Model::AllocationMethodForm'],
		    value => Bivio::UI::HTML::Widget::Join->new({
			values => [
			    Bivio::UI::HTML::Widget::RadioGrid->new({
				field => 'Tax1065.allocation_method',
				choices => 'Bivio::Type::AllocationMethod',
				show_unknown => 0,
				auto_submit => 1,
			    }),
			    '<noscript><input type=submit value="Update">',
			    '</noscript>',
			],
		    }),
		}),
	    ],
	    [
		Bivio::UI::HTML::Widget::HorizontalRule->new({
		    size => 1,
		    noshade => 1,
		}),
	    ],
	    [
		$self->string('Informational Reports', 'page_heading'),
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		$self->link('Member Allocation Report',
			'CLUB_ACCOUNTING_TAX99_MEMBER_ALLOCATION'),
	    ],
	    [
		$self->join('<br>',
		    Bivio::UI::HTML::Widget::HorizontalRule->new({
			size => 1,
			noshade => 1,
		    }),
		),
	    ],
	    [
		$self->string('Tax Forms', 'page_heading'),
	    ],
	    [
		$self->string(<<'EOF'),

Investment clubs are required to file one copy of Form 1065, one copy of Schedule K-1 for each member, and the Schedule D and supplementary schedules below. Each member should also receive a copy of the Schedule K-1 for their records.

Form 1065 is only an informational return, used to report gains and losses for the partnership. Taxable items are allocated proportionally among members, who then claim their portion of the club's tax burden on their individual tax returns.
EOF
	    ],
	    [
		$self->join(
		    $self->string('
To properly view and print the PDF tax forms requires the free Adobe Acrobat Reader version 4.0 or greater. Download the latest Acrobat Reader '),
		    Bivio::UI::HTML::Widget::Link->new({
			value => $self->string('at the Adobe web site'),
			href =>
			'http://www.adobe.com/products/acrobat/readstep.html',
		    }),
		    $self->string('.'),
		),
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		$self->link('IRS 1065 Form (pdf)',
			'CLUB_ACCOUNTING_TAX99_F1065'),
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		$self->string('Member K-1 (pdf)', 'table_heading'),
	    ],
	    [
		Bivio::UI::HTML::Widget::MultiColumnedList->new({
		    source => ['Bivio::Biz::Model::MemberTaxList'],
		    columns => 3,
		    widget => Bivio::UI::HTML::Widget::Link->new({
			href => ['->format_uri_for_this_child'],
			value => Bivio::UI::HTML::Widget::String->new({
			    value => ['last_first_middle'],
			}),
		    }),
		}),
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		$self->string('Required Schedules and Itemizations',
			'page_heading'),
	    ],
	    [
		$self->string(<<'EOF'),

The following documents should be submitted with the partnership return.
EOF
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		$self->link('Schedule D', 'CLUB_ACCOUNTING_TAX99_SCHEDULE_D'),
	    ],
	    [
		$self->link('Other Portfolio Income',
			'CLUB_ACCOUNTING_TAX99_INCOME'),
	    ],
	    [
		$self->link('Other Portfolio Deductions',
			'CLUB_ACCOUNTING_TAX99_DEDUCTIONS'),
	    ],
	    [
		$self->link('Distributions of Money and Property',
			'CLUB_ACCOUNTING_TAX99_DISTRIBUTIONS'),
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

    $req->put(
	    page_type => Bivio::UI::PageType::LIST(),
	    list_model => $req->get('Bivio::Biz::Model::MemberTaxList'),
	    list_uri => $req->format_stateless_uri($req->get('task_id')),
	    detail_uri => $req->format_stateless_uri(
		Bivio::Agent::TaskId::CLUB_ACCOUNTING_TAX99_F1065K1()),
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
