# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::TextTabMenu;
use strict;
$Bivio::UI::HTML::Widget::TextTabMenu::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::TextTabMenu - renders a menu of tabbed strings

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::TextTabMenu;
    Bivio::UI::HTML::Widget::TextTabMenu->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::TextTabMenu::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::TextTabMenu> renders a menu of tabbed strings,
e.g.
       +---------+
       | Messages|   Motions   Accounting
       |         |

The I<control> attribute causes a tab to be highlighted.  Each tab
string can be mapped to one or more tasks.

=head1 ATTRIBUTES

=over 4

=item text_tab_color : string [text_tab_bg] (inherited)

Color of the tab.  See L<Bivio::UI::Color|Bivio::UI::Color>.

=item text_tab_font : string [] (inherited)

Font for the tab tab.  See L<Bivio::UI::Color|Bivio::UI::Color>.

=item text_tab_height : int [1] (inherited)

How high should the tab "extension" be.  If zero, no extension
will be drawn.

=item orient : string (required)

Must be either C<up> or C<down>.  Defines the direction of the tabs.

=item values : array_ref (required)

The list of labels to task ids.  Each label may map to more than
one task id.  The first task id is the defines the URI to which
the menu item points.  For example,

    values => [
        Motions => [Bivio::Agent::TaskId::MOTIONS_LIST(),
                    Bivio::Agent::TaskId::SUGGEST_MOTION()],
        Messages => Bivio::Agent::TaskId::MESSAGES_LIST(),
    ],

=back

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::UI::Color;
use Bivio::UI::Icon;
use Carp ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::TextTabMenu

Creates a new TextTabMenu widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Copies the attributes to local fields.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{items};
    my($o) = $self->get('orient');
    my($values) = $self->get('values');
    my($th) = $self->ancestral_get('text_tab_height', 1);
    my($tc) = $self->ancestral_get('text_tab_color', 'text_tab_bg');
    $tc = Bivio::UI::Color->as_html_bg($tc) if $tc;
    $o = lc($o);
    $fields->{up} = 1 if $o eq 'up';
    $fields->{up} = 0 if $o eq 'down';
    Carp::croak("$o: invalid orient value") unless exists($fields->{up});
    my($dot) = Bivio::UI::Icon->get_clear_dot->{uri};
    $fields->{highlight_extender} =
	    qq!<td$tc><img src="$dot" height=$th!
		    . " width=1 border=0></td>"
			    if $fields->{tab_height} = $th;
    $fields->{highlight_prefix} = qq!<td$tc><strong>!;
    $fields->{highlight_suffix} = "</strong></td>";
    my($tf) = $self->ancestral_get('text_tab_font', undef);
    $fields->{text_prefix} = '<td>';
    $fields->{text_suffix} = '</td>';
    if ($tf) {
	my(@f) = Bivio::UI::Font->as_html($tf);
	$fields->{text_prefix} .= $f[0];
	$fields->{text_suffix} = $f[0] . $fields->{text_suffix};
    }
    $fields->{text_space} = $fields->{text_prefix}.'&nbsp;'
	    .$fields->{text_suffix}."\n";
    $fields->{items} = [];
    $fields->{task2first_task} = {};
    Carp::croak('odd number of values') if int(@$values) % 2;
    my($j) = 0;
    for (my($i) = 0; $i < int(@$values); $i += 2, $j++) {
	my($label, $tasks) = ($values->[$i] , $values->[$i+1]);
	$tasks = [$tasks] unless ref($tasks) eq 'ARRAY';
	my($t);
	foreach $t (@$tasks) {
	    Carp::croak($t, ": not a task id (row $i)") unless
			$t->isa('Bivio::Agent::TaskId');
	    $fields->{task2first_task}->{$t} = $tasks->[0];
	}
	push(@{$fields->{items}}, [$label, $tasks->[0]]);
    }
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the link.  Most of the code is involved in avoiding unnecessary method
calls.  If the I<value> is a constant, then it will only be rendered once.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = Bivio::Agent::Request->get_current;
    my($task) = $req->get('task_id');
    my($this_task) = $fields->{task2first_task}->{$task};
    die($task->get_name, ': unknown task') unless defined($this_task);
    my($labels, $pad) = ('<td>&nbsp;</td>', '<td></td>');
    my($th) = $fields->{tab_height};
    my($item);
    my($text_prefix, $text_suffix, $text_space)
	    = @{$fields}{'text_prefix','text_suffix', 'text_space'};
    foreach $item (@{$fields->{items}}) {
	my($t) = $item->[1];
#TODO: Bug: tasks in other realm types are not visible.  Need to know
#      which role the user plays in other realms.
	next unless $req->task_ok($t);
	my($link) = '<a href="'.$req->format_uri($t)
		.'">'.$item->[0].'</a>';
        if ($t == $this_task) {
            $pad .= $fields->{highlight_extender} if $th;
            $labels .= $fields->{highlight_prefix}
		    .$link.$fields->{highlight_suffix};
        }
        else {
            $pad .= '<td></td>' if $th;
            $labels .= $text_prefix.$link.$text_suffix;
        }
	$pad .= '<td></td>' if $th;
	$labels .= $text_space;
    }
    $$buffer .= "<table border=0 cellpadding=2 cellspacing=0><tr>\n";
    # 9 is length of '<td></td>'.
    $$buffer .= $th == 0 ? $labels
	    : $fields->{up} ? ($labels."</tr><tr>\n".$pad."\n")
	    : ($pad."\n</tr><tr>\n".$labels);
    $$buffer .= "</tr></table>\n";
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
