# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Cleaner;
use strict;
$Bivio::Test::HTMLParser::Cleaner::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::HTMLParser::Cleaner::VERSION;

=head1 NAME

Bivio::Test::HTMLParser::Cleaner - cleans up HTML and stores in html.

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::HTMLParser::Cleaner;

=cut

=head1 EXTENDS

L<Bivio::Test::HTMLParser>

=cut

use Bivio::Test::HTMLParser;
@Bivio::Test::HTMLParser::Cleaner::ISA = ('Bivio::Test::HTMLParser');

=head1 DESCRIPTION

C<Bivio::Test::HTMLParser::Cleaner> replaces special characters and p and br
tags.

=head1 ATTRIBUTES

=over 4

=item html : string

The cleaned HTML.

=back

=cut

#=IMPORTS
use Bivio::HTML;

#=VARIABLES
__PACKAGE__->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Test::HTMLParser parser) : Bivio::Test::HTMLParser::Cleaner

Gets html and saves a cleaned copy in I<html> attribute.

=cut

sub new {
    my($proto, $parser) = @_;
    my($html) = $parser->get('html');
    $html =~ s/\015//g;
    $html =~ s/&nbsp;/ /g;
    $html =~ s/<\/?(?:br|p)>/\n/ig;
    $html =~ s/\&\#\d+\;/*/g;
    return $proto->SUPER::new({
	html => $html,
    })->set_read_only;
}

=head1 METHODS

=cut

=for html <a name="text"></a>

=head2 static text(string text) : string

Unescapes and deletes trailing and leading whitespace.  Assumes I<text> has already been cleaned by this class.

=cut

sub text {
    my($self, $text) = @_;
    return '' unless defined($text);
    $text = Bivio::HTML->unescape($text);
    $text =~ s/\s+/ /g;
    $text =~ s/^\s+|\s+$//g;
    return $text;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
