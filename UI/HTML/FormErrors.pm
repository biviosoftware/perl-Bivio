# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::FormErrors;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

# C<Bivio::UI::HTML::FormErrors> maps form errors to strings.  The
# mapping is by FormModel with defaults.  If not found, calls
# C<get_long_desc> on the L<Bivio::TypeError|Bivio::TypeError>.
#
# The syntax of the delegate info is:
#
#     Forms
#     Fields
#     TypeErrors
#     Text
#     %%
#
# Forms may be blank iwc the text applies to every form with that field,
# by default.
#
# Fields may be blank iwc the text applies to all fields.
#
# Double quotes in Text are escaped.  Text must be valid html use
# the utilities (_escape and _link) where appropriate.
#
# The result is eval'd when an error occurs.  Valid variables during eval are:
# $unsafe_value (not truncated, escaped), $value (truncated, escaped), $source,
# $form, $field, $label (escaped), $error, plus anything in @{[]}.
# See to_html.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_HTML) = b_use('Bivio.HTML');
my($_M) = b_use('Biz.Model');
my($_TE) = b_use('Bivio.TypeError');
my($_T) = b_use('FacadeComponent.Text');
my($_TI) = b_use('Agent.TaskId');
my($_MAP) = _compile();

sub to_html {
    # (self, any, Biz.FormModel, string) : string
    # (self, any, Biz.FormModel, string, string, Bivio.TypeError) : string
    # Returns the error string for this tuple.  If none is found,
    # C<get_long_desc> is called.
    #
    # The I<source> is so widget values can be inserted.
    my(undef, $source, $form, $field, $label, $error) = @_;
    my($form_class) = ref($form) || $form;
    $error ||= $form->get_field_error($field);

    # FormModel takes precedence
    my($msg) = _lookup($form_class, $field, $error);
    $msg = _lookup($form_class, '', $error) unless $msg;
    $msg = _lookup('', $field, $error) unless $msg;
    $msg = _lookup('', '', $error) unless $msg;

    if ($msg) {
	# Ensure Bivio::Die doesn't see the errors here
	local($SIG{__DIE__});

	# Interpolate in double quotes (double quotes have been escaped
	# by _compile().  Do the get_field in case there is an error.
	# Provide both a truncated and a non-truncated value.
	my($res) = eval(qq(
            my(\$unsafe_value) = \$form->get_field_as_literal(\$field);
            my(\$value) = \$unsafe_value;
            substr(\$value, 20) = '...' if length(\$value) > 20;
            \$unsafe_value = $_HTML->escape(\$unsafe_value);
            \$value = $_HTML->escape(\$value);
            \$label = $_HTML->escape(\$label);
            "$$msg";
        ));

	# Success return with escapes
	return $res if $res;
	b_warn('Error interpolating: ', $msg, ': ', $@);
    }

    # Use TypeError as default or if error
    return $_HTML->escape($error->get_long_desc);
}

sub _compile {
    # () : hash_ref
    # Compiles the FormError delegate info.
    my($map) = {};

    my($data) = b_use('IO.ClassLoader')->delegate_require_info(__PACKAGE__);
    my(@lines) = split("\n", $$data);

    while (int(@lines)) {
	# Read the forms, fields, and errors lists
	my(@forms, @fields, @errors);
	foreach my $v (\@forms, \@fields, \@errors) {
	    @$v = split(' ', shift(@lines));
	    @$v = ('') unless @$v;
	    die('unexpected eof') unless int(@lines);
	}
	die('no errors defined') if "@errors" eq "";

	# Read in the text till %%
	my($text) = '';
	while (1) {
	    die('unexpected eof') unless int(@lines);
	    my($line) = shift(@lines);
	    last if $line =~ /^%%/;
	    $text .= $line.' ';
	}
	# So eval can work properly
	$text =~ s/"/\\"/g;

	# Populate $map, validating down the hierarchy
	foreach my $form (@forms) {
	    $form = $_M->get_instance($form) if $form;
	    my($m1) = $map->{ref($form) || $form} ||= {};
	    foreach my $field (@fields) {
		$form->get($field) if $field && $form;
		my($m2) = $m1->{$field} ||= {};
		foreach my $error (@errors) {
		    my($e) = $_TE->unsafe_from_any($error);
		    die("$error: no such TypeError") unless $e;
		    $m2->{$e} = \$text;
		}
	    }
	}
    }
    return $map;
}

sub _escape {
    my($text) = @_;
    return $_HTML->escape($text);
}

sub _link {
    # (any, string) : string
    # (any, string, string) : string
    # Returns an href for the string.  See NO_VALUATION_FOR_DATE for
    # an example usage.  If text is not supplied, will use task's label.
    my($source, $task, $text) = @_;
    $task = $_TI->$task();
    $text = $_T->get_value($task->get_name, $source->get_request)
	unless $text;
    return '<a href="'
	. $_HTML->escape_attr_value($source->format_stateless_uri($task))
	. '">'.Bivio::HTML->escape($text)
	. '</a>';
}

sub _lookup {
    # (string, string, string) : string
    # Returns value in $_MAP, if defined.
    # Traverse the hierarchy in order of arguments
    my($res) = $_MAP;
    foreach my $index (@_) {
	$res = $res->{$index};
	return undef unless defined($res);
    }
    return $res;
}

sub _mail_to {
    # (any, string, string) : string
    # Returns a mailto href.
    my($source, $email, $subject) = @_;
    return '<a href="'
        . $_HTML->escape_attr_value(
	    $source->get_request->format_mailto($email, $subject))
	. '">'
        . $email
	. '</a>';
    return;
}

1;
