# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::MenuRenderer;
use strict;
$Bivio::UI::HTML::MenuRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::MenuRenderer - Draws a Bivio::UI::Menu as HTML.

=head1 SYNOPSIS

    use Bivio::UI::HTML::MenuRenderer;
    my($menu) = Bivio::UI::Menu->new(1,
	    ['human', 'Human',
	     'cat', 'Cat',
	     'dog', 'Dog']);
    $menu->set_selected('cat');
    my($mr) = Bivio::UI::HTML::MenuRenderer->new();
    $mr->render($menu, $req);

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

use Bivio::UI::Renderer;
@Bivio::UI::HTML::MenuRenderer::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::HTML::MenuRenderer> renders top-level and sub menus as a
single row table of menu item cells.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::MenuRenderer

Creates a new menu renderer.

=cut

sub new {
    my($self) = &Bivio::UI::Renderer::new(@_);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(Menu target, Request req)

Draws the state of the menu. Top level menus are anchored downward,
sub menus are anchored upward.

=cut

sub render {
    my($self, $menu, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($names) = $menu->get_names();
    my($display_names) = $menu->get_display_names();
    my($active) = $menu->get_selected();

    # don't show menu if is a sub menu and has only one item
    if (!$menu->is_top() && scalar(@{$names}) <= 1) {
        return;
    }

    $req->print('<table border=0 cellpadding=2 cellspacing=0><tr>');

    my($pad) = '<td></td>';
    my($html) = '<td>&nbsp;</td>';
    my($link_root) = $menu->is_top() ? '/'.$req->get_target_name().'/'
	    : '/'.$req->get_target_name().'/'.$req->get_controller_name().'/';

    for (my($i) = 0; $i < scalar(@$names); $i++) {
        my($name) = $names->[$i];
	my($display_name) = $display_names->[$i];
	my($link) = '<a href="'.$link_root.$name.'">'.$display_name.'</a>';

        if ($name eq $active) {
            $pad .= '<td bgcolor="#E0E0FF"><img src="/i/dot.gif"'
		    .'height=1 width=1 border=0></td>';
            $html .= '<td bgcolor="#E0E0FF"><strong>'
		    .$link.'</strong></td>';
        }
        else {
            $pad .= '<td></td>';
            $html .= '<td>'.$link.'</td>';
        }

        $pad .= '<td></td>';
        $html .= '<td>&nbsp;</td>';
    }

    if ($menu->is_top()) {
        $req->print($html);
        $req->print('</tr><tr>');
        $req->print($pad);
    }
    else {
        $req->print($pad);
        $req->print('</tr><tr>');
        $req->print($html);
    }

    $req->print('</tr></table>');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
