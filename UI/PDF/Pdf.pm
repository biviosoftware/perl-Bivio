# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Pdf;
use strict;
$Bivio::UI::PDF::Pdf::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Pdf - the parent class of all Pdf objects.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Pdf;
    Bivio::UI::PDF::Pdf->new(string pdf_file);

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::Pdf::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Pdf>

=cut


=head1 CONSTANTS

=cut

# =for html <a name="EOL_REGEX"></a>

# =head2 EOL_REGEX : string

# This regular expression fragment matches the normal end of line sequences.  It
# has parens around it with the "?:" construction.  The perl pattern matching
# functions are sensitive to how many sets of parens are in a regular expression.


# =cut

# sub EOL_REGEX {
#     return('(?:(?:\r\n)|\r|\n)');
# }

#=IMPORTS
use Bivio::UI::PDF::ArrayIterator;
use Bivio::UI::PDF::Emit;
use Bivio::UI::PDF::FirstParsedUpdate;
use Bivio::UI::PDF::OpaqueUpdate;
use Bivio::UI::PDF::Regex;
use Bivio::UI::PDF::ParsedUpdate;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_EOL_REGEX) = Bivio::UI::PDF::Regex::EOL_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string pdf_file) : Bivio::UI::PDF::Pdf



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    my(undef, $arg1) = @_;
    my($fields) = $self->{$_PACKAGE};
    $self->{$_PACKAGE} = {
	# Keep a reference to the original Pdf file text.
	'pdf_text_ref' => undef,
	# The Pdf literature doesn't seem to have a name for the pieces of
	# a Pdf file that are added at different times.  We will call them
	# updates, including the original piece, even though it isn't an
	# "update", logically speaking.  The updates array is an array of
	# references to Update objects, each of which has data about an
	# update.  They are stored in the order in which they were added
	# to the file, newest first.
	'updates_ref' => [],
	# Keep an array of all the updates sorted in the reverse order in which
	# they were added to the file.
	'sorted_updates_ref' => [],
	# Keep a dictionary of references to all the indirect objects in the
	# document by their object number.
	'object_refs_ref' => {},
	# Keep a dictionary of references to all the field objects in the
	# document by their field name.
	'field_refs_ref' => {},
	# Keep a reference to the catalog object.
	'catalog_ref' => undef
    };

    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_update"></a>

=head2 add_update() : 



=cut

sub add_update {
    my($self, $update_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    push(@{$fields->{'updates_ref'}}, $update_ref);
    return;
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($emit_ref) = Bivio::UI::PDF::Emit->new();
    local($_);

    map {
	$_->emit($emit_ref);
    } @{$fields->{'updates_ref'}};

    return($emit_ref->get_text_ref());
}

=for html <a name="get_field_ref_by_name"></a>

=head2 get_field_ref_by_name() : 



=cut

sub get_field_ref_by_name {
    my($self, $field_name) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(${$fields->{'field_refs_ref'}}{$field_name});
}

=for html <a name="get_length"></a>

=head2 get_length() : 



=cut

sub get_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    local($_);

    # Add up the lengths of all the top level updates.
    my($length);
    map {
	$length += $_->get_length();
    } @{$fields->{'updates_ref'}};
    return($length);
}

=for html <a name="get_obj_ref_by_number"></a>

=head2 get_obj_ref_by_number() : 



=cut

sub get_obj_ref_by_number {
    my($self, $field_number) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(${$fields->{'object_refs_ref'}}{$field_number});
}

=for html <a name="get_pdf_text_ref"></a>

=head2 get_pdf_text_ref() : 



=cut

sub get_pdf_text_ref {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'pdf_text_ref'});
}

=for html <a name="get_root_pointer"></a>

=head2 get_root_pointer() : 



=cut

sub get_root_pointer {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'sorted_updates_ref'}->[0]->get_root_pointer());
}

=for html <a name="get_size"></a>

=head2 get_size() : 



=cut

sub get_size {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'sorted_updates_ref'}->[0]->get_size());
}

=for html <a name="get_xref_offset"></a>

=head2 get_xref_offset() : 



=cut

sub get_xref_offset {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

#TODO: This is a hack.  Linearized documents have a dummy xref section in the
# first update, so use the secont.
    my($xref_offset) = $fields->{'sorted_updates_ref'}->[0]->get_xref_offset();
    if (0 == $xref_offset) {
	return($xref_offset);
    }
    else {
	return($fields->{'sorted_updates_ref'}->[1]->get_xref_offset());
    }
}

