# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::Form;
use strict;
$Bivio::UI::PDF::Form::Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form - a base class for PDF form objects.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::Form;
    Bivio::UI::PDF::Form->new();

=cut

use Bivio::UI::PDF::Pdf;
@Bivio::UI::PDF::Form::Form::ISA = ('Bivio::UI::PDF::Pdf');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form>

=cut


=head1 CONSTANTS

=cut

=for html <a name="SECTION_NAME_REGEX"></a>

=head2 SECTION_NAME_REGEX : string

This regular expression returns the name of a section of data from a section
header of the form "!!! <section name> !!!'.

=cut

sub SECTION_NAME_REGEX {
    return('!!! (.*) !!!');
}

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::IO::Trace;
use Bivio::UI::PDF::BuiltUpdate;
use Bivio::UI::PDF::OpaqueUpdate;
use Bivio::UI::PDF::Strings;
use Bivio::Util;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_EOL_REGEX) = Bivio::UI::PDF::Regex::EOL_REGEX();
my($_NUMBER_REGEX) = Bivio::UI::PDF::Regex::NUMBER_REGEX();
my($_OBJ_REF_REGEX) = Bivio::UI::PDF::Regex::OBJ_REF_REGEX();
my($_SECTION_NAME_REGEX) = SECTION_NAME_REGEX();

my($_BASE_FILE) = Bivio::UI::PDF::Strings::BASE_FILE();
my($_BASE_ROOT) = Bivio::UI::PDF::Strings::BASE_ROOT();
my($_BASE_SIZE) = Bivio::UI::PDF::Strings::BASE_SIZE();
my($_BASE_XREF) = Bivio::UI::PDF::Strings::BASE_XREF();
my($_DATA_END) = Bivio::UI::PDF::Strings::DATA_END();
my($_FIELD_TEXT) = Bivio::UI::PDF::Strings::FIELD_TEXT();
my($_XLATOR_SET) = Bivio::UI::PDF::Strings::XLATOR_SET();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::Form



=cut

sub new {
    my($self) = Bivio::UI::PDF::Pdf::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() : 



=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Add an OpaqueUpdate that contains the base Pdf text to the Pdf object.
    my($base_update_ref) = $self->get_base_update_ref();
    $self->add_update($base_update_ref);

    # Add an empty update to the Pdf object into which we will put the field
    # objects that have values inserted.
    my($update_ref) = Bivio::UI::PDF::BuiltUpdate->new();
    $self->add_update($update_ref);

    my($xlator_set_ref) = $self->get_xlator_set_ref();

    # Do any initialization of the XlatorSet.
    $xlator_set_ref->set_up($req);

    # Create an hash of output values.  Each key is the name of a field in the
    # Pdf document, and its value is reference to a direct object that contains
    # the value for the field.
    my($value_obj_ref) = $xlator_set_ref->create_value_objs($req);

    my($key, $value);
    while (($key, $value) = each(%{$value_obj_ref})) {
	# Clone a field object for the value.
	my($field_obj_ref) = $self->get_field_ref($key);

	# Insert the value into the field object.  Sometimes we get back a
	# different object than the one we started with, as when the value goes
	# into a kid of the one we started with.
	my($new_obj_ref) = $field_obj_ref->insert_field_value($value, $self);
	if (defined($new_obj_ref)) {
	    # Add the field object to the update.
	    $update_ref->add_body_obj($new_obj_ref);
	}
	else {
	    # Add the field object to the update.
	    $update_ref->add_body_obj($field_obj_ref);
	}
    }

    # Now add data to the trailer.
    $update_ref->set_prev_offset($base_update_ref->get_xref_offset());
    $update_ref->set_root_pointer($base_update_ref->get_root_pointer());
    $update_ref->set_size($base_update_ref->get_size());

    # Get the text of the PDF file to output.
    my($text_ref) = $self->emit();

    my($reply) = $req->get('reply');
    $reply->set_output_type('application/pdf');
    $reply->set_output($text_ref);

#TODO:  Temporary hack.
#    open(OUT, '>/home/yates/junk/Form.pdf')
#	    or die("Can't open PDF output file.\n");
#    print(OUT ${$text_ref});
#    close(OUT);

    return;
}

=for html <a name="internal_read_data"></a>

=head2 internal_read_data(glob_ref fh_ref) : array



=cut

