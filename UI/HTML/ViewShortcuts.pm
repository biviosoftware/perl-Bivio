# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::ViewShortcuts;
use strict;
$Bivio::UI::HTML::ViewShortcuts::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::ViewShortcuts::VERSION;

=head1 NAME

Bivio::UI::HTML::ViewShortcuts - html helper routines

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::ViewShortcuts

=cut

=head1 EXTENDS

L<Bivio::UI::ViewShortcuts>

=cut

use Bivio::UI::ViewShortcuts;
@Bivio::UI::HTML::ViewShortcuts::ISA = qw(Bivio::UI::ViewShortcuts);

=head1 DESCRIPTION

Provides many utility routines to help create widgets and such.

Some of these routines are deprecated.

=cut


=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::IO::ClassLoader;
use Bivio::UI::HTML;
#NOTE: Do not import any widgets here, use _use().

#=VARIABLES

=head1 METHODS

=for html <a name="vs_acknowledgement"></a>

=head2 static vs_acknowledgement() : Bivio::UI::Widget

=head2 static vs_acknowledgement(boolean die_if_not_found) : Bivio::UI::Widget

Display acknowledgement, if it exists.  Sets row_control on the widget.
Dies if die_if_not_found is specified and the acknowledgement is missing.

=cut

sub vs_acknowledgement {
    my($proto, $die_if_not_found) = @_;
    return $proto->vs_call('Join', [
        '<p class="acknowledgement">',
        [sub {
             my($req) = shift->get_request;
             return __PACKAGE__->vs_call('String',
                 __PACKAGE__->vs_call('Prose',
                     Bivio::UI::Text->get_value('acknowledgement',
                         $req->get_nested('Action.Acknowledgement', 'label'),
                         $req)),
             );
         }],
        '</p>',
    ], $die_if_not_found
        ? ()
        : {
            row_control =>
                [['->get_request'], '->unsafe_get', 'Action.Acknowledgement'],
        });
}

=for html <a name="vs_blank_cell"></a>

=head2 static vs_blank_cell() : Bivio::UI::Widget

=head2 static vs_blank_cell(int count) : Bivio::UI::Widget

Returns a cell which renders a blank.  Makes the code clearer to use.

=cut

sub vs_blank_cell {
    my($proto, $count) = @_;
    return $proto->vs_join('&nbsp;' x ($count || 1));
}

=for html <a name="vs_center"></a>

=head2 static vs_center(any value, ....) : Bivio::UI::Widget

Create a centered DIV from the contents.

=cut

sub vs_center {
    return shift->vs_join(["\n<div align=center>\n", @_, "\n</div>\n"]);
}

=for html <a name="vs_clear_dot"></a>

=head2 clear_dot(any width, any height) : Bivio::UI::HTML::Widget::ClearDot

=head2 clear_dot(any width, any height) : Bivio::UI::HTML::Widget::ClearDot

B<DEPRECATED.  Use L<vs_new|"vs_new">>.

=cut

sub vs_clear_dot {
    my($proto, $width, $height) = @_;
    return $proto->vs_new('ClearDot', {
	defined($width) ? (width => $width) : (),
	defined($height) ? (height => $height) : (),
    });
}

=for html <a name="vs_clear_dot_as_html"></a>

=head2 clear_dot_as_html(int width, int height) : string

Returns an html string which loads a ClearDot image in
width and height.

Don't use in rendering code.  Use L<vs_clear_dot|"vs_clear_dot"> instead.

=cut

sub vs_clear_dot_as_html {
    my(undef) = shift;
    my($c) = _use('ClearDot');
    return $c->as_html(@_);
}

=for html <a name="vs_correct_table_layout_bug"></a>

=head2 vs_correct_table_layout_bug() : Bivio::UI::Widget

Returns a widget which renders a table layout correction javascript if
necessary.

=cut

sub vs_correct_table_layout_bug {
    my($proto) = @_;
    return $proto->vs_call('If',
        [['->get_request'], 'Type.UserAgent', '->has_table_layout_bug'],
        $proto->vs_call('Script', 'correct_table_layout_bug'));
}

=for html <a name="vs_descriptive_field"></a>

=head2 static vs_descriptive_field(string field, any description) : array_ref

Calls vs_form_field and adds I<description> to the result.  I<description>
is an optional string, widget value, or widget.  It is always wrapped
in a String with font form_field_description.

=cut

sub vs_descriptive_field {
    my($proto, $field, $description) = @_;
    my($label, $input) = $proto->vs_form_field($field);
    return [
	$label,
	$proto->vs_call('Join', [
	    $input,
	    [sub {
		 my($req) = shift->get_request;
		 my($proto, $field) = @_;
#TODO: Need to create a separate space for field_descriptions so we don't
#      default to something that we don't expect.
		 my($v) = $req->get_nested('Bivio::UI::Facade', 'Text')
		     ->unsafe_get_value($field, 'field_description');
		 return $v ?
		     $proto->vs_call(
			 'String',
			 $proto->vs_call('Prose', '<br><p class="form_field_description">' . $v . '</p>'),
			 'form_field_description',
		     ) :  '';
	    }, $proto, $field],
	]),
    ];
}

