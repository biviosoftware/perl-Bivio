# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Regex;
use strict;
$Bivio::UI::PDF::Regex::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Regex - contains various regular expressions used by the
PDF code.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Regex;
    Bivio::UI::PDF::Regex->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::Regex::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Regex>

=cut


=head1 CONSTANTS

=cut

=for html <a name="ARRAY_END_REGEX"></a>

=head2 ARRAY_END_REGEX : string

This regular expression matches the end of an array.

=cut

sub ARRAY_END_REGEX {
    return('^\s*(\])');
}

=for html <a name="ARRAY_START_REGEX"></a>

=head2 ARRAY_START_REGEX : string

This regular expression matches the start of an array.

=cut

sub ARRAY_START_REGEX {
    return('^\s*(\[)');
}

=for html <a name="BOOLEAN_REGEX"></a>

=head2 BOOLEAN_REGEX : string

This regular expression matches 'true' and 'false'.

=cut

sub BOOLEAN_REGEX {
    return('^\s*\b((?:true)|(?:false))\b');
}

=for html <a name="COMMENT_REGEX"></a>

=head2 COMMENT_REGEX : string

This regular expression matches a comment on a line by itself.

=cut

sub COMMENT_REGEX {
    return('^\s*(%.*)');
}

=for html <a name="CONTINUED_STRING_REGEX"></a>

=head2 CONTINUED_STRING_REGEX : string

This regular expression matches the text of a string that is continued onto the
next line.  It returns the text without the '\' that escapes the end of line
character.

=cut

sub CONTINUED_STRING_REGEX {
    return '(.*)\\\\$';
}

=for html <a name="DIC_END_REGEX"></a>

=head2 DIC_END_REGEX : string

This regular expression matches the end of a dictionary object.

=cut

sub DIC_END_REGEX {
    return('^\s*(>>)');
}

=for html <a name="DIC_START_REGEX"></a>

=head2 DIC_START_REGEX : string

This regular expression matches the start of a dictionary object.

=cut

sub DIC_START_REGEX {
    return('^\s*(<<)');
}

=for html <a name="ENDOBJ_REGEX"></a>

=head2 ENDOBJ_REGEX : string

This regular expression matches the end of an object definition.

=cut

sub ENDOBJ_REGEX {
    return('^\s*(endobj\b)');
}

=for html <a name="EOF_REGEX"></a>

=head2 EOF_REGEX : string

This regular expression matches the EOF line.

=cut

sub EOF_REGEX {
    return('^\s*(%%EOF)');
}

=for html <a name="EOL_REGEX"></a>

=head2 EOL_REGEX : string

This regular expression fragment matches the normal end of line sequences.  It
has parens around it with the "?:" construction.  The perl pattern matching
functions are sensitive to how many sets of parens are in a regular expression.


=cut

sub EOL_REGEX {
    return('((?:\r\n)|\r|\n)');
}

=for html <a name="FLOAT_REGEX"></a>

=head2 FLOAT_REGEX : string

This regular expression matches a number and returns the integer and fractional
parts separately.

=cut

sub FLOAT_REGEX {
    return('([-+]?[0-9]*)\.?([0-9]*)');
}

=for html <a name="FRAC_REGEX"></a>

=head2 FRAC_REGEX : string

This regular expression returns the fractional part of a number, if there is
one.

=cut

sub FRAC_REGEX {
    return('[-+]?[0-9]*\.([0-9]+)');
}

=for html <a name="IGNORE_REGEX"></a>

=head2 IGNORE_REGEX : string

This regular expression matches empty lines or lines with just whitespace.

=cut

sub IGNORE_REGEX {
    return('(^\s*$)');
}

=for html <a name="INT_REGEX"></a>

=head2 INT_REGEX : string

This regular expression matches the integer part of a number and returns it.
It returns the integer part and an optional sign.

=cut

sub INT_REGEX {
    return('([-+]?[0-9]+)');
}

=for html <a name="NAME_REGEX"></a>

=head2 NAME_REGEX : string

