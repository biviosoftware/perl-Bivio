# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Store::TextFormatter;
use strict;
$Bivio::Mail::Store::TextFormatter::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Store::TextFormatter - A simple text/plain or text/enriched formatting tool.

=head1 SYNOPSIS

    use Bivio::Mail::Store::TextFormatter;
    Bivio::Mail::Store::TextFormatter->format_item();

=cut

=head1 EXTENDS

L<Bivio::Mail::Store::Formatter>

=cut

use Bivio::Mail::Store::Formatter;
@Bivio::Mail::Store::TextFormatter::ISA = ('Bivio::Mail::Store::Formatter');

=head1 DESCRIPTION

C<Bivio::Mail::Store::TextFormatter> Formats mail for
display in a web page.

This package takes a text/plain mail body and formats it for display as HTML.
It will color code the 'quoted' email portions, re-wrap badly
formatted paragraphs (for example, paragraphs that were pasted
into an email from Netscape, or 80 column emails that have been
repeatedly re-wrapped so that they are now REALLY ugly), and
will format email signatures and such.

NOTE that this package does not yet rewrap badly formatted
mail.

I expect, before I am done with this, the package will have to
do multiple-pass parsing. Once, for example, to 'guess' if the
message has a badly formatted paragraph, and then again to reformat
that paragraph. 

=cut

#=IMPORTS
use IO::Scalar;
use IO::Handle;
use Bivio::IO::Trace;
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=head1 METHODS

=cut

=for html <a name="format_item"></a>

=head2 static format_item(MIME::Body body) : scalar_ref

Formats a text/plain or text/enriched MIME body.

=cut

sub format_item {
    my($proto, $body) = @_;
#    _trace('body: ', $body) if $_TRACE;
    my($io) = $body->open('r');
    return format_mail($io);
}

=for html <a name="format_mail"></a>

=head2 format_mail() : scalar_ref

Parses through each line of the mail sent into the
constructor and makes it 'pretty.' Newly formatted
mail is written to an IO::Scalar output.

Returns a scalar ref to the output.

=cut

sub format_mail {
    my($in_io) = @_;
    my($s);
    my($out_io) = IO::Scalar->new();
    _parse($in_io, \$s);
    $out_io->close();
    return \$s;
}

#=PRIVATE METHODS

# _parse(IO::Handle in, scalar_ref out) : 
#
# parses the in handle and writes modified lines
# (formatted in HTML) to out.
#
sub _parse {
    my($in, $out) = @_;

    #\n for the sake of RFC822 consistency. Kinda not necessary, since
    #we're formatting this for display in HTML, and it is no longer text/plain:

    $$out .= "\n<!DOCTYPE HTML PUBLIC";
    $$out .= "\"-//W3C//DTD HTML 4.0 Transitional//EN\">\n";
    $$out .= "<HTML><HEAD></HEAD><BODY>";
    my $s='';
    while(!$in->eof){
	$s .= $in->getline();
    }
    _subparse(\$s, $out);
    $$out .= "</BODY></HTML>";
    return;
}

# _parse_line() : 
#
#
sub _parse_line {
    my $line = shift;
#    _trace('parse_line is handling: ' , $line) if $_TRACE;
    _delete_enriched_tags(\$line);
    my @words = split(' ', $line);
    my $len = @words;
    return "" unless ($len > 0);
    my $newline = ();
    foreach my $word (@words){
        Bivio::Util::escape_html($word);
#	_trace('word to parse: ' , $word) if $_TRACE;
	if($word =~ /(\w+@([[\w-]{2,}\.?){2,}(\?.+|))/){
	    my $uri = $1;
	    $word = "$`<a HREF=\"MAILTO:$uri\">$uri</a>$'";
#	    _trace('found a mailto: ', $word) if $_TRACE;
	}
	elsif($word =~ /(https?:\/\/([[\w-]{2,}\.?){2,}.*?)[\>\)\]\,]?$/){
	    my $uri = $1;
	    $word =~ s/\Q$uri/\<a HREF=\"$uri\"\>$uri\<\/a\>/;
	}
	elsif($word =~ /(www(\.[\w-]{2,}){2,}.*?)[\>\)\]\,]?$/){
	    my $uri = $1;
	    $word =~ s/\Q$uri/\<a HREF=\"http:\/\/$uri\"\>$uri\<\/a\>/;
	}
        push @$newline, $word;
    }
    my $s =  join ' ' , @$newline;
    $s =~ s/^&gt;/<BR>&gt;/;
    return $s;
}

# _parse_paragraph() : 
#
# This method parses a paragraph of text. It receives
# a reference to a paragraph, and calls _parse_line for each
# line it finds in the paragraph. 
sub _parse_paragraph {
    my($paragraph_ref, $out) = @_;
    if(!$out){die('received an undef for output stream!')};
    my @lines = split("\n", $$paragraph_ref);
    my $count = @lines;
    if($count == 0){return ;}
    if(($lines[$count-1] =~ s/\<+?$//) && ($lines[0] =~ s/^\>*//)){
	foreach my $line (@lines){
	    $line =~ s/^/\> /;
	}
    }
    foreach my $line (@lines){
#	$line =~ s/\>/\&gt;/g;
        # $line =~ s/[\x00-\x19]//g; # delete control characters
	$$out .= "\n" . _parse_line($line);
    }
}

# _sub_parse() : 
#
# Probably redundant to call it _subparse, but this method 
# takes a reference to a large scalar and parses it into paragraphs.
# This works assuming we can use '\n\n' as a paragraph delimiter.
sub _subparse {
    my($str_ref, $out) = @_;
    if(!$out){die('received <undef> for output stream!');}
    my @paragraphs = split("\n\n", $$str_ref);
    foreach my $s (@paragraphs){
	$$out .= "\n<P ALIGN=LEFT>";
	_parse_paragraph(\$s, $out);
	$$out .= "</P>\n";
    }
    
}

sub _delete_enriched_tags {
    my($str) = @_;
    $$str =~ s|<<|<|gi; # should map to \&lt;, but not displayed correctly

    $$str =~ s|<fontfamily>\s*<param>([^<]+)</param>||gi;
    $$str =~ s|<color>\s*<param>\s*(\S+)\s*</param>||gi;
    $$str =~ s|<excerpt>\s*(<param>([^<]*)</param>)?||gi;
    $$str =~ s|<lang>\s*<param>([^<]*)</param>||gi;
    $$str =~ s|<paraindent>\s*<param>([^<]*)</param>||gi;

    $$str =~ s,<(/?)(bold|italic|underline|fixed|smaller|bigger)>,,gi;
    $$str =~ s,<(/?)(fontfamily|color|center|flushleft|flushright)>,,gi;
    $$str =~ s,<(/?)(flushboth|paraindent|excerpt|lang|nofill)>,,gi;
}


=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
