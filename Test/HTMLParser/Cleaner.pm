# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Cleaner;
use strict;
use Bivio::Base 'Test.HTMLParser';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->register;

sub internal_new {
    return shift->new(@_);
}

sub new {
    my($proto, $parser) = @_;
    my($html) = $parser->get('html');
    $html =~ s/\015//g;
    $html =~ s/&nbsp;/ /g;
    $html =~ s/<\/?(?:br|p) ?\/?>/\n/ig;
    $html =~ s/\&\#39\;/'/g;
    $html =~ s/\&quot\;/"/g;
    $html =~ s/\&\#\d+\;/ /g;
    return $proto->SUPER::new({
	html => $html,
    })->set_read_only;
}

sub text {
    my($self, $text) = @_;
    return '' unless defined($text);
    $text = Bivio::HTML->unescape($text);
    $text =~ s/\s+/ /g;
    $text =~ s/^\s+|\s+$//g;
    return $text;
}

1;