=for html <a name="vs_director"></a>

=head2 static vs_director(any control, hash_ref values, Bivio::UI::Widget default_value, Bivio::UI::Widget undef_value) : Bivio::UI::Widget

B<DEPRECATED.  Use L<vs_new|"vs_new">>.

=cut

sub vs_director {
    my($proto) = shift;
    return $proto->vs_new('Director', @_);
}

=for html <a name="vs_fe"></a>

=head2 static vs_fe(string item) : string

Calls SUPER and escapes.

=cut

sub vs_fe {
    return Bivio::HTML->escape(shift->SUPER::vs_fe(@_));
}

=for html <a name="vs_first_focus"></a>

=head2 static vs_first_focus(any control) : Bivio::UI::Widget

Returns script widget that focuses on the first field on the page.
I<control> is optional.

=cut

sub vs_first_focus {
    my($proto, $control) = @_;
    my($w) = $proto->vs_call('Script', 'first_focus');
    return defined($control) ? $proto->vs_call('If', $control, $w) : $w;
}

=for html <a name="vs_task_link"></a>

=head2 vs_task_link(string text, string task) : Bivio::UI::HTML::Widget::Link

Returns a link widget for the specified task. Only renders if the current
user can execute the task.

=cut

sub vs_task_link {
    my($proto, $text, $task) = @_;
    return $proto->vs_call('Link', $text, $task, {
        control => $task,
    });
}

#TODO: Why doesn't this work right?
#=for html <a name="vs_display"></a>
#
#=head2 static vs_display(any model, string field, hash_ref attrs) : Bivio::UI::Widget
#
#Uses L<Bivio::UI::HTML::WidgetFactory|Bivio::UI::HTML::WidgetFactory> to
#create a display widget.
#
#=cut
#
#sub vs_display {
#    my(undef, $model, $field, $attrs) = @_;
#    $field = [ref(Bivio::Biz::Model->get_instance($model)), $field];
#    return Bivio::IO::ClassLoader->simple_require(
#	'Bivio::UI::HTML::WidgetFactory')->create(
#	    join('.', @$field), {
#		$attrs ? %$attrs : (),
#		value => $field,
#		field => $field->[0],
#	    });
#}

=for html <a name="vs_escape_html"></a>

=head2 vs_escape_html(array_ref value) : array_ref

Wraps I<value> in L<Bivio::HTML::escape|Bivio::HTML/"escape">,

=cut

sub vs_escape_html {
    my(undef, $value) = @_;
    return [\&_escape, $value];
}

=for html <a name="vs_form_field"></a>

=head2 static vs_form_field(string field) : array

Creates a new I<HTMLWidget.FormField> and returns the widgets (label, field).
This is equivalent to:

   vs_new('FormField', @_)->get_label_and_field

=cut

sub vs_form_field {
    my($proto) = shift;
    return $proto->vs_new('FormField', @_)->get_label_and_field;
}

=for html <a name="vs_image"></a>

=head2 static vs_image(any icon) : Bivio::UI::HTML::Widget::Image

=head2 static vs_image(any icon, any alt, hash_ref attrs) : Bivio::UI::HTML::Widget::Image

B<DEPRECATED.  Use L<vs_new|"vs_new">>.

=cut

sub vs_image {
    my($proto, $icon, $alt, $attrs) = @_;
    _use('Image');
    return Bivio::UI::HTML::Widget::Image->new({
	src => $icon,
	(defined($alt) || ref($icon) ? (alt => $alt) : (alt_text => $icon)),
	$attrs ? %$attrs : (),
    });
}

=for html <a name="vs_join"></a>

=head2 static vs_join(any value, ...) : Bivio::UI::Widget::Join

B<DEPRECATED.  Use L<vs_new|"vs_new">>.

=cut

sub vs_join {
    my($proto, @values) = @_;
    my($values) = int(@values) == 1 && ref($values[0]) eq 'ARRAY'
	    ? $values[0] : [@values];
    return $proto->vs_new('Join', $values);
}

=for html <a name="vs_link"></a>

=head2 static vs_link(string task) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link(any label, string task) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link(any label, string task, string font) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link(any label, array_ref widget_value) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link(any label, Bivio::UI::Widget widget) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link(any label, string abs_uri) : Bivio::UI::HTML::Widget::Link

If only I<task> is supplied, it is used for both the label and the href.
It will also be the control for the link.  This is the preferred way
to create links.

Returns a C<Link> with I<label> and I<widget_value>

If I<label> is not a widget, will wrap in a C<String> widget.

If I<task> is passed, will create a widget value by formatting
as a stateless uri for the TaskId named by I<task>.

If I<abs_uri> is passed, it must contain a / or : or #.

=cut

