# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::FormErrors;
use strict;
$Bivio::UI::HTML::FormErrors::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::FormErrors::VERSION;

=head1 NAME

Bivio::UI::HTML::FormErrors - maps form, field, and TypeError to strings

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::FormErrors;

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::HTML::FormErrors::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::HTML::FormErrors> maps form errors to strings.  The
mapping is by FormModel with defaults.  If not found, calls
C<get_long_desc> on the L<Bivio::TypeError|Bivio::TypeError>.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Model;
use Bivio::HTML;
use Bivio::IO::Alert;
use Bivio::IO::ClassLoader;
use Bivio::TypeError;
use Bivio::UI::Text;

#=VARIABLES
# form_class->field->error returns a scalar ref
my($_MAP) = _compile();

=head1 METHODS

=cut

=for html <a name="to_html"></a>

=head2 to_html(any source, Bivio::Biz::FormModel form, string field) : string

=head2 to_html(any source, Bivio::Biz::FormModel form, string field, string label, Bivio::TypeError error) : string

Returns the error string for this tuple.  If none is found,
C<get_long_desc> is called.

The I<source> is so widget values can be inserted.

=cut

sub to_html {
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
            \$unsafe_value = Bivio::HTML->escape(\$unsafe_value);
            \$value = Bivio::HTML->escape(\$value);
            \$label = Bivio::HTML->escape(\$label);
            "$$msg";
        ));

	# Success return with escapes
	return $res if $res;

	Bivio::IO::Alert->warn('Error interpolating: ', $msg,
		': ', $@);
    }

    # Use TypeError as default or if error
    return Bivio::HTML->escape($error->get_long_desc);
}

#=PRIVATE METHODS

# _compile() : hash_ref
#
# Compiles the FormError delegate info.
#
sub _compile {
    my($map) = {};

    my($data) = Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__);
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
	    $text .= $line;
	}
	# So eval can work properly
	$text =~ s/"/\\"/g;

	# Populate $map, validating down the hierarchy
	foreach my $form (@forms) {
	    $form = Bivio::Biz::Model->get_instance($form) if $form;
	    my($m1) = $map->{ref($form) || $form} ||= {};
	    foreach my $field (@fields) {
		$form->get($field) if $field && $form;
		my($m2) = $m1->{$field} ||= {};
		foreach my $error (@errors) {
		    my($e) = Bivio::TypeError->unsafe_from_any($error);
		    die("$error: no such TypeError") unless $e;
		    $m2->{$e} = \$text;
		}
	    }
	}
    }
    return $map;
}

# _escape(string text) : string
#
# Escape the html.  Use wherever you have a form value that needs
# escaping.
#
sub _escape {
    my($text) = @_;
    return Bivio::HTML->escape($text);
}

# _link(any source, string task) : string
# _link(any source, string task, string text) : string
#
# Returns an href for the string.  See NO_VALUATION_FOR_DATE for
# an example usage.  If text is not supplied, will use task's label.
#
sub _link {
    my($source, $task, $text) = @_;
    $task = Bivio::Agent::TaskId->$task();
    $text = Bivio::UI::Text->get_value($task->get_name, $source->get_request)
	    unless $text;
    return '<a href="'
	    .Bivio::HTML->escape($source->format_stateless_uri($task))
	    .'">'.Bivio::HTML->escape($text).'</a>';
}

# _lookup(string class, string field, string error) : string
#
# Returns value in $_MAP, if defined.
#
sub _lookup {
    # Traverse the hierarchy in order of arguments
    my($res) = $_MAP;
    foreach my $index (@_) {
	$res = $res->{$index};
	return undef unless defined($res);
    }
    return $res;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;

# Syntax:
#    Forms
#    Fields
#    TypeErrors
#    Text
#    %%
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
#
# See to_html.
#
