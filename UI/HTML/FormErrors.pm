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
use Bivio::HTML;
use Bivio::Agent::TaskId;
use Bivio::Biz::Model;
use Bivio::Die;

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
    close(DATA);
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
    $text = Bivio::UI::Label->get_simple($task->get_name) unless $text;
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
such as your zipcode, e.g. ${value}$$.
%%


NULL
You must supply a value for $label.
%%
LoginForm
RealmOwner.password
PASSWORD_MISMATCH
The password you entered does not match the value stored
in our database.
Please remember that passwords are case-sensitive, i.e.
"HELLO" is not the same as "hello".
%%
FileUploadForm
source
EMPTY
The file uploaded is empty.  This may be because it doesn't
exist or because it is really empty.  Select another
file.  If you really want to create an empty file,
click "OK" now (you need not supply a value for this field).
%%
FileUploadForm
File.name_sort
EXISTS
The name you selected already exists in the folder you have
selected.  If you really want to replace this file, you
may do so by clicking "OK" after (reselecting File above).
%%
FileUploadForm
source
NOT_FOUND
The file "$value" was not found.  To ensure the file exists,
you may want to use the Browse button.  Please select another
file and click OK.
%%


FILE_FIELD_RESET_FOR_SECURITY
Your browser has reset this file field for security reasons.
The value sent to us was: $unsafe_value
%%


NO_VALUATION_FOR_DATE
The date selected cannot be used, because your portfolio is missing
valuations for unlisted investments.  Either change the date to a day
when all unlisted investments have been valued or
@{[_link($source, 'CLUB_ACCOUNTING_LOCAL_VALUE',
'enter valuations for the date below using this link')]}.
%%


NAME_LIKE_FUND
The name you entered seems to be a club name.
First you register yourself with bivio.  The next step
is to create your own private club space on bivio.
%%


INCORRECT_EXPORT_FILE_NAME
The file you upload must be named NCADATA.DAT.  We only support
imports from NAIC Club Accounting software.  If you are trying to
upload another format, please email the file to customer support
and we will try to import your data.
%%
AddMemberListForm
RealmOwner.display_name
EXISTS
This person is already a member of your club.
%%
CreateDirectoryForm
File.name_sort
EXISTS
A folder or file by the name "${value}" already exists.  Please
select another name or delete the named file or folder before
continuing.
%%


ACCOUNTING_IMPORT_IN_FILES
The Files area is not used to Import Club Accounting.  You should
use @{[_link($source, 'CLUB_LEGACY_UPLOAD')]} located under
Administration &gt; Tools.  If you don't understand this message,
please contact customer support.
%%


TRANSACTION_PRIOR_TO_MEMBER_DEPOSIT
You cannot enter this transaction because no one in your club has
made any payments prior to the transaction date.
@{[_link($source, 'CLUB_ACCOUNTING_PAYMENT',
'Enter member payments using this link')]}.
%%
