# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::MenuRenderer;
use strict;
$Bivio::UI::HTML::MenuRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::MenuRenderer - Draws a Bivio::UI::Menu as HTML.

=head1 SYNOPSIS

    use Bivio::UI::HTML::MenuRenderer;
    my($menu) = Bivio::UI::Menu->new(1,
	    [Bivio::Agent::TaskId::HUMAN_DETAIL, 'Human',
	     Bivio::Agent::TaskId::CAT_DETAIL, 'Cat',
	     Bivio::Agent::TaskId::DOG_DO, 'Dog']);
    $menu->set_selected(Bivio::Agent::TaskId::CAT_DETAIL);
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
    my($reply) = $req->get_reply();

    my($task_ids) = $menu->get_task_ids();
    my($display_names) = $menu->get_display_names();
    my($active) = $menu->get_selected();

    # don't show menu if is a sub menu and has only one item
    if (!$menu->is_top() && int(@{$task_ids}) <= 1) {
        return;
    }

    $reply->print('<table border=0 cellpadding=2 cellspacing=0><tr>');

    my($pad) = '<td></td>';
    my($html) = '<td>&nbsp;</td>';
    for (my($i) = 0; $i < int(@$task_ids); $i++) {
        my($task_id) = $task_ids->[$i];
	my($display_name) = $display_names->[$i];
	my($link) = '<a href="'.$req->format_uri($task_id)
			.'">'.$display_name.'</a>';
        if ($task_id eq $active) {
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
        $reply->print($html);
        $reply->print('</tr><tr>');
        $reply->print($pad);
    }
    else {
        $reply->print($pad);
        $reply->print('</tr><tr>');
        $reply->print($html);
    }
    $reply->print('</tr></table>');
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
