# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::ViewShortcuts;
use strict;
$Bivio::UI::HTML::ViewShortcuts::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::ViewShortcuts::VERSION;

=head1 NAME

Bivio::UI::HTML::ViewShortcuts - html helper routines

=head1 SYNOPSIS

    use Bivio::UI::HTML::ViewShortcuts

=cut

=head1 EXTENDS

L<Bivio::UI::ViewShortcutsBase>

=cut

use Bivio::UI::ViewShortcutsBase;
@Bivio::UI::HTML::ViewShortcuts::ISA = qw(Bivio::UI::ViewShortcutsBase);

=head1 DESCRIPTION

Provides many utility routines to help create widgets.

=cut


=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Agent::Request;
use Bivio::Agent::TaskId;
use Bivio::Biz::Model;
use Bivio::Die;
use Bivio::HTML;
use Bivio::IO::ClassLoader;
use Bivio::IO::File;
use Bivio::UI::HTML::Format::Link;
use Bivio::UI::Label;
#NOTE: Do not import any widgets here, use _use().

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="vs_action_bar"></a>

=head2 static vs_action_bar(string button, ...) : Bivio::UI::HTML::Widget::ActionBar

Returns an action bar for the specified I<button>s.

=cut

sub vs_action_bar {
    my($self) = shift;
    _use('ActionBar', 'Bivio::UI::HTML::ActionButtons');
    return Bivio::UI::HTML::Widget::ActionBar->new({
	values => Bivio::UI::HTML::ActionButtons->get_list(@_)});
}

=for html <a name="vs_action_grid"></a>

=head2 static vs_action_grid(array_ref rows) : Bivio::UI::HTML::Widget::Grid

Creates Grid which is filled with rows created from I<rows>.

A value in I<rows> looks like:

    [
       'label',
       'task',
       $value,
       # Arbitrary attributes
       {
           control => ['link_control'],
           whats_this => 'privileges',
       }
    ],

If I<task> is true, I<label> will be wrapped in a link.
I<task> may be name, an actual C<TaskId> instance or
an array_ref in which case it is treated as a widget value
returning the proper URI at rendering time.

If I<value> is a widget, it is used literally.

If I<value> is an array_ref, the syntax is:

    [
       'model_name',
       'model_field',
    ],

The values will be aligned properly for a 2x2 grid where
the I<label> appears on the left.  The label is looked up
using L<Bivio::UI::Label|Bivio::UI::Label>.

If I<model_name> begins with a capital letter and consists
of alphanumerics (no underscores),
it will be prefixed by C<Bivio::Biz::Model::>.

=cut

