# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Cleaner;
use strict;
use Bivio::Base 'Test.HTMLParser';

__PACKAGE__->register;

sub internal_new {
    return shift->new(@_);
}

sub new {
    my($proto, $parser) = @_;
    my($html) = $parser->get('html');
    $html =~ s/&nbsp;/ /g;
    $html =~ s/<\/?(?:br|p) ?\/?>/\n/ig;
    return $proto->SUPER::new({
	html => $html,
    })->set_read_only;
}

sub unescape_text {
    my($self, $text) = @_;
    return ''
	unless defined($text);
    $text =~ s/\&\#39\;/'/g;
    $text =~ s/\&quot\;/"/g;
    $text =~ s/\&\#\d+\;/ /g;
    $text = Bivio::HTML->unescape($text);
    return $text;
}

sub text {
    my($self, $text) = @_;
    return ''
	unless defined($text);
    $text = $self->unescape_text($text);
    $text =~ s/\s+/ /g;
    $text =~ s/^\s+|\s+$//g;
    return $text;
}

1;
