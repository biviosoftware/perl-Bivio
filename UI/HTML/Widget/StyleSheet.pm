# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::StyleSheet;
use strict;
use Bivio::Base 'HTMLWidget.ControlBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_HTML) = b_use('Bivio.HTML');
my($_T) = b_use('Agent.Task');
my($_TI) = b_use('Agent.TaskId');

sub control_off_render {
    return _do(sub {
        my($self, $source, $buffer, $value) = @_;
        $$buffer .= qq{<style type="text/css">\n<!--\n}
            . ${b_use('AgentEmbed.Dispatcher')
                ->call_task($source->get_request, $value
               )->get_output}
            . "\n-->\n</style>\n";
        return;
    }, @_);
}

sub control_on_render {
    return _do(sub {
        my($self, $source, $buffer, $value) = @_;
        $$buffer .= qq{<link href="@{[$_HTML->escape_attr_value($value)]}" rel="stylesheet" type="text/css" />\n};
        return;
    }, @_);
}

sub initialize {
    my($self) = @_;
    my($v);
    if ($v = $self->unsafe_get('value')
        and $_TI->is_valid_name($v),
    ) {
        $v = $_TI->from_name($v);
        my($rt) = $_T->get_by_id($v)->get('realm_type');
        $self->put(value => And(
#TODO: This doesn't seem private enough, but it simplifies ThreePartPage
            # General renders always.  Unless doesn't have uri
            $rt->eq_general ? ()
                : [['->get_request'], qw(auth_realm type ->equals), $rt],
            vs_task_has_uri($v),
            URI({task_id => $v}),
        ));
    }
    $self->initialize_attr('value');
    $self->initialize_attr(control => [
        ['->req', 'UI.Facade'], 'want_local_file_cache',
    ]);
    return shift->SUPER::initialize(@_);
}

sub internal_as_string {
    return shift->unsafe_get('value');
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(value)], \@_);
}

sub _do {
    my($op, $self, $source, $buffer) = @_;
    my($v) = '';
    $op->($self, $source, $buffer, $v)
        if $self->unsafe_render_attr('value', $source, \$v) && length($v);
    return;
}

1;
