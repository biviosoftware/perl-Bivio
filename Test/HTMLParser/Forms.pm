# Copyright (c) 2002-2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Forms;
use strict;
$Bivio::Test::HTMLParser::Forms::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::HTMLParser::Forms::VERSION;

=head1 NAME

Bivio::Test::HTMLParser::Forms - models forms on the page

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::HTMLParser::Forms;

=cut

=head1 EXTENDS

L<Bivio::Test::HTMLParser>

=cut

use Bivio::Test::HTMLParser;
@Bivio::Test::HTMLParser::Forms::ISA = ('Bivio::Test::HTMLParser');

=head1 DESCRIPTION

C<Bivio::Test::HTMLParser::Forms> models the forms on a page.

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;
__PACKAGE__->register(['Cleaner']);
Bivio::IO::Config->register(my $_CFG = {
    error_color => '#990000',
    # Set by XHTMLWidget.FormFieldError
    error_class => 'field_err',
    label_class => 'label',
    disable_checkbox_heading => {},
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Test::HTMLParser parser) : Bivio::Test::HTMLParser::Forms

Parses cleaned html for forms.

=cut

sub new {
    my($proto, $parser) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_by_field_names"></a>

=head2 get_by_field_names(any name, ...) : hash_ref

Returns the form data by finding by I<name>(s) in visible and submit fields of
forms.  See interpretation of I<name> in L<unsafe_get_field|"unsafe_get_field">.

=cut

sub get_by_field_names {
    my($self, @name) = @_;
    my($found);
    my($forms) = $self->get_shallow_copy;
 FORM: while (my($form, $values) = each(%$forms)) {
	foreach my $n (@name) {
	    next FORM
		unless @{$self->unsafe_get_field($values, $n)};
	}
	Bivio::Die->die(\@name, ': too many forms matched fields')
	    if $found;
	$found = $values;
    }
    return $found if $found;
    Bivio::IO::Alert->info($forms);
    my(@fields) = map({[sort(keys(%{$_->{visible}}), keys(%{$_->{submit}}))]}
            values(%$forms));
    _trace(join("\n", map({@$_} @fields)));
    Bivio::Die->die(\@name, ': no form matches named fields; all visible form fields: ',
        @fields);
}

=for html <a name="get_field"></a>

=head2 static get_field(hash_ref form, any name) : hash_ref

Calls L<unsafe_get_field|"unsafe_get_field"> and dies unless matches
fields exactly.

=cut

sub get_field {
    my($proto, $form, $name) = @_;
    my($res) = shift->unsafe_get_field(@_);
    Bivio::Die->die($name, ': ',
	(@$res ? ('matches too many fields: ', @$res) : 'field not found'),
	' in ', $form->{label})
        unless @$res == 1;
    return $res->[0];
}

=for html <a name="get_ok_button"></a>

=head2 get_ok_button(any form) : string

Returns name of ok_button.  There cannot be more than one button, excluding
cancel.  If there are no submit buttons, returns undef.

=cut

sub get_ok_button {
    my($self, $form) = @_;
    $form = $self->get_by_field_names($form)
	unless ref($form) eq 'HASH';
    my(@ok) = grep(!/cancel/i, keys(%{$form->{submit}}));
    Bivio::Die->die('must not be more than one submit ', \@ok)
        if @ok > 1;
    return $ok[0];
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item error_class : string [form_field_error]

unique class for error text on page. If found, assumes form failed.

=item error_color : string [#990000]

unique color for error text on page. If found, assumes form failed.

=item disable_checkbox_heading : hash_ref {}

Controls whether a checkbox in a table uses the table heading as a
label, or if the label is parsed from nearby text.
The key is the name of the table heading.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

=for html <a name="html_parser_end"></a>

=head2 html_parser_end(string tag, string origtext)

Dispatch to the _end_XXX routines.

=cut

sub html_parser_end {
    my($self, $tag) = @_;
    my($fields) = $self->[$_IDI];
    return _end_th($fields)
	if $tag eq 'th';
    return _end_table($fields)
	if $tag eq 'table';
    return _end_form($self)
	if $tag eq 'form';
    return _end_textarea($fields)
	if $tag eq 'textarea';
    return _end_select($fields)
	if $tag eq 'select';
    return _end_maybe_err($fields)
	if $tag =~ /^(font|span|div)$/;
    return;
}

=for html <a name="html_parser_start"></a>

=head2 html_parser_start(string tag, hash_ref attr, array_ref attrseq, string origtext)

Calls _fixup_attr then dispatches to the _start_XXX routines.

=cut

sub html_parser_start {
    my($self, $tag, $attr) = @_;
    my($fields) = $self->[$_IDI];
    _fixup_attr($tag, $attr);
    if (($attr->{class} || '') eq 'label') {
	$fields->{text} = undef;
    }
    return _start_tx($fields, $attr, $tag)
	if $tag =~ /^t(?:d|r|h|able)$/;
    return _start_form($fields, $attr)
	if $tag eq 'form';
    return _start_option($fields, $attr)
	if $tag eq 'option';
    return _start_input($self, $attr)
	if $tag eq 'input' || ($attr->{type} && $tag !~ /^(?:link|style|script)$/);
    return _start_maybe_err($fields, $attr)
	if $tag =~ /^(font|span|div)$/;
    return;
}

=for html <a name="html_parser_text"></a>

=head2 html_parser_text(string text)

Text is applied as labels to form fields. It is cleaned first.
In the case of textareas, the cleaned text is saved as the "value"
(see _end_textarea).

We assume that we can parse an entire sequence of text for
column headers, etc.

=cut

sub html_parser_text {
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    if ($fields->{textarea}) {
	$fields->{textarea}->{value}
	    .= defined($text) ? Bivio::HTML->unescape($text) : '';
	return;
    }
    $text = $self->get('cleaner')->text($text);
    # We never label fields with blanks.  There are occassions where blanks
    # are upcalled just after the actual text.
    # Select widgets may have an empty value.
    return unless length($text) || $fields->{option};
    $fields->{text} .= $text;

    return if _have_prefix_label($fields);
    return _label_option($fields) if $fields->{option} || $fields->{radio};
    return _label_visible($fields) if $fields->{input};
    return;
}

=for html <a name="unsafe_get_field"></a>

=head2 static unsafe_get_field(hash_ref form, any name) : array_ref

Returns field from I<form>.  I<name> may be a string or a regular expression.
If it is a string and it matches '(?.*)', I<name> will be treated as a regular
expression.  Returns list of matches or empty array_ref.

=cut

sub unsafe_get_field {
    my(undef, $form, $name) = @_;
    $name = $name =~ /^\(\?.*\)$/s ? qr/$name/ : qr/^\Q$name\E$/s
	unless ref($name);
    my($res) = [];
    foreach my $c (qw(visible submit hidden)) {
	push(@$res, map(
	    $form->{$c}->{$_},
	    grep($_ =~ $name, keys(%{$form->{$c}}))));
    }
    return $res;
}

#=PRIVATE METHODS

# _empty(string value) : boolean
#
# Returns true if !defined or zero length
#
sub _empty {
    return !grep(defined($_) && length($_), @_);
}

# _end_form(self)
#
# Ends the form and puts in $fields->{current}.
#
sub _end_form {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    Bivio::Die->die('unlabeled form field: ', $fields->{input},
	' form: ', $fields->{current})
	if $fields->{input};
    _unwind_duplicates($fields);
    my($label) = $fields->{current}->{label};
    my($curr) = $fields->{current};
    $fields->{current} = undef;
    if (defined($label)) {
	my($e) = $self->get('elements');
	# If there is a complete duplicate, then we ignore.
	if ($e->{$label}) {
	    if (Bivio::IO::Ref->nested_equals($e->{$label}, $curr)) {
		_trace('ignoring duplicate form: ', $curr) if $_TRACE;
		return;
	    }
	    # Rename first form
	    my($new_label) = "$label#0";
	    $e->{$new_label} = $e->{$label};
	    $e->{$new_label}->{label} = $label;
	    $e->{$label} = undef;
	}
	for (my $i = 0; $e->{"$label#$i"};) {
	    $curr->{label} = $label . '#' . ++$i;
	}
        $self->get('elements')->{$curr->{label}} = $curr;
    }
    _trace($curr) if $_TRACE;
    return;
}

# _end_maybe_err(hash_ref fields)
#
# Ends the current tag which may contain err.
#
sub _end_maybe_err {
    my($fields) = @_;
    my($f) = pop(@{$fields->{maybe_err}});
    return
	unless (
	    $f->{color} ? $f->{color} eq $_CFG->{error_color}
	    : $f->{class} ? $f->{class} eq $_CFG->{error_class}
	    : 0
	) && !_empty($fields->{text})
	&& !_have_prefix_label($fields);
    $fields->{input_error} = substr($fields->{text}, $f->{text_start_length});
    $fields->{text} = undef;
    return;
}

# _end_select(hash_ref fields)
#
# Ends the select.
#
sub _end_select {
    my($fields) = @_;
    $fields->{select} = undef;
    return;
}

# _end_table(hash_ref fields)
#
# The only tables we track are "data" tables.
#
sub _end_table {
    my($fields) = @_;
    $fields->{in_data_table}-- if $fields->{in_data_table};
    return;
}

# _end_textarea(hash_ref fields)
#
# Saves the value for the textarea.  May not have "text", because
# textarea might be blank.
#
sub _end_textarea {
    my($fields) = @_;
    _trace($fields->{textarea}) if $_TRACE;
    $fields->{textarea}->{value} = ''
        unless defined($fields->{textarea}->{value});
    $fields->{textarea} = undef;
    return;
}

# _end_th(hash_ref fields)
#
# Ends the "th".
#
sub _end_th {
    my($fields) = @_;
    # There's a weird case where {text} will be the empty string,
    # but that's ok in this case.
    $fields->{text} = ' '
	if _empty($fields->{text});
    push(@{$fields->{headers}}, _text($fields));
    _trace('push header ', $fields->{headers}->[$#{$fields->{headers}}])
	if $_TRACE;
    return;
}

# _fixup_attr(string tag, hash_ref attr)
#
# Lowercases all attr values which we care about.  Sets type
# for select and textarea.
#
sub _fixup_attr {
    my($tag, $attr) = @_;
    while (my($k, $v) = each(%$attr)) {
	$attr->{$k} = lc($v) if $k =~ /^(?:method|name|type)$/;
    }
    $attr->{type} = $tag if $tag =~ /^(?:select|textarea)$/;
    $attr->{type} = 'submit'
	if $tag eq 'input' && $attr->{type} && $attr->{type} eq 'image';

    # HTML::Parser sets these values to "checked" or "selected"
    $attr->{selected} = $attr->{checked} = 1 if $attr->{checked};
    $attr->{selected} = 1 if $attr->{selected};
    return;
}

# _have_prefix_label(hash_ref fields) : boolean
#
# Returns true if $fields->{text} is a prefix label (ends with colon)
#
sub _have_prefix_label {
    my($fields) = @_;
    return $fields->{text} && $fields->{text} =~ /:$/;
}

# _label_field(hash_ref fields, string class, hash_ref attr)
#
# Labels all fields, checking for duplicates.  Allows _radio
# for labels, however.
#
sub _label_field {
    my($fields, $class, $attr) = @_;
    _trace($attr) if $_TRACE;
    push(@{$fields->{current}->{$class}->{$attr->{label}} ||= []}, $attr);
    _trace($fields->{current}, ' ', $attr);
    $fields->{current}->{label} = $attr->{label}
	unless $fields->{current}->{label}
	    || $attr->{label} =~ /^_anon/
	    || $class eq 'hidden';
    return;
}

# _label_hidden(hash_ref fields, hash_ref attr)
#
# Labels the hidden fields.
#
sub _label_hidden {
    my($fields, $attr) = @_;
    $attr->{label} = $attr->{name};
    _label_field($fields, 'hidden', $attr);
    return;
}

# _label_option(hash_ref fields)
#
# Labels the option and adds to select or radio.  We label the select (not the
# radio) if it hasn't already been labeled and the option is selected.  This
# handles the Select Site, Select Investment, etc. cases.
#
sub _label_option {
    my($fields) = @_;
    my($which) = $fields->{radio} ? 'radio' : 'option';
    my($group) = $fields->{radio}
	    ? $fields->{radios}->{$fields->{radio}->{name}}
	    : $fields->{select};
    my($o) = $fields->{$which};
    $o->{label} = _text($fields, $fields->{option} ? 1 : 0);
    _trace($o) if $_TRACE;
    Bivio::Die->die('duplicate ', $which, ': ', $o, ' select: ', $group)
	if $group->{options}->{$o->{label}};
    $group->{options}->{$o->{label}} = $o;
    # We take the "last" value selected as the default value
    $group->{value} = $o->{value}
	if $o->{selected} || !defined($group->{value});

    # Label the select?
    if ($fields->{option} && $o->{selected}
	    && !defined($fields->{select}->{label})) {
	$fields->{text} = $o->{label};
	_label_visible($fields);
    }
    $fields->{$which} = undef;
    return;
}

# _label_radio(hash_ref fields)
#
# Labels a radio button and puts it in the appropriate radio hash.
#
sub _label_radio {
    my($fields) = @_;
    my($r) = $fields->{radio};
    $r->{label} = _text($fields);

    $fields->{input} = $fields->{radio};
    return;
}

# _label_submit(self, hash_ref attr)
#
# Labels the submit fields.
#
sub _label_submit {
    my($self, $attr) = @_;
    my($fields) = $self->[$_IDI];
    $attr->{label} = $self->get('cleaner')->text(
	$attr->{src} ? _submit_label_clean($attr->{src})
	: $attr->{value});
    $attr->{label} .= '_'.$attr->{index} if defined($attr->{index});
    _label_field($fields, 'submit', $attr);
    if ($fields->{input_error}) {
	$attr->{error} = $fields->{input_error};
	push(@{$fields->{current}->{errors} ||= []}, $attr);
	$fields->{input_error} = undef;
    }
    return;
}

# _label_visible(hash_ref fields)
#
# Labels the current input field.
#
sub _label_visible {
    my($fields) = @_;
    my($label) = _text($fields);

    # We don't label selects with blanks.  Rather with the selected value.
    return if !length($label) && $fields->{input}->{type} eq 'select';

    $fields->{input}->{label} = $label;
    _label_field($fields, 'visible', $fields->{input});
    if ($fields->{input_error}) {
	$fields->{input}->{error} = $fields->{input_error};
	push(@{$fields->{current}->{errors} ||= []}, $fields->{input});
	$fields->{input_error} = undef;
    }
    $fields->{input} = undef;
    return;
}

# _leftover_input(hash_ref fields, hash_ref next)
#
# Left over input field at start of new input.  Anonymous field.  Save
# context for next field.
#
sub _leftover_input {
    my($fields, $next) = @_;
    my(@save) = @{$fields}{qw{text prev_cell_text}};
    $fields->{text} = '_anon';
    _label_visible($fields);
    @{$fields}{qw{text prev_cell_text}} = @save;
    return;
}

# _start_form(hash_ref fields, hash_ref attr)
#
# Starts a form.
#
sub _start_form {
    my($fields, $attr) = @_;
    $fields->{current} = {
	%$attr,
	visible => {},
	hidden => {},
	submit => {},
    };
    $fields->{radios} = {};
    return;
}

# _start_input(self, hash_ref attr)
#
# Starts a new field.   Certain fields have labels before.  Others
# have labels after.  Some have labels as the column header.
#
sub _start_input {
    my($self, $attr) = @_;
    $attr->{type} ||= 'text';
    my($fields) = $self->[$_IDI];
    _trace($fields->{text}, ' ', $fields->{input}, ' ',
	$fields->{prev_cell_text}, ' ', $attr)
	if $_TRACE;
    _leftover_input($fields, $attr) if $fields->{input};

    return _label_hidden($fields, $attr) if $attr->{type} eq 'hidden';

    # If a ListForm field, we grab the index from the header.
    $attr->{index} = $1 if $attr->{name} && $attr->{name} =~ /_(\d+)$/;

    return _label_submit($self, $attr) if $attr->{type} eq 'submit';

    # visible field
    $fields->{input} = $attr;

    return _start_radio($fields) if $attr->{type} eq 'radio';

    # Text areas and select are special
    $fields->{$attr->{type}} = $attr
	if $attr->{type} =~ /^(?:select|textarea)$/;

    # Visible list form field is labeled with the header
    # if there is one.
#TODO: Deal with the case when no header and not a checkbox
    if (defined($attr->{index}) && $fields->{headers}
	&& defined($fields->{headers}->[$fields->{cell_num}])) {

        return if $attr->{type} =~ /checkbox/
            && $_CFG->{disable_checkbox_heading}->{
                $fields->{headers}->[$fields->{cell_num}]};
	$fields->{text} = $fields->{headers}->[$fields->{cell_num}]
		. '_' . $attr->{index};
	return _label_visible($fields);
    }

    # Nothing to label unless defined
    return if _empty($fields->{text}, $fields->{prev_cell_text});

    # A field has a label if the word preceding it begins with a ':'
    return _label_visible($fields)
        if ($fields->{text} || $fields->{prev_cell_text}) =~ /\:\s*$/
            && $attr->{type} !~ /checkbox/;

    # Unlabeled field.  Will be dealt with on closing tag or next text
    return;
}

# _start_maybe_err(hash_ref fields, hash_ref attr)
#
# Saves current tag info.
#
sub _start_maybe_err {
    my($fields, $attr) = @_;
    if (($fields->{text} || '') =~ m/:$/) {
	$fields->{prev_cell_text} = $fields->{text};
	$fields->{text} = undef;
    }
    push(@{$fields->{maybe_err}}, {
	%$attr,
	text_start_length => length($fields->{text} || ''),
    });
    return;
}

# _start_option(hash_ref fields, hash_ref attr)
#
# Handles an OPTION tag.
#
sub _start_option {
    my($fields, $attr) = @_;
    Bivio::Die->die('not in a select: ', $fields)
	unless $fields->{select};
    $fields->{select}->{options} ||= {};
    $fields->{option} = $attr;
    return;
}

# _start_radio(hash_ref fields)
#
# Deals with a new radio.   We may have to start a new record in
# $fields->{radios}.  All radios are labelled non-uniquely "_radio".
#
sub _start_radio {
    my($fields) = @_;
    my($r) = $fields->{radio} = $fields->{input};
    $fields->{input} = undef;

    return if $fields->{radios}->{$r->{name}};

    # Save state in both radios and input.  Then label the field.
    $fields->{input} = $fields->{radios}->{$r->{name}} = {
	name => $r->{name},
	options => {},
	type => 'radio',
    };
    $fields->{text} = '_radio';
    _label_visible($fields);
    return;
}


# _start_tx(hash_ref fields, hash_ref attr, string tag)
#
# Starts a TD, TH, TR, or TABLE.
#
sub _start_tx {
    my($fields, $attr, $tag) = @_;
    if ($tag =~ /th|td/) {
	$fields->{prev_cell_text} = $fields->{text}
	    if defined($fields->{text}) && length($fields->{text});
	$fields->{text} = undef;
    }
    if ($fields->{in_data_table}) {
	return $fields->{in_data_table}++ if $tag eq 'table';
	# Only count the top level rows
	if ($fields->{in_data_table} == 1) {
	    return $fields->{cell_num} = -1 if $tag eq 'tr';
	    return $fields->{cell_num}++ if $tag =~ /td|th/;
	}
    }
    elsif ($tag eq 'th') {
	_trace('begin data table') if $_TRACE;
	$fields->{headers} = [];
	$fields->{cell_num} = 0;
	return $fields->{in_data_table} = 1;
    }
    return;
}

# _submit_label_clean(string src) : string
#
# Grabs icon name.
#
sub _submit_label_clean {
    my($src) = @_;
    $src =~ /(?:.*\/)?([^\/]+)\.\w+$/;
    return $1;
}

# _text(hash_ref fields, boolean no_die) : string
#
# Returns the text field or dies if zero length.  Won't die if !$no_die.
#
sub _text {
    my($fields, $no_die) = @_;
    my($res) = !_empty($fields->{text})
	? $fields->{text}
	: !_empty($fields->{prev_cell_text})
	    ? $fields->{prev_cell_text}
        : $no_die ? ''
	: Bivio::Die->die('no text field: ', $fields);
    $fields->{prev_cell_text} = $fields->{text} = undef;
    return $res;
}

# _unwind_duplicates(hash_ref fields)
#
# Renames duplicates and unwinds singletons.
#
sub _unwind_duplicates {
    my($fields) = @_;
    foreach my $class (qw(visible hidden submit)) {
	my($c) = $fields->{current}->{$class};
	foreach my $k (keys(%$c)) {
	    my($found) = $c->{$k};
	    my($unique) = [];
	    if (@$found == 1) {
		$c->{$k} = $found->[0];
		next;
	    }
	    # If all values are identical, we leave #NNN values and
	    # copy a simple one.
	    if (grep(Bivio::IO::Ref->nested_equals($found->[0], $_), @$found)
		== @$found) {
		_trace('all duplicates ', $k) if $_TRACE;
		$c->{$k} = {%{$found->[0]}, label => $k};
	    }
	    else {
		delete($c->{$k});
	    }
	    my($i) = 0;
	    foreach my $v (@$found) {
		$c->{$v->{label} = $k . '#' . $i++} = $v;
		_trace('relabeled ', $v) if $_TRACE;
	    }
	}
    }
    return;
}


=head1 COPYRIGHT

Copyright (c) 2002-2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
