# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Body;
use strict;
$Bivio::UI::PDF::Body::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Body - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Body;
    Bivio::UI::PDF::Body->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Section>

=cut

use Bivio::UI::PDF::Section;
@Bivio::UI::PDF::Body::ISA = ('Bivio::UI::PDF::Section');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Body>

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::UI::PDF::Comment;
use Bivio::UI::PDF::IndirectObj;
use Bivio::UI::PDF::Regex;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_COMMENT_REGEX) = Bivio::UI::PDF::Regex::COMMENT_REGEX();
my($_IGNORE_REGEX) = Bivio::UI::PDF::Regex::IGNORE_REGEX();
my($_OBJ_REGEX) = Bivio::UI::PDF::Regex::OBJ_REGEX();
my($_XREF_REGEX) = Bivio::UI::PDF::Regex::XREF_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Body



=cut

sub new {
    my($self) = Bivio::UI::PDF::Section::new(@_);
    my(undef, $xref_ref, $trailer_ref) = @_;
    $self->{$_PACKAGE} = {
	'item_refs' => [],	# Indirect objects and comments.
	'xref_ref' => $xref_ref,
	'trailer_ref' => $trailer_ref
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_obj"></a>

=head2 add_obj() : 



=cut

sub add_obj {
    my($self, $obj_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    push(@{$fields->{'item_refs'}}, $obj_ref);
    return;
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    local($_);

    map {
	$_->emit($emit_ref);
	# If the item is an indirect object (and not a comment), add a
	# reference to it to the xref section.
	if ($_->is_indirect_obj()) {
	    $fields->{'xref_ref'}->add_obj_ref($_);
	}
    } @{$fields->{'item_refs'}};
    return;
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    _trace("Extracting body") if $_TRACE;

    while (1) {
	if (${$line_iter_ref->current_ref()}
		=~ /$_OBJ_REGEX|$_XREF_REGEX|$_IGNORE_REGEX|$_COMMENT_REGEX/) {
	    # $_OBJ_REGEX returns two values, the object number and the object
	    # generation.
	    if (defined($1)) {
		unless (defined($2)) {
		    die(__FILE__,", ", __LINE__,
			    ": Missing object generation\n");
		}
		# We matched the start of an object definition.
		_trace("Extracting indirect object $1 $2") if $_TRACE;
		# Create a new objct and have it extract its data.
		my($obj_ref) = Bivio::UI::PDF::IndirectObj->new();
		$obj_ref->extract($line_iter_ref);

		$self->add_obj($obj_ref);
	    } elsif (defined($3)) {
		# We matched the start of the xref table.
		return;
	    } elsif (defined($4)) {
		# We matched a blank line.  Skip it.
		$line_iter_ref->increment();
	    } elsif (defined($5)) {
		# We matched a comment line.
		my($comment_ref) = Bivio::UI::PDF::Comment->new();
		$comment_ref->extract($line_iter_ref);
		$self->add_obj($comment_ref);
	    } else {
		die(__FILE__,", ", __LINE__,
			": No regex text returned\n");
	    }
	} else {
	    die(__FILE__,", ", __LINE__,
		    ": No object match\n");
	}
    }

    return;
}

=for html <a name="get_objects_array_ref"></a>

=head2 get_objects_array_ref() : 



=cut

sub get_objects_array_ref {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my(@objects_array);
    local($_);

    map {
	# If the item is an indirect object (and not a comment), add a
	# reference to it to the objects array.
	if ($_->is_indirect_obj()) {
	    push(@objects_array, $_);
	}
    } @{$fields->{'item_refs'}};
    return(\@objects_array);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
