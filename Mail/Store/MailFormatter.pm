# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Mail::Store::MailFormatter;
use strict;
$Bivio::Mail::Store::MailFormatter::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Mail::Store::MailFormatter - A simple mail formatting tool.
This package takes a mail body and formats it for display as HTML.
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

=head1 SYNOPSIS

    use Bivio::Mail::Store::MailFormatter;
    Bivio::Mail::Store::MailFormatter->new();

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::Mail::Store::MailFormatter::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Mail::Store::MailFormatter> Formats mail for
display in a web page.

=cut

#=IMPORTS
use IO::Scalar;
use IO::Handle;
use Bivio::IO::Trace;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(scalar_ref msg) : Bivio::Mail::Store::MailFormatter

msg is a scalar reference to a mail body.

=cut

sub new {
    _trace('new MailFormatter being created.') if $_TRACE;
    my($proto, $msg) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	message => $msg,
	in_io => IO::Scalar->new(),
	out_io => IO::Scalar->new(),
	char_table => _init(),
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="format_mail"></a>

=head2 format_mail() : scalar_ref

Parses through each line of the mail sent into the
constructor and makes it 'pretty.' Newly formatted
mail is written to an IO::Scalar output.

Returns a scalar ref to the output.

=cut

sub format_mail {
    my($self) = @_;
    my($s);
    my($fields) = $self->{$_PACKAGE};
    my($msg) = $fields->{message};
    my($in_io) = $fields->{in_io}->open($msg);
    my($out_io) = $fields->{out_io}->open(\$s);
    my($chars) = $fields->{char_table};
    _parse($in_io, $out_io, $fields->{char_table});
    $out_io->close();
    $in_io->close();
    return \$s;
}

#=PRIVATE METHODS

# _init() : 
#
# Initializes the char_table in fields.
# This table holds all the mappings from 'funky' characters
# to their HTML equivalents (i.e. '<', '>', '&', etc).
#
#TODO change this to be a static data structure. No need to pay
# the initialization costs on every new();
sub _init {
    my($chars) = {};
    my $i = 34;
    my($key, $val);
    while($i < 45){
	$key = chr($i);
	$val = "&#" . $i . ";";
	eval "\$chars->{\$key}=\$val;";
	$i++;
    }
    $i = 91;
    while($i < 97){
	$key = chr($i);
	$val = "&#" . $i . ";";
	eval "\$chars->{\$key}=\$val;";
	$i++;
    }
    $i=123;
    while($i < 256){
	$key = chr($i);
	$val = "&#" . $i . ";";
	eval "\$chars->{\$key}=\$val;";
	$i++;
    }
    $chars->{chr(60)} = "&lt;";
    $chars->{chr(62)} = "&gt;";
    return $chars;
}

# _parse(IO::Handle in, IO::Handle out) : 
#
# parses the in handle and writes modified lines
# (formatted in HTML) to out.
#
sub _parse {
    my($in, $out, $chars) = @_;
    my($font_color) = "CC0000";

    #\r\n for the sake of RFC822 consistency. Kinda not necessary, since
    #we're formatting this for display in HTML, and it is no longer text/plain:

    $out->print("\r\n<!DOCTYPE HTML PUBLIC");
    $out->print("\"-//W3C//DTD HTML 4.0 Transitional//EN\">\n");
    $out->print("<HTML><HEAD></HEAD><BODY BGCOLOR=\"#CCCCCC\">");
#TODO don't hardcode the bg color.    

    while(!$in->eof){
	my($line) = $in->getline();
	_process_line(\$line, $chars);
#TODO count the number of '>' chars at the start of this line and
#	use a different colored font for each number.
	if ($line =~ /^&gt;/){
	    $line = "<BR><font color = $font_color >" . $line . "</font>";
	}
	$out->print($line);
    }
    #end the 'document'
    $out->print("</BODY></HTML>");
    return;
}

# _process_line(scalar_ref line) : 
#
# This method does very basic processing of a plain/text line.
# It converts non [a-z][A-Z[0-9] characters into valid HTML
# representations. It is called on each line we get in _parse().
#
# There is probably a more efficient way to do this. Currently,
# we iterate over all the characters in {char_map} and do
# global replaces for each in the line. However, the vast majority
# of these characters probably won't be in the line. We could
# perhaps check for characters falling outsize [a-z][A-Z][0-9]
# before proceding on to the pattern match and replace...
sub _process_line {
    my($line, $chars) = @_;
    if($$line =~ /^\s*$/){
	$$line = "\n<P>";
	return;
    }
    my($s);
    my @keys = keys(%$chars);
    foreach $s (@keys){
	my($r) = $chars->{$s};
	$s = "\\" . $s;
	$$line =~ s/$s/$r/g;
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
