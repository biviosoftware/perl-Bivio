# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::AllWomenInvest::TopMenu;
use strict;
$Bivio::UI::Facade::AllWomenInvest::TopMenu::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Facade::AllWomenInvest::TopMenu - replaces image and text menus

=head1 SYNOPSIS

    use Bivio::UI::Facade::AllWomenInvest::TopMenu;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::Facade::AllWomenInvest::TopMenu::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Facade::AllWomenInvest::TopMenu> replaces the image and text
menus with an enumerated text menu.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_URI) = 'allwomeninvest_top_menu_uri';
my($_STRING) = 'allwomeninvest_top_menu_string';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Facade::AllWomenInvest::TopMenu

Create a new TopMenu.

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Configure some widgets.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{main};

    $fields->{sub_normal} = Bivio::UI::HTML::Widget->join(
#TODO: Make this the same width as menu_arrow
	    Bivio::UI::HTML::Widget->clear_dot(7, 10)->put(align => 'sw'),
	    Bivio::UI::HTML::Widget->link(
		    Bivio::UI::HTML::Widget->string([$_STRING],
			    'top_menu_normal'),
		    [$_URI])->put_and_initialize(parent => $self),
	    "<br>\n",
	   )->put_and_initialize(parent => $self);

    $fields->{sub_selected} = Bivio::UI::HTML::Widget->join(
	    Bivio::UI::HTML::Widget->image('menu_arrow', '')->put(
		    align => 'sw'),
	    Bivio::UI::HTML::Widget->link(
		    Bivio::UI::HTML::Widget->string([$_STRING],
			    'top_menu_selected'),
		    [$_URI])->put_and_initialize(parent => $self),
	    "<br>\n",
	    )->put_and_initialize(parent => $self);

    $fields->{main_normal} = Bivio::UI::HTML::Widget->link(
	    Bivio::UI::HTML::Widget->string([$_STRING],
		    'top_menu_normal',),
	    [$_URI])->put_and_initialize(parent => $self);

    $fields->{main_selected} = Bivio::UI::HTML::Widget->link(
	    Bivio::UI::HTML::Widget->string([$_STRING],
		    'top_menu_selected'),
	    [$_URI])->put_and_initialize(parent => $self);

    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Renders the menu from page_menu_cfg.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    my($cfg) = $req->unsafe_get('page_menu_cfg');

    # Is there a menu?
    unless ($cfg && @$cfg) {
	# Empty cell
	$$buffer .= ' ';
	return;
    }

    my($state) = {
	fields => $self->{$_PACKAGE},
	req => $req,
	source => $source,
	selected => 0,
	this_task_id => $req->get('task_id'),
	color_index => 0,
	main_buffer => '',
    };

    # Still may not be a menu, so render and then copy in.
    for(my $i = 0; $i < $#$cfg; $i += 2) {
	my($main) = $cfg->[$i]->[0];
	my($sub) = $cfg->[$i + 1];
	Bivio::Die->die($sub, ': does not contain a default value')
		    unless $sub->[1];
	_render_main($state, $main, $sub->[1]->[0])
		if _render_sub($state, $sub);
    }

    # Did we render anything?
    unless ($state->{main_buffer}) {
	$$buffer .= ' ';
	return;
    }

    # Render the table
    $$buffer .= "<table border=0 cellpadding=10 cellspacing=0><tr>\n"
	    .$state->{main_buffer}."</tr></table>";
    return;
}

#=PRIVATE METHODS

# _render_item(hash_ref state, Bivio::UI::HTML::Widget widget, string label, string task_id, string_ref buffer)
#
# Renders the label/link in buffer
#
sub _render_item {
    my($state, $widget, $label, $task_id, $buffer) = @_;
    $state->{req}->put($_STRING => $label,
	    $_URI => $state->{req}->format_stateless_uri($task_id));
    $widget->render($state->{source}, $buffer);
    return;
}

# _render_main(hash_ref state, string label, string task_name)
#
# Renders the main task based on $state->{selected} into $state->{main_buffer}.
# Doesn't render if the main task is not accessible.
#
sub _render_main {
    my($state, $label, $task_name) = @_;
    my($task_id) = Bivio::Agent::TaskId->$task_name();
    return unless $state->{req}->task_ok($task_id);

    $state->{main_buffer} .= '<td valign=top'
	    .Bivio::UI::Color->format_html(
		    'top_menu_bg_'.$state->{color_index}++,
		    'bgcolor', $state->{req})
	    .'>';
    _render_item($state,
	    $state->{fields}->{$state->{selected}
		? 'main_selected' : 'main_normal'},
	    # Labels are all upper case
	    uc($label),
	    $task_id,
	    \$state->{main_buffer});
    $state->{main_buffer} .=  "<br>\n".$state->{sub_buffer}."</td>\n";
    return;
}

# _render_sub(hash_ref state, array_ref menu) : boolean
#
# Renders into $state->{buffer}.
#
sub _render_sub {
    my($state, $menu) = @_;

    $state->{selected} = 0;
    $state->{sub_buffer} = '';
    $state->{ok} = 0;
    for (my $i = 0; $i < $#$menu; $i += 2) {
	_render_sub_item($state, $menu->[$i], $menu->[$i + 1]);
    }
    # If we get selected or get any text, then render.
    return $state->{ok} ? 1 : 0;
}

# _render_sub_item(hash_ref state, string label, array_ref tasks)
#
# Renders a single item in the sub menu if any of @$tasks is ok.
# Sets selected if the item was selected.
#
sub _render_sub_item {
    my($state, $label, $tasks) = @_;

    # Only render this label if the FIRST task is ok.
    my($task_id) = $tasks->[0];
    $task_id = Bivio::Agent::TaskId->$task_id();
    return unless $state->{req}->task_ok($task_id);

    # Got one
    $state->{ok} = 1;

    # Now go through each task to see if we are selected (if not already)
    my($widget)= $state->{fields}->{sub_normal};

    # There may be two selected items in the list: default label ('') and
    # label we want to render.
    foreach my $tn (@$tasks) {
	next unless $state->{this_task_id} == Bivio::Agent::TaskId->$tn();
	$widget = $state->{fields}->{sub_selected};
	$state->{selected} = 1;
	last;
    }

    # Don't end up rendering if the label is empty.  Still need to compute
    # ok and selected, though.
    return unless $label;

    _render_item($state, $widget, $label, $task_id, \$state->{sub_buffer});
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
