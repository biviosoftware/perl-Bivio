# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::ViewShortcuts;
use strict;
use base 'Bivio::UI::ViewShortcuts';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WF) = __PACKAGE__->use('Bivio::UI::HTML::WidgetFactory');
my($_V6) = __PACKAGE__->use('IO.Config')->if_version(6);
my($_LINK_TARGET) = $_V6 ? undef : '_top';
my($_ATTRS) = {};
our($_TRACE);
my($_AA) = __PACKAGE__->use('Action.Acknowledgement');

sub BOP_HTML_CLASSES {
    return [qw(
acknowledgement
actions
all want_sep
alphabetical_chooser
amount_cell
ascend
attachment
author
blog
body
bottom
bottom_left
bottom_right
byline
checkbox
checkbox_label
date
desc
descend
empty_list
err_title
even
excerpt
field
field_err
footer
footer_left
footer_middle
footer_right
form_prose
forward
go
header
header_left
header_middle
header_right
heading
help_wiki_add
inline
label
label_err
label_ok
list
list_actions
logo
logo_su
main
main_body
main_bottom
main_left
main_middle
main_right
main_top
menu
msg
msg_compose
msg_sep
nav
next
not_found
num
odd
off
on
paged_list
pager
part
parts
prev
prose
realm
required
rounded_box
rounded_box_body
search
selected
selector
sep
user_settings
simple
standard_submit
su
submit
task_menu
text
text_html
text_plain
textarea
title
tools
top
top_left
top_right
topic
tuple
user_state
value
want_sep
    )];
}

sub vs_acknowledgement {
    # (proto) : UI.Widget
    # (proto, boolean) : UI.Widget
    # Display acknowledgement, if it exists or can be extracted.  Sets row_control on
    # the widget.  Dies if die_if_not_found is specified and the acknowledgement is
    # missing (does not extract_label in this case).
    my($proto, $die_if_not_found) = @_;
    return $proto->vs_call('Tag', 'p',
        [sub {
             my($req) = shift->get_request;
             return __PACKAGE__->vs_call('String',
                 __PACKAGE__->vs_call('Prose',
                     Bivio::UI::Text->get_value('acknowledgement',
                         $req->get_nested('Action.Acknowledgement', 'label'),
                         $req)),
             );
         }],
	'acknowledgement',
        $die_if_not_found ? ()
        : {
            row_control => [sub {$_AA->extract_label(shift->req)}],
        });
}

sub vs_alphabetical_chooser {
    # (proto, string) : UI.Widget
    # Generates a list of links which are alphabetically ordered and pass their
    # "letter" on to the ListQuery.search.
    my($proto, $list_model) = @_;
    my($all) = Bivio::Biz::Model->get_instance($list_model)
	->LOAD_ALL_SEARCH_STRING;
    return $proto->vs_call('String',
	$proto->vs_call('Join', [
	    map({(
		$_ =~ /^A/ ? $_ eq $all ? ' | ' : '' : ' ',
		$proto->vs_call('Link',
		    $proto->vs_call('Join', [$_]),
		    ['->format_uri', undef,
			[sub {
			     return {
				 'ListQuery.search' => $_[1],
				 'ListQuery.date' => $_[0]->get($_[2])
				     ->get_query->get('date'),
			     };
			 },
			 $_,
			 "Model.$list_model",
			],
		    ],
		),
	    )} 'A'..'Z', $all),
	]),
    );
}

sub vs_blank_cell {
    # (proto) : UI.Widget
    # (proto, int) : UI.Widget
    # Returns a cell which renders a blank.  Makes the code clearer to use.
    my($proto, $count) = @_;
    return $proto->vs_join('&nbsp;' x ($count || 1));
}

sub vs_center {
    # (proto, any, ....) : UI.Widget
    # Create a centered DIV from the contents.
    return shift->vs_join(["\n<div align=center>\n", @_, "\n</div>\n"]);
}