sub internal_read_data {
    my($proto, $fh_ref) = @_;

    my($base_pdf_text_ref, $base_root_ref, $base_size_ref, $base_xref_ref,
	    $last_section, $next_section);

    # Things to return.
    my($base_update_ref, $xlator_set_ref);
    my($field_dictionary_ref) = {};
    my($obj_dictionary_ref) = {};

    while (1) {
	$last_section = $next_section;
	if (defined($last_section) && ($_DATA_END eq $last_section)) {
	    _trace('Got data end section');
	    last;
	}
	my($text_ref) = _get_section($fh_ref, \$next_section);
	unless (defined($last_section)) {
	    next;
	}

	_trace("last section is \"", $last_section, "\"") if $_TRACE;

	if ($_BASE_FILE eq $last_section) {
	    _trace('Got base file section');
#TODO: fix this
die("undef text_ref") if ! defined($text_ref);
	    chop(${$text_ref});
	    $base_pdf_text_ref = $text_ref;
	}
	elsif ($_BASE_ROOT eq $last_section) {
	    _trace('Got base root section');
	    if (${$text_ref} =~ /$_OBJ_REF_REGEX/o) {
		unless (defined($1) && defined($2)) {
		    die(__FILE__, ", ", __LINE__,
			    ": missing obj number and/or object generation\n");
		}
		$base_root_ref = Bivio::UI::PDF::IndirectObjRef->new($1, $2);
	    }
	    else {
		die(__FILE__, ", ", __LINE__, ": no match\n");
	    }
	}
	elsif ($_BASE_SIZE eq $last_section) {
	    _trace('Got base size section');
	    if (${$text_ref} =~ /$_NUMBER_REGEX/o) {
		unless (defined($1)) {
		    die(__FILE__, ", ", __LINE__, ": missing base size\n");
		}
		$base_size_ref = Bivio::UI::PDF::Number->new($1);
	    }
	    else {
		die(__FILE__, ", ", __LINE__, ": no match\n");
	    }
	}
	elsif ($_BASE_XREF eq $last_section) {
	    _trace('Got base xref section');
	    if (${$text_ref} =~ /$_NUMBER_REGEX/o) {
		unless (defined($1)) {
		    die(__FILE__, ", ", __LINE__, ": missing base xref\n");
		}
		$base_xref_ref = Bivio::UI::PDF::Number->new($1);
	    }
	    else {
		die(__FILE__, ", ", __LINE__, ": no match\n");
	    }
	}
	elsif ($_FIELD_TEXT eq $last_section) {
	    _trace('Got field text section');
	    chop(${$text_ref});

	    # We have the Pdf text of the field objects.  Parse it into
	    # indirect objects.  First create an array of lines of text.
	    my(@lines) = split(/$_EOL_REGEX/o, ${$text_ref});
	    # Create an iterator for the @lines array.
	    my($line_iter_ref) = Bivio::UI::PDF::ArrayIterator->new(\@lines);

	    # Extract the indirect objects.
	    while (!$line_iter_ref->at_end()) {
		# Create a new indirect object and extract its data from the
		# Pdf text.
		my($obj_ref) = Bivio::UI::PDF::IndirectObj->new();
		$obj_ref->extract($line_iter_ref);
		${$obj_dictionary_ref}{$obj_ref->get_obj_number} = $obj_ref;

		# If the object is a dictionary and has a /T field, assume that
		# the value is the field name.
		if ($obj_ref->is_dictionary()) {
		    my($field_name_ref) = $obj_ref->get_direct_obj_ref()
			    ->get_value('T');
		    if (defined($field_name_ref)) {
			my($field_name) = $field_name_ref->get_value();
			${$field_dictionary_ref}{$field_name} = $obj_ref;
		    }
		}
	    }
	}
	elsif ($_XLATOR_SET eq $last_section) {
	    _trace('Got xlator set section');
	    chop(${$text_ref});
	    Bivio::Util::my_require($$text_ref);
	    $xlator_set_ref = ${$text_ref}->new();
	}
	else {
	    Bivio::IO::Alert->die($last_section, ": bad section name\n");
	}
    }
    # Close, so warnings don't always say "at chunk 9993813 of <DATA>"
    close($fh_ref);

    $base_update_ref = Bivio::UI::PDF::OpaqueUpdate->new($base_pdf_text_ref,
	    $base_root_ref, $base_size_ref, $base_xref_ref);

    return ($base_update_ref, $xlator_set_ref, $field_dictionary_ref,
	    $obj_dictionary_ref);
}

#=PRIVATE METHODS

# _get_section() : 
#
#
#
sub _get_section {
    my($fh_ref, $next_section_ref) = @_;
    my($text);
    local($_);

    while (<$fh_ref>) {
	if (/$_SECTION_NAME_REGEX/o) {
	    ${$next_section_ref} = $1;
	    return \$text;
	}
	$text .= $_;
    }
    _trace("Text is \"", $text, "\"") if $_TRACE;
    Bivio::IO::Alert->die('unexpected end of file');
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
