# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ListActions;
use strict;
use Bivio::Base 'UI.Widget';

# link_target : string [] (inherited)
#
# The value to be passed to the TARGET attribute of <A> tag.
#
# link_font : string [list_action]
#
# Font to use for rendering links in the list.
#
# values : array_ref (required)
#
# An array_ref of array_refs where the order is the order of the
# actions to appear.
#
# The first element of sub-array_ref is the name of the action.
# It may also be a widget.
#
# The second element is the task name.
#
# The third optional element of sub-array_ref is
# either a Bivio::Biz::QueryType (default value is THIS_DETAIL)
# or a value renders to a URI.
#
# The fourth optional element is a control.  If the control returns
# true, the action is rendered.
#
# The fifth optional element is a widget value which returns the realm
# for the task.
#
# The sixth optional element is a widget value which returns the 'path_info'
#
my($_IDI) = __PACKAGE__->instance_data_index;
my($_HTML) = b_use('Bivio.HTML');
my($_PI) = b_use('Type.PrimaryId');
my($_RO) = b_use('Cache.RealmOwner');
my($_T) = b_use('Agent.TaskId');
my($_VS) = b_use('UIHTML.ViewShortcuts');

sub initialize {
    my($self) = @_;
    # Initializes "values" in field.
    my($fields) = $self->[$_IDI];
    return if exists($fields->{values});
    $fields->{values} = [];
    my($target) = $_VS->vs_link_target_as_html($self);
    my($font) = $self->get_or_default('link_font', 'list_action');

    my($i) = 0;
    foreach my $value (@{$self->get('values')}) {
        my($v) = ref($value) ? $value : [$value];
        $v->[0] = $v->[1]
            unless defined($v->[0]);
        unshift(@$v, $_VS->vs_text('ListActions', $v->[0]))
            if !ref($v->[0]) && $_T->is_valid_name($v->[0])
                && $_T->unsafe_from_name($v->[0]);
        $i++;
        push(@{$fields->{values}}, {
            prefix => '<a'.$target.' href="',
            task_id => $_T->from_name($v->[1]),
            label => _init_label($self, $v->[0], $font),
            ref($v->[2]) eq 'ARRAY'
                || UNIVERSAL::isa($v->[2], 'Bivio::UI::Widget') ? (
                format_uri => $self->initialize_value(
                    "$i.format_uri", $v->[2]),
            ) : (method => Bivio::Biz::QueryType->from_any(
                    $v->[2] || 'THIS_DETAIL')),
            control => $v->[3],
            realm => $v->[4],
            path_info => $v->[5],
        });
    }
    return;
}

sub internal_new_args {
    my(undef, $values, $attributes) = @_;
    # Implements positional argument parsing for L<new|"new">.
    return '"values" must be defined' unless defined($values);
    return {
        values => $values,
        ($attributes ? %$attributes : ()),
    };
}

sub new {
    my($self) = shift->SUPER::new(@_);
    # Creates a new ListActions widget.
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    my($self, $source, $buffer) = @_;
    # Renders the list, skipping those tasks that are invalid.
    my($fields) = $self->[$_IDI];
    my($i) = 0;
    my($sep) = '';

    foreach my $v (@{$fields->{values}}) {
        $sep = ",\n"
            if _render_link($self, $source, ++$i, $v, $sep, $buffer);
    }
    return;
}

sub _init_label {
    my($self, $label, $font) = @_;
    # Returns the label value.  Initializing appropriately.
    $label = $_VS->vs_new('String', $label, $font, {hard_spaces => 1})
        unless UNIVERSAL::isa($label, 'Bivio::UI::Widget');
    return $label->initialize_with_parent($self);
}

sub _realm_name {
    my($self, $source, $realm) = @_;
    # realm must be a name, not an ID for format_uri() below
    return undef
        unless $realm;

    if ($_PI->is_valid($realm)) {
        return $_RO->get_cache_value($realm, $source->req)->get('name');
    }
    return $realm;
}

sub _render_link {
    my($self, $source, $i, $v, $sep, $buffer) = @_;
    return 0
        if $v->{control}
        && !$self->render_simple_value($v->{control}, $source);
    my($realm) = ref($v->{realm})
        ? $self->render_simple_value($v->{realm}, $source) || undef
        : $v->{realm};
    my($path_info) = ref($v->{path_info})
        ? $self->render_simple_value($v->{path_info}, $source) || undef
        : $v->{path_info};
    return 0
        unless $source->req->can_user_execute_task($v->{task_id}, $realm);
    $$buffer .= $sep
        . $v->{prefix}
        . $_HTML->escape_attr_value(
            $v->{format_uri}
            ? ${$self->render_value(
                "$i.format_uri",
                $v->{format_uri},
                $source,
            )}
            : $source->format_uri($v->{method},
                $source->req->format_uri({
                    task_id => $v->{task_id},
                    query => undef,
                    realm => _realm_name($self, $source, $realm),
                    path_info => $path_info,
                }),
            ),
        )
        . '">'
        . (ref($v->{label})
            ? $self->render_simple_value($v->{label}, $source)
            : $v->{label})
        . '</a>';
    return 1;
}

1;
