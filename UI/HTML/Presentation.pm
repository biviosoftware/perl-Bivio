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

L<Bivio::UI::HTML::MultiView>

=cut

@Bivio::UI::HTML::Presentation::ISA = qw(Bivio::UI::HTML::MultiView);

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

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name, hash views, string default_view) : Bivio::UI::HTML::Presentation

Creates a presentation with the specified views. The active view has its
actions rendered in an ActionBar.

=cut

sub new {
    my($proto, $name, $views, $default_view) = @_;
    my($self) = &Bivio::UI::HTML::MultiView::new($proto, $name, $views,
	    $default_view);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(UNIVERSAL target, Request req)

Renders a view with NavBar, ActionBar, and Menu.

=cut

sub render {
    my($self, $model, $req) = @_;

    print('<table border=0 cellpadding=0 cellspacing=0 width="100%">
<tr><td colspan=3><!-- TITLE -->
');

    $self->render_title($model, $req);

    print('</td></tr>
<tr><td valign=top><!-- NAV BAR -->
');

    $self->render_nav_bar($model, $req);

    print('<td width="1%" rowspan=2>
<!-- SPACER -->&nbsp;</td>
');

    print('<td width="1%" rowspan=2 valign="top">
<table border=0 cellpadding=0 cellspacing=0>
<tr><td><!-- VIEW ACTIONS -->
');

    $self->render_action_bar($model, $req);

    print('</td></tr></table></td></tr>
<tr><td valign="top"><!-- VIEW -->
');

    $self->get_active_view()->render($model, $req);

    print('</td></tr></table>
');
}

=for html <a name="render_action_bar"></a>

=head2 render_action_bar(Model model, Request req)

Renders a model's actions.

=cut

sub render_action_bar {
    my($self, $model, $req) = @_;

    print('<table border=0 cellpadding=5 cellspacing=0 bgcolor="#E9E3C7">
<tr><td align=center valign="top"><small>
');

    #TODO: get actions

    for (my($i) = 1; $i <= 3; $i++) {
	print('<p><a href="mailto:societas@bivio.com">
<img src="/i/compose.gif" height=17 width=25 border=0
alt="Compose a new message to the club"><br>Compose'.$i
.'</a>');
    }

    print('</small></td></tr></table>
');
}

=for html <a name="render_nav_bar"></a>

=head2 render_nav_bar(Model model, Request req)

Draws the nav and menu bar.

=cut

sub render_nav_bar {
    my($self, $model, $req) = @_;

    print('<table border=0 cellpadding=0 cellspacing=0>
<tr><td width="1%"><img src="/i/scroll_up_ia.gif" height=31
width=31 border=0 alt="Next page" vspace=5></td>
<td width="1%"><img src="/i/scroll_up_ia.gif" height=31
width=31 border=0 alt="Previous page" hspace=3></td>
<td width="100%" valign=top align=center>
<!-- VIEW MENU -->
');

    $self->render_menu(0, $req);

    print('</td>
<td width="1%"><img src="/i/scroll_up_ia.gif" height=31
width=31 border=0 alt="Next message" hspace=3></td>
<td width="1%"><img src="/i/scroll_up_ia.gif" height=31
width=31 border=0 alt="Previous message"></td>
</tr></table></td>
');
}

=for html <a name="render_title"></a>

=head2 render_title(Model model, Request req)

Draws the active view title.

=cut

sub render_title {
    my($self, $model, $req) = @_;

    print('<table border=0 cellpadding=5 cellspacing=0 width="100%">
<tr bgcolor="#E0E0FF">
<td width="100%" colspan=2>
<font face="arial,helvetica,sans-serif">
<big><strong>');

    print($self->get_title());

    print('</strong></big></font>
</td></tr></table>
');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
