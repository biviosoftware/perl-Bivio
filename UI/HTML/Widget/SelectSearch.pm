# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::SelectSearch;
use strict;
$Bivio::UI::HTML::Widget::SelectSearch::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::SelectSearch::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::SelectSearch - wraps a Select widget in a form for a ListModel search chooser

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::SelectSearch;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Select>

=cut

use Bivio::UI::HTML::Widget::Select;
@Bivio::UI::HTML::Widget::SelectSearch::ISA = ('Bivio::UI::HTML::Widget::Select');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::SelectSearch>

=head1 ATTRIBUTES

=over 4

=item list_class : string (required)

Name of ListModel.

=item cell_end_form : boolean [0]

Won't write end form tag.

=back

=cut

#=IMPORTS

#=VARIABLES


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::SelectSearch

Returns new of super.

=cut

sub new {
    return shift->SUPER::new(@_);
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes self then parent.  list_class must be set.

=cut

sub initialize {
    my($self) = @_;
    $self->put(
	form_class => 'SelectSearchForm',
	form_model => [ref(Bivio::Biz::Model
	    ->get_instance('SelectSearchForm'))],
	field => 'search',
	auto_submit => 1,
	choices => [ref(Bivio::Biz::Model
	    ->get_instance($self->get('list_class')))],
    );
    return shift->SUPER::initialize(@_);
}

=for html <a name="render"></a>

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate
widget values.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    Bivio::Biz::Model->new($req, 'SelectSearchForm')->process($req, {
	search => $source->get('list_model')->get_query->get('search'),
    });
    $$buffer .= '<form method=get action="' . $req->get('uri') . '">';
    $self->SUPER::render($source, $buffer);
    $$buffer .= '</form>'
	unless $self->get_or_default('cell_end_form', 0);
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
