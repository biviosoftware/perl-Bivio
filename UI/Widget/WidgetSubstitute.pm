# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::WidgetSubstitute;
use strict;
use Bivio::Base 'Widget.Simple';
b_use('UI.ViewLanguageAUTOLOAD');

my($_WS) = b_use('FacadeComponent.WidgetSubstitute');

sub control_on_render {
    my($self, $source, $wo) = shift->widget_render_args(@_);
    if (defined(my $ws = $_WS->get_widget_substitute_value($self->get('value'), $source))) {
        $wo->append_buffer($ws);
        return;
    }
    return $self->SUPER::control_on_render(@_);
}

sub initialize {
    my($self) = @_;
    b_die($self->get('value'), ': value must be a widget')
        unless UI_Widget()->is_super_of($self->get('value'));
    return shift->SUPER::initialize(@_);
}

1;
