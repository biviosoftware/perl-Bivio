# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::String;
use strict;
$Bivio::UI::PDF::String::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::String - base class for the two kinds of direct string object:
string and angle.

=head1 SYNOPSIS

    use Bivio::UI::PDF::String;
    Bivio::UI::PDF::String->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::DirectObj>

=cut

use Bivio::UI::PDF::DirectObj;
@Bivio::UI::PDF::String::ISA = ('Bivio::UI::PDF::DirectObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::String>

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_CONTINUED_STRING_REGEX) = Bivio::UI::PDF::Regex::CONTINUED_STRING_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::String



=cut

sub new {
    my($self) = Bivio::UI::PDF::DirectObj::new(@_);
    # The text argument is optional.
    my(undef, $text) = @_;
    $self->{$_PACKAGE} = {
	'text' => $text
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="clone"></a>

=head2 clone() : 



=cut

sub clone {
    my($self, $clone) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($clone_fields) = $clone->{$_PACKAGE};
    $clone_fields->{'text'} = $fields->{'text'};
    return;
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $emit_ref->append($self->_get_opening_char() . $fields->{'text'}
	    . $self->_get_closing_char());
    return;
}

=for html <a name="emit_length"></a>

=head2 emit_length() : 



=cut

sub emit_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(length($fields->{'text'}) + 2);	# 2 for the enclosing chars.
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($text) = ${$line_iter_ref->current_ref()};
    my($opening_char) = "\\" . $self->_get_opening_char();
    $text =~ s/\s*$opening_char//;
    $line_iter_ref->replace_first($text);
    $fields->{'text'} = '';

    my($regex) = $self->_get_closing_regex();
    # Strings may span many lines.
    while (1) {
	if (${$line_iter_ref->current_ref()}
		=~ /$regex|$_CONTINUED_STRING_REGEX/) {
	    if (defined($1)) {
		# We found the end of a string.
		# If there are any '\)' sequences in the text, the regular
		# expression will only return the text following the last one.
		$fields->{'text'} .= $` . $&;
		# Get rid of the closing paren or angle.
		chop($fields->{'text'});

		$line_iter_ref->replace_first($');

		_trace("Extracting ", $self->_get_string_type(),
			" string\n\t\"", $fields->{'text'}, "\"") if $_TRACE;
		last;
	    }
	    elsif (defined($2)) {
		# We found a continued string.
		$fields->{'text'} .= $2;

		$line_iter_ref->replace_first($');

		_trace("Extracting continued string\n\t\"",
			$fields->{'text'}, "\"") if $_TRACE;

		# Go to the next line.
		$line_iter_ref->increment();
	    } else {
		die(__FILE__,", ", __LINE__, ": no matched text returned\n");
	    }
	}
	elsif ($self->_get_closing_char()
		eq substr(${$line_iter_ref->current_ref()}, 0, 1)) {
	    # The regular expression didn't match because the next character is
	    # just the string closing character, which it doesn't match.
	    $fields->{'text'} = '';
	    $line_iter_ref->replace_first(
		    substr(${$line_iter_ref->current_ref()}, 1));

	    _trace("Extracting ", $self->_get_string_type(),
		    " string\n\t\"", $fields->{'text'}, "\"") if $_TRACE;
	    last;
	}
	else {
	    die(__FILE__,", ", __LINE__, ": No match for \"",
		    ${$line_iter_ref->current_ref()}, "\"\n");
	}
    }
    return;
}

=for html <a name="get_value"></a>

=head2 get_value() : 



=cut

sub get_value {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'text'});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
