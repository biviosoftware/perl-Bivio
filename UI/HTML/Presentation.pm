# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Presentation;
use strict;
$Bivio::UI::HTML::Presentation::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Presentation - A view arranger with NavBar and ActionBar.

=head1 SYNOPSIS

    use Bivio::UI::HTML::Presentation;
    my($model) = Bivio::Biz::PropertyModel::Test->new('test2', {}, 'title', 'heading');
    my($view) = Bivio::UI::TestView->new('test', '<i>a test view</i>', $model);
    my($page) = Bivio::UI::HTML::Presentation->new([view]);
    $view->activate()->render($model, $req);

=cut

=head1 EXTENDS

L<Bivio::UI::MultiView>

=cut

use Bivio::UI::MultiView;
@Bivio::UI::HTML::Presentation::ISA = qw(Bivio::UI::MultiView);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Presentation> is a multi part view renderer. It renders
one active view and its action bar. Other sub view names are drawn
in a menu. The format looks like:

 +-------+
 |       | model-title
 +----++-+
 |    || | navbar   actionbar
 +----+| |
 |    || | active-view
 +----++-+

The title bar is rendered using the L<Bivio::Biz::Model/"get_title"> of
L<Bivio::Biz::Model>.

Navbar items are looked up using the NAV constants defined below. Views
which wish to export navigation links should use these names of the
L<Bivio::UI::HTML::LinkSupport> interface. Action links are rendered
in a similar way.

=cut

=head1 CONSTANTS

=cut

=for html <a name="NAV_BACK"></a>

=head2 NAV_BACK : string

Name used to look up the 'back' nagivation link from the active view.

=cut

sub NAV_BACK {
    return 'back';
}

=for html <a name="NAV_DOWN"></a>

=head2 NAV_DOWN : string

The name used to look up the 'down' navigation link from the active view.

=cut

sub NAV_DOWN {
    return 'down';
}

=for html <a name="NAV_LEFT"></a>

=head2 NAV_LEFT : string

The name used to look up the 'left' navigation link from the active view.

=cut

sub NAV_LEFT {
    return 'left';
}

=for html <a name="NAV_RIGHT"></a>

=head2 NAV_RIGHT : string

The name used to look up the 'right' navigation link from the active view.

=cut

sub NAV_RIGHT {
    return 'right';
}

=for html <a name="NAV_UP"></a>

=head2 NAV_UP : string

The name used to look up the 'up' navigation link from the active view.

=cut

sub NAV_UP {
    return 'up';
}

#=IMPORTS
use Bivio::UI::HTML::Link;
use Bivio::UI::HTML::MenuRenderer;

#=VARIABLES
my($_MENU_RENDERER) = Bivio::UI::HTML::MenuRenderer->new();

my($_EMPTY_LINK) = Bivio::UI::HTML::Link->new('empty',
	Bivio::UI::HTML::Link::EMPTY_ICON(), '', '', '');

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(Model target, Request req)

Renders a view with NavBar, ActionBar, and Menu.

=cut

sub render {
    my($self, $model, $req) = @_;
    my($reply) = $req->get_reply();

    $reply->print('<table border=0 cellpadding=0 cellspacing=0 width="100%">'
	    .'<tr><td colspan=3>'
	    ."\n<!-- TITLE -->");

    $self->render_title($model, $req);

    $reply->print('</td></tr><tr><td valign=top>'
	    ."\n<!-- NAV BAR -->");

    $self->render_nav_bar($model, $req);

    $reply->print('</td><td width="1%" rowspan=2>'
	    ."\n<!-- SPACER -->&nbsp;</td>");

    $reply->print('<td width="1%" rowspan=2 valign="top">'
	    .'<table border=0 cellpadding=0 cellspacing=0>'
	    ."<tr><td>\n<!-- VIEW ACTIONS -->");

    $self->render_action_bar($model, $req);

    $reply->print('</td></tr></table></td></tr>'
	    .'<tr><td valign=top><br>'
	    ."\n<!-- PRESENTATION VIEW -->");

    $self->get_active_view()->render($model, $req);

    $reply->print('</td></tr></table>');
    return;
}

=for html <a name="render_action_bar"></a>

=head2 render_action_bar(Model model, Request req)

