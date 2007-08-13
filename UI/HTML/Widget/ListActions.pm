# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ListActions;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::Biz::QueryType;
use Bivio::UI::HTML::ViewShortcuts;

# link_target : string [] (inherited)
#
# The value to be passed to the C<TARGET> attribute of C<A> tag.
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
# either a
# L<Bivio::Biz::QueryType|Bivio::Biz::QueryType>
# (default value is C<THIS_DETAIL>)
# or a value renders to a URI.
#
# The fourth optional element is a control.  If the control returns
# true, the action is rendered.
#
# The fifth optional element is a widget value which returns the realm
# for the task.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';
my($_T) = 'Bivio::Agent::TaskId';

my($_IDI) = __PACKAGE__->instance_data_index;

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
    my($values) = $fields->{values};
    my($req) = $source->get_request;
    my($sep) = '';
    my($i) = 0;
    foreach my $v (
	map(+{
	    value => $_,
	    $_->{method} ? (uri => $req->format_stateless_uri($_->{task_id}))
		: (),
	}, @$values),
    ) {
	$i++;
	my($v2) = $v->{value};
	next if $v2->{control}
            && !$self->render_simple_value($v2->{control}, $source);
        next unless $req->can_user_execute_task(
	    $v2->{task_id},
            $v2->{realm}
                ? (ref($v2->{realm})
                    ? $self->render_simple_value($v2->{realm}, $source) || undef
                    : $v2->{realm})
                : (),
	);
	$$buffer .= $sep
	    . $v2->{prefix}
	    . ($v2->{format_uri}
		? ${$self->render_value(
		    "$i.format_uri", $v2->{format_uri}, $source)}
		: $source->format_uri($v2->{method}, $v->{uri}))
	    . '">'
	    . (ref($v2->{label})
		? $self->render_simple_value($v2->{label}, $source)
		: $v2->{label})
	    . '</a>';
	$sep = ",\n";
    }
    return;
}

sub _init_label {
    my($self, $label, $font) = @_;
    # Returns the label value.  Initializing appropriately.
    $label = $_VS->vs_new('String', $label, $font, {hard_spaces => 1})
	unless UNIVERSAL::isa($label, 'Bivio::UI::Widget');
    return $label->put_and_initialize(parent => $self);
}

1;
