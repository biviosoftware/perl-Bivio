# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Form;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::HTML;
use Bivio::UI::HTML::ViewShortcuts;

# C<Bivio::UI::HTML::Widget::Form> is an HTML C<FORM> tag surrounding
# a widget, which is usually a
# L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>,
# but might be a
# L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
# The widget or its children should contain a
# L<Bivio::UI::HTML::Widget::FormButton|Bivio::UI::HTML::Widget::FormButton>.
#
# No special formatting is implemented.  For layout, use, e.g.
#
#
#
# action : string [$req->format_uri]
#
# Literal text to use as
# the C<ACTION> attribute of the C<FORM> tag.
#
# action : Bivio::Agent::TaskId [$req->format_uri]
#
# Task to format_stateless_uri.
#
# action : array_ref [$req->format_uri]
#
# Dereferenced, passed to C<$source-E<gt>get_widget_value>, and
# used as the C<ACTION> attribute of the C<FORM> tag.
#
# cell_end_form : boolean [0]
#
# Same value as L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
# Used to set default for I<end_tag>.
#
# end_tag : boolean [see below]
#
# Renders the C<FORM> end tag if true.  Default is true unless
# I<cell_end_form> is true iwc is set to false.  See
# L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
#
# form_class : Bivio::Biz::FormModel (inherited, get_request)
#
# The simple name of the class or the mapped name, e.g. I<Model.FooForm>.
# This value is computed from I<form_model> if it can be.
#
# form_end_cell : boolean [0]
#
# Opposite of I<cell_end_form>.  Will end the cell as well as the form.
# Do not set I<end_tag> or I<cell_end_form> with this value.  You should
# set I<cell_end> on a Grid to false.
#
# form_method : string [POST] (inherited)
#
# The value to be passed to the C<METHOD> attribute of the C<FORM> tag.
#
# form_model : array_ref [*computed*] (required, inherited, get_request)
#
# B<DEPRECATED>. Which form are we dealing with.
# Use I<form_class>.
#
# form_name : string [fnNNN] (inherited)
#
# Name of the form which can be used within JavaScript.  Set dynamically
# to C<fn>I<NNN> where I<NNN> is globally assigned starting at 1.
# The value is set on the I<self>, so it can be used by fields.
#
# link_target : string [] (inherited)
#
# The value to be passed to the C<TARGET> attribute of C<A> tag.
#
# value : Bivio::UI::Widget (required)
#
# How to render the form.  Usually a
# L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join>
# or
# L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_FORM_NAME_INDEX) = 0;

sub initialize {
    my($self) = @_;
    # Initializes static information.
    my($fields) = $self->[$_IDI];
    return if $fields->{prefix};

    # Compute form_class from form_model or vice-versa
    my($class) = $self->unsafe_get('form_class');
    if ($class && $class !~ /:/) {
	# lookup the full class name
	$class = ref(Bivio::Biz::Model->get_instance($class));
	$self->put(form_class => $class);
    }
    my($model) = $self->unsafe_get('form_model');
    if ($class && $model) {
	# fall through
    }
    elsif ($model) {
	# DEPRECATED
	$class = $model->[0];
	$self->put(form_class => $class);
    }
    elsif ($class) {
	$model = [$class];
	$self->put(form_model => $model);
    }
    else {
	die('form_class not set');
    }
    die($class, ': invalid or not set form_class')
	    unless UNIVERSAL::isa($class, 'Bivio::Biz::FormModel');
    $fields->{class} = $class;

    # Compute form_name
    my($name) = $self->ancestral_get('form_name', undef);
    if ($name) {
	# Should be at least two chars starting with a letter
	die($name, ': invalid form_name') unless $name =~ /^[a-z]\w+$/i;
    }
    else {
	$name = 'fn'.$_FORM_NAME_INDEX++;
	$self->put(form_name => $name);
    }

    $self->initialize_attr(action => [['->get_request'], '->format_uri']);
    my($a) = $self->get('action');
    $self->put(action => [['->get_request'], '->format_stateless_uri', $a])
	if $self->is_blessed($a, 'Bivio::Agent::TaskId');
    my($p) = '<form method="'
	. lc($self->ancestral_get('form_method', 'post'))
        . '"'
	. $_VS->vs_link_target_as_html($self)
	. qq{ name="$name" action="};
    $fields->{prefix} = $p;
    $fields->{end_tag} = $self->get_or_default('end_tag',
	    $self->get_or_default('cell_end_form', 0)
	    ? 0 : 1);
    $fields->{form_end_cell} = $self->get_or_default('form_end_cell', 0);
    $fields->{value} = $self->get('value');
    $fields->{value}->put(parent => $self);
    $fields->{value}->initialize;
    return;
}

sub internal_new_args {
    my(undef, $class, $value, $attributes) = @_;
    # Implements positional argument parsing for L<new|"new">.
    return '"form_class" attribute must be defined' unless defined($class);
    return '"value" attribute must be defined' unless defined($value);
    return {
	form_class => $class,
	value => $value,
	($attributes ? %$attributes : ()),
    };
}

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    # Passes I<form_class> and I<value> as attributes.  And optionally, set extra
    # I<attributes>.
    #
    #
    # Creates a new Form widget using I<attributes>.
    $self->[$_IDI] = {};
    return $self;
}

sub render {
    my($self, $source, $buffer) = @_;
    # Render the form.
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($model) = $req->get_widget_value($fields->{class});
    my($action) = ${$self->render_attr('action', $source)};
#TODO: Tightly Coupled with FormModel & Location.  Do not propagate form
#      context when you have a form to store the context in fields.
#      Context management is hard....
    $action =~ s/[&?]fc=[^&=]+//;
    $$buffer .= $fields->{prefix}
	. $action
	. '"'
	. ($model->get_info('file_fields')
	       ? ' enctype="multipart/form-data"' : '')
        . ">\n";
    $_VS->vs_new('TimezoneField')->render($source, $buffer);
    my($hidden) = $model->get_hidden_field_values();
    while (@$hidden) {
	# hidden fields have been converted to literal, but not  escaped.
	$$buffer .= '<input type="hidden" name="'.shift(@$hidden).'" value="'
		.Bivio::HTML->escape(shift(@$hidden))."\" />\n";
    }
    $fields->{value}->render($source, $buffer);
    $$buffer .= '</td>'
	if $fields->{form_end_cell};
    $$buffer .= '</form>'
	if $fields->{end_tag};
    return;
}

1;
