# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::HTML::t::Scraper::T1;
use strict;
$Bivio::HTML::t::Scraper::T1::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::HTML::t::Scraper::T1::VERSION;

=head1 NAME

Bivio::HTML::t::Scraper::T1 - test scrapper for the petshop site

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::HTML::t::Scraper::T1;

=cut

=head1 EXTENDS

L<Bivio::HTML::Scraper>

=cut

use Bivio::HTML::Scraper;
@Bivio::HTML::t::Scraper::T1::ISA = ('Bivio::HTML::Scraper');

=head1 DESCRIPTION

C<Bivio::HTML::t::Scraper::T1>

=cut

#=IMPORTS
use Bivio::Test::Language::HTTP;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 new(string dir) : self

Creates new instance

=cut

sub new {
    my($proto, $dir) = @_;
    return $proto->SUPER::new({directory => $dir});
}

=head1 METHODS

=cut

=for html <a name="attempt_login"></a>

=head2 attempt_login() : boolean

Uses home_page_uri.

=cut

sub attempt_login {
    my($self) = @_;
    my($uri) = Bivio::Test::Language::HTTP->home_page_uri . '/pub/login';
    my($rs) = $self->http_get($uri, 'login.html');
    $self->client_error("couldn't find fields on login page")
	unless $$rs =~ /name="v.*value="?1"?/mig;
    $rs = $self->http_post(
	Bivio::Test::Language::HTTP->home_page_uri . '/pub/login', [
	v => 1,
	f2 => 'demo',
	f3 => 'password',
        f0 => 'ok',
    ], 'post-login.html');
    return 1;
}

=head2 html_parser_end(string tag, string origtext)

=cut

sub html_parser_end {
    my($self, $tag) = @_;
    my($fields) = $self->[$_IDI];
    return;
}

=for html <a name="html_parser_start"></a>

=head2 html_parser_start(string tag, hash_ref attr, array-ref attrseq, string origtext)

=cut

sub html_parser_start {
    my($self, $tag, $attr) = @_;
    my($fields) = $self->[$_IDI];
    return;
}

=for html <a name="html_parser_text"></a>

=head2 html_parser_text(string html_parser_text)



=cut

sub html_parser_text {
    my($self, $html_parser_text) = @_;
    my($fields) = $self->[$_IDI];
    # Get rid of special characters, squeeze white space
    $html_parser_text = $self->strip_tags_and_whitespace($html_parser_text);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
