# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Xref;
use strict;
$Bivio::UI::PDF::Xref::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Xref - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Xref;
    Bivio::UI::PDF::Xref->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Section>

=cut

use Bivio::UI::PDF::Section;
@Bivio::UI::PDF::Xref::ISA = ('Bivio::UI::PDF::Section');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Xref>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_TRAILER_REGEX) = Bivio::UI::PDF::Regex::TRAILER_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Xref



=cut

sub new {
    my($self, $header_ref, $body_ref) = Bivio::UI::PDF::Section::new(@_);
    $self->{$_PACKAGE} = {
	'header_ref' => $header_ref,
	'body_ref' => $body_ref,
	# An array of references to the indirect objects in this update.
	'obj_refs' => []
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_obj_ref"></a>

=head2 add_obj_ref() : 



=cut

sub add_obj_ref {
    my($self, $obj_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    push(@{$fields->{'obj_refs'}}, $obj_ref);
    return;
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Sort the objects in order of object number.  The xref has subsections of
    # objects with consecutive object numbers.
    my(@sorted_obj_refs) = sort {
	$a->get_obj_number() <=> $b->get_obj_number()
    } @{$fields->{'obj_refs'}};

    # Mark in the emit object where the offset where the xref table starts.
    $emit_ref->mark_xref_start();

    # Cycle through the objects and build up the xref section.
    $emit_ref->append("xref\n");
    # Accumulate a subsection here.  The first one starts with the head of the
    # free list, which contains, by convention, object zero.
    my($xref_sub_section) = "0000000000 65535 f \n";
    my($first_obj_number) = 0;
    my($obj_count) = 1;
    map {
	if ($first_obj_number + $obj_count != $_->get_obj_number()) {
	    # We found a discontinuity in the object numbers.  Write out the
	    # existing sub-section and start a new one.
	    $emit_ref->append($first_obj_number . ' ' . $obj_count . "\n"
		    . $xref_sub_section);

	    # Reset the tracking information.
	    $first_obj_number = $_->get_obj_number();
	    $obj_count = 0;
	    $xref_sub_section = '';
	}

	# Put this object in the current sub-section.
	$xref_sub_section .= sprintf("%.10d %.5d n \n",
		$_->get_offset(), $_->get_obj_generation());
	$obj_count += 1;
    } @sorted_obj_refs;
    # Write out the last sub-section
    $emit_ref->append($first_obj_number . ' ' . $obj_count . "\n"
		    . $xref_sub_section);

    return;
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

#TODO:  Just skip over the xref section for now.
    while (1) {
	if (${$line_iter_ref->current_ref()}
		=~ /$_TRAILER_REGEX/) {
	    last;
	} else {
	    $line_iter_ref->increment();
	}
    }

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
