# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile;
use strict;
use Bivio::Base 'Search.Parser';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = b_use('Type.FilePath');
my($_HANDLER) = _handler_map();

sub handle_new_text {
    return _do(@_);
}

sub handle_new_excerpt {
    return _do(@_);
}

sub handle_realm_file_new_excerpt {
    return shift->SUPER::handle_new_excerpt(@_);
}

sub _do {
    my($proto) = shift;
    my($parseable) = @_;
    return
	unless my $handler = $_HANDLER->{$parseable->get('content_type')};
    my($method) = $proto->my_caller;
    $method =~ s/^handle/handle_realm_file/;
    return
	unless my $self = $handler->$method(@_);
    return $self;
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
