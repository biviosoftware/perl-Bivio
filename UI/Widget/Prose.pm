# Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.
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

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Widget::Prose::ISA = ('Bivio::UI::Widget');

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
use Bivio::UI::Widget::Join;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes widget state and children.

=cut

sub initialize {
    my($self) = @_;
    if (ref(my $v = $self->get('value'))) {
	$self->initialize_attr('value');
    }
    else {
	$self->put(_join => Bivio::UI::Widget::Join->new(_parse($v)));
    }
    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $value, $attributes) = @_;
    return "'value' must be defined"
	unless defined($value);
    return {
        value => $value,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    ($self->unsafe_get('_join') || $self->initialize_value(
	'value',
	Bivio::UI::Widget::Join->new(
	    _parse($self->render_simple_attr('value', $source)),
	),
    ))->render($source, $buffer);
    return;
}

#=PRIVATE METHODS

# _parse(string value) : array_ref
#
# Parses the string and returns an array_ref for the join.
#
sub _parse {
    my($value) = @_;
    my($res) = [
	map($_ =~ s/^\<\{// ? _parse_code($_) : _parse_text($_),
	    split(/(?=\<\{)|(?<=\}\>)/, ref($value) ? $$value : $value)),
    ];
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
	unless ($text =~ /^(?:[a-zA-Z]\w+|[A-Z])\(/) {
	    ($bit, $text) = split(/(?=\b(?:[a-zA-Z]\w+|[A-Z])\()/, $text, 2);
	    # Unescape any specials in <>.
	    $bit =~ s/\<([\<\>\{\}\(\);])\>/$1/g if $bit;
	    push(@res, $bit);
	    last unless defined($text) && length($text);
	}
	# We have a function at the start of $text.  Strip it off and
	# leave in $bit.  $text will contain the rest
	$bit = $text;
	Bivio::Die->die($bit, ': missing Prose function terminator ");"')
		unless $bit =~ s/\);(.*)//s;
	$text = $1;
	# Unescape any escaped values in perl code
	$bit =~ s/\<([\<\>\{\}\(\);])\>/$1/g;
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

Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
