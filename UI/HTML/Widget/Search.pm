# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Search;
use strict;
$Bivio::UI::HTML::Widget::Search::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Search::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Search - search field

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Search;
    Bivio::UI::HTML::Widget::Search->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Search::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Search> draws a C<INPUT> tag with
attribute C<TYPE=TEXT>. Adds a C<SUBMIT> button labeled "Search"
to the right.

=head1 ATTRIBUTES

=over 4

=item cell_end_form : boolean [0]

Same value as L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
If true, won't write the C<FORM> end tag.

=item link_target : string [] (inherited)

The value to be passed to the C<TARGET> attribute of C<A> tag.

=item size : int (required)

How wide is the field represented.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Does nothing.  Widget is entirely dynamic.

=cut

sub initialize {
    return;
}

=for html <a name="render"></a>

=head2 render(any source, Text_ref buffer)

Render the input field.  First render is special, because we need
to extract the field's type and can only do that when we have a form.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    my($fp, $fs) = Bivio::UI::Font->format_html('search_field', $req);
    my($bp, $bs) = Bivio::UI::Font->format_html('form_submit', $req);
    # search list might not be loaded
    my($list) = $req->unsafe_get('Bivio::Biz::Model::SearchList');
    $$buffer .= '<form method=get action="'
	    .$req->format_stateless_uri(
		    $req->get('auth_realm')->get('type')
		        == Bivio::Auth::RealmType::CLUB()
		    ? Bivio::Agent::TaskId::CLUB_SEARCH()
		    : Bivio::Agent::TaskId::GENERAL_SEARCH())
            .'"'
	    .$self->link_target_as_html().'>'
	    .$fp.'<input type=text size='.$self->get('size')
#TODO: should be flush left
            .' maxlength='.Bivio::Type::Line->get_width()
	    .' name='.Bivio::SQL::ListQuery->to_char('search')
            .' value="'
	    .($list ? Bivio::Type::String->to_html($list->get_query->get(
		    'search'))
		    : '')
	    .'">'.$fs
            .$bp.'<input type=submit value="'
	    .Bivio::UI::Label->get_simple('search_button')
            .'">'.$bs
	    .($self->get_or_default('cell_end_form', 0) ? '' : '</form>');

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
