# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Search;
use strict;
$Bivio::UI::HTML::Widget::Search::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::Search::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::Search - search field

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Search;
    Bivio::UI::HTML::Widget::Search->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::Search::ISA = qw(Bivio::UI::Widget);

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

=item search_use_this_task : boolean [0] (inherited)

Task to use for searching.  By default, searches CLUB_SEARCH
and GENERAL_SEARCH.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';


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
#TODO: Make this more general so can be using any search list
    my($list) = $req->unsafe_get('Model.SearchList');
    $$buffer .= '<form method=get action="'
	    .$req->format_stateless_uri(
		    $self->ancestral_get('search_use_this_task', 0)
		    ? undef
		    : $req->get('auth_realm')->get('type')
		        == Bivio::Auth::RealmType->CLUB
		        ? Bivio::Agent::TaskId->CLUB_SEARCH
		        : Bivio::Agent::TaskId->GENERAL_SEARCH)
            .'"'
	    .$_VS->vs_link_target_as_html($self).'>'
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
	    .Bivio::HTML->escape_attr_value(
		    Bivio::UI::Text->get_value('search_button', $req))
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
