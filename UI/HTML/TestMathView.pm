# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::TestMathView;
use strict;
$Bivio::UI::HTML::TestMathView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::TestMathView - a view with a multiplication table model

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::HTML::TestMathView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::HTML::TestMathView>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::UI::HTML::ListView;
use Bivio::Biz::TestListModel;
use Bivio::UI::HTML::Link;
use Bivio::UI::HTML::Presentation;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_LIST_VIEW) = Bivio::UI::HTML::ListView->new('');
my($_UP_LINK) = Bivio::UI::HTML::Link->new(
	Bivio::UI::HTML::Presentation::NAV_UP(),
	'', '', '', '');
my($_DOWN_LINK) = Bivio::UI::HTML::Link->new(
	Bivio::UI::HTML::Presentation::NAV_DOWN(),
	'', '', '', '');
my($_NAV_LINKS) = [$_UP_LINK, $_DOWN_LINK];

my($_RESET_LINK) = Bivio::UI::HTML::Link->new( 'reset',
	'"/i/undo.gif" border=0',
	'', 'Reset', 'Reset to (1,1)');
my($_ACTION_LINKS) = [$_RESET_LINK];


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::TestMathView

Creates a new view which shows a list view for a multiplication table.

=cut

sub new {
    my($proto, $name)  = @_;
    my($self) = &Bivio::UI::View::new($proto, $name);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_action_links"></a>

=head2 get_action_links(Model model, Request req)

Returns the reset action link.

=cut

sub get_action_links {
    my($self) = @_;

    $_RESET_LINK->set_url('./'.$self->get_name()
	    .'?mf=index(0)');

    return $_ACTION_LINKS;
}

=for html <a name="get_default_model"></a>

=head2 get_default_model() : Model

Returns the default model ready for rendering.

=cut

sub get_default_model {
    #NOTE: could cache this
    return Bivio::Biz::TestListModel->new();
}

=for html <a name="get_nav_links"></a>

=head2 get_nav_links(Model target, Request req) : array

Returns the up and down nav links.

=cut

sub get_nav_links {
    my($self, $model, $req) = @_;

    # hacked for now - need better page determination & boundaries

    my($size) = $model->get_result_set_size();
    my($page_size) = 10;

    my($next_index) = $model->get_index() + $page_size;
    my($prev_index) = $model->get_index() - $page_size;

    if ($next_index < $size) {
	$_DOWN_LINK->set_icon(Bivio::UI::HTML::Link::SCROLL_DOWN_ICON());
	$_DOWN_LINK->set_description("Next $page_size items");
	$_DOWN_LINK->set_url('./'.$self->get_name()
		.'?mf=index('.$next_index.')');
    }
    else {
	$_DOWN_LINK->set_icon(Bivio::UI::HTML::Link::SCROLL_DOWN_IA_ICON());
	$_DOWN_LINK->set_description("No more items");
	$_DOWN_LINK->set_url('');
    }

    if ($prev_index > 0) {
	$_UP_LINK->set_icon(Bivio::UI::HTML::Link::SCROLL_UP_ICON());
	$_UP_LINK->set_description("Previous $page_size items");
	$_UP_LINK->set_url('./'.$self->get_name()
		.'?mf=index('.$prev_index.')');
    }
    else {
	$_UP_LINK->set_icon(Bivio::UI::HTML::Link::SCROLL_UP_IA_ICON());
	$_UP_LINK->set_description("No previous items");
	$_UP_LINK->set_url('');
    }

    return $_NAV_LINKS;
}

=for html <a name="render"></a>

=head2 render(Model target, Request req)

Renders the model onto the request's output stream.

=cut

sub render {
    my($self, $model, $req) = @_;

    $_LIST_VIEW->render($model, $req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
