# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget;
use strict;
$Bivio::UI::HTML::Widget::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget - an HTML display entity

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget;
    Bivio::UI::HTML::Widget->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::ISA = qw(Bivio::UI::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget> is the superclass of all HTML
widgets.

Provides many utility routines to help create widgets.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::HTML;
#NOTE: Do not import any widgets here, use _use().
#      This class uses many other Widgets, but it is the parent class
#      of all Widgets.  We avoid import circularities by using
#      Bivio::IO::ClassLoader->simple_require via _use().  It is also used in
#      facade initialization.
use Bivio::Agent::Request;
use Bivio::Agent::TaskId;
use Bivio::Biz::Model;
use Bivio::UI::Label;
use Bivio::ShellUtil;
use Bivio::UI::HTML::Format::Link;

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::UI::HTML::Widget

Creates the widget.

=cut

sub new {
    return Bivio::UI::Widget::new(@_);
}

=head1 METHODS

=cut

=for html <a name="action_bar"></a>

=head2 static action_bar(string button, ...) : Bivio::UI::HTML::Widget::ActionBar

Returns an action bar for the specified I<button>s.

=cut

sub action_bar {
    my($self) = shift;
    _use('ActionBar', 'Bivio::UI::HTML::ActionButtons');
    return Bivio::UI::HTML::Widget::ActionBar->new({
	values => Bivio::UI::HTML::ActionButtons->get_list(@_)});
}

=for html <a name="action_grid"></a>

=head2 static action_grid(array_ref rows) : Bivio::UI::HTML::Widget::Grid

Creates Grid which is filled with rows created from I<rows>.

A value in I<rows> looks like:

    [
       'label',
       'task',
       $value
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

sub action_grid {
    my($proto, $values) = @_;
    _use('Link', 'Grid');

    my($rows) = [];
    foreach my $v (@$values) {
	my($label, $task, $value, $attrs) = @$v;
	# Label
	$label = $proto->string(
		Bivio::UI::Label->get_simple($label));
	$label = Bivio::UI::HTML::Widget::Link->new({
	    href => ref($task) eq 'ARRAY' ? $task
            : ['->format_uri', Bivio::Agent::TaskId->from_any($task)],
	    value => $label
	}) if $task;
	$label->put(cell_align => 'ne');

	# Value
	$value = $proto->string(
		# Only prefix with Bivio::Biz::Model:: if possible model name.
		[$value->[0] =~ /^[A-Z][a-z0-9A-Z]+$/
		    ? ref(Bivio::Biz::Model->get_instance($value->[0]))
		    : $value->[0],
		    @{$value}[1..$#$value]],
	       ) if ref($value) eq 'ARRAY';
	$value->put(cell_align => 'nw');

	# Attributes: What's This
	if (defined($attrs->{whats_this})) {
	    push(@$rows, [$label, $value,
		$proto->whats_this($attrs->{whats_this})]);
	}
	else {
	    push(@$rows, [$label, $value]);
	}
    }
    return Bivio::UI::HTML::Widget::Grid->new({
#TODO: If you put in this, it screws up the footer.  Don't ask me why...
#	    align => 'left',
	pad => 5,
	values => $rows,
    });
}

=for html <a name="blank_cell"></a>

=head2 static blank_cell() : Bivio::UI::HTML::Widget

Returns a cell which renders a blank.  Makes the code clearer to use.

=cut

sub blank_cell {
    return shift->join('&nbsp;');
}

=for html <a name="button"></a>

=head2 static button() : array

=head2 static button(string name, Bivio::Agent::TaskId task) : array

=head2 static button(string name, Bivio::Agent::TaskId task, any description) : array

=head2 static button(string name, Bivio::Agent::TaskId task, any description, boolean no_label) : array

=head2 static button(array_ref control, Bivio::Agent::TaskId task, any description) : array

=head2 static button(array_ref control, Bivio::Agent::TaskId task, any description, boolean no_label) : array

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

sub button {
    my($proto, $name, $task, $description, $no_label) = @_;

    _use(qw(TaskButton StandardSubmit));
    if ($task) {
	# Create the button for simpler modes
	$task = Bivio::Agent::TaskId->from_any($task);
	my($res) = [
	    $proto->indent(Bivio::UI::HTML::Widget::TaskButton->new({
		value => $task,
		label => ref($name) ? undef : $name,
	    }))];
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
		$proto->description(
			$no_label ? undef : ($name || $task->get_name),
			$description));

	# Have control, create a director
	return $proto->director($control,
		{1 => $proto->join($res),
		    0 => $proto->join('')});
    }
    return $proto->indent(Bivio::UI::HTML::Widget::StandardSubmit->new());
}

=for html <a name="center"></a>

=head2 static center(any value, ....) : array

Create a centered DIV from the contents.

=cut

sub center {
    shift;
    return ("\n<div align=center>\n", @_, "\n</div>\n");
}

=for html <a name="checkmark"></a>

=head2 static checkmark(string field) : Bivio::UI::HTML::Widget

Shows a checkmark for the field.  Looks up $field."_ALT" for
alt text for image.

=cut

sub checkmark {
    my($proto, $field) = @_;
    my($alt) = $field;
    $alt =~ s/\./_/;
    $alt = Bivio::UI::Label->get_simple($alt.'_ALT');
    return $proto->director([$field], {
	0 => '',
	1 => $proto->image('check_on', $alt),
    });
}

=for html <a name="clear_dot"></a>

=head2 clear_dot(any width, any height) : Bivio::UI::HTML::Widget::ClearDot

=head2 clear_dot(any width, any height) : Bivio::UI::HTML::Widget::ClearDot

Returns a ClearDot widget.  I<width> and I<height> may be C<undef>,
a widget value or an integer.

=cut

sub clear_dot {
    my(undef, $width, $height) = @_;
    _use('ClearDot');
    return Bivio::UI::HTML::Widget::ClearDot->new({
	defined($width) ? (width => $width) : (),
	defined($height) ? (height => $height) : (),
    });
}

=for html <a name="clear_dot_as_html"></a>

=head2 clear_dot_as_html(int width, int height) : string

Returns an html string which loads a ClearDot image in
width and height.

Don't use in rendering code.  Use L<clear_dot|"clear_dot"> instead.

=cut

sub clear_dot_as_html {
    my(undef) = shift;
    _use('ClearDot');
    return Bivio::UI::HTML::Widget::ClearDot->as_html(@_);
}

=for html <a name="club_or_fund"></a>

=head2 club_or_fund() : Bivio::UI::HTML::Widget

Returns a widget with the "club" or "fund" terminology.  Uses
HTML's club_or_fund attribute.

=cut

sub club_or_fund {
    return shift->html_string('club_or_fund');
}

=for html <a name="date_time"></a>

=head2 static date_time(any value) : Bivio::UI::HTML::Widget::DateTime

=head2 static date_time(any value, any mode) : Bivio::UI::HTML::Widget::DateTime

Returns a C<Widget::DateTime> for the I<value> and I<mode>.  

If I<value> is undef, uses DateTime-E<gt>now.

=cut

sub date_time {
    my(undef, $value, $mode) = @_;
    _use('DateTime');
    return Bivio::UI::HTML::Widget::DateTime->new({
	value => defined($value) ? $value : [sub {Bivio::Type::DateTime->now}],
	int(@_) >= 3 ? (mode => $mode) : (),
    });
}

=for html <a name="description"></a>

=head2 static description(string label, any body) : array

Returns a descriptive paragraph which begins with I<label> and
is followed by I<body>.  If I<body> is an array_ref, it will
be unwrapped (@$body).

If I<label> is C<undef>, no label will be put on the paragraph.

=cut

sub description {
    my($proto, $label, $body) = @_;
    return ('&nbsp;<br>',
	    defined($label)
	    ? ($proto->string(Bivio::UI::Label->get_simple($label).'.',
		    'description_label'), ' ')
	    : (),
	    ref($body) eq 'ARRAY' ? @$body : $body,
	    '<br>');
}

=for html <a name="director"></a>

=head2 static director(any control, hash_ref values, Bivio::UI::HTML::Widget default_value, Bivio::UI::HTML::Widget undef_value) : Bivio::UI::HTML::Widget

Create a C<Director> widget with I<control>, I<values>,
I<default_value>, and I<undef_value>.  The last three of
which may be C<undef>.

=cut

sub director {
    my($proto, $control, $values, $default_value, $undef_value) = @_;
    _use('Director');
    my($res) = Bivio::UI::HTML::Widget::Director->new({
	control => $control,
	values => $values ? $values : {},
    });
    $res->put(default_value => $default_value) if defined($default_value);
    $res->put(undef_value => $undef_value) if defined($undef_value);
    return $res;
}

=for html <a name="display_widget"></a>

=head2 static display_widget(any model, string property) : Bivio::UI::HTML::Widget

=head2 static display_widget(any model, string property, array_ref widget_value) : Bivio::UI::HTML::Widget

=head2 static display_widget(any model, string property, array_ref widget_value, hash_ref attrs) : Bivio::UI::HTML::Widget

Returns the widget for I<property> of I<model>.  I<model> will be
loaded by
L<Bivio::Biz::Model::get_instance|Bivio::Biz::Model/"get_instance">.

If I<widget_value> is C<undef>, it will be set to

    [ref($model), $property]

I<attrs> is an optional and will be applied to the created widget.

=cut

sub display_widget {
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

=for html <a name="english_a"></a>

=head2 static english_a(array_ref widget_value) : array_ref

Adds C<EnglishSyntax> formatter for 'a'.

=cut

sub english_a {
    my(undef, $widget_value) = @_;
    _use('Bivio::UI::HTML::Format::EnglishSyntax');
    push(@$widget_value, 'Bivio::UI::HTML::Format::EnglishSyntax', 'a');
    return $widget_value;
}

=for html <a name="english_list"></a>

=head2 static english_list(string connective, array words) : string

Concatenates the list words into an English conjunction ('and') or
disjunction ('or').

=cut

sub english_list {
    my(undef, $connective, @words) = @_;

    # One
    return $words[0] if int(@words) == 1;

    # One and two
    return $words[0].' '.$connective.' '.$words[1] if int(@words) == 2;

    # One, two, and three
    my($last) = pop(@words);
    return join(', ', @words, $connective.' '.$last);
}

=for html <a name="form"></a>

=head2 static form(string form_class) : Bivio::UI::HTML::DescriptivePageForm

=head2 static form(string form_class, array_ref values, array_ref list_values) : Bivio::UI::HTML::DescriptivePageForm

=head2 static form(string form_class, array_ref values, hash_ref attrs) : Bivio::UI::HTML::DescriptivePageForm

=head2 static form(string form_class, array_ref values, array_ref list_values, hash_ref attrs) : Bivio::UI::HTML::DescriptivePageForm

Returns a new C<DescriptivePageForm>.  If I<values> are passed,
the fields will be created with C<$form-E<gt>create_fields>.
If I<attrs> is passed, will be set on C<DescriptivePageForm::new>.

I<list_values> are passed to C<$form-E<gt>create_list_fields>.

=cut

sub form {
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

=for html <a name="form_button"></a>

=head2 static form_button(string field) : Bivio::UI::HTML::Widget::FormButtonn

=head2 static form_button(string field, string label) : Bivio::UI::HTML::Widget::FormButton

Creates a form button widget for the specified, fully qualified field name.
The button label may be overridden by supplying the Bivio::UI::Label value.

=cut

sub form_button {
    return shift->simple_form_field(@_);
}

=for html <a name="format_uri_static_site"></a>

=head2 static format_uri_static_site(Bivio::Agent::Request req, string page) : string

Returns a uri formatted for the static site.

=cut

sub format_uri_static_site {
    my(undef, $req, $page) = @_;
    return $req->format_uri(Bivio::Agent::TaskId::HTTP_DOCUMENT(),
	    undef,
	    '',
	    Bivio::Agent::HTTP::Location->get_document_path_info($page),
	    1),
}

=for html <a name="get_label"></a>

=head2 static get_label(string name, ....) : string

Looks up label with
L<Bivio::UI::Label::get_simple|Bivio::UI::Label/"get_simple">.

=cut

sub get_label {
    shift;
    return Bivio::UI::Label->get_simple(@_);
}

=for html <a name="heading"></a>

=head2 static heading(any heading) : Bivio::UI::HTML::Widget::Join

Return parts that make a heading (in page_heading font).

=cut

sub heading {
    my($proto, $heading) = @_;
    # HotJava Bug: Replace the nbsp<br> with a <p> and hotjava renders
    # infinitely.
    return $proto->join([$proto->string($heading, 'page_heading'), '<br>']);
}

=for html <a name="heading_as_label"></a>

=head2 static heading_as_label() : Bivio::UI::HTML::Widget::Join

=head2 static heading_as_label(string label) : Bivio::UI::HTML::Widget::Join

Returns a page heading for I<label>.  If there is no label,
will use the task_id (dynamically).

=cut

sub heading_as_label {
    my($proto, $label) = @_;
    return $proto->heading(
	    defined($label) ? Bivio::UI::Label->get_simple($label)
	    : [sub {Bivio::UI::Label->get_simple(shift->get('task_id')
		    ->get_name)}]);
}

=for html <a name="heading_with_search"></a>

=head2 static heading_with_search(string label) : Bivio::UI::HTML::Widget

=head2 static heading_with_search(Bivio::UI::HTML::Widget widget) : Bivio::UI::HTML::Widget

Returns a widget which renders I<label> in page_heading font or
I<widget> on left
with a search box to the right.

=cut

sub heading_with_search {
    my($proto, $widget) = @_;
    return $proto->load_and_new('Grid', {
        expand => 1,
        values => [[
            ref($widget) ? $widget : $proto->label($widget, 'page_heading'),
	    $proto->load_and_new('Search', {
		size => 20,
		cell_align => 'SE',
		cell_end_form => 1,
	    }),
        ]],
    });
    return;
}

=for html <a name="highlight"></a>

=head2 static highlight(any value) : Bivio::UI::HTML::Widget::String

Returns a string widget for I<value> whose font is highlighted
(strong for now).

If already a string widget, will simply change the font.

=cut

sub highlight {
    my($proto, $value) = @_;
    _use('String');
    $value = $proto->string($value)
	    unless ref($value) eq 'Bivio::UI::HTML::Widget::String';
    $value->put(string_font => 'strong');
    return $value;
}

=for html <a name="href_goto"></a>

=head2 href_goto(any uri) : array_ref

Widget value to create a goto link href for "offsite" links.
I<uri> may be a string or an array_ref (widget value).

=cut

sub href_goto {
    my(undef, $uri) = @_;
    Bivio::Die->die($uri, ": must be an absolute uri")
		unless $uri =~ m!^\w+://!;
    return ref($uri) ? [$uri, 'Bivio::UI::HTML::Format::Link']
	    : ['Bivio::UI::HTML::Format::Link', $uri];
}

=for html <a name="html_string"></a>

=head2 html_string(string attr) : Bivio::UI::HTML::Widget

Returns a widget which renders L<html_value|"html_value"> as a string
(no font).

=cut

sub html_string {
    my($proto, $attr) = @_;
    # Parent widget will wrap font in a font.
    return $proto->string($proto->html_value($attr), 0);
}

=for html <a name="html_value"></a>

=head2 static html_value(string attr) : array_ref

Returns a call to L<Bivio::UI::HTML::get_value|Bivio::UI::HTML/"get_value">
as an array ref.

=cut

sub html_value {
    my($proto, $attr) = @_;
    return [['->get_request'], 'Bivio::UI::HTML', '->get_value', $attr];
}

=for html <a name="image"></a>

=head2 static image(any icon) : Bivio::UI::HTML::Widget::Image

=head2 static image(any icon, any alt, hash_ref attrs) : Bivio::UI::HTML::Widget::Image

Returns an Image widget configured with I<icon> and I<alt>.

If I<alt> is not defined and I<icon> is not a ref, will lookup
in the label table as I<icon>_ALT.

I<attrs> are applied to the Image Widget.

=cut

sub image {
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

=for html <a name="indent"></a>

=head2 static indent(any value, ...) : array

Create an indented paragraph from the contents.

=cut

sub indent {
    shift;
    return ("\n<blockquote>\n", @_, "\n</blockquote>\n");
}

=for html <a name="indirect"></a>

=head2 indirect(any value) : Bivio::UI::HTML::Widget::Indirect



=cut

sub indirect {
    my(undef, $value) = @_;
    _use('Indirect');
    return Bivio::UI::HTML::Widget::Indirect->new({
	value => $value,
    });
}

=for html <a name="join"></a>

=head2 static join(array_ref values) : Bivio::UI::HTML::Widget::Join

=head2 static join(any value, ...) : Bivio::UI::HTML::Widget::Join

Returns a join widget wrapping values.

=cut

sub join {
    my(undef, @values) = @_;
    _use('Join');
    my($values) = int(@values) == 1 && ref($values[0]) eq 'ARRAY'
	    ? $values[0] : [@values];
    return Bivio::UI::HTML::Widget::Join->new({values => $values});
}

=for html <a name="label"></a>

=head2 static label(string label, string font) : Bivio::UI::HTML::Widget::String

=head2 static label(array_ref label, string font) : Bivio::UI::HTML::Widget::String

Looks up I<label>--dereferencing the array_ref if necessary.  Uses
C<label_in_text> if I<font> is not supplied.  Does not set I<string_font> if
I<font> is C<undef>.

=cut

sub label {
    my($proto, $label, $font) = @_;
    return $proto->string(Bivio::UI::Label->get_simple(
	    ref($label) ? @$label : $label),
	    defined($font) ? $font : 'label_in_text');
}

=for html <a name="learn_more"></a>

=head2 static learn_more(string help_topic) : Bivio::UI::HTML::Widget

=head2 static learn_more(string task) : Bivio::UI::HTML::Widget

Creates a small "what's this?' link widget which points to the help for
I<task> or I<help_topic>

=cut

sub learn_more {
    return _link_help(@_, 'learn_more');
}

=for html <a name="link"></a>

=head2 static link(string task) : Bivio::UI::HTML::Widget::Link

=head2 static link(any label, string task) : Bivio::UI::HTML::Widget::Link

=head2 static link(any label, string task, string font) : Bivio::UI::HTML::Widget::Link

=head2 static link(any label, array_ref widget_value) : Bivio::UI::HTML::Widget::Link

=head2 static link(any label, Bivio::UI::HTML::Widget widget) : Bivio::UI::HTML::Widget::Link

=head2 static link(any label, string abs_uri) : Bivio::UI::HTML::Widget::Link

If only I<task> is supplied, it is used for both the label and the href.
It will also be the control for the link.  This is the preferred way
to create links.

Returns a C<Link> with I<label> and I<widget_value>

If I<label> is not a widget, will wrap in a C<String> widget.

If I<task> is passed, will create a widget value by formatting
as a stateless uri for the TaskId named by I<task>.

If I<abs_uri> is passed, it must contain a / or : or #.

=cut

sub link {
    my($proto, $label, $widget_value, $font) = @_;
    _use('Link');
    my($control);
    if (int(@_) <= 2) {
	$control = $label;
	$widget_value = $label;
	$label = Bivio::UI::Label->get_simple($widget_value);
    }
    $label = $proto->string($label, defined($font) ? ($font) : ())
	    unless UNIVERSAL::isa($label, 'Bivio::UI::HTML::Widget');
    $widget_value = [['->get_request'], '->format_stateless_uri',
	Bivio::Agent::TaskId->$widget_value()]
	    # Use widget value or abs_uri (literal)
	    unless ref($widget_value) || $widget_value =~ m![/:#]!;
    return Bivio::UI::HTML::Widget::Link->new({
	href => $widget_value,
	value => $label,
	$control ? (control => $control) : (),
    });
}

=for html <a name="link_amazon"></a>

=head2 static link_amazon(string asin, any value) : Bivio::UI::HTML::Widget::Link

Returns a link to an amazon book.

=cut

sub link_amazon {
    my($self, $asin, $value) = @_;
    _use('Link');
    return Bivio::UI::HTML::Widget::Link->new({
	href => 'http://www.amazon.com/exec/obidos/ASIN/'.$asin
	.'/bivioalllower/',
	value => $value,
    });
}

=for html <a name="link_ask_candis"></a>

=head2 static link_ask_candis() : Bivio::UI::HTML::Widget::Link

Returns a link to Trez Talk.

=cut

sub link_ask_candis {
    return shift->link('Ask Candis', '/ask_candis');
}

=for html <a name="link_goto"></a>

=head2 link_goto(string label, string uri) : Bivio::UI::HTML::Widget::Link

Create a "goto" link, which allows us to track references to other
sites.

=cut

sub link_goto {
    my($proto, $label, $uri, $font) = @_;
    return $proto->link($label, $proto->href_goto($uri), $font);
}

=for html <a name="link_help"></a>

=head2 static link_help(string label) : string

=head2 static link_help(string label, any task) : string

=head2 static link_help(string label, any task, string font) : string

Returns the URL to the help topic for the specified task.
See
L<Bivio::Agent::Request::format_help_uri|Bivio::Agent::Request/"format_help_uri">
for a description of I<task>'s values.

=cut

sub link_help {
    my($proto, $label, $task, $font) = @_;
    Bivio::Die->die($label, ": label must be a string")
	if !defined($label) || ref($label);

    return $proto->link($label, ['->format_help_uri', $task], $font)
	    ->put(control => $proto->html_value('want_help'));
}

=for html <a name="link_secure"></a>

=head2 static link_secure() : Bivio::UI::HTML::Widget::Director

Show a paragraph (with leading <p>) describing secure mode if not
in secure mode.

=cut

sub link_secure {
    my($self) = @_;
    return $self->director([sub {
	    my($req) = shift->get_request;
	    return Bivio::UI::HTML->get_value('want_secure', $req)
		    ? ($req->get('is_secure') ? 1 : 0) : 2;
	}], {
	0 => $self->join(
		"\n<p>&#149; ",
		$self->link('Click here to switch to secure mode.',
			['->format_http_toggling_secure']),
		" &#149;\n"),
	1 => $self->join("\n<p>&#149; This page is secure. &#149;\n"),
	# When the facade doesn't support SSL
	2 => $self->join("\n"),
    });
}

=for html <a name="link_static_site"></a>

=head2 static link_static_site(any label, string page, string font) : Bivio::UI::HTML::Widget

Returns a link to the static site I<page>.  It will append C<.html> and prefix
with a '/', but must include directory, e.g. "hm/services.html".

=cut

sub link_static_site {
    my($proto, $label, $page, $font) = @_;
    return $proto->link($label, $proto->format_uri_static_site(
	    Bivio::Agent::Request->get_current, $page),
	    $font);
}

=for html <a name="link_support"></a>

=head2 static link_support() : string

Returns URL to support.

=cut

sub link_support {
    my($proto) = @_;
    return $proto->link(['support_email'], 'MAIL_SUPPORT');
}

=for html <a name="link_target_as_html"></a>

=head2 link_target_as_html() : string

Looks up the attribute I<link_target> ancestrally and renders
it as ' target="XXX"' (with leading space) whatever its value is.

Default is '_top', because we don't use frames.

=cut

sub link_target_as_html {
    my($self) = @_;
    my($t) = $self->ancestral_get('link_target', '_top');
    return defined($t) ? (' target="'.Bivio::HTML->escape($t).'"') : '';
}

=for html <a name="link_tm"></a>

=head2 static link_tm(any label, string task) : Bivio::UI::HTML::Widget::Link

=head2 static link_tm(any label, string task, string font) : Bivio::UI::HTML::Widget::Link

=head2 static link_tm(any label, array_ref widget_value) : Bivio::UI::HTML::Widget::Link

=head2 static link_tm(any label, string abs_uri) : Bivio::UI::HTML::Widget::Link

Generates a L<link|"link"> with a trademark symbol at the end.

=cut

sub link_tm {
    my($proto, $label, $arg, $font) = @_;
    Bivio::Die->die($label, ": label must be a string")
	if !defined($label) || ref($label);

    # Must be in a join, because we are pre-escaping the string
    return $proto->link($proto->string(
	    Bivio::HTML->escape($label).'&#153;',
	    defined($font) ? ($font) : (),
	   )->put(escape_html => 0),
	    $arg);
}

=for html <a name="link_trez_talk"></a>

=head2 static link_trez_talk() : Bivio::UI::HTML::Widget::Link

Returns a link to Trez Talk.

=cut

sub link_trez_talk {
    return shift->link('Trez Talk', '/trez_talk');
}

=for html <a name="list_actions"></a>

=head2 static list_actions(array_ref actions) : hash_ref

Returns a L<table|"table"> column value which is a
L<Bivio::UI::HTML::Widget::ListActions|Bivio::UI::HTML::Widget::ListActions>.

=cut

sub list_actions {
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

=for html <a name="load_and_new"></a>

=head2 static load_and_new(string class, hash_ref attrs) : Bivio::UI::HTML::Widget

Returns an instance of I<class> created with I<attrs>.  Loads I<class>, if not
already loaded.

=cut

sub load_and_new {
    my(undef, $class, $attrs) = @_;
    my($c) = _use($class);
    return $c->new($attrs);
}

=for html <a name="load_class"></a>

=head2 load_class(string widget, ...)

Loads a widget class dynamically.  Can be used by modules which
want to avoid static imports.

Widgets can be referred to by their base class name, e.g.
C<load_class('Grid')> loads C<Bivio::UI::HTML::Widget::Grid>.

=cut

sub load_class {
    shift;
    _use(@_);
    return;
}

=for html <a name="mailto"></a>

=head2 static static mailto(any email) : Bivio::UI::HTML::Widget::MailTo

=head2 static static mailto(any email, any value) : Bivio::UI::HTML::Widget::MailTo

=head2 static static mailto(any email, any value, any subject) : Bivio::UI::HTML::Widget::MailTo

Returns a C<Widget::MailTo> for email.

=cut

sub mailto {
    my(undef, $email, $value, $subject) = @_;
    _use('MailTo');
    my($x) = Bivio::UI::HTML::Widget::MailTo->new({
	email => $email,
	defined($value) ? (value => $value) : (),
	defined($subject) ? (subject => $subject) : (),
    });
    return $x;
}

=for html <a name="noop"></a>

=head2 noop() : Bivio::UI::HTML::Widget

Returns an empty join widget.

=cut

sub noop {
    return shift->join('');
}

=for html <a name="page_heading_banner_ad"></a>

=head2 page_heading_banner_ad() : Bivio::UI::HTML::Widget

Returns a banner ad widget which fits in the page heading area.

=cut

sub page_heading_banner_ad {
    my($proto) = @_;
    return $proto->link_static_site(
	    $proto->image('promote_stop_small'), 'hm/account-sync')
	    ->put(control => $proto->html_value('want_ads'));
}

=for html <a name="page_text"></a>

=head2 static page_text(array_ref values) : Bivio::UI::HTML::Widget::String

Returns a String widget with I<string_font> C<page_text> and
the html is NOT escaped.  Used for long strings which contain
html.  I<value> will be enclosed in a join if it contains more
than one element.

=cut

sub page_text {
    my($proto, $value) = @_;
    die('value must be an array_ref') unless ref($value) eq 'ARRAY';
    return $proto->string(
	    int(@$value) == 1 ? $value->[0] : $proto->join($value),
	    'page_text')
	    ->put(escape_html => 0);
}

=for html <a name="realm_name"></a>

=head2 static realm_name() : array

=head2 static realm_name(array_ref widget_value) : array

Returns the realm_name widget.  Defaults to

    ['auth_realm', 'owner', 'display_name']

if I<widget_value> not supplied.

=cut

sub realm_name {
    my($proto, $widget_value) = @_;
    $widget_value = ['auth_realm', 'owner', 'display_name']
	    unless $widget_value;
    return $proto->indent($proto->string($widget_value, 'realm_name'));
}

=for html <a name="secure_data"></a>

=head2 static secure_data(Bivio::UI::HTML::Widget widget) : Bivio::UI::HTML::Widget

Wraps I<widget> in a
L<Bivio::UI::HTML::Widget::SecureData|Bivio::UI::HTML::Widget::SecureData>
widget.

=cut

sub secure_data {
    my($proto, $widget) = @_;
    return $proto->load_and_new('SecureData', {value => $widget});
}

=for html <a name="simple_form"></a>

=head2 simple_form(string class, any widget) : Bivio::UI::HTML::Widget::Form

=head2 simple_form(Bivio::Biz::FormModel class, any widget) : Bivio::UI::HTML::Widget::Form

Creates a form which renders I<widget>.  Use L<form|"form"> to create a
L<Bivio::UI::HTML::DescriptivePageForm|Bivio::UI::HTML::DescriptivePageForm>.
I<class>

=cut

sub simple_form {
    my(undef, $class, $widget) = @_;
    _use('Form');
    return Bivio::UI::HTML::Widget::Form->new({
        form_class => ref(Bivio::Biz::Model->get_instance($class)),
        value => $widget,
    });
}

=for html <a name="simple_form_field"></a>

=head2 static simple_form_field(string field) : Bivio::UI::HTML::Widget::FormButtonn

=head2 static simple_form_field(string field, string label) : Bivio::UI::HTML::Widget::FormButton

Creates a form button widget for the specified, fully qualified field name.
The label (if any) may be overridden by supplying the Bivio::UI::Label value.

=cut

sub simple_form_field {
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

=for html <a name="site_name"></a>

=head2 static site_name() : string

Returns a widget containing the site name.

=cut

sub site_name {
    return shift->html_string('site_name');
}

=for html <a name="string"></a>

=head2 static string(any value) : Bivio::UI::Widget::String

=head2 static string(any value, string font) : Bivio::UI::Widget::String

Returns a string widget for I<value> and I<font> if supplied.
Use C<0> (zero) to set "no font".  Will not set font, if C<undef>.

=cut

sub string {
    my($self, $value, $font) = @_;
    _use('String');
    return Bivio::UI::HTML::Widget::String->new({
	value => $value,
	# Allow caller to set font to undef
	defined($font) ? (string_font => $font) : (),
    });
}

=for html <a name="table"></a>

=head2 static table(string list_class, array_ref columns, hash_ref attrs) : Bivio::UI::HTML::Widget::Table

Wrapper for
L<Bivio::UI::HTML::Widget::Table|Bivio::UI::HTML::Widget::Table>.

I<attrs> are the global attributes sans I<list_class> and I<columns>.
I<attrs> may be C<undef> or an empty hash_ref.

=cut

sub table {
    my($proto, $list_class, $columns, $attrs) = @_;
    _use('Table');
    $attrs ||= {};
    $attrs->{list_class} = $list_class;
    $attrs->{columns} = $columns;
    return Bivio::UI::HTML::Widget::Table->new($attrs);
}

=for html <a name="task_list"></a>

=head2 static task_list(any heading, array_ref values) : Bivio::UI::HTML::Widget::TaskList

=head2 static task_list(any heading, array_ref values, boolean want_sort) : Bivio::UI::HTML::Widget::TaskList

Wrapper for
L<Bivio::UI::HTML::Widget::TaskList|Bivio::UI::HTML::Widget::TaskList>.

I<want_sort> is false by default.

=cut

sub task_list {
    my($self, $heading, $values, $want_sort) = @_;
    _use('TaskList');
    return Bivio::UI::HTML::Widget::TaskList->new({
	heading => $heading,
	values => $values,
	want_sort => $want_sort,
    });
}

=for html <a name="template"></a>

=head2 static template(string value) : Bivio::UI::HTML::Widget

=head2 static template(string_ref value) : Bivio::UI::HTML::Widget

Returns an instance of a Template widget configured with I<value>.

=cut

sub template {
    my($proto, $value, $font) = @_;
    die('font is deprecated usage') if defined($font);
    return $proto->load_and_new('Template', {value => $value});
}

=for html <a name="template_as_string"></a>

=head2 static template_as_string(string value, string font) : Bivio::UI::HTML::Widget

=head2 static template_as_string(string_ref value, string font) : Bivio::UI::HTML::Widget

Wraps a L<template|"template"> in a string.

If I<font> not supplied, defaults to I<page_text>.

=cut

sub template_as_string {
    my($proto, $value, $font) = @_;
    return $proto->string($proto->template($value),
	    defined($font) ? $font : 'page_text');
}

=for html <a name="toggle_secure"></a>

=head2 toggle_secure() : Bivio::UI::HTML::Widget::ToggleSecureModeButton

Returns an lock/unlock image link to toggle secure mode.

=cut

sub toggle_secure {
    my($proto) = @_;
    return $proto->director(['task', 'require_secure'], {
	1 => $proto->image('lock', 'Secure mode (required)'),
	0 => $proto->link(
		$proto->director(['is_secure'], {
		    0 => $proto->image('unlock',
			    'Switch to secure mode (slower)'),
		    1 => $proto->image('lock',
			    'Switch to non-secure mode (faster)'),
		}),
		['->format_http_toggling_secure']),
    });
}

=for html <a name="tour"></a>

=head2 static tour() : array

Part explaining you should take the tour.  Begins with a C<P>.

=cut

sub tour {
    my($proto) = @_;
    return (<<'EOF',
<p>
If you have not done so already, we encourage you to
EOF
	    $proto->link('take the tour', 'TOUR'),
	    " which you'll find on the bivio home page.<br>\n",
    );
}

=for html <a name="whats_this"></a>

=head2 static whats_this(string help_topic) : Bivio::UI::HTML::Widget

=head2 static whats_this(string task) : Bivio::UI::HTML::Widget

Creates a small "what's this?' link widget which points to the help for
I<task> or I<help_topic>

=cut

sub whats_this {
    return _link_help(@_, 'whats_this');
}

#=PRIVATE METHODS

# _link_help(Bivio::UI::HTML::Widget proto, string task, string label) : Bivio::UI::HTML::Widget
#
# Returns a help widget
#
sub _link_help {
    my($proto, $task, $label) = @_;
    my($task_id) = Bivio::Agent::TaskId->unsafe_from_name($task);
    my($path_info) = $task_id
	    ? Bivio::Agent::Task->get_by_id($task_id)->get('help')
	    : Bivio::Agent::HTTP::Location->get_help_path_info($task);
    return $proto->link(
	    Bivio::UI::Label->get_simple($label),
	    ['->format_uri', Bivio::Agent::TaskId::HELP(), undef,
		undef, $path_info],
	    'help_hint')
	    ->put(control => $proto->html_value('want_help'));
}

# _use(string class, ....) : array
#
# Executes Bivio::IO::ClassLoader->simple_require on its args.  Inserts
# Bivio::UI::HTML::Widget:: prefix, if class does not contain
# colons.  Returns the named classes.
#
sub _use {
    my(@class) = @_;
    foreach my $c (@class) {
	$c =~ s/^([^:]+)$/Bivio::UI::HTML::Widget::$1/;
    }
    Bivio::IO::ClassLoader->simple_require(@class);
    return @class;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
