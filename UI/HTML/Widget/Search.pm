# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Search;
use strict;
$Bivio::UI::HTML::Widget::Search::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
#RJN: PLease update your emacs.local.
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
#RJN: Removed the imports.  Just creates a maintenance burden.
#     IF it compiles cleanly with perl -w Search.pm, then don't need
#     the imports.

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
#RJN: Deleted list_model, because it is inappropriate.  There is only
#RJN: one search list.  ancestral_get was inappropriate, too.  Should only
#RJN: be used in clear circumstances.  Removed initialize, because to
#RJN: make fully dynamic.  This has been my problem.  I want to pre-optimize. 
    # search list might not be loaded
    my($list) = $req->unsafe_get('Bivio::Biz::Model::SearchList');
#RJN: '.' doesn't have spaces around it.  I adopted Paul's style
#RJN: Don't repeat the assignment.  Assign one long string to $$buffer.
    $$buffer .= '<form method=get action="'
#RJN: Don't assume the auth_id is the GENERAL->as_int.  This assumption
#RJN: shouldn't be spread around.  That's what the 'type" on the realm is for.
#RJN: Avoid the if, use ?:, It may look ugly, but it is less of a maint burden.
#RJN: Note the switch of the test to == CLUB.  If the name of the task is
#RJN: CLUB, then you it shouldn't be the "other" case.  If the user is in
#RJN: RealmType::USER, then make it a general search until we can search the
#RJN: user's realm.
	    .$req->format_stateless_uri(
		    $req->get('auth_realm')->get('type')
		        == Bivio::Auth::RealmType::CLUB()
		    ? Bivio::Agent::TaskId::CLUB_SEARCH()
		    : Bivio::Agent::TaskId::GENERAL_SEARCH())
            .'"'
#RJN: All links should have this.  (See Widget::Form)
	    .$self->link_target_as_html().'>'
	    .$fp.'<input type=text size='.$self->get('size')
#RJN: #TODO: should be flush left
#TODO: We don't have a type for the query 'search' field, or do we?
#RJN: This would normally be part of the form model.  It is
#RJN:  ok to use Line here until we understand the problem better.
            .' maxlength='.Bivio::Type::Line->get_width()
	    .' name='.Bivio::SQL::ListQuery->to_char('search')
            .' value="'
	    .($list ? Bivio::Type::String->to_html($list->get_query->get(
		    'search'))
		    : '')
	    .'">'.$fs
            .$bp.'<input type=submit value="'
#RJN: Use labels as much as possible
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
