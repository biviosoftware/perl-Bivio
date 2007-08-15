# Copyright (c) 1999-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ListActions;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::Biz::QueryType;
use Bivio::UI::HTML::ViewShortcuts;

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
    return $label->put_and_initialize(parent => $self);
}

sub _realm_name {
    my($self, $source, $realm) = @_;
    # realm must be a name, not an ID for format_uri() below
    return undef
        unless $realm;

    if (Bivio::Type->get_instance('PrimaryId')->is_valid($realm)) {
        # chances are, it is already on the request at this point
        # (loaded from can_user_execute_task())
        if ($source->req->unsafe_get('Model.RealmOwner')
            && $source->req(qw(Model.RealmOwner realm_id)) eq $realm) {
            return $source->req(qw(Model.RealmOwner name));
        }
        # otherwise go to the database
        return Bivio::Biz::Model->new($source->req, 'RealmOwner')
            ->unauth_load_by_id_or_name_or_die($realm)->get('name');
    }
    return $realm;
}

sub _render_link {
    my($self, $source, $i, $v, $sep, $buffer) = @_;
    return 0 if $v->{control}
        && ! $self->render_simple_value($v->{control}, $source);
    my($realm) = ref($v->{realm})
        ? $self->render_simple_value($v->{realm}, $source) || undef
        : $v->{realm};
    return 0 unless $source->req->can_user_execute_task($v->{task_id}, $realm);
    $$buffer .= $sep
        . $v->{prefix}
	. ($v->{format_uri}
            ? ${$self->render_value(
                "$i.format_uri", $v->{format_uri}, $source)}
            : $source->format_uri($v->{method},
                $source->req->format_uri({
                    task_id => $v->{task_id},
                    query => undef,
                    realm => _realm_name($self, $source, $realm),
                    path_info => undef,
                })))
        . '">'
        . (ref($v->{label})
            ? $self->render_simple_value($v->{label}, $source)
            : $v->{label})
        . '</a>';
    return 1;
}

1;
