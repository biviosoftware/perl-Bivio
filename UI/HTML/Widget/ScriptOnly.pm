# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ScriptOnly;
use strict;
use Bivio::Base 'Bivio::UI::Widget';

# C<Bivio::UI::HTML::Widget::ScriptOnly> java script only widget rendering.
#
#
#
# widget : Bivio::UI::Widget (required)
#
# The widget to render when javascript is present.
#
# alt_widget : Bivio::UI::Widget []
#
# The widget which is rendered if javascript is not present.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub initialize {
    # (self) : undef
    # Preparse the widget during startup.
    my($self) = @_;
    $self->get('widget')->put(parent => $self)->initialize;
    $self->get('alt_widget')->put(parent => $self)->initialize
	    if $self->unsafe_get('alt_widget');
    return;
}

sub new {
    # (proto) : Widget.ScriptOnly
    # Creates a new ScriptOnly widget.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    # (self, any, string_ref) : undef
    # Draws the widget on the buffer so that it will only be rendered if
    # javascript is present.
    my($self, $source, $buffer) = @_;

    $$buffer .= <<'EOF';
<script type="text/javascript">
<!--
EOF

    # draw the javascript text within a document.write()
    my($str) = '';
    $self->get('widget')->render($source, \$str);
    # escape any single quotes
    $str =~ s|'|\\'|g;
    # ensure it is one line
    $str =~ s|\n| |g;
    $$buffer .= "document.write('".$str."');
// -->
</script>";

    if ($self->unsafe_get('alt_widget')) {
	$$buffer .= "\n<noscript>\n";
	$self->get('alt_widget')->render($source, $buffer);
	$$buffer .= "\n</noscript>\n";
    }
    return;
}

1;