Renders a model's actions. Action links are accessed through the active
view L<Bivio::UI::HTML::LinkSupport/"get_action_links"> method.

=cut

sub render_action_bar {
    my($self, $model, $req) = @_;
    my($reply) = $req->get_reply();

    # see if the active view implements LinkSupport
    my($action_links) = undef;
    if ($self->get_active_view()->can('get_action_links')) {
	$action_links =  $self->get_active_view()->get_action_links(
		$model, $req);
    }

    if ($action_links && scalar(@$action_links)) {

	$reply->print('<table border=0 cellpadding=5 cellspacing=0'
		.' bgcolor="#E9E3C7"><tr>'
		.'<td align=center valign="top"><small>');

	my($link);
	foreach $link (@$action_links) {
	    $reply->print('<p>');
	    $link->render($model, $req);
	}
	$reply->print('</small></td></tr></table>');
    }
    return;
}

=for html <a name="render_nav_bar"></a>

=head2 render_nav_bar(Model model, Request req)

Draws the nav and menu bar. Navigation links (arrows) are accesses
through the active view L<Bivio::UI::HTML::LinkSupport/"get_nav_links">
method.

=cut

sub render_nav_bar {
    my($self, $model, $req) = @_;
    my($reply) = $req->get_reply();

    $reply->print('<table border=0 cellpadding=0 cellspacing=0'
	    .' width="100%"><tr>');

    my($nav_links) = undef;
    # see if the active view implements LinkSupport
    if ($self->get_active_view()->can('get_nav_links')) {
	$nav_links = $self->get_active_view()->get_nav_links(
		$model, $req);

	$reply->print('<td width="1%">');

	my($link) = &_find_named_object(NAV_BACK(), $nav_links);
	if ($link) {
	    $link->render($model, $req);
	    $reply->print('</td><td width="1%">');
	}
	$link = &_find_named_object(NAV_UP(), $nav_links)
		|| $_EMPTY_LINK;
        $link->render($model, $req);

	$reply->print('</td><td width="1%">');
	$link = &_find_named_object(NAV_DOWN(), $nav_links)
		|| $_EMPTY_LINK;
	$link->render($model, $req);

	$reply->print('</td>');
    }

    $reply->print('<td width="100%" valign=top align=center>'
	    ."\n<!-- VIEW MENU -->");

    my($menu) = $self->get_menu();
    if ($menu) {
	$menu->set_selected($req->get('task_id'));
	$_MENU_RENDERER->render($menu, $req);
    }
    $reply->print('</td>');

    if ($nav_links) {

	$reply->print('<td width="1%">');

	my($link) = &_find_named_object(NAV_LEFT(), $nav_links)
		|| $_EMPTY_LINK;
        $link->render($model, $req);

	$reply->print('</td><td width="1%">');
	$link = &_find_named_object(NAV_RIGHT(), $nav_links)
		|| $_EMPTY_LINK;
	$link->render($model, $req);

	$reply->print('</td>');
    }
    $reply->print('</tr></table>');
    return;
}

=for html <a name="render_title"></a>

=head2 render_title(Model model, Request req)

Draws the model's title. The title is determined using the
L<Bivio::Biz::Model/"get_title"> method of L<BIvio::Biz::Model>.

=cut

sub render_title {
    my($self, $model, $req) = @_;
    my($reply) = $req->get_reply();

    $reply->print('<table border=0 cellpadding=5 cellspacing=0 width="100%">'
	    .'<tr bgcolor="#E0E0FF">'
	    .'<td width="100%" colspan=2>'
	    .'<font face="arial,helvetica,sans-serif">'
	    .'<big><strong>');
    my($view) = $self->get_active_view();
    my($title) = $view->can('get_title') ? $view->get_title($model, $req)
	    : '&nbsp;';
    $reply->print($title);

    $reply->print('</strong></big></font></td></tr></table>');
    return;
}

#=PRIVATE METHODS

# _find_named_object(array a) : ref
#
# Finds the named object in an array of named things. Returns undef
# if no object by that name is found.

sub _find_named_object {
    my($name, $array) = @_;

    my($item);
    foreach $item (@$array) {
	if ($item->get_name() eq $name) {
	    return $item;
	}
    }
    return undef;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