=for html <a name="parse_complete_pdf"></a>

=head2 parse_complete_pdf() : 



=cut

sub parse_complete_pdf {
    my($self, $arg1) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($text_ref);
    my(@lines);
    local($_);

    # Handle the various cases of overloading of this function.
    if (!defined($arg1)) {
	die(__FILE__, ", ", __LINE__, ": No Pdf text\n");
    } else {
	if (ref($arg1)) {
	    if ('SCALAR' eq ref($arg1)) {
		# Must be a reference to a string containing the Pdf text.
		$fields->{'pdf_text_ref'} = $arg1;
	    } else {
		die(__FILE__, ", ", __LINE__,
			": Unexpected reference type \"", ref($arg1), "\"\n");
	    }
	} else {
	    # Must be a string constaining a file name.  Open the Pdf file and
	    # read it into a string.
	    my($real_pdf_file);
	    unless (-r $arg1) {
		die(__FILE__, ", ", __LINE__,
			": can't read file \"$arg1\"\n");
	    }
	    if (-l $arg1) {
		$real_pdf_file = readlink($arg1);
	    } else {
		$real_pdf_file = $arg1;
	    }
	    my($file_length) = (-s $real_pdf_file);
	    if ($file_length == 0) {
		die(__FILE__, ", ", __LINE__,
			": Zero length file \"$arg1\"\n");
	    }
	    open(PDF, $arg1)
		    or die(__FILE__, ", ", __LINE__,
			    ": Error opening \"$arg1\"\n");
	    binmode(PDF);
	    read(PDF, my($file_text), $file_length)
		    or die(__FILE__, ", ", __LINE__,
			    ": Error reading \"$arg1\"\n");
	    $fields->{'pdf_text_ref'} = \$file_text;
	}
    }

    # Divide the text into lines.  The regular expression also returns the end
    # of line sequence, since we need it to really handle streams correctly.
    @lines = split(/$_EOL_REGEX/, ${$fields->{'pdf_text_ref'}});

    # Create an iterator for the @lines array.
    my($line_iter_ref) = Bivio::UI::PDF::ArrayIterator->new(\@lines);

    # Add the initial update object.
    my($update_ref) = Bivio::UI::PDF::FirstParsedUpdate->new();
    $self->add_update($update_ref);

    # Extract the data into the update.
    $update_ref->extract($line_iter_ref);

    # In case there are more updates...
    while (!$line_iter_ref->at_end()) {
	$update_ref = Bivio::UI::PDF::ParsedUpdate->new();
	$self->add_update($update_ref);
	$update_ref->extract($line_iter_ref);
    }

    # Now sort the updates in reverse order in which they were added to the
    # file.
    $self->_sort_updates();

    # Go through the updates in sorted order, extract the indirect objects,
    # populate the object_refs_ref dictionarie, and find the catalog object.
    # Going through the updates in sorted order allows newer versions of
    # objects to override older ones.
    map {
	# For each indirect object in the update...
	map {
	    # Add a reference to the object to the dictionary of all objects,
	    # keyed by the object's number.
	    ${$fields->{'object_refs_ref'}}{$_->get_obj_number()}
		    = $_;
	    # If the object is a dictionary, see if it is the catalog object.
	    if ($_->is_dictionary()) {
		my($type_value_ref);
		if (defined($type_value_ref = $_->get_direct_obj_ref()
			->get_value('Type'))) {
		    if ('Catalog' eq $type_value_ref->get_value()) {
			# We found the catalog.
			$fields->{'catalog_ref'} = $_;
		    }
		}
	    }
	} @{$_->get_objects_array_ref()};
    } @{$fields->{'sorted_updates_ref'}};
    unless (defined($fields->{'catalog_ref'})) {
	die(__FILE__, ", ", __LINE__, ": no catalog object\n");
    }

    # Find the fields array in the catalog.  The 'AcroForm' entry in the
    # catalog dictionary is an indirect reference to the AcroForm dictionary.
    # That dictionary contains an entry named 'Fields' that is an array of
    # indirect references to all the field objects.
    my($acroform_ref) = $fields->{'catalog_ref'}->get_direct_obj_ref()
	    ->get_value('AcroForm');
    $acroform_ref = $acroform_ref->get_obj_number();
    $acroform_ref = ${$fields->{'object_refs_ref'}}{$acroform_ref};
    # This gets a reference to the dictionary, finally.
    $acroform_ref = $acroform_ref->get_direct_obj_ref();

    # This is a reference to the array of indirect references to the field
    # objects.
    my($field_array_ref) = $acroform_ref->get_value('Fields')->get_array_ref();

    # Go through the array and add aeach object to the dictionary of field
    # objects.
    map {
	# Each entry in the array should be a reference to an indirect object
	# reference object.
	my($obj_number) = $_->get_obj_number();
	# Get a reference to an IndirectObj object.
	my($indirect_obj_ref) = ${$fields->{'object_refs_ref'}}{$obj_number};
	# Get a reference to the direct object (a dictionary).
	my($direct_obj_ref) = $indirect_obj_ref->get_direct_obj_ref();
	my($field_name) = undef;
	$field_name = $direct_obj_ref->get_value('T')->get_value();
	# Store a reference to the indirect object in the field_refs_ref
	# dictionary with the field name as key.
	${$fields->{'field_refs_ref'}}{$field_name} = $indirect_obj_ref;
    } @{$field_array_ref};

    return;
}