This regular expression matches a name.

=cut

sub NAME_REGEX {
    return('^\s*/([-!"$&-+.0-;=?-Z\^-z|]+)');
}

=for html <a name="NULL_OBJ_REGEX"></a>

=head2 NULL_OBJ_REGEX : string

This regular expression matches the 'null' keyword of a null direct object.

=cut

sub NULL_OBJ_REGEX {
    return '^\s*(null)';
}

=for html <a name="NUMBER_REGEX"></a>

=head2 NUMBER_REGEX : string

This regular expression matches a number, with optional sign and optional
decimal part.

=cut

sub NUMBER_REGEX {
    return('^\s*((?:[-+0-9]+\.?[0-9]*)|(?:[-+]?\.[0-9]+))\b');
}

=for html <a name="OBJ_REF_REGEX"></a>

=head2 OBJ_REF_REGEX : string

This regular expression matches a reference to an indirect objec.  It returns
two values: the ojbect number and the object generation.

=cut

sub OBJ_REF_REGEX {
    return('^\s*([0-9]+)\s+([0-9]+)\s+R');
}

=for html <a name="OBJ_REGEX"></a>

=head2 OBJ_REGEX : string

This regular expression matches any of the legal Pdf end of line sequences.
Note that there is a different set of end of line sequences on a line that
starts a stream.

=cut

sub OBJ_REGEX {
    return('^\s*([0-9]+)\s+([0-9]+)\s+obj\b');
}

=for html <a name="STARTXREF_REGEX"></a>

=head2 STARTXREF_REGEX : string

This regulare expression matches the startxref line in the trailer.  The actual
offset is in the next line.

=cut

sub STARTXREF_REGEX {
    return('(\bstartxref\b)');
}

=for html <a name="STREAM_REGEX"></a>

=head2 STREAM_REGEX : string

This regular expression matches a endstream token.

=cut

sub STREAM_END_REGEX {
    return('^\s*(endstream\b)');
}

=for html <a name="STREAM_START_REGEX"></a>

=head2 STREAM_START_REGEX : string

This regular expression matches a stream token.

=cut

sub STREAM_START_REGEX {
    return('^\s*(stream\b)');
}

=for html <a name="STRING_END_ANGLE_REGEX"></a>

=head2 STRING_END_ANGLE_REGEX : string

This regular expression matches the end of an angle string and returns the text before the final '>'.

=cut

sub STRING_END_ANGLE_REGEX {
    return('([0-9a-fA-F\s]*)>');
#    return('(.*[^\\\\]*)>');
}

=for html <a name="STRING_END_PAREN_REGEX"></a>

=head2 STRING_END_PAREN_REGEX : string

This regulare expression matches the end of a paren string and returns the text
before the final ')'.  If the string contains any '\)' sequences, it only
returns the text following the last one.

=cut

sub STRING_END_PAREN_REGEX {
    return('([^)]*[^\\\\])\)');
}

=for html <a name="STRING_START_ANGLE_REGEX"></a>

=head2 STRING_START_ANGLE_REGEX : string

This regular expression matches the start of a string that is enclosed by angle
brackets.  It has to not match '<<', which is the start of a dictionary.

=cut

sub STRING_START_ANGLE_REGEX {
    return('^\s*(<)[^<]');
}

=for html <a name="STRING_START_PAREN_REGEX"></a>

=head2 STRING_START_PAREN_REGEX : string

This regular expression matches the start of a string that is enclosed in
parentheses.

=cut

sub STRING_START_PAREN_REGEX {
    return('^\s*(\()');
}

=for html <a name="TRAILER_REGEX"></a>

=head2 TRAILER_REGEX : string

This regular expression matches the 'trailer' line.

=cut

sub TRAILER_REGEX {
    return('^\s*(trailer)\b');
}

=for html <a name="XREF_REGEX"></a>

=head2 XREF_REGEX : string

This regex matches the start of an xref section.

=cut

sub XREF_REGEX {
    return('^\s*(xref\b)');
}

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