sub vs_clear_dot {
    # (self, any, any) : Widget.ClearDot
    # (self, any, any) : Widget.ClearDot
    # B<DEPRECATED.  Use L<vs_new|"vs_new">>.
    my($proto, $width, $height) = @_;
    return $proto->vs_new('ClearDot', {
	defined($width) ? (width => $width) : (),
	defined($height) ? (height => $height) : (),
    });
}

sub vs_clear_dot_as_html {
    # (self, int, int) : string
    # Returns an html string which loads a ClearDot image in
    # width and height.
    #
    # Don't use in rendering code.  Use L<vs_clear_dot|"vs_clear_dot"> instead.
    my(undef) = shift;
    my($c) = _use('ClearDot');
    return $c->as_html(@_);
}

sub vs_correct_table_layout_bug {
    # (self) : UI.Widget
    # Returns a widget which renders a table layout correction javascript if
    # necessary.
    my($proto) = @_;
    return $proto->vs_call('If',
        [['->get_request'], 'Type.UserAgent', '->has_table_layout_bug'],
        $proto->vs_call('Script', 'correct_table_layout_bug'));
}

sub vs_descriptive_field {
    # (proto, any) : array_ref
    # Calls vs_form_field and adds I<description> to the result.  I<description>
    # is an optional string, widget value, or widget.  It is always wrapped
    # in a String with font form_field_description.
    my($proto, $field) = @_;
    my($name, $attrs) = ref($field) ? @$field : $field;
    my($label, $input) = $proto->vs_form_field($name, $attrs);
    return [
	$label->put(cell_class => 'form_field_label'),
	$proto->vs_call('Join', [
	    $input,
	    [sub {
		 my($req) = shift->get_request;
		 my($proto, $name) = @_;
#TODO: Need to create a separate space for field_descriptions so we don't
#      default to something that we don't expect.
		 my($v) = $req->get_nested('Bivio::UI::Facade', 'Text')
		     ->unsafe_get_value($name, 'field_description');
		 return $v ?
		     $proto->vs_call(
			 'String',
			 $proto->vs_call('Prose', '<br><p class="form_field_description">' . $v . '</p>'),
			 'form_field_description',
		     ) :  '';
	    }, $proto, $name],
	], {
	    cell_class => 'form_field_input',
        }),
    ];
}

sub vs_director {
    # (proto, any, hash_ref, UI.Widget, UI.Widget) : UI.Widget
    # B<DEPRECATED.  Use L<vs_new|"vs_new">>.
    my($proto) = shift;
    return $proto->vs_new('Director', @_);
}

sub vs_display {
    return _wf(@_);
}

sub vs_edit {
    return _wf(@_);
}

sub vs_escape_html {
    # (self, array_ref) : array_ref
    # Wraps I<value> in L<Bivio::HTML::escape|Bivio::HTML/"escape">,
    my(undef, $value) = @_;
    return [\&_escape, $value];
}

sub vs_fe {
    # (proto, string) : string
    # Calls SUPER and escapes.
    return Bivio::HTML->escape(shift->SUPER::vs_fe(@_));
}

sub vs_first_focus {
    # (proto, any) : UI.Widget
    # Returns script widget that focuses on the first field on the page.
    # I<control> is optional.
    my($proto, $control) = @_;
    my($w) = $proto->vs_call('Script', 'first_focus');
    return defined($control) ? $proto->vs_call('If', $control, $w) : $w;
}

sub vs_form_field {
    # (proto, string) : array
    # Creates a new I<HTMLWidget.FormField> and returns the widgets (label, field).
    # This is equivalent to:
    #
    #    vs_new('FormField', @_)->get_label_and_field
    my($proto) = shift;
    return $proto->vs_new('FormField', @_)->get_label_and_field;
}

sub vs_html_attrs_initialize {
    my($proto, $widget, $attrs, $source) = @_;
    $widget->map_invoke(
	'unsafe_initialize_attr',
	$attrs || $proto->vs_html_attrs_merge,
        undef,
        [$source],
    );
    return;
}

