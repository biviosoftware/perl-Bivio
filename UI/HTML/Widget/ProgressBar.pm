# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ProgressBar;
use strict;
use Bivio::Base 'Bivio::UI::Widget';

# C<Bivio::UI::HTML::Widget::ProgressBar>
#
#
#
# maximum_text : code_ref
#
# The maximum value as text (ex. "50.0MB")
#
# percent : code_ref
#
# The current percent value.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_VS) = __PACKAGE__->use('UI.ViewShortcuts');
my($_RENDER_KEY) = __PACKAGE__ . 'rendered';

sub initialize {
    # (self) : undef
    # Widget setup.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{grid};
    $fields->{grid} = $self->initialize_value('grid, ', $_VS->vs_new('Grid', [
        [$_VS->vs_new('Grid', [[
            $_VS->vs_new('Grid', [[
                $_VS->vs_new('ClearDot', {
                    height => '10',
                    cell_bgcolor => 'page_heading',
                    cell_width_as_html => [\&_get_cell_width, $self],
                }),
                $_VS->vs_new('ClearDot'),
            ]], {
                width => '200',
            }),
        ]], {
            border => 1,
        })],
        [$_VS->vs_new('String', $_VS->vs_new('Join', [
            [$self->get('percent')],
            '% of ',
            [$self->get('maximum_text')],
        ]))->put(cell_align => 'center')]
    ], {
        pad => 1,
    }));
    return;
}

sub new {
    # (proto, hash_ref) : Widget.ProgressBar
    # Creates a new ProgressBar widget.
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    # (self, any, string_ref) : undef
    # Renders the progress bar.
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    return if $req->unsafe_get($_RENDER_KEY);
    $fields->{grid}->render($source, $buffer);
    $req->put($_RENDER_KEY => 1);
    return;
}

sub _get_cell_width {
    # (any, self) : string
    # Returns the HTML for the table cell width.
    my($source, $self) = @_;
    # want min width to be 1, 0% isn't rendered correctly by mozilla
    return ' width="' . ($self->get('percent')->($source) || 1) . '%"';
}

1;
