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
    $self->put(page_heading => '1999 Taxes (Beta)');

    return Bivio::UI::HTML::Widget::Grid->new({
	values => [
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		Bivio::UI::HTML::Widget::String->new({
		    value => <<'EOF',
Investment clubs are required to file one copy of Form 1065, and one
copy of Schedule K-1 for each member. Each member should also receive
a copy of the Schedule K-1 for their records. Form 1065 is only an
informational return, used to report gains and losses for the
partnership. Taxable items are allocated proportionally among members,
who then claim their portion of the club's tax burden on their
individual tax returns.
EOF
		}),
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		Bivio::UI::HTML::Widget::String->new({
		    value => 'Tax Options',
		    string_font => 'table_heading',
		}),
	    ],
	    [
		Bivio::UI::HTML::Widget::String->new({
		    value => <<'EOF',
Before selecting the reports below, follow the option links to specify
extra information about your partnership and members.

EOF
		}),
	    ],
	    [
		$self->join(
		    '<ul><li>',
		    $self->link('IRS 1065 Options',
			    'CLUB_ACCOUNTING_TAX99_1065_PARAMETERS'),
		    '</li><li>',
		    $self->link('IRS K-1 Options',
			    'CLUB_ACCOUNTING_TAX99_K1_PARAMETERS'),
		    '</li></ul>',
		),
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
		Bivio::UI::HTML::Widget::String->new({
		    value => 'Tax Forms',
		    string_font => 'page_heading',
		}),
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		$self->link('IRS 1065 Form', 'CLUB_ACCOUNTING_TAX99_F1065'),
	    ],
	    [
		$self->join('&nbsp;'),
	    ],
	    [
		Bivio::UI::HTML::Widget::String->new({
		    value => 'Member K-1',
		    string_font => 'table_heading',
		}),
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
		$self->join('<br>',
		    Bivio::UI::HTML::Widget::HorizontalRule->new({
			size => 1,
			noshade => 1,
		    }),
		),
	    ],
	    [
		Bivio::UI::HTML::Widget::String->new({
		    value => 'Schedules and Itemizations',
		    string_font => 'page_heading',
		}),
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