sub vs_html_attrs_merge {
    my(undef, $extra) = @_;
    return [qw(class id), @{$extra || []}];
}

sub vs_html_attrs_render {
    my($proto, $widget, $source, $attrs) = @_;
    return join(
	'',
	map($proto->vs_html_attrs_render_one($widget, $source, $_),
	    @{$attrs || $proto->vs_html_attrs_merge}),
    );
    return;
}

sub vs_html_attrs_render_one {
    my($proto, $widget, $source, $attr) = @_;
    return ''
	unless length(my $v = $widget->render_simple_attr($attr, $source));
    my($k) = lc(($attr =~ /([^_]+)$/)[0]);
    if ($k =~ /^(?:class|id)$/) {
	_trace($k, '=', $v) if $_TRACE && !$_ATTRS->{$k}->{$v}++;
	$v =~ s/^b_//
	    unless $_V6;
    }
    return ' '
	# The '_' handles row_class => class
	. lc(($attr =~ /([^_]+)$/)[0])
	. '="'
	. Bivio::HTML->escape_attr_value($v)
	. '"';
}

sub vs_image {
    # (proto, any) : Widget.Image
    # (proto, any, any, hash_ref) : Widget.Image
    # B<DEPRECATED.  Use L<vs_new|"vs_new">>.
    my($proto, $icon, $alt, $attrs) = @_;
    _use('Image');
    return Bivio::UI::HTML::Widget::Image->new({
	src => $icon,
	(defined($alt) || ref($icon) ? (alt => $alt) : (alt_text => $icon)),
	$attrs ? %$attrs : (),
    });
}

sub vs_join {
    # (proto, any, ...) : Widget.Join
    # B<DEPRECATED.  Use L<vs_new|"vs_new">>.
    my($proto, @values) = @_;
    my($values) = int(@values) == 1 && ref($values[0]) eq 'ARRAY'
	    ? $values[0] : [@values];
    return $proto->vs_new('Join', $values);
}

