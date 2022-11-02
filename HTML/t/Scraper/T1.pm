# Copyright (c) 2002-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::HTML::t::Scraper::T1;
use strict;
use Bivio::Base 'HTML.Scraper';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_HTTP) = b_use('TestLanguage.HTTP');

sub attempt_login {
    # (self) : boolean
    # Uses home_page_uri.
    my($self) = @_;
    my($uri) = $_HTTP->home_page_uri . '/pub/login';
    my($hres) = $self->http_get($uri, 'login.html');
    $self->client_error("couldn't find fields on login page")
        unless $hres->content =~ /name="v.*value="?1"?/mig;
    $self->http_post(
        $_HTTP->home_page_uri . '/pub/login', [
        v => 1,
        f2 => 'demo',
        f3 => 'password',
        f0 => 'ok',
    ], 'post-login.html');
    return 1;
}

sub html_parser_end {
    # (self, string, string) : undef
    my($self, $tag) = @_;
    my($fields) = $self->[$_IDI];
    return;
}

sub html_parser_start {
    # (self, string, hash_ref, array-ref, string) : undef
    my($self, $tag, $attr) = @_;
    my($fields) = $self->[$_IDI];
    return;
}

sub html_parser_text {
    # (self, string) : undef
    my($self, $html_parser_text) = @_;
    my($fields) = $self->[$_IDI];
    # Get rid of special characters, squeeze white space
    $html_parser_text = $self->strip_tags_and_whitespace($html_parser_text);
    return;
}

sub new {
    # (self, string) : self
    # Creates new instance
    my($proto, $dir) = @_;
    return $proto->SUPER::new({directory => $dir});
}

1;
