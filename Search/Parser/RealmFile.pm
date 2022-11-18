# Copyright (c) 2008-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile;
use strict;
use Bivio::Base 'Search.Parser';

my($_M) = b_use('Biz.Model');
my($_FP) = b_use('Type.FilePath');
my($_S) = b_use('Type.String');
my($_HANDLER) = _handler_map();

sub do_iterate_realm_models {
    my($self, $op, $req) = @_;
    $_M->new($req, 'RealmFile')
        ->do_iterate(
            $op,
            'realm_file_id asc',
            {is_folder => 0},
        );
    return;
}

sub handle_new_text {
    return _do(@_);
}

sub handle_new_excerpt {
    return _do(@_);
}

sub handle_realm_file_new_excerpt {
    my($proto, $parseable, @rest) = @_;
    return undef
        unless my $self = ref($proto) ? $proto
        : $proto->new_text($parseable, @rest);
    return $self->put(excerpt => ${$_S->canonicalize_and_excerpt($self->get('text'))});
}

sub realms_for_rebuild_db {
    my($self, $req) = @_;
    return $_M->new($req, 'RealmFile')
        ->map_iterate(
            sub {shift->get('realm_id')},
            'unauth_iterate_start',
            'realm_id',
            {path => '/'},
        ); 
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
