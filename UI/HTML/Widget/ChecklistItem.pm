# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ChecklistItem;
use strict;
$Bivio::UI::HTML::Widget::ChecklistItem::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::ChecklistItem - a checklist item

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ChecklistItem;
    Bivio::UI::HTML::Widget::ChecklistItem->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::ChecklistItem::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ChecklistItem> a checklist item. Displays a
title with an icon representing the checked and unchecked state.

Format:

  icon  title

     body

where body may be 'checked_body' or 'unchecked_body' depending on the
current state of attribute 'checked'.

=head1 ATTRIBUTES

=over 4

=item checked : boolean (required)

Is the item checked? Determines which body is displayed.

=item checked : array_ref (required)

Same as above except it is passed to C<$source-E<gt>get_widget_value>
and the result is used as a boolean.

=item title : string (required)

The title of the item.

=item checked_body : widget (required)

The body to display when the widget is checked.

=item unchecked_body : widget (required)

The body to display when the widget isn't checked.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::Widget::String;

#=VARIABLES

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::ChecklistItem

Creates a new checklist item.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    # prepare constants (could be static)
    $fields->{prefix} = "\n<table border=0>\n<tr><td colspan=2>";
    $fields->{middle} = "</td>\n</tr>\n<tr><td width=15>&nbsp;</td><td>";
    $fields->{suffix} = "</td>\n</tr>\n</table>";

    # create/initialize subwidgets
    _initialize_subwidget($self, Bivio::UI::HTML::Widget::String->new({
	value => $self->get('title'),
	string_font => 'table_heading',
    }), 'title');
    _initialize_subwidget($self, $self->get('checked_body'),
	    'checked_body');
    _initialize_subwidget($self, $self->get('unchecked_body'),
	    'unchecked_body');
    _initialize_subwidget($self,Bivio::UI::HTML::Widget::String->new({
	value => 'OK ',
	string_font => 'checked_icon',
    }), 'checked_icon');
    _initialize_subwidget($self,Bivio::UI::HTML::Widget::String->new({
	value => '! ',
	string_font => 'error_icon',
    }), 'error_icon');

    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the table upon the output buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};

    $$buffer .= $fields->{prefix};

    # render a different icon/body depending on checked state
    my($icon, $body);

    # get the checked value
    my($value) = $self->get('checked');
    my($checked) = ref($value)
	    ? $source->get_widget_value(@{$value})
	    : $value;

    if ($checked) {
	$icon = $fields->{checked_icon};
	$body = $fields->{checked_body};
    }
    else {
	$icon = $fields->{error_icon};
	$body = $fields->{unchecked_body};
    }

    $icon->render($source, $buffer);
    $fields->{title}->render($source, $buffer);
    $$buffer .= $fields->{middle};
    $body->render($source, $buffer);
    $$buffer .= $fields->{suffix};
    return;
}

#=PRIVATE METHODS

# _initialize_subwidget(Bivio::UI::Widget widget, string name)
#
# Initializes the specified sub widget and stores it in the named
# instance field.
#
sub _initialize_subwidget {
    my($self, $widget, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    $widget->put(parent => $self);
    $widget->initialize;
    $fields->{$name} = $widget;
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
