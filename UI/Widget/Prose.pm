# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::Prose;
use strict;
$Bivio::UI::Widget::Prose::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::Prose::VERSION;

=head1 NAME

Bivio::UI::Widget::Prose - renders text embedded with widgets and values

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Widget::Prose;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget::Join>

=cut

use Bivio::UI::Widget::Join;
@Bivio::UI::Widget::Prose::ISA = ('Bivio::UI::Widget::Join');

=head1 DESCRIPTION

C<Bivio::UI::Widget::Prose> defines a language of text comingled with widgets,
widget values, and view values.  The text can be in any output language,
e.g. XML, HTML, or rfc822.  The intent is for the text and dynamic values to be
free-form.  Prose widgets are probably not appropriate for displaying program
source.

The text looks like whatever output language you are using.  You can
insert a simple L<Bivio::UI::ViewLanguage|Bivio::UI::ViewLanguage>
function call right in the text:

   Here is some text.  Here is a dynamic vs_any_value();.

The function C<vs_any_value> is an application specific shortcut.  You
can insert widgets the same way:

   Here is an Image('my_image', 'my alt text'); in the middle.

Any ViewLanguage function call can be inserted as long as it does not
contain the code sequence C<);> (close parethesis followed immediately
by a semicolon).

You can escape a word followed by an open parethesis as follows:

   My text with escape<(>s)

This sequence is a bit cumbersome to type, but is unlikely to occur
in any of the common text formatting languages or in source text.
Ideally, you would be able to insert a space between the word (C<escape>
in this case) and the open parenthesis, e.g.

   My text with escape (s)

However, this is cumbersome in certain languages, hence the escape
mechanism.

You can enter more complex ViewLanguage programs by bracketing the
programs as follows:

   Here is a complex <{
       if (vs_some_condition()) {
           vs_do_this();
       else {
           vs_do_that();
       }
   }
   }> and some more text here.

Currently, nested bracketing is not supported.  You can escape a
E<lt>{ or }E<gt> sequence using the same bracketing technique around
the angle brackets, e.g.

    This is my escaped opening program bracket <<>{
    and my escaped closing bracket }<>>.
    You can also escape a closing()<;>

Note that any E<lt>E<lt>E<gt> and E<lt>E<gt><gt> sequences in the
text will be unescaped when processing.

=head1 ATTRIBUTES

=over 4

=item value : string (required)

=item value : string_ref (required)

I<value> is parsed as described above and the result is put
on I<self> as I<values> for the Join widget (superclass).

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::UI::Widget;
use Bivio::UI::ViewLanguage;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string value) : Bivio::UI::Widget::Prose

=head2 static new(hash_ref attrs) : Bivio::UI::Widget::Prose

Creates super class.  Value must be set.

=cut

sub new {
    my($self) = Bivio::UI::Widget::Join::new(_new_args(@_));
    return $self->put(values => _parse($self->get('value')));
}

=head1 METHODS

=cut

#=PRIVATE METHODS

# _new_args(proto, any value) : array
#
# Returns arguments to be passed to Attributes::new.
#
sub _new_args {
    my($proto, $value) = @_;
    return ($proto, $value) if ref($value) eq 'HASH';
    return ($proto, {value => $value}) if defined($value) && !ref($value);
    Bivio::Die->die('invalid arguments to new');
    # DOES NOT RETURN
}

# _parse(string value) : array_ref
#
# Parses the string and returns an array_ref for the join.
#
sub _parse {
    my($value) = @_;
    my($res) = [];
    foreach my $bit (split(/(?=\<\{)|(?<=\}\>)/,
	    ref($value) ? $$value : $value)) {
	push(@$res, $bit =~ s/^\<\{// ? _parse_code($bit)
		: _parse_text($bit));
    }
    _trace($res) if $_TRACE;
    return $res;
}

# _parse_code(string code) : array
#
# Parses the code and returns the result of the eval.
#
sub _parse_code {
    my($code) = @_;
    Bivio::Die->die($code, ': missing Prose program terminator "}>"')
		unless $code =~ s/\}\>$//;
    return Bivio::UI::ViewLanguage->eval(\$code);
}

# _parse_text(string text) : array
#
# Called for text with embedded function calls.
#
sub _parse_text {
    my($text) = @_;
    my(@res, $bit);
    while (length($text)) {
	unless ($text =~ /^\w+\(/) {
	    ($bit, $text) = split(/(?=\b\w+\()/, $text, 2);
	    # Unescape any specials in <>.
	    $bit =~ s/\<([\<\>\(;])\>/$1/g if $bit;
	    push(@res, $bit);
	    last unless defined($text) && length($text);
	}
	$bit = $text;
	Bivio::Die->die($bit, ': missing Prose function terminator ");"')
		unless $bit =~ s/\);(.*)//s;
	$text = $1;
	push(@res, map {
	    Bivio::Die->die($_, ': invalid value in Prose function: ', $bit)
		unless defined($_) && (UNIVERSAL::isa($_, 'Bivio::UI::Widget')
		       || ref($_) eq 'ARRAY' || !ref($_));
	    $_;
	} _parse_code($bit.');}>'));
    }
    return @res;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
