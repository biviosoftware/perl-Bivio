# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::IndirectObj;
use strict;
$Bivio::UI::PDF::IndirectObj::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::IndirectObj - base class for Pdf indiret objects.

=head1 SYNOPSIS

    use Bivio::UI::PDF::IndirectObj;
    Bivio::UI::PDF::IndirectObj->new();

=cut

use Bivio::UI::PDF::PdfObj;
@Bivio::UI::PDF::IndirectObj::ISA = ('Bivio::UI::PDF::PdfObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::IndirectObj>

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::UI::PDF::Array;
use Bivio::UI::PDF::Boolean;
use Bivio::UI::PDF::Dictionary;
use Bivio::UI::PDF::Name;
use Bivio::UI::PDF::Number;
use Bivio::UI::PDF::Regex;
use Bivio::UI::PDF::Stream;
use Bivio::UI::PDF::StringParen;
use Bivio::UI::PDF::StringAngle;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_ENDOBJ_REGEX) = Bivio::UI::PDF::Regex::ENDOBJ_REGEX();
my($_IGNORE_REGEX) = Bivio::UI::PDF::Regex::IGNORE_REGEX();
my($_OBJ_REGEX) = Bivio::UI::PDF::Regex::OBJ_REGEX();
my($_STREAM_START_REGEX) = Bivio::UI::PDF::Regex::STREAM_START_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::IndirectObj



=cut

sub new {
    my($self) = Bivio::UI::PDF::PdfObj::new(@_);
    my(undef, $obj_number, $obj_generation) = @_;
    $self->{$_PACKAGE} = {
	'obj_number' => undef,
	'obj_generation' => undef,
	'direct_obj_ref' => undef,
	'offset' => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="clone"></a>

=head2 clone() : 



=cut

sub clone {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($clone) = Bivio::UI::PDF::IndirectObj->new();
    my($clone_fields) = $clone->{$_PACKAGE};
    $clone_fields->{'obj_number'} = $fields->{'obj_number'};
    $clone_fields->{'obj_generation'} = $fields->{'obj_generation'};
    $clone_fields->{'direct_obj_ref'} = $fields->{'direct_obj_ref'}->clone();
    $clone_fields->{'offset'} = $fields->{'offset'};
    return($clone);
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Store the offset in the Pdf text that this object will have.
    $fields->{'offset'} = $emit_ref->get_length();

    # Store a reference to this object in a hash of all objects in the
    # document.
    $emit_ref->add_obj_ref($self);

    # Add this object's text to the Pdf text.
    $emit_ref->append($fields->{'obj_number'} . ' '
	    . $fields->{'obj_generation'} . " obj\n");
    $fields->{'direct_obj_ref'}->emit($emit_ref);
    $emit_ref->append("\nendobj\n");

    return;
}

=for html <a name="emit_with_kids"></a>

=head2 emit_with_kids() : 



=cut

sub emit_with_kids {
    my($self, $emit_ref, $pdf_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    local($_);

    # I think this only makes sense with a dictionary object.
    unless ($self->is_dictionary()) {
	die(__FILE__,", ", __LINE__, ": dictionary expected.\n");
    }

    # First emit this object.
    $self->emit($emit_ref);

    # See if there are any kids and emit them.
    my($dictionary_ref) = $self->get_direct_obj_ref();
    my($kids_array_ref) = $dictionary_ref->get_value('Kids');
    if (defined($kids_array_ref)) {
	my($array_ref) = $kids_array_ref->get_array_ref();
	# The array should be an array of IndirectObjRef objects.
	map {
	    my($obj_ref)
		    = $pdf_ref->get_obj_ref_by_number($_->get_obj_number());
	    $obj_ref->emit_with_kids($emit_ref, $pdf_ref);
	} @{$array_ref};
    }
    return;
}

=for html <a name="extract"></a>

=head2 extract() : extract an indirect object from an array of
lines of Pdf text.



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    # The current line should be the one containing the object number, the
    # object generation, and the 'obj' keyword.
    if (${$line_iter_ref->current_ref()} =~ /$_OBJ_REGEX/) {
	unless (defined($1) && defined($2)) {
	    die(__FILE__,", ", __LINE__,
		    ": missing object number or generation number\n");
	}
	$fields->{'obj_number'} = $1;
	$fields->{'obj_generation'} = $2;
    }
    else {
	die(__FILE__,", ", __LINE__,
		": missing object number or generation number\n");
    }
    $line_iter_ref->increment();

    my($direct_obj_ref) = $self->extract_direct_obj($line_iter_ref);

    # A stream object has a dictionary before the 'stream' keyword.
    while (1) {
	if (${$line_iter_ref->current_ref()}
		=~ /$_ENDOBJ_REGEX|$_STREAM_START_REGEX|$_IGNORE_REGEX/) {
	    if (defined($1)) {
		# We found the end of the object.
		last;
	    } elsif (defined($2)) {
		# We found a stream keyword.
		unless ($direct_obj_ref->is_dictionary()) {
		    die(__FILE__,", ", __LINE__,
			    ": no dictionary for stream\n");
		}
		$direct_obj_ref = Bivio::UI::PDF::Stream->new($direct_obj_ref);
		$direct_obj_ref->extract($line_iter_ref);
	    } elsif (defined($3)) {
		# We found a blank line.
		$line_iter_ref->increment();
	    } else {
		die(__FILE__,", ", __LINE__, ": no matched text returned\n");
	    }
	} else {
	    die(__FILE__,", ", __LINE__, ": No match\n");
	}
    }

    $fields->{'direct_obj_ref'} = $direct_obj_ref;
    $line_iter_ref->increment();
    return;
}

=for html <a name="get_direct_obj_ref"></a>

=head2 get_direct_obj_ref() : 



=cut

sub get_direct_obj_ref {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'direct_obj_ref'});
}

=for html <a name="get_obj_generation"></a>

=head2 get_obj_generation() : 



=cut

sub get_obj_generation {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'obj_generation'});
}

=for html <a name="get_obj_number"></a>

=head2 get_obj_number() : 



=cut

sub get_obj_number {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'obj_number'});
}

=for html <a name="get_offset"></a>

=head2 get_offset() : 



=cut

sub get_offset {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'offset'});
}

=for html <a name="insert_field_value"></a>

=head2 insert_field_value() : 



=cut

sub insert_field_value {
    my($self, $new_value, $form_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($obj_ref) = $fields->{'direct_obj_ref'};
    unless ($obj_ref->is_dictionary) {
	die(__FILE__,", ", __LINE__, ": not a dictionary\n");
    }
    return($obj_ref->insert_field_value($new_value, $form_ref));
}

=for html <a name="is_dictionary"></a>

=head2 is_dictionary() : 



=cut

sub is_dictionary {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    unless (defined($fields->{'direct_obj_ref'})) {
	return(0);
    }
    return($fields->{'direct_obj_ref'}->is_dictionary());
}

=for html <a name="is_indirect_obj"></a>

=head2 is_indirect_obj() : 



=cut

sub is_indirect_obj {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(1);
}

=for html <a name="is_stream"></a>

=head2 is_stream() : 



=cut

sub is_stream {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    unless (defined($fields->{'direct_obj_ref'})) {
	return(0);
    }
    return($fields->{'direct_obj_ref'}->is_stream());
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
