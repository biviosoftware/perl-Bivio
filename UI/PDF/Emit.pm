# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Emit;
use strict;
$Bivio::UI::PDF::Emit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Emit - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Emit;
    Bivio::UI::PDF::Emit->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::Emit::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Emit>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Emit



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	# The Pdf text of the whole document.
	'text' => '',
	# The number of characters in the last line in 'text'.
	'current_line_count' => 0,
	# Keep a document wide hash with keys that are object numbers and
	# values that are pointers to the latest instance of an object with
	# that number.  This is necessary to get the '/Size' attribute for the
	# trailer.
	'obj_refs_ref' => {},
	# Keep the reference of a Number that has the start of the xref section.
	'xref_start_ref' => undef
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
    ${$fields->{'obj_refs_ref'}}{$obj_ref->get_obj_number()} = $obj_ref;
    return;
}

=for html <a name="append"></a>

=head2 append() : 



=cut

sub append {
    my($self, $text) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Handle either text or a reference to text as input.
    my($text_ref);
    if (ref($text)) {
	$text_ref = $text;
    }
    else {
	$text_ref = \$text;
    }

    # Find the last "\n" in the new text, if there is one.  If there is, reset
    # current_line_count.
    my($index) = rindex(${$text_ref}, "\n");
    if (-1 == $index) {
	# We didn't find a "\n".
	$fields->{'current_line_count'} += length(${$text_ref});
    }
    else {
	$fields->{'current_line_count'} = length(${$text_ref}) - $index;
    }

    $fields->{'text'} .= ${$text_ref};

    return;
}

=for html <a name="append_no_new_lines"></a>

=head2 append_no_new_lines() : 



=cut

sub append_no_new_lines {
    my($self, $text) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{'current_line_count'} += length($text);
    $fields->{'text'} .= $text;
    return;
}

=for html <a name="get_current_line_count"></a>

=head2 get_current_line_count() : 



=cut

sub get_current_line_count {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'current_line_count'});
}

=for html <a name="get_length"></a>

=head2 get_length() : 



=cut

sub get_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(length($fields->{'text'}));
}

=for html <a name="get_text_ref"></a>

=head2 get_text_ref() : 



=cut

sub get_text_ref {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(\$fields->{'text'});
}

=for html <a name="get_xref_start"></a>

=head2 get_xref_start() : 



=cut

sub get_xref_start {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'xref_start_ref'});
}

=for html <a name="mark_xref_start"></a>

=head2 mark_xref_start() : 



=cut

sub mark_xref_start {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{'xref_start_ref'}
	    = Bivio::UI::PDF::Number->new(length(${$self->get_text_ref()}));
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
