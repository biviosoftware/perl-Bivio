# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::MenuRenderer;
use strict;
use Bivio::UI::Renderer();
$Bivio::UI::HTML::MenuRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::MenuRenderer - Draws a menu bar.

=head1 SYNOPSIS

    use Bivio::UI::HTML::MenuRenderer;
    Bivio::UI::HTML::MenuRenderer->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

@Bivio::UI::HTML::MenuRenderer::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::HTML::MenuRenderer>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SINGLETON) = Bivio::UI::HTML::MenuRenderer->new();

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

=for html <a name="get_instance"></a>

=head2 static get_instance() : MenuRenderer

Returns a singleton instance of a menu renderer.

=cut

sub get_instance {
    return $_SINGLETON;
}

=for html <a name="render"></a>

=head2 render(Menu target, Request req)

Draws the state of the menu.

=cut

sub render {
    my($self, $menu, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($names) = $menu->get_names();
    my($display_names) = $menu->get_display_names();
    my($active) = $menu->get_selected();

    # don't show menu if bottom and only one item
    if (!$menu->is_top() && scalar(@{$names}) <= 1) {
        return;
    }

    $req->print('<table border=0 cellpadding=2 cellspacing=0>
<tr>');

    my($pad) = '<td></td>';
    my($html) = '<td>&nbsp;</td>'."\n";
    my($link_root) = $menu->is_top() ? '/'.$req->get_target_name().'/'
	    : '/'.$req->get_target_name().'/'.$req->get_controller_name().'/';

    for (my($i) = 0; $i < scalar(@$names); $i++) {
        my($name) = $names->[$i];
	my($display_name) = $display_names->[$i];
	my($link) = '<a href="'.$link_root.$name.'">'.$display_name.'</a>';

        if ($name eq $active) {
            $pad .= '<td bgcolor="#E0E0FF"><img src="/i/dot.gif"
height=1 width=1 border=0></td>
';
            $html .= '<td bgcolor="#E0E0FF"><strong>
'.$link.'</strong></td>
';
        }
        else {
            $pad .= '<td></td>';
            $html .= '<td>'.$link.'</td>
';
        }

        $pad .= '<td></td>';
        $html .= '<td>&nbsp;</td>';
    }

    if ($menu->is_top()) {
        $req->print($html."\n");
        $req->print('</tr><tr>
');
        $req->print($pad."\n");
    }
    else {
        $req->print($pad."\n");
        $req->print('</tr><tr>
');
        $req->print($html."\n");
    }

    $req->print('</tr></table>
');

}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