sub vs_action_grid {
    my($proto, $values) = @_;
    _use('Link', 'Grid');

    my($rows) = [];
    foreach my $v (@$values) {
	my($label, $task, $value, $attrs) = @$v;
	# Label
	$label = $proto->vs_string(
		Bivio::UI::Label->get_simple($label));
	$attrs ||= {};
	$label = Bivio::UI::HTML::Widget::Link->new({
	    href => ref($task) eq 'ARRAY' ? $task
            : ['->format_uri', Bivio::Agent::TaskId->from_any($task)],
	    value => $label,
	    %$attrs,
	}) if $task;
	$label->put(cell_align => 'ne');

	# Value
	$value = $proto->vs_string(
		# Only prefix with Bivio::Biz::Model:: if possible model name.
		[$value->[0] =~ /^[A-Z][a-z0-9A-Z]+$/
		    ? ref(Bivio::Biz::Model->get_instance($value->[0]))
		    : $value->[0],
		    @{$value}[1..$#$value]],
	       ) if ref($value) eq 'ARRAY';
	$value->put(cell_align => 'nw');

	$value = $proto->vs_append_whats_this($value, $attrs->{whats_this})
		if $attrs->{whats_this};
	push(@$rows, [$label, $value]);
    }
    return Bivio::UI::HTML::Widget::Grid->new({
#TODO: If you put in this, it screws up the footer.  Don't ask me why...
#	    align => 'left',
	pad => 5,
	values => $rows,
    });
}

=for html <a name="vs_append_whats_this"></a>

=head2 static vs_append_whats_this(Bivio::UI::Widget widget, string help_topic) : Bivio::UI::Widget

=head2 static vs_append_whats_this(Bivio::UI::Widget widget, string task) : Bivio::UI::Widget

Adds a L<whats_this|"whats_this"> to the right of I<widget>.

=cut

sub vs_append_whats_this {
    my($proto, $widget) = (shift, shift);
    my($font) = $widget->unsafe_get('string_font');
    return $proto->vs_string(
	    $proto->vs_join([
		$widget->put(string_font => 0),
		'&nbsp;' x 5,
		$proto->vs_whats_this(@_)->put(string_font => 0)
	    ]),
	    $font,
	   );
}

=for html <a name="vs_blank_cell"></a>

=head2 static vs_blank_cell() : Bivio::UI::Widget

Returns a cell which renders a blank.  Makes the code clearer to use.

=cut

sub vs_blank_cell {
    return shift->vs_join('&nbsp;');
}

=for html <a name="vs_button"></a>

=head2 static vs_button() : Bivio::UI::Widget

=head2 static vs_button(string name, Bivio::Agent::TaskId task) : Bivio::UI::Widget

=head2 static vs_button(string name, Bivio::Agent::TaskId task, any description) : Bivio::UI::Widget

=head2 static vs_button(string name, Bivio::Agent::TaskId task, any description, boolean no_label) : Bivio::UI::Widget

=head2 static vs_button(array_ref control, Bivio::Agent::TaskId task, any description) : Bivio::UI::Widget

=head2 static vs_button(array_ref control, Bivio::Agent::TaskId task, any description, boolean no_label) : Bivio::UI::Widget

If no I<name>, creates a
L<Bivio::UI::HTML::Widget::StandardSubmit|Bivio::UI::HTML::Widget::StandardSubmit>.

Surrounds the widget with L<indent|"indent"> if has a name.
C<StandardSubmit> is centered.

If I<task> is supplied, creates a C<TaskButton> widget and indents.

If I<description> is supplied, a L<description|"description"> will precede the
button.  If I<control> is not supplied in this case, the control will
be I<can_user_execute_task>.  If I<control> returns true, the
description and button will be displayed.

Don't put a label on the description if I<no_label> is true.

=cut

sub vs_button {
    my($proto, $name, $task, $description, $no_label) = @_;

    _use(qw(TaskButton StandardSubmit));
    if ($task) {
	# Create the button for simpler modes
	$task = Bivio::Agent::TaskId->from_any($task);
	my($res) = [
	    $proto->vs_string($proto->vs_join(
		    $proto->vs_indent(Bivio::UI::HTML::Widget::TaskButton->new({
			value => $task,
			label => ref($name) ? undef : $name,
		    }))))];
	return @$res unless $description;

	# Have a description, so may have control
	my($control);
	if (ref($name)) {
	    $control = $name;
	    $name = undef;
	}
	else {
	    $control = ['->can_user_execute_task', $task];
	}

	# Put description in front of button
	unshift(@$res,
		$proto->vs_description(
			$no_label ? undef : ($name || $task->get_name),
			$description));

	# Have control, create a director
	return $proto->vs_director($control,
		{1 => $proto->vs_join($res),
		    0 => $proto->vs_join('')});
    }
    return $proto->vs_indent(Bivio::UI::HTML::Widget::StandardSubmit->new());
}

=for html <a name="vs_center"></a>

=head2 static vs_center(any value, ....) : Bivio::UI::Widget

Create a centered DIV from the contents.

=cut

sub vs_center {
    return shift->vs_join(["\n<div align=center>\n", @_, "\n</div>\n"]);
}

=for html <a name="vs_checkmark"></a>

=head2 static vs_checkmark(string field) : Bivio::UI::Widget

Shows a checkmark for the field.  Looks up $field."_ALT" for
alt text for image.

=cut

sub vs_checkmark {
    my($proto, $field) = @_;
    my($alt) = $field;
    $alt =~ s/\./_/;
    $alt = Bivio::UI::Label->get_simple($alt.'_ALT');
    return $proto->vs_director([$field], {
	0 => '',
	1 => $proto->vs_image('check_on', $alt),
    });
}

=for html <a name="vs_clear_dot"></a>

=head2 clear_dot(any width, any height) : Bivio::UI::HTML::Widget::ClearDot

=head2 clear_dot(any width, any height) : Bivio::UI::HTML::Widget::ClearDot

Returns a ClearDot widget.  I<width> and I<height> may be C<undef>,
a widget value or an integer.

=cut

sub vs_clear_dot {
    my(undef, $width, $height) = @_;
    _use('ClearDot');
    return Bivio::UI::HTML::Widget::ClearDot->new({
	defined($width) ? (width => $width) : (),
	defined($height) ? (height => $height) : (),
    });
}

=for html <a name="vs_clear_dot_as_html"></a>

=head2 clear_dot_as_html(int width, int height) : string

Returns an html string which loads a ClearDot image in
width and height.

Don't use in rendering code.  Use L<clear_dot|"clear_dot"> instead.

=cut

sub vs_clear_dot_as_html {
    my(undef) = shift;
    _use('ClearDot');
    return Bivio::UI::HTML::Widget::ClearDot->as_html(@_);
}

=for html <a name="vs_club_or_fund"></a>

=head2 club_or_fund() : Bivio::UI::Widget

Returns a widget with the "club" or "fund" terminology.  Uses
HTML's club_or_fund attribute.

=cut

sub vs_club_or_fund {
    return shift->vs_html_string('club_or_fund');
}

=for html <a name="vs_date_time"></a>

=head2 static vs_date_time(any value) : Bivio::UI::HTML::Widget::DateTime

=head2 static vs_date_time(any value, any mode) : Bivio::UI::HTML::Widget::DateTime

Returns a C<Widget::DateTime> for the I<value> and I<mode>.  

If I<value> is undef, uses DateTime-E<gt>now.

=cut

sub vs_date_time {
    my(undef, $value, $mode) = @_;
    _use('DateTime');
    return Bivio::UI::HTML::Widget::DateTime->new({
	value => defined($value) ? $value : [sub {Bivio::Type::DateTime->now}],
	int(@_) >= 3 ? (mode => $mode) : (),
    });
}

=for html <a name="vs_description"></a>

=head2 static vs_description(string label, any body) : Bivio::UI::Widget

Returns a descriptive paragraph which begins with I<label> and
is followed by I<body>.  If I<body> is an array_ref, it will
be unwrapped (@$body).

If I<label> is C<undef>, no label will be put on the paragraph.

=cut

sub vs_description {
    my($proto, $label, $body) = @_;
    return $proto->vs_join(['&nbsp;<br>',
	    defined($label)
	    ? ($proto->vs_string(Bivio::UI::Label->get_simple($label).'.',
		    'description_label'), ' ')
	    : (),
	    ref($body) eq 'ARRAY' ? @$body : $body,
	    '<br>']);
}

=for html <a name="vs_director"></a>

=head2 static vs_director(any control, hash_ref values, Bivio::UI::Widget default_value, Bivio::UI::Widget undef_value) : Bivio::UI::Widget

DEPRECATED

=cut

sub vs_director {
    my($proto) = shift;
    return $proto->vs_new('Director', @_);
}

=for html <a name="vs_display_widget"></a>

=head2 static vs_display_widget(any model, string property) : Bivio::UI::Widget

=head2 static vs_display_widget(any model, string property, array_ref widget_value) : Bivio::UI::Widget

=head2 static vs_display_widget(any model, string property, array_ref widget_value, hash_ref attrs) : Bivio::UI::Widget

Returns the widget for I<property> of I<model>.  I<model> will be
loaded by
L<Bivio::Biz::Model::get_instance|Bivio::Biz::Model/"get_instance">.

If I<widget_value> is C<undef>, it will be set to

    [ref($model), $property]

I<attrs> is an optional and will be applied to the created widget.

=cut

sub vs_display_widget {
    my($proto, $model, $property, $widget_value, $attrs) = @_;
    _use('Bivio::UI::HTML::WidgetFactory');
    $attrs ||= {};
    $model = Bivio::Biz::Model->get_instance($model);

#TODO: need a generic way to switch a widget's source
    # Default the widget_value
    $widget_value = [ref($model), $property] unless $widget_value;
#TODO: This breaks WidgetFactory's code
    $attrs->{field} = $widget_value;
    $attrs->{value} = $widget_value;

    return Bivio::UI::HTML::WidgetFactory->create(
	    ref($model).'.'.$property, $attrs);
}

=for html <a name="vs_english_a"></a>

=head2 static vs_english_a(array_ref widget_value) : array_ref

Adds C<EnglishSyntax> formatter for 'a'.

=cut

sub vs_english_a {
    my(undef, $widget_value) = @_;
    _use('Bivio::UI::HTML::Format::EnglishSyntax');
    push(@$widget_value, 'Bivio::UI::HTML::Format::EnglishSyntax', 'a');
    return $widget_value;
}

=for html <a name="vs_english_list"></a>

=head2 static vs_english_list(string connective, array words) : string

Concatenates the list words into an English conjunction ('and') or
disjunction ('or').

=cut

sub vs_english_list {
    my(undef, $connective, @words) = @_;

    # One
    return $words[0] if int(@words) == 1;

    # One and two
    return $words[0].' '.$connective.' '.$words[1] if int(@words) == 2;

    # One, two, and three
    my($last) = pop(@words);
    return join(', ', @words, $connective.' '.$last);
}

=for html <a name="vs_form"></a>

=head2 static vs_form(string form_class) : Bivio::UI::HTML::DescriptivePageForm

=head2 static vs_form(string form_class, array_ref values, array_ref list_values) : Bivio::UI::HTML::DescriptivePageForm

=head2 static vs_form(string form_class, array_ref values, hash_ref attrs) : Bivio::UI::HTML::DescriptivePageForm

=head2 static vs_form(string form_class, array_ref values, array_ref list_values, hash_ref attrs) : Bivio::UI::HTML::DescriptivePageForm

Returns a new C<DescriptivePageForm>.  If I<values> are passed,
the fields will be created with C<$form-E<gt>create_fields>.
If I<attrs> is passed, will be set on C<DescriptivePageForm::new>.

I<list_values> are passed to C<$form-E<gt>create_list_fields>.

=cut

sub vs_form {
    my(undef, $form_class, $values, $list_values, $attrs) = @_;
    _use('Bivio::UI::HTML::DescriptivePageForm');

    # Figure out params: list_values must be an ARRAY to be used as such
    $attrs ||= $list_values, $list_values = undef
	    if ref($list_values) ne 'ARRAY';

    my($form) = Bivio::UI::HTML::DescriptivePageForm->new({
	form_class => $form_class,
	$attrs ? %$attrs : (),
    });

    # Create list fields first
    $form->create_list_fields($list_values) if $list_values;

    # Create other fields next.  Must call create_fields for list fields
    # to work properly.
    $form->put(value => $form->create_fields($values || []))
	    if $values || $list_values;
    return $form;
}

=for html <a name="vs_form_button"></a>

=head2 static vs_form_button(string field) : Bivio::UI::HTML::Widget::FormButtonn

=head2 static vs_form_button(string field, string label) : Bivio::UI::HTML::Widget::FormButton

Creates a form button widget for the specified, fully qualified field name.
The button label may be overridden by supplying the Bivio::UI::Label value.

=cut

sub vs_form_button {
    return shift->vs_simple_form_field(@_);
}

=for html <a name="vs_format_uri_static_site"></a>

=head2 static vs_format_uri_static_site(Bivio::Agent::Request req, string page) : string

Returns a uri formatted for the static site.

=cut

sub vs_format_uri_static_site {
    my(undef, $req, $page) = @_;
    return $req->format_uri(Bivio::Agent::TaskId::HTTP_DOCUMENT(),
	    undef,
	    '',
	    Bivio::Agent::HTTP::Location->get_document_path_info($page),
	    1),
}

=for html <a name="vs_get_label"></a>

=head2 static vs_get_label(string name, ....) : string

Looks up label with
L<Bivio::UI::Label::get_simple|Bivio::UI::Label/"get_simple">.

=cut

sub vs_get_label {
    shift;
    return Bivio::UI::Label->get_simple(@_);
}

=for html <a name="vs_heading"></a>

=head2 static vs_heading(any heading) : Bivio::UI::Widget::Join

Return parts that make a heading (in page_heading font).

=cut

sub vs_heading {
    my($proto, $heading) = @_;
    # HotJava Bug: Replace the nbsp<br> with a <p> and hotjava renders
    # infinitely.
    return $proto->vs_join([$proto->vs_string($heading, 'page_heading'), '<br>']);
}

=for html <a name="vs_heading_as_label"></a>

=head2 static vs_heading_as_label() : Bivio::UI::Widget::Join

=head2 static vs_heading_as_label(string label) : Bivio::UI::Widget::Join

Returns a page heading for I<label>.  If there is no label,
will use the task_id (dynamically).

=cut

sub vs_heading_as_label {
    my($proto, $label) = @_;
    return $proto->vs_heading(
	    defined($label) ? Bivio::UI::Label->get_simple($label)
	    : [sub {Bivio::UI::Label->get_simple(shift->get('task_id')
		    ->get_name)}]);
}

=for html <a name="vs_heading_with_search"></a>

=head2 static vs_heading_with_search(string label) : Bivio::UI::Widget

=head2 static vs_heading_with_search(Bivio::UI::Widget widget) : Bivio::UI::Widget

Returns a widget which renders I<label> in page_heading font or
I<widget> on left
with a search box to the right.

=cut

sub vs_heading_with_search {
    my($proto, $widget) = @_;
    return $proto->vs_new('Grid', {
        expand => 1,
        values => [[
            ref($widget) ? $widget : $proto->vs_label($widget, 'page_heading'),
	    $proto->vs_new('Search', {
		size => 20,
		cell_align => 'SE',
		cell_end_form => 1,
	    }),
        ]],
    });
    return;
}

=for html <a name="vs_highlight"></a>

=head2 static vs_highlight(any value) : Bivio::UI::HTML::Widget::String

Returns a string widget for I<value> whose font is highlighted
(strong for now).

If already a string widget, will simply change the font.

=cut

sub vs_highlight {
    my($proto, $value) = @_;
    _use('String');
    $value = $proto->vs_string($value)
	    unless ref($value) eq 'Bivio::UI::HTML::Widget::String';
    $value->put(string_font => 'strong');
    return $value;
}

=for html <a name="vs_href_goto"></a>

=head2 href_goto(any uri) : array_ref

Widget value to create a goto link href for "offsite" links.
I<uri> may be a string, task, or an array_ref (widget value).

=cut

sub vs_href_goto {
    my(undef, $uri) = @_;
    Bivio::Die->die($uri, ": must be an absolute uri")
		unless $uri =~ m!^\w+://!;
    return ref($uri) ? [$uri, 'Bivio::UI::HTML::Format::Link']
	    : ['Bivio::UI::HTML::Format::Link', $uri];
}

=for html <a name="vs_html_string"></a>

=head2 html_string(string attr) : Bivio::UI::Widget

Returns a widget which renders L<html_value|"html_value"> as a string
(no font).

=cut

sub vs_html_string {
    my($proto, $attr) = @_;
    # Parent widget will wrap font in a font.
    return $proto->vs_string($proto->vs_html_value($attr), 0);
}

=for html <a name="vs_html_value"></a>

=head2 static vs_html_value(string attr) : array_ref

Returns a call to L<Bivio::UI::HTML::get_value|Bivio::UI::HTML/"get_value">
as an array ref.

=cut

sub vs_html_value {
    my($proto, $attr) = @_;
    return [['->get_request'], 'Bivio::UI::HTML', '->get_value', $attr];
}

=for html <a name="vs_image"></a>

=head2 static vs_image(any icon) : Bivio::UI::HTML::Widget::Image

=head2 static vs_image(any icon, any alt, hash_ref attrs) : Bivio::UI::HTML::Widget::Image

Returns an Image widget configured with I<icon> and I<alt>.

If I<alt> is not defined and I<icon> is not a ref, will lookup
in the label table as I<icon>_ALT.

I<attrs> are applied to the Image Widget.

=cut

sub vs_image {
    my($proto, $icon, $alt, $attrs) = @_;
    _use('Image');
    $alt = Bivio::UI::Label->unsafe_get_simple($icon, 'image_alt')
	    || Bivio::UI::Label->unsafe_get_simple($icon.'alt')
	    unless defined($alt) || ref($icon);
    return Bivio::UI::HTML::Widget::Image->new({
	src => $icon,
	alt => $alt,
	$attrs ? %$attrs : (),
    });
}

=for html <a name="vs_indent"></a>

=head2 static vs_indent(any value, ...) : Bivio::UI::Widget

Create an indented paragraph from the contents.

=cut

sub vs_indent {
    return shift->vs_join(["\n<blockquote>\n", @_, "\n</blockquote>\n"]);
}

=for html <a name="vs_indirect"></a>

=head2 indirect(any value) : Bivio::UI::Widget::Indirect

DEPRECATED

=cut

sub vs_indirect {
    my(undef, $value) = @_;
    _use('Indirect');
    return Bivio::UI::Widget::Indirect->new({
	value => $value,
    });
}

=for html <a name="vs_join"></a>

=head2 static vs_join(any value, ...) : Bivio::UI::Widget::Join

DEPRECATED

=cut

sub vs_join {
    my($proto, @values) = @_;
#    Bivio::IO::Alert->warn_deprecated('source arguments in a array_ref')
#		unless int(@values) == 1 && ref($values[0]) eq 'ARRAY';
    my($values) = int(@values) == 1 && ref($values[0]) eq 'ARRAY'
	    ? $values[0] : [@values];
    return $proto->vs_new('Join', $values);
}

=for html <a name="vs_label"></a>

=head2 static vs_label(string label, string font) : Bivio::UI::HTML::Widget::String

=head2 static vs_label(array_ref label, string font) : Bivio::UI::HTML::Widget::String

Looks up I<label>--dereferencing the array_ref if necessary.  Uses
C<label_in_text> if I<font> is not supplied.  Does not set I<string_font> if
I<font> is C<undef>.

=cut

sub vs_label {
    my($proto, $label, $font) = @_;
    return $proto->vs_string(Bivio::UI::Label->get_simple(
	    ref($label) ? @$label : $label),
	    defined($font) ? $font : 'label_in_text');
}

=for html <a name="vs_learn_more"></a>

=head2 static vs_learn_more(string help_topic) : Bivio::UI::Widget

=head2 static vs_learn_more(string task) : Bivio::UI::Widget

Creates a small "what's this?' link widget which points to the help for
I<task> or I<help_topic>

=cut

sub vs_learn_more {
    return _link_help(@_, 'learn_more');
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
	$label = Bivio::UI::Label->get_simple($widget_value);
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

=for html <a name="vs_link_amazon"></a>

=head2 static vs_link_amazon(string asin, any value) : Bivio::UI::HTML::Widget::Link

Returns a link to an amazon book.

=cut

sub vs_link_amazon {
    my($proto, $asin, $value) = @_;
    _use('Link');
    return Bivio::UI::HTML::Widget::Link->new({
	href => 'http://www.amazon.com/exec/obidos/ASIN/'.$asin
	.'/bivioalllower/',
	value => $value,
    });
}

=for html <a name="vs_link_ask_candis"></a>

=head2 static vs_link_ask_candis() : Bivio::UI::HTML::Widget::Link

Returns a link to Trez Talk.

=cut

sub vs_link_ask_candis {
    return shift->vs_link('Ask Candis', '/ask_candis');
}

=for html <a name="vs_link_goto"></a>

=head2 link_goto(any label, any uri) : Bivio::UI::HTML::Widget::Link

Create a "goto" link, which allows us to track references to other
sites.

See L<link|"link"> for a description of I<label>.

See L<href_goto|"href_goto"> for description of I<uri>.

=cut

sub vs_link_goto {
    my($proto, $label, $uri, $font) = @_;
    return $proto->vs_link($label, $proto->vs_href_goto($uri), $font);
}

=for html <a name="vs_link_help"></a>

=head2 static vs_link_help(string label) : string

=head2 static vs_link_help(string label, any task) : string

=head2 static vs_link_help(string label, any task, string font) : string

Returns the URL to the help topic for the specified task.
See
L<Bivio::Agent::Request::format_help_uri|Bivio::Agent::Request/"format_help_uri">
for a description of I<task>'s values.

=cut

sub vs_link_help {
    my($proto, $label, $task, $font) = @_;
    Bivio::Die->die($label, ": label must be a string")
	if !defined($label) || ref($label);

    return $proto->vs_link($label, ['->format_help_uri', $task], $font)
	    ->put(control => $proto->vs_html_value('want_help'));
}

=for html <a name="vs_link_secure"></a>

=head2 static vs_link_secure() : Bivio::UI::Widget::Director

Show a paragraph (with leading <p>) describing secure mode if not
in secure mode.

=cut

sub vs_link_secure {
    my($proto) = @_;
    return $proto->vs_director([sub {
	    my($req) = Bivio::Agent::Request->get_current;
	    return Bivio::UI::HTML->get_value('want_secure', $req)
		    ? ($req->get('is_secure') ? 1 : 0) : 2;
	}], {
	0 => $proto->vs_join(
		"\n<p>&#149; ",
		$proto->vs_link('Click here to switch to secure mode.',
			['->format_http_toggling_secure']),
		" &#149;\n"),
	1 => $proto->vs_join("\n<p>&#149; This page is secure. &#149;\n"),
	# When the facade doesn't support SSL
	2 => $proto->vs_join("\n"),
    });
}

=for html <a name="vs_link_static_site"></a>

=head2 static vs_link_static_site(any label, string page, string font) : Bivio::UI::Widget

Returns a link to the static site I<page>.  It will append C<.html> and prefix
with a '/', but must include directory, e.g. "hm/services.html".

=cut

sub vs_link_static_site {
    my($proto, $label, $page, $font) = @_;
    return $proto->vs_link($label, $proto->vs_format_uri_static_site(
	    Bivio::Agent::Request->get_current, $page),
	    $font);
}

=for html <a name="vs_link_support"></a>

=head2 static vs_link_support() : string

Returns URL to support.

=cut

sub vs_link_support {
    my($proto) = @_;
    return $proto->vs_link(['support_email'], 'MAIL_SUPPORT');
}

=for html <a name="vs_link_target_as_html"></a>

=head2 static vs_link_target_as_html(Bivio::UI::Widget widget) : string

Looks up the attribute I<link_target> ancestrally and renders
it as ' target="XXX"' (with leading space) whatever its value is.

Default is '_top', because we don't use frames.

=cut

sub vs_link_target_as_html {
    my($proto, $widget) = @_;
    my($t) = $widget->ancestral_get('link_target', '_top');
    return defined($t) ? (' target="'.Bivio::HTML->escape($t).'"') : '';
}

=for html <a name="vs_link_tm"></a>

=head2 static vs_link_tm(any label, string task) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link_tm(any label, string task, string font) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link_tm(any label, array_ref widget_value) : Bivio::UI::HTML::Widget::Link

=head2 static vs_link_tm(any label, string abs_uri) : Bivio::UI::HTML::Widget::Link

Generates a L<link|"link"> with a trademark symbol at the end.

=cut

sub vs_link_tm {
    my($proto, $label, $arg, $font) = @_;
    Bivio::Die->die($label, ": label must be a string")
	if !defined($label) || ref($label);

    # Must be in a join, because we are pre-escaping the string
    return $proto->vs_link($proto->vs_string(
	    Bivio::HTML->escape($label).'&#153;',
	    defined($font) ? ($font) : (),
	   )->put(escape_html => 0),
	    $arg);
}

=for html <a name="vs_link_trez_talk"></a>

=head2 static vs_link_trez_talk() : Bivio::UI::HTML::Widget::Link

Returns a link to Trez Talk.

=cut

sub vs_link_trez_talk {
    return shift->vs_link('Trez Talk', '/trez_talk');
}

=for html <a name="vs_list_actions"></a>

=head2 static vs_list_actions(array_ref actions) : hash_ref

Returns a L<table|"table"> column value which is a
L<Bivio::UI::HTML::Widget::ListActions|Bivio::UI::HTML::Widget::ListActions>.

=cut

sub vs_list_actions {
    my($proto, $actions) = @_;
    _use('ListActions');
    return {
	column_heading => 'list_actions',
	column_widget => Bivio::UI::HTML::Widget::ListActions->new({
	    values => $actions,
	}),
	column_align => 'w',
    };
}

=for html <a name="vs_load_class"></a>

=head2 load_class(string widget, ...)

Loads a widget class dynamically.  Can be used by modules which
want to avoid static imports.

Widgets can be referred to by their base class name, e.g.
C<load_class('Grid')> loads C<Bivio::UI::HTML::Widget::Grid>.

=cut

sub vs_load_class {
    shift;
    _use(@_);
    return;
}

=for html <a name="vs_mailto"></a>

=head2 static vs_mailto(any email) : Bivio::UI::HTML::Widget::MailTo

=head2 static vs_mailto(any email, any value) : Bivio::UI::HTML::Widget::MailTo

=head2 static vs_mailto(any email, any value, any subject) : Bivio::UI::HTML::Widget::MailTo

Returns a C<Widget::MailTo> for email.

=cut

sub vs_mailto {
    my(undef, $email, $value, $subject) = @_;
    _use('MailTo');
    my($x) = Bivio::UI::HTML::Widget::MailTo->new({
	email => $email,
	defined($value) ? (value => $value) : (),
	defined($subject) ? (subject => $subject) : (),
    });
    return $x;
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

=for html <a name="vs_noop"></a>

=head2 noop() : Bivio::UI::Widget

Returns an empty join widget.

=cut

sub vs_noop {
    return shift->vs_join('');
}

=for html <a name="vs_page_heading_banner_ad"></a>

=head2 page_heading_banner_ad() : Bivio::UI::Widget

Returns a banner ad widget which fits in the page heading area.

=cut

sub vs_page_heading_banner_ad {
    my($proto) = @_;
#    return $proto->vs_link_static_site(
#	    $proto->vs_image('promote_stop_small'), 'hm/account-sync')
#	    ->put(control => $proto->vs_html_value('want_ads'));
    return $proto->vs_link_goto(
	$proto->vs_image('ad_mld_onyourown_230x33_4k_NL',
		'Enroll with Merrill Lynch and get $100'),
	'http://www.mldirect.ml.com/publish/public/offer.asp?medium=BIV0001')
	->put(control => $proto->vs_html_value('want_ads'));
}

=for html <a name="vs_page_text"></a>

=head2 static vs_page_text(array_ref values) : Bivio::UI::HTML::Widget::String

Returns a String widget with I<string_font> C<page_text> and
the html is NOT escaped.  Used for long strings which contain
html.  I<value> will be enclosed in a join if it contains more
than one element.

=cut

sub vs_page_text {
    my($proto, $value) = @_;
    die('value must be an array_ref') unless ref($value) eq 'ARRAY';
    return $proto->vs_string(
	    int(@$value) == 1 ? $value->[0] : $proto->vs_join($value),
	    'page_text')
	    ->put(escape_html => 0);
}

=for html <a name="vs_realm_name"></a>

=head2 static vs_realm_name() : Bivio::UI::Widget

=head2 static vs_realm_name(array_ref widget_value) : Bivio::UI::Widget

Returns the realm_name widget.  Defaults to

    ['auth_realm', 'owner', 'display_name']

if I<widget_value> not supplied.

=cut

sub vs_realm_name {
    my($proto, $widget_value) = @_;
    $widget_value = ['auth_realm', 'owner', 'display_name']
	    unless $widget_value;
    return $proto->vs_indent($proto->vs_string($widget_value, 'realm_name'));
}

=for html <a name="vs_secure_data"></a>

=head2 static vs_secure_data(Bivio::UI::Widget widget) : Bivio::UI::Widget

Wraps I<widget> in a
L<Bivio::UI::HTML::Widget::SecureData|Bivio::UI::HTML::Widget::SecureData>
widget.

=cut

sub vs_secure_data {
    my($proto, $widget) = @_;
    return $proto->vs_new('SecureData', {value => $widget});
}

=for html <a name="vs_simple_form"></a>

=head2 simple_form(string class, any widget) : Bivio::UI::HTML::Widget::Form

=head2 simple_form(Bivio::Biz::FormModel class, any widget) : Bivio::UI::HTML::Widget::Form

Creates a form which renders I<widget>.  Use L<form|"form"> to create a
L<Bivio::UI::HTML::DescriptivePageForm|Bivio::UI::HTML::DescriptivePageForm>.
I<class>

=cut

sub vs_simple_form {
    my(undef, $class, $widget) = @_;
    _use('Form');
    return Bivio::UI::HTML::Widget::Form->new({
        form_class => ref(Bivio::Biz::Model->get_instance($class)),
        value => $widget,
    });
}

=for html <a name="vs_simple_form_field"></a>

=head2 static vs_simple_form_field(string field) : Bivio::UI::HTML::Widget::FormButtonn

=head2 static vs_simple_form_field(string field, string label) : Bivio::UI::HTML::Widget::FormButton

Creates a form button widget for the specified, fully qualified field name.
The label (if any) may be overridden by supplying the Bivio::UI::Label value.

=cut

sub vs_simple_form_field {
    my($proto, $field, $label) = @_;
    _use('Bivio::UI::HTML::WidgetFactory');

    if ($label) {
	$label = Bivio::UI::Label->get_simple($label) unless ref($label);
	return Bivio::UI::HTML::WidgetFactory->create($field, {
	    label => $label,
	});
    }

    return Bivio::UI::HTML::WidgetFactory->create($field);
}

=for html <a name="vs_site_name"></a>

=head2 static vs_site_name() : string

Returns a widget containing the site name.

=cut

sub vs_site_name {
    return shift->vs_html_string('site_name');
}

=for html <a name="vs_string"></a>

=head2 static vs_string(any value) : Bivio::UI::Widget::String

=head2 static vs_string(any value, string font) : Bivio::UI::Widget::String

Returns a string widget for I<value> and I<font> if supplied.
Use C<0> (zero) to set "no font".  Will not set font, if C<undef>.

=cut

sub vs_string {
    my($proto, $value, $font) = @_;
    return $proto->vs_new('String', {
	value => $value,
	# Allow caller to set font to undef
	defined($font) ? (string_font => $font) : (),
    });
}

=for html <a name="vs_table"></a>

=head2 static vs_table(string list_class, array_ref columns, hash_ref attrs) : Bivio::UI::HTML::Widget::Table

Wrapper for
L<Bivio::UI::HTML::Widget::Table|Bivio::UI::HTML::Widget::Table>.

I<attrs> are the global attributes sans I<list_class> and I<columns>.
I<attrs> may be C<undef> or an empty hash_ref.

=cut

sub vs_table {
    my($proto, $list_class, $columns, $attrs) = @_;
    _use('Table');
    $attrs ||= {};
    $attrs->{list_class} = $list_class;
    $attrs->{columns} = $columns;
    return Bivio::UI::HTML::Widget::Table->new($attrs);
}

=for html <a name="vs_task_list"></a>

=head2 static vs_task_list(any heading, array_ref values) : Bivio::UI::HTML::Widget::TaskList

=head2 static vs_task_list(any heading, array_ref values, boolean want_sort) : Bivio::UI::HTML::Widget::TaskList

Wrapper for
L<Bivio::UI::HTML::Widget::TaskList|Bivio::UI::HTML::Widget::TaskList>.

I<want_sort> is false by default.

=cut

sub vs_task_list {
    my($proto, $heading, $values, $want_sort) = @_;
    return $proto->vs_new('TaskList', {
	heading => $heading,
	values => $values,
	want_sort => $want_sort,
    });
}

=for html <a name="vs_template"></a>

=head2 static vs_template(string value) : Bivio::UI::Widget

=head2 static vs_template(string_ref value) : Bivio::UI::Widget

Returns an instance of a Template widget configured with I<value>.

=cut

sub vs_template {
    my($proto, $value, $font) = @_;
    die('font is deprecated usage') if defined($font);
    return $proto->vs_new('Template', {value => $value});
}

=for html <a name="vs_template_as_string"></a>

=head2 static vs_template_as_string(string value, string font) : Bivio::UI::Widget

=head2 static vs_template_as_string(string_ref value, string font) : Bivio::UI::Widget

Wraps a L<template|"template"> in a string.

If I<font> not supplied, defaults to I<page_text>.

=cut

sub vs_template_as_string {
    my($proto, $value, $font) = @_;
    return $proto->vs_string($proto->vs_template($value),
	    defined($font) ? $font : 'page_text');
}

=for html <a name="vs_toggle_secure"></a>

=head2 toggle_secure() : Bivio::UI::HTML::Widget::ToggleSecureModeButton

Returns an lock/unlock image link to toggle secure mode.

=cut

sub vs_toggle_secure {
    my($proto) = @_;
    return $proto->vs_director(['task', 'require_secure'], {
	1 => $proto->vs_image('lock', 'Secure mode (required)'),
	0 => $proto->vs_link(
		$proto->vs_director(['is_secure'], {
		    0 => $proto->vs_image('unlock',
			    'Switch to secure mode (slower)'),
		    1 => $proto->vs_image('lock',
			    'Switch to non-secure mode (faster)'),
		}),
		['->format_http_toggling_secure']),
    });
}

=for html <a name="vs_tour"></a>

=head2 static vs_tour() : Bivio::UI::Widget

Part explaining you should take the tour.  Begins with a C<P>.

=cut

sub vs_tour {
    my($proto) = @_;
    return $proto->vs_join(['<p>',
	    $proto->vs_string('If you have not done so already,'
		    .' we encourage you to '),
	    $proto->vs_link('take the tour', 'TOUR'),
	    $proto->vs_string(" which you'll find on the bivio home page.\n"),
    ]);
}

=for html <a name="vs_whats_this"></a>

=head2 static vs_whats_this(string help_topic) : Bivio::UI::Widget

=head2 static vs_whats_this(string task) : Bivio::UI::Widget

Creates a small "what's this?' link widget which points to the help for
I<task> or I<help_topic>

=cut

sub vs_whats_this {
    return _link_help(@_, 'whats_this');
}

#=PRIVATE METHODS

# _link_help(Bivio::UI::Widget proto, string task, string label) : Bivio::UI::Widget
#
# Returns a help widget
#
sub _link_help {
    my($proto, $task, $label) = @_;
    my($task_id) = Bivio::Agent::TaskId->unsafe_from_name($task);
    my($path_info) = $task_id
	    ? Bivio::Agent::Task->get_by_id($task_id)->get('help')
	    : Bivio::Agent::HTTP::Location->get_help_path_info($task);
    return $proto->vs_link(
	    Bivio::UI::Label->get_simple($label),
	    ['->format_uri', Bivio::Agent::TaskId::HELP(), undef,
		undef, $path_info],
	    'help_hint')
	    ->put(control => $proto->vs_html_value('want_help'));
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
