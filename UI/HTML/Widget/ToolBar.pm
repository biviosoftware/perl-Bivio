# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ToolBar;
use strict;
$Bivio::UI::HTML::Widget::ToolBar::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::ToolBar - renders a menu of tasks

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ToolBar;
    Bivio::UI::HTML::Widget::ToolBar->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::ToolBar::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ToolBar> renders a menu of tasks.  Each
task is represented by two table cells.  The list of actions
can be found in
L<Bivio::UI::HTML::ActionButtons|Bivio::UI::HTML::ActionButtons>

If the task is not executable in the current realm by the current role, the
button is not displayed.

If I<tool_bar_nav> is set, the nav buttons will be rendered.

=head1 BAR ATTRIBUTES

=over 4

=item values : array_ref (required)

The list of ActionButton widgets.

=back

=head1 BUTTON ATTRIBUTES

=over 4

=item button_task_id : Bivio::Agent::TaskId (required,dynamic)

Which task will this widget execute?  If C<$req-E<gt>task_ok> returns
false, the widget will not be rendered.

=back

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Carp ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::ToolBar

Creates a new ToolBar widget.

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
    return if $fields->{prefix};
    $fields->{values} = $self->get('values');
    my($v);
    foreach $v (@{$fields->{values}}) {
	# Throw an exception if task_id doesn't exist
	$v->get('button_task_id');
	$v->put(parent => $self);
	$v->initialize;
    }
    my($s);
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Renders the buttons and nav.  If none of these is valid,
renders nothing.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($b) = '<table border=0 cellpadding=2 cellspacing=0 width="100%">'
	    ."<tr>\n";
    my($got_one) = 0;

    # Insert the nav bar
    my($nav) = $source->unsafe_get('tool_bar_nav');
    if ($nav) {
	$b .= '<td nowrap>';
	$nav->render($source, \$b);
	$b .= "</td>\n";
	$got_one++;
    }

    # Make a cell which expands
    $b .= '<td width="100%">&nbsp;</td>'."\n";

    foreach my $v (@{$fields->{values}}) {
	my($task_id, $control) = $v->get('button_task_id', 'button_control');
	next unless $source->task_ok($task_id);
	next if $control && !$source->get_widget_value(@$control);
	$b .= '<td nowrap>';
	$v->render($source, \$b);
	$b .= "</td>\n";
	$got_one++;
    }

    # Render nothing if no components
    $$buffer .= $b.'</tr></table>' if $got_one;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
