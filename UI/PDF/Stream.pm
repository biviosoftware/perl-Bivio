# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Stream;
use strict;
$Bivio::UI::PDF::Stream::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Stream - encapsulates a PDF direct stream object.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Stream;
    Bivio::UI::PDF::Stream->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::DirectObj>

=cut

use Bivio::UI::PDF::DirectObj;
@Bivio::UI::PDF::Stream::ISA = ('Bivio::UI::PDF::DirectObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Stream>

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_STREAM_END_REGEX) = Bivio::UI::PDF::Regex::STREAM_END_REGEX();
my($_STREAM_START_REGEX) = Bivio::UI::PDF::Regex::STREAM_START_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Stream



=cut

sub new {
    my($self) = Bivio::UI::PDF::DirectObj::new(@_);
    my(undef, $dictionary_ref) = @_;
    $self->{$_PACKAGE} = {
	'dictionary_ref' => $dictionary_ref,
	'text' => undef
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
    $fields->{'dictionary_ref'}->emit($emit_ref);

    $emit_ref->append("\nstream" . $fields->{'text'}
	    . "endstream");
    return;
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    unless (${$line_iter_ref->current_ref()} =~ /$_STREAM_START_REGEX/) {
	die(__FILE__,", ", __LINE__, ": no stream keyword\n");
    }

    # Capture the end of line sequence after the 'stream' keyword.
    $fields->{'text'} = ${$line_iter_ref->current_eol_ref()};
    $line_iter_ref->increment();

    _trace("Extracting stream starting\n\t\"",
	    ${$line_iter_ref->current_ref()}, "\"") if $_TRACE;

#TODO: we need to handle the end of line sequence.  The stream's dictionary
# has a count of characters in the stream that includes the end of line
# characters.
    while (1) {
	if (${$line_iter_ref->current_ref()} =~ /$_STREAM_END_REGEX/) {
	    if (defined($1)) {
		# We found the end of the stream.
		$line_iter_ref->increment();
		last;
	    } else {
		die(__FILE__,", ", __LINE__, ": no matched text returned\n");
	    }
	} else {
	    # This line must be stream text.
	    $fields->{'text'} .= ${$line_iter_ref->current_ref()};
	    $fields->{'text'} .= ${$line_iter_ref->current_eol_ref()};
	    $line_iter_ref->increment();
	}
    }
    return;
}

=for html <a name="is_stream"></a>

=head2 is_stream() : 



=cut

sub is_stream {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(1);
}

=for html <a name="set_dictionary"></a>

=head2 set_dictionary() : 



=cut

sub set_dictionary {
    my($self, $dictionary_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{'dictionary_ref'} = $dictionary_ref;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
