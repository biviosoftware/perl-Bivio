# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::FormErrors;
use strict;
$Bivio::UI::HTML::FormErrors::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::FormErrors - maps form, field, and TypeError to strings

=head1 SYNOPSIS

    use Bivio::UI::HTML::FormErrors;
    Bivio::UI::HTML::FormErrors->to_html($source, $form, $field, $label, $type_error);

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::HTML::FormErrors::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::HTML::FormErrors> maps form errors to strings.  The
mapping is by FormModel with defaults.  If not found, calls
C<get_long_desc> on the L<Bivio::TypeError|Bivio::TypeError>.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::Util;
use Bivio::Collection::SingletonMap;

#=VARIABLES
# form_class->field->error returns a scalar ref
my($_MAP) = _compile();

=head1 METHODS

=cut

=for html <a name="to_html"></a>

=head2 to_html(any source, Bivio::Biz::FormModel form, string field, string label, Bivio::TypeError error) : string

Returns the error string for this tuple.  If none is found,
C<get_long_desc> is called.

The I<source> is so widget values can be inserted.

=cut

sub to_html {
    my(undef, $source, $form, $field, $label, $error) = @_;
    my($form_class) = ref($form) || $form;

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
	my($res) = eval(qq(
            my(\$value) = \$form->get_field_as_literal(\$field);
            "$$msg";
        ));

	# Success return with escapes
	return Bivio::Util::escape_html($res) if $res;

	Bivio::IO::Alert->warn('Error interpolating: ', $msg,
		': ', $@);
    }

    # Use TypeError as default or if error
    return Bivio::Util::escape_html($error->get_long_desc);
}

#=PRIVATE METHODS

# _compile() : hash_ref
#
# Compiles __DATA__ into a hash map.
#
sub _compile {
    my($map) = {};
    until (eof(DATA)) {

	# Read the forms, fields, and errors lists
	my(@forms, @fields, @errors);
	foreach my $v (\@forms, \@fields, \@errors) {
	    @$v = split(' ', scalar(<DATA>));
	    @$v = ('') unless @$v;
	    die('unexpected eof') if eof(DATA);
	}
	die("__DATA__, line $.: no errors") if "@errors" eq "";

	# Read in the text till %%
	my($text) = '';
	while (1) {
	    die('unexpected eof') if eof(DATA);
	    my($line) = scalar(<DATA>);
	    last if $line =~ /^%%/;
	    $text .= $line;
	}
	# So eval can work properly
	$text =~ s/"/\\"/g;

	# Populate $map, validating down the hierarchy
	foreach my $form (@forms) {
	    ($form) = Bivio::Collection::SingletonMap->get(
		    'Bivio::Biz::Model::'.$form) if $form;
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
    close(DATA);
    return $map;
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
# Fields may be blank iwc the text applies to all fields.
# Double quotes in Text are escaped.  The result is eval'd when an error
# occurs.  Valid variables during eval are: $value (may be truncated),
# $source, $form, $field, $label, $error, plus anything in @{[]}.
# See to_html.
#
__DATA__
CreateUserForm
Email.email
EXISTS
Another user has registered with this $label. If you share an email with
someone, you must also share your bivio account.
%%
CreateUserForm
RealmOwner.name
EXISTS
Another user has registered with this $label.  You may need to add a qualifier
such as your zipcode, e.g. ${value}12345.
%%


NULL
You must supply a value for $label.
%%
