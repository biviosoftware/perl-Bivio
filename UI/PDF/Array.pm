# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Array;
use strict;
$Bivio::UI::PDF::Array::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Array - encapsulates a PDF array direct object.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Array;
    Bivio::UI::PDF::Array->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::DirectObj>

=cut

use Bivio::UI::PDF::DirectObj;
@Bivio::UI::PDF::Array::ISA = ('Bivio::UI::PDF::DirectObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Array>

=cut


#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_ARRAY_END_REGEX) = Bivio::UI::PDF::Regex::ARRAY_END_REGEX();
my($_IGNORE_REGEX) = Bivio::UI::PDF::Regex::IGNORE_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Array



=cut

sub new {
    my($self) = Bivio::UI::PDF::DirectObj::new(@_);
    $self->{$_PACKAGE} = {
	'value_refs' => []
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
    my($clone) = Bivio::UI::PDF::Array->new();
    my($clone_fields) = $clone->{$_PACKAGE};
    local($_);

    map {
	push (@{$clone_fields->{'value_refs'}}, $_->clone());
    } @{$fields->{'value_refs'}};

    return($clone);
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    local($_);

    $emit_ref->append_no_new_lines('[ ');
    map {
	if ($self->get_max_line()
		< ($_->emit_length() + 1
			+ $emit_ref->get_current_line_count())) {
	    # Start a new line.  Always allow room for the ending ']'.
	    $emit_ref->append("\n");
	}
	$_->emit($emit_ref);
	$emit_ref->append_no_new_lines(' ');
    } @{$fields->{'value_refs'}};
    $emit_ref->append_no_new_lines(']');
    return;
}

=for html <a name="emit_length"></a>

=head2 emit_length() : 



=cut

sub emit_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($length) = 4;	# 2 for the initial '[ ' and 1 for the final ']'.
    local($_);

    map {
	$length += $_->emit_length() + 1;	# 1 for a space.
    } @{$fields->{'value_refs'}};

    return($length);
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    # The current line nas the '[' on it.  It may or may not have array items
    # in it, too.  Get the text of the line, remove the '[', remove the current
    # line from the iterator, and push the altered text back on the iterator so
    # it gets read again.
    my($text) = ${$line_iter_ref->current_ref()};
    $text =~ s/\[//;
    $line_iter_ref->replace_first($text);

    _trace("Extracting array starting\n\t\"",
	    ${$line_iter_ref->current_ref()}, "\"") if $_TRACE;

    while (1) {
	if (${$line_iter_ref->current_ref()}
		=~ /$_ARRAY_END_REGEX|$_IGNORE_REGEX/) {
	    if (defined($1)) {
		# We found the end of the array.  Remove the ']'.
		$line_iter_ref->replace_first($');
		last;
	    } elsif (defined($2)) {
		# We found an empty line.
		$line_iter_ref->increment();
	    } else {
		die(__FILE__,", ", __LINE__,
		    ": No match text returned\n");
	    }
	} else {
	    # Must be a member of the array.
	    my($direct_obj_ref) = $self->extract_direct_obj($line_iter_ref);
	    push(@{$fields->{'value_refs'}}, $direct_obj_ref);
	}
    }
    return;
}

=for html <a name="get_array_ref"></a>

=head2 get_array_ref() : 



=cut

sub get_array_ref {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'value_refs'});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
