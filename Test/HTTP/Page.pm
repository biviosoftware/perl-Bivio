# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTTP::Page;
use strict;
$Bivio::Test::HTTP::Page::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::HTTP::Page::VERSION;

=head1 NAME

Bivio::Test::HTTP::Page - page requests

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::HTTP::Page;

=cut

use Bivio::UNIVERSAL;
@Bivio::Test::HTTP::Page::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Test::HTTP::Page>

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::Ext::LWPUserAgent;
use Bivio::IO::Trace;
use HTTP::Cookies ();
use HTTP::Request ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string uri) : Bivio::Test::HTTP::Page

Creates a new page, loaded from the specified URI.

=cut

sub new {
    my($proto, $uri) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
	cookies => HTTP::Cookies->new,
    };
    $self->goto_page($uri);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="follow_link"></a>

=head2 follow_link(string link_text)

Loads the page for the specified link.

=cut

sub follow_link {
    my($self, $link_text) = @_;
    my($fields) = $self->[$_IDI];

#TODO: can be removed when parser is available
    # search for the link text
    $fields->{response}->content
	=~ /href="([^"]+)"[^>]*>(<[^>]+>)*\s*$link_text\s*</is;

    my($uri) = $1;
    Bivio::Die->die("couldn't find link: ", $link_text)
	    unless $uri;
    $self->goto_page($uri);
    return;
}

=for html <a name="goto_page"></a>

=head2 goto_page(string uri)

Loads the page using the specified URI.

=cut

sub goto_page {
    my($self, $uri) = @_;
    _trace($uri) if $_TRACE;
    _send_request($self, HTTP::Request->new(GET => _fixup_uri($self, $uri)));
    return;
}

=for html <a name="submit"></a>

=head2 submit(string form_name, array_ref form_fields)

Submits form data to the named form.

=cut

sub submit {
    my($self, $form_name, $form_fields) = @_;
    my($fields) = $self->[$_IDI];

#TODO: can be removed when parser is available
    # parse the method and action for the named form
    Bivio::Die->die("didn't find form name: ", $form_name)
	    unless $fields->{response}->content
		=~ /(<form[^>]+name="$form_name"[^>]*>)/is;
    my($body) = $1;
    Bivio::Die->die("didn't find form method: ", $body)
	    unless $body =~ /method="?([^\s">]+)[">\s]?/is;
    my($method) = $1;
    Bivio::Die->die("didn't find form action: ", $body)
	    unless $body =~ /action="([^">]+)"/is;
    my($uri) = $1;

    my($request) = HTTP::Request->new(uc($method) => _fixup_uri($self, $uri));
    $request->content_type('application/x-www-form-urlencoded');
    $request->content(_format_form($form_fields));
    _send_request($self, $request);
    return;
}

=for html <a name="verify_text"></a>

=head2 verify_text(string text)

Verifies that the specified text appears on the page.

=cut

sub verify_text {
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    Bivio::Die->die("text not found: ", $text)
	    unless $fields->{response}->content =~ /$text/;
    _trace($text) if $_TRACE;
    return;
}

#=PRIVATE SUBROUTINES

# _fixup_uri(self, string uri) : string
#
# Add in the current URI prefix if not present.
#
sub _fixup_uri {
    my($self, $uri) = @_;
    my($fields) = $self->[$_IDI];

    unless ($uri =~ m,://,) {
	Bivio::Die->die("couldn't find http prefix: ", $fields->{uri})
		unless $fields->{uri} =~ m,^([^/]+//[^/]+)/?,;
	my($prefix) = $1;
	$uri = $prefix.$uri;
    }
    return $uri;
}

#TODO: copied method from AccountScraper
# _format_form(array_ref form) : string
#
# Returns URL encoded form.
#
sub _format_form {
    my($form) = @_;
    my($res) = '';
    my($sep) = '';
    Bivio::Die->die('expecting even number of elements') if int(@$form) % 2;
    foreach my $i (@$form) {
	$res .= $sep.Bivio::HTML->escape_query($i) if defined($i);
	# Works first time through, because we compare to '='
	$sep = $sep eq '=' ? '&' : '=';
    }
    return $res;
}

# _send_request(self, HTTP::Request request)
#
# Sends the specified request.
#
sub _send_request {
    my($self, $request) = @_;
    my($fields) = $self->[$_IDI];

    $fields->{cookies}->add_cookie_header($request);
    $fields->{response} = Bivio::Ext::LWPUserAgent->new()->request($request);

    Bivio::Die->die("uri request failed: ", $request->uri)
	    unless $fields->{response}->is_success;

    $fields->{cookies}->extract_cookies($fields->{response});
    $fields->{uri} = $fields->{response}->base;
    return;
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
