# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::TaxTest;
use strict;
$Bivio::UI::HTML::Club::TaxTest::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::TaxTest - test tax links

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::TaxTest;
    Bivio::UI::HTML::Club::TaxTest->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::TaxTest::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::TaxTest> test tax links

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::Table2;
use Bivio::UI::PageType;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::TaxTest

Creates a tax test page.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    $fields->{content} = Bivio::UI::HTML::Widget::Grid->new({
	values => [
	    [
		Bivio::UI::HTML::Widget::Link->new({
		    href => ['->format_stateless_uri',
		      Bivio::Agent::TaskId::CLUB_ACCOUNTING_TAX99_F1065_TEST(),
		    ],
		    value => Bivio::UI::HTML::Widget::String->new({
			value => "\nIRS 1065 Form",
		    }),
		}),
	    ],
	    [
		Bivio::UI::HTML::Widget::Table2->new({
		    list_class => 'MemberTaxList',
		    columns => [
			['last_first_middle', {
			    column_widget => Bivio::UI::HTML::Widget::Link
			    ->new({
				href => ['->format_uri_for_this_child'],
				value => Bivio::UI::HTML::Widget::String
				->new({
				    value => ['last_first_middle'],
				}),
			    }),
			}],
		    ],
		}),
	    ],
	],
    });
    $fields->{content}->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Draws the links.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->put(page_subtopic => undef,
	    page_content => $fields->{content},
	    page_type => Bivio::UI::PageType::LIST(),
	    list_model => $req->get('Bivio::Biz::Model::MemberTaxList'),
	    list_uri => $req->format_stateless_uri($req->get('task_id')),
	    detail_uri => $req->format_stateless_uri(
		Bivio::Agent::TaskId::CLUB_ACCOUNTING_TAX99_F1065K1_TEST()),
	   );
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