sub vs_link {
    my($proto, $label, $widget_value, $font) = @_;
    _use('Link');
    my($control);
    if (int(@_) <= 2) {
	$control = $label;
	$widget_value = $label;
	$label = $proto->vs_text($widget_value);
    }
    unless (UNIVERSAL::isa($label, 'Bivio::UI::Widget')) {
	$label = $proto->vs_string($label);
    }
    else {
#TODO: Does this make sense. I put it it in for backward compatibility [RJN]
	# Don't assign the font unless creating a string.
	$font = undef;
    }
    $widget_value = [['->get_request'], '->format_stateless_uri',
	Bivio::Agent::TaskId->$widget_value()]
	    # Use widget value or abs_uri (literal)
	    unless ref($widget_value) || $widget_value =~ m![/:#]!;
    return Bivio::UI::HTML::Widget::Link->new({
	href => $widget_value,
	value => $label,
	$control ? (control => $control) : (),
	defined($font) ? (string_font => $font) : (),
    });
}

=for html <a name="vs_link_target_as_html"></a>

=head2 static vs_link_target_as_html(Bivio::UI::Widget widget, any source) : string

Looks up the attribute I<link_target> ancestrally and renders
it as ' target="XXX"' (with leading space) whatever its value is.

Default is '_top', because we don't use frames.

If I<source> is supplied, renders dynamically.  Otherwise, renders
a static string only.

=cut

sub vs_link_target_as_html {
    my($proto, $widget, $source) = @_;
    my($t) = $widget->ancestral_get('link_target', '_top');
    if ($source) {
	my($b);
	$widget->unsafe_render_value('link_target', $t, $source, \$b);
	$t = $b;
    }
    return defined($t) && length($t)
	? ' target="' . Bivio::HTML->escape($t) . '"' : '';
}

=for html <a name="vs_new"></a>

=head2 static vs_new(string class, any new_args, ...) : Bivio::UI::Widget

Returns an instance of I<class> created with I<new_args>.  Loads I<class>, if
not already loaded.

=cut

sub vs_new {
    my(undef, $class) = (shift, shift);
    my($c) = _use($class);
    return $c->new(@_);
}

=for html <a name="vs_simple_form"></a>

=head2 static vs_simple_form(string form_name, array_ref fields, Bivio::UI::Widget preamble, Bivio::UI::Widget epilogue) : Bivio::UI::Widget

Creates a Form in a Grid.  Preamble text.

=cut

sub vs_simple_form {
    my($proto, $form, $fields, $preamble, $epilogue) = @_;
    return $proto->vs_call('Form', $form,
	$proto->vs_call('Grid', [
	    $preamble ? (
		[$preamble->put(
		    cell_colspan => 2,
		    cell_align => 'left',
	        )],
		[$proto->vs_blank_cell()],
	    ) : (),
	    map({
		my($x);
		if (ref($_)) {
		    $x = [$_->put(cell_colspan => 2)];
		}
		elsif ($_ =~ s/^-//) {
		    $x = [$proto->vs_call(
			'String',
			$proto->vs_text('separator', $_),
			0,
			{
			    cell_colspan => 2,
			    cell_class => 'separator',
			},
		    )];
		}
		else {
		    $x = $proto->vs_descriptive_field($_);
		    $x->[0]->put(cell_class => 'form_field_label');
		    $x->[1]->put(cell_class => 'form_field_input');
		}
		$x;
	    } @$fields),
	    [$proto->vs_blank_cell()],
	    [$proto->vs_call('StandardSubmit', {
		cell_colspan => 2,
		cell_align => 'center',
	    })],
	    $epilogue ? (
		[$proto->vs_blank_cell()],
		[$epilogue->put(
		    cell_colspan => 2,
		    cell_align => 'left',
	        )],
	    ) : (),
	], {
	    pad => 2,
	}));
}

=for html <a name="vs_string"></a>

=head2 static vs_string(any value) : Bivio::UI::Widget::String

=head2 static vs_string(any value, string font, hash_ref attrs) : Bivio::UI::Widget::String

B<DEPRECATED.  Use L<vs_new|"vs_new">>.

=cut

sub vs_string {
    my($proto, $value, $font, $attrs) = @_;
    return $proto->vs_new('String', $value, $font, $attrs);
}

#=PRIVATE METHODS

# _escape(any source, string value) : string
#
# Escapes its argument.  Must be a scalar, and not undef.
#
sub _escape {
    my(undef , $value) = @_;
    Bivio::Die->die($value, ': vs_escape_html not passed a string')
        if ref($value) || !defined($value);
    return Bivio::HTML->escape($value);
}

# _use(string class, ....) : array
#
# Executes Bivio::IO::ClassLoader->simple_require on its args.  Inserts
# HTMLWidget# prefix, if class does not contain
# colons.  Returns the named classes.
#
sub _use {
    my(@class) = @_;
    return map {
	$_ =~ /:/ ? Bivio::IO::ClassLoader->simple_require($_)
	: Bivio::IO::ClassLoader->map_require('HTMLWidget', $_);
    } @class;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