sub vs_link {
    # (proto, string) : Widget.Link
    # (proto, any, string) : Widget.Link
    # (proto, any, string, string) : Widget.Link
    # (proto, any, array_ref) : Widget.Link
    # (proto, any, UI.Widget) : Widget.Link
    # (proto, any, string) : Widget.Link
    # If only I<task> is supplied, it is used for both the label and the href.
    # It will also be the control for the link.  This is the preferred way
    # to create links.
    #
    # Returns a C<Link> with I<label> and I<widget_value>
    #
    # If I<label> is not a widget, will wrap in a C<String> widget.
    #
    # If I<task> is passed, will create a widget value by formatting
    # as a stateless uri for the TaskId named by I<task>.
    #
    # If I<abs_uri> is passed, it must contain a / or : or #.
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

sub vs_link_target_as_html {
    my($proto, $widget, $source) = @_;
    return ''
	unless defined(my $t = $widget->ancestral_get(
	    'link_target', $_LINK_TARGET));
    if ($source) {
	my($b);
	$widget->unsafe_render_value('link_target', $t, $source, \$b);
	$t = $b;
    }
    return defined($t) && length($t)
	? ' target="' . Bivio::HTML->escape($t) . '"' : '';
}

sub vs_mailto_for_user_id {
    my($proto, $user_id) = @_;
    return $proto->vs_call('MailTo',
	map([sub {
	    my($source, $user_id, $model, $field) = @_;
	    return $source->use('Model.' . $model)->new($source->req)
		->unauth_load_or_die({
		    realm_id => $user_id,
		})->get($field);
	}, $user_id, split('\.', $_)],
	    qw(Email.email RealmOwner.display_name)));
}

sub vs_new {
    # (proto, string, any, ...) : UI.Widget
    # Returns an instance of I<class> created with I<new_args>.  Loads I<class>, if
    # not already loaded.
    my($proto, $class) = (shift, shift);
    return UNIVERSAL::can('Bivio::UI::ViewLanguage', 'view_ok')
	&& Bivio::UI::ViewLanguage->view_ok
	? $proto->vs_call($class, @_) : (_use($class))[0]->new(@_);
}

sub vs_simple_form {
    # (proto, string, array_ref) : UI.Widget
    # Creates a Form in a Grid.  I<rows> may be a field name, a separator name
    # (preceded by a dash), a widget (iwc colspan will be set to 2), or a list of
    # button names separated by spaces (preceded by a '*').  If there is no '*'
    # list, then StandardSubmit will be appended to the list of fields.
    my($proto, $form, $rows, $attr) = @_;
    $attr ||= {};
    $attr->{pad} = 2;
    my($have_submit) = 0;
    return $proto->vs_call('Form', $form,
	$proto->vs_call('Grid', [
	    map({
		my($x);
		if (UNIVERSAL::isa($_, 'Bivio::UI::Widget')) {
		    $_->get_if_exists_else_put(cell_align => 'left'),
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
		elsif ($_ =~ s/^\*//) {
		    $have_submit = 1;
		    $x = [$proto->vs_call(
			'StandardSubmit',
			{
			    cell_colspan => 2,
			    cell_align => 'center',
			    cell_class => 'form_submit',
			    $_ ? (buttons => [split(/\s+/, $_)]) : (),
			},
		    )];
		}
		elsif (ref($_) eq 'ARRAY' && ref($_->[0])) {
		    $x = $_;
		}
		else {
		    $x = $proto->vs_descriptive_field($_);
		}
		$x;
	    } @$rows),
	    $have_submit ? () : [$proto->vs_call('StandardSubmit', {
		cell_colspan => 2,
		cell_align => 'center',
		cell_class => 'form_submit',
	    })],
	], $attr));
}

sub vs_string {
    # (proto, any) : Widget.String
    # (proto, any, string, hash_ref) : Widget.String
    # B<DEPRECATED.  Use L<vs_new|"vs_new">>.
    my($proto, $value, $font, $attrs) = @_;
    return $proto->vs_new('String', $value, $font, $attrs);
}

sub vs_task_link {
    # (self, string, string) : Widget.Link
    # Returns a link widget for the specified task. Only renders if the current
    # user can execute the task.
    my($proto, $text, $task) = @_;
    return $proto->vs_call('Link', $text, $task, {
        control => $task,
    });
}

sub vs_ts {
    # (proto, any, ...) : Widget.String
    # Wraps vs_text() in a String().  All arguments passed to vs_text(),
    my($proto) = shift;
    return $proto->vs_new('String', $proto->vs_text(@_));
}

sub vs_unknown_label {
    my($proto, $model, $field) = @_;
    return $proto->vs_text(
	ref($model) || $model =~ /::/ ? $model->simple_package_name : $model,
	$field,
	'unknown_label',
    );
}

sub vs_xhtml {
    # (proto, any) : boolean
    # Returns true if rendering in xhtml.
    my(undef, $source) = @_;
    return $source->get_request->get_or_default('xhtml', 0);
}

sub _escape {
    # (any, string) : string
    # Escapes its argument.  Must be a scalar, and not undef.
    my(undef , $value) = @_;
    Bivio::Die->die($value, ': vs_escape_html not passed a string')
        if ref($value) || !defined($value);
    return Bivio::HTML->escape($value);
}

sub _use {
    # (string, ....) : array
    # Executes Bivio::IO::ClassLoader->simple_require on its args.  Inserts
    # HTMLWidget# prefix, if class does not contain
    # colons.  Returns the named classes.
    my(@class) = @_;
    return map {
	$_ =~ /:/ ? Bivio::IO::ClassLoader->simple_require($_)
	: Bivio::IO::ClassLoader->map_require('HTMLWidget', $_);
    } @class;
}

sub _wf {
    my($proto, $field, $attrs) = @_;
    $attrs ||= {};
    $attrs->{wf_want_display} = $proto->my_caller =~ /display/ ? 1 : 0;
    return $_WF->create($field, $attrs);
}

1;
