# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Presentation;
use strict;
$Bivio::UI::HTML::Presentation::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::Presentation - A view arranger with NavBar and ActionBar.

=head1 SYNOPSIS

    use Bivio::UI::HTML::Presentation;
    Bivio::UI::HTML::Presentation->new();

=cut

=head1 EXTENDS

L<Bivio::UI::MultiView>

=cut

use Bivio::UI::MultiView;
@Bivio::UI::HTML::Presentation::ISA = qw(Bivio::UI::MultiView);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Presentation> is a multi part view renderer. It renders
one active view, its title and its action bar. Other view names are drawn
in a menu. The format looks like:

 +-------+
 |       | view-title
 +----++-+
 |    || | navbar   actionbar
 +----+| |
 |    || | active-view
 +----++-+

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

my($_EMPTY_LINK) = Bivio::UI::HTML::Link->new('empty',
	Bivio::UI::HTML::Link::EMPTY_ICON(), '', '', '');

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array views, Menu menu) : Bivio::UI::HTML::Presentation

Creates a view presentation with the specified subviews and menu.

=head2 static new(array views) : Bivio::UI::HTML::Presentation

Creates a view presentation with the specified subviews.

=cut

sub new {
    my($proto, $views, $menu) = @_;

    # no view name
    my($self) = &Bivio::UI::MultiView::new($proto, undef, $views, $menu);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(Model target, Request req)

Renders a view with NavBar, ActionBar, and Menu.

=cut

sub render {
    my($self, $model, $req) = @_;

    $req->print('<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr><td colspan=3><!-- TITLE -->
');

    $self->render_title($model, $req);

    $req->print('</td></tr>
<tr><td valign=top><!-- NAV BAR -->
');

    $self->render_nav_bar($model, $req);

    $req->print('</td><td width="1%" rowspan=2>
<!-- SPACER -->&nbsp;</td>
');

    $req->print('<td width="1%" rowspan=2 valign="top">
<table border=0 cellpadding=0 cellspacing=0>
<tr><td><!-- VIEW ACTIONS -->
');

    $self->render_action_bar($model, $req);

    $req->print('</td></tr></table></td></tr>
<tr><td valign=top><br>
<!-- VIEW -->
');

    $self->get_active_view()->render($model, $req);

    $req->print('</td></tr></table>
');
}

=for html <a name="render_action_bar"></a>

=head2 render_action_bar(Model model, Request req)

Renders a model's actions.

=cut

sub render_action_bar {
    my($self, $model, $req) = @_;

    # see if the active view implements LinkSupport
    my($action_links) = undef;
    if ($self->get_active_view()->can('get_action_links')) {
	$action_links =  $self->get_active_view()->get_action_links(
		$model, $req);
    }

    if ($action_links && scalar(@$action_links)) {

	$req->print('<table border=0 cellpadding=5 cellspacing=0
bgcolor="#E9E3C7"><tr><td align=center valign="top"><small>
');

	my($link);
	foreach $link (@$action_links) {
	    $req->print('<p>');
	    $link->render($model, $req);
	}

#    for (my($i) = 1; $i <= 3; $i++) {
#	print('<p><a href="mailto:societas@bivio.com">
#<img src="/i/compose.gif" height=17 width=25 border=0
#alt="Compose a new message to the club"><br>Compose'.$i
#.'</a>');
#    }

	$req->print('</small></td></tr></table>');
    }
}

=for html <a name="render_nav_bar"></a>

=head2 render_nav_bar(Model model, Request req)

Draws the nav and menu bar.

=cut

sub render_nav_bar {
    my($self, $model, $req) = @_;

#=pod

    $req->print('<table border=0 cellpadding=0 cellspacing=0
width="100%"><tr>');

    my($nav_links) = undef;
    # see if the active view implements LinkSupport
    if ($self->get_active_view()->can('get_nav_links')) {
	$nav_links = $self->get_active_view()->get_nav_links(
		$model, $req);

	$req->print('<td width="1%">');

	my($link) = &_find_named_object(NAV_BACK(), $nav_links);
	if ($link) {
	    $link->render($model, $req);
	    $req->print('</td><td width="1%">');
	}
	$link = &_find_named_object(NAV_UP(), $nav_links)
		|| $_EMPTY_LINK;
        $link->render($model, $req);

	$req->print('</td><td width="1%">');
	$link = &_find_named_object(NAV_DOWN(), $nav_links)
		|| $_EMPTY_LINK;
	$link->render($model, $req);

	$req->print('</td>');
    }

    $req->print('<td width="100%" valign=top align=center>
<!-- VIEW MENU -->
');

    my($menu) = $self->get_menu();
    if ($menu) {
	$menu->set_selected($self->get_active_view()->get_name());
	Bivio::UI::HTML::MenuRenderer->get_instance()->render($menu, $req);
    }
    $req->print('</td>');

    if ($nav_links) {

	$req->print('<td width="1%">');

	my($link) = &_find_named_object(NAV_LEFT(), $nav_links)
		|| $_EMPTY_LINK;
        $link->render($model, $req);

	$req->print('</td><td width="1%">');
	$link = &_find_named_object(NAV_RIGHT(), $nav_links)
		|| $_EMPTY_LINK;
	$link->render($model, $req);

	$req->print('</td>');
    }
    $req->print('</tr></table>');
}

=for html <a name="render_title"></a>

=head2 render_title(Model model, Request req)

Draws the model's title.

=cut

sub render_title {
    my($self, $model, $req) = @_;

    $req->print('<table border=0 cellpadding=5 cellspacing=0 width="100%">
<tr bgcolor="#E0E0FF">
<td width="100%" colspan=2>
<font face="arial,helvetica,sans-serif">
<big><strong>');

    $req->print($model->get_title() || '&nbsp;');

    $req->print('</strong></big></font>
</td></tr></table>
');
}

#=PRIVATE METHODS

# Finds the named object in an array of named things. Returns undef
# if no object by that name is found.
#
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