=for html <a name="print_stuff"></a>

=head2 print_stuff() : 



=cut

sub print_stuff {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    print("Root pointer is \"", $self->get_root_pointer()->get_value(), "\"\n");
    print("Size \"", $self->get_size()->get_value(), "\"\n");
    print("Xref offset \"", $self->get_xref_offset()->get_value(), "\"\n");

    return;
}

=for html <a name="set_base_root_pointer"></a>

=head2 set_base_root_pointer() : 



=cut

sub set_base_root_pointer {
    my($self, $pointer) = @_;
    my($fields) = $self->{$_PACKAGE};
    ${$fields->{'updates_ref'}}[0]->set_root_pointer($pointer);
    return;
}

=for html <a name="set_base_xref_offset"></a>

=head2 set_base_xref_offset() : 



=cut

sub set_base_xref_offset {
    my($self, $offset) = @_;
    my($fields) = $self->{$_PACKAGE};
    ${$fields->{'updates_ref'}}[0]->set_xref_offset($offset);
    return;
}

#=PRIVATE METHODS

# _find_next_oldest_update() : 
#
#
#
sub _find_next_oldest_update {
    my($self, $update_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    local($_);

    map {
	my($prev_offset) = $_->get_prev_offset();
	if (defined($prev_offset)) {
	    if ($prev_offset->equals($update_ref->get_xref_offset())) {
		return($_);
	    }
	}
    } @{$fields->{'updates_ref'}};
    return(undef);
}

# _find_no_prev() : 
#
# Find the first update that has no /Prev entry in its trailer dictionary.
# There should be only one such update.
#
sub _find_no_prev {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    local($_);

    map {
	my($prev_offset) = $_->get_prev_offset();
	unless (defined($prev_offset)) {
	    return($_);
	}
    } @{$fields->{'updates_ref'}};

    die(__FILE__, ", ", __LINE__, ": No update without a prev offset.\n");
}

# _get_dummy_startxref_update() : 
#
#
#
sub _get_dummy_startxref_update {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    local($_);

    map {
	my($xref_offset) = $_->get_xref_offset();
	if (defined($xref_offset) && (0 == $xref_offset->get_value())) {
	    return($_);
	}
    } @{$fields->{'updates_ref'}};

    die(__FILE__, ", ", __LINE__, ": no dummy startxref offset\n");
}

sub _sort_updates {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    # First find the update with no prev offset.  There should be only one, and
    # it should be the first update.
    my($next_update_ref) = $self->_find_no_prev();

    # Now keep finding the next oldest update.
#TODO: Can you use reverse to reverse an array savely, or do we need this
# temporary?
    my(@updates_tmp);
    while (defined($next_update_ref)) {
	push(@updates_tmp, $next_update_ref);
	$next_update_ref
		= $self->_find_next_oldest_update($next_update_ref);
    }
    unless ($#updates_tmp == $#{$fields->{'updates_ref'}}) {
	# A file that has been lineraized doesn't have all its updates linked
	# together in the normal way.  Assume that if we are just missing one
	# update, and there are just two, total, that the missing one is the
	# liniarize update, which has a dummy startxref offset of 0.  Add it
	# in.
	if ((0 == $#updates_tmp) && (1 == $#{$fields->{'updates_ref'}})) {
	    $next_update_ref = $self->_get_dummy_startxref_update();
	} else {
	    die(__FILE__,", ", __LINE__, ": missing updates\n");
	}
	push(@updates_tmp, $next_update_ref);
    }

    # Now reverse the order.
    @{$fields->{'sorted_updates_ref'}} = reverse(@updates_tmp);

    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
