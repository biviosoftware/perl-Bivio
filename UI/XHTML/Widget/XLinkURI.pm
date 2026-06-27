# Copyright (c) 2011-2026 bivio Software, Inc.  All Rights Reserved.
package Bivio::UI::XHTML::Widget::XLinkURI;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_TI) = b_use('Agent.TaskId');

sub NEW_ARGS {
    return [qw(facade_label)];
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('facade_label');
    return shift->SUPER::initialize(@_);
}

sub qualify_label {
    my(undef, $label) = @_;
    return "xlink_$label";
}

sub render {
    my($self, $source, $buffer) = @_;
    # Build the URI transiently rather than storing it on $self: a stored value
    # whose code_ref captures $self forms a cycle that leaks per render.
    my($l) = $self->render_simple_attr('facade_label', $source);
    ($_TI->is_valid_name($l)
        ? URI({
            task_id => $_TI->from_name($l),
            query => undef,
            path_info => undef,
        })
        : URI(vs_constant($source->req, $self->qualify_label($l)))
    )->render_transient($source, $buffer);
    return;
}

1;
