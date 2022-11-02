# Copyright (c) 2002-2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser;
use strict;
use Bivio::Base 'Collection.Attributes';

use Encode ();

# C<Bivio::Test::HTMLParser> directs parsing of html by calling classes in the
# TestHTMLParser class map.
#
# html : string
#
# The HTML which was passed to new
#
# E<lt>simple_classE<gt> : string
#
# Each parser class is put on I<self>.  See parser classes for their attributes.

my(@_CLASSES);
b_use('IO.ClassLoader')->map_require_all('TestHTMLParser');
my($_HP) = b_use('Ext.HTMLParser');

sub html_parser_comment {
    return;
}

sub html_parser_end {
    return;
}

sub html_parser_start {
    return;
}

sub html_parser_text {
    return;
}

sub internal_new {
    # (proto, Test.HTMLParser) : Test.HTMLParser
    # Calls parser subclass to parse cleaned html.  Subclass must implement
    # L<Bivio::Ext::HTMLParser|Bivio::Ext::HTMLParser> interface.  Sets two
    # attributes: I<cleaner> and I<elements>.  I<cleaner> is an instance of
    # C<Cleaner>, and I<elements> is a hash which will be put as the attributes of
    # I<self> when parsing is complete.
    my($proto, $parser) = @_;
    return undef
        unless my $self = $proto->new($parser);
    $self->internal_put({
        cleaner => $parser->get('Cleaner'),
        elements => {},
    });
    my($p) = $_HP->new($self);
    $p->ignore_elements(qw(script style));
    $p->parse($self->get('cleaner')->get('html'));
    $self->internal_put($self->get('elements'));
    return $self->set_read_only;
}

sub is_not_bivio_html {
    return shift->unsafe_get('is_not_bivio_html') ? 1 : 0;
}

sub new {
    # (proto, string_ref) : Test.HTMLParser
    # (proto, hash_ref) : Test.HTMLParser
    # Parse I<html> using registered parser classes.
    #
    # If I<html> is undef or I<attrs> is passed, does nothing (pass through
    # L<internal_new|"internal_new"> for subclasses).
    my($proto) = shift;
    return $proto->SUPER::new(@_)
       unless (ref($proto) || $proto) eq __PACKAGE__;

    my($html, $attrs) = @_;
    my($self) = $proto->SUPER::new({
        %{$attrs || {}},
        html => Encode::decode_utf8($$html),
    });
    foreach my $c (@_CLASSES) {
        $self->put($c->simple_package_name => $c->internal_new($self));
    }
    return $self->set_read_only;
}

sub register {
    # (proto, array_ref) : undef
    # Adds I<proto> to list of classes, but first loads I<prerequisite_classes>.
    my($proto, $prerequisite_classes) = @_;
    foreach my $p (@{$prerequisite_classes || []}) {
        b_use('TestHTMLParser', $p);
    }
    push(@_CLASSES, ref($proto) || $proto);
    return;
}

1;
