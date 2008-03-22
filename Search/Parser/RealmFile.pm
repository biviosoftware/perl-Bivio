# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_HANDLER) = _handler_map();

sub parse {
    my($proto, $parseable) = @_;
    return
	unless my $handler = $_HANDLER->{$parseable->get('content_type')};
    return
	unless my $attr = Bivio::Die->eval(
	    sub {$handler->handle_parse($parseable)},
	);
    return ref($attr) eq 'ARRAY'
	? {map(($_ => shift(@$attr)), qw(type title text))}
	: ref($attr) eq 'HASH' ? $attr
	: Bivio::Die->die($attr, ': invalid return value')
}

sub _handler_map {
    return {
	map({
	    my($c) = $_;
	    map(($_ => $c), $c->CONTENT_TYPE_LIST),
	} @{__PACKAGE__->use('IO.ClassLoader')
	    ->map_require_all('SearchParserRealmFile')}),
    };
}

1;
