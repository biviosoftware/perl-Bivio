# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Trailer;
use strict;
$Bivio::UI::PDF::Trailer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Trailer - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Trailer;
    Bivio::UI::PDF::Trailer->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Section>

=cut

use Bivio::UI::PDF::Section;
@Bivio::UI::PDF::Trailer::ISA = ('Bivio::UI::PDF::Section');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Trailer>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_DIC_START_REGEX) = Bivio::UI::PDF::Regex::DIC_START_REGEX();
my($_EOF_REGEX) = Bivio::UI::PDF::Regex::EOF_REGEX();
my($_IGNORE_REGEX) = Bivio::UI::PDF::Regex::IGNORE_REGEX();
my($_STARTXREF_REGEX) = Bivio::UI::PDF::Regex::STARTXREF_REGEX();
my($_TRAILER_REGEX) = Bivio::UI::PDF::Regex::TRAILER_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Trailer



=cut

sub new {
    my($self) = Bivio::UI::PDF::Section::new(@_);
    $self->{$_PACKAGE} = {
	# Reference to the trailer dictionary.
	'dictionary' => Bivio::UI::PDF::Dictionary->new(),
	# Reference to a number object containing the offset of the xref.
	'startxref' => {}
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    $emit_ref->append("trailer\n");
    $fields->{'dictionary'}->emit($emit_ref);
    $emit_ref->append("\nstartxref\n");
    $fields->{'startxref'}->emit($emit_ref);
    $emit_ref->append("\n%%EOF\n");

    return;
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    unless (${$line_iter_ref->current_ref()} =~ /$_TRAILER_REGEX/) {
	die(__FILE__, ", ", __LINE__, "missing tralier keyword");
    }
    $line_iter_ref->increment();

    unless (${$line_iter_ref->current_ref()} =~ /$_DIC_START_REGEX/) {
	die(__FILE__, ", ", __LINE__, "missing tralier dictionary");
    }

    # The first part of the trailer consists of a dictionary.
#    $fields->{'dictionary'} = Bivio::UI::PDF::Dictionary->new();
    $fields->{'dictionary'}->extract($line_iter_ref);

    while (1) {
	if (${$line_iter_ref->current_ref()}
		=~ /$_EOF_REGEX|$_IGNORE_REGEX|$_STARTXREF_REGEX/) {
	    if (defined($1)) {
		# We matched the end of file keyword.
		$line_iter_ref->increment();
		return;
	    }
	    elsif (defined($2)) {
		# We matched a blank line.
		$line_iter_ref->increment();
	    }
	    elsif (defined($3)) {
		# We found the startxref keyword.  The offset of the xref is on
		# the next line.
		$line_iter_ref->increment();
		$fields->{'startxref'} = Bivio::UI::PDF::Number->new();
		$fields->{'startxref'}->extract($line_iter_ref);
	    }
	    else {
		die(__FILE__, ", ", __LINE__, ": no matched text returned\n");
	    }
	} else {
	    die(__FILE__, ", ", __LINE__, ": No match\n");
	}
    }

    return;
}

=for html <a name="get_prev_offset"></a>

=head2 get_prev_offset() : 



=cut

sub get_prev_offset {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'dictionary'}->get_value('Prev'));
}

=for html <a name="get_root_pointer"></a>

=head2 get_root_pointer() : 



=cut

sub get_root_pointer {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'dictionary'}->get_value('Root'));
}

=for html <a name="get_size"></a>

=head2 get_size() : 



=cut

sub get_size {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'dictionary'}->get_value('Size'));
}

=for html <a name="get_xref_offset"></a>

=head2 get_xref_offset() : 



=cut

sub get_xref_offset {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'startxref'});
}

=for html <a name="set_prev_offset"></a>

=head2 set_prev_offset() : 



=cut

sub set_prev_offset {
    my($self, $number_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{'dictionary'}->set_value('Prev', $number_ref);
    return;
}

=for html <a name="set_root_pointer"></a>

=head2 set_root_pointer() : 



=cut

sub set_root_pointer {
    my($self, $indirect_obj_ref_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{'dictionary'}->set_value('Root', $indirect_obj_ref_ref);
    return;
}

=for html <a name="set_size"></a>

=head2 set_size() : 



=cut

sub set_size {
    my($self, $number_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{'dictionary'}->set_value('Size', $number_ref);
    return;
}

=for html <a name="set_xref_offset"></a>

=head2 set_xref_offset() : 



=cut

sub set_xref_offset {
    my($self, $number_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{'startxref'} = $number_ref;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
