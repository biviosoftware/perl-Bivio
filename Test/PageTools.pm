$Bivio::Test::Engine::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Engine::VERSION;

package Bivio::Test::PageTools;
use strict;

=head1 NAME

Bivio::Test::PageTools - static methods run by test scripts

=head1 SYNOPSIS

    use Bivio::Test::PageTools;

=cut

use Bivio::UNIVERSAL;

@Bivio::Test::PageTools::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Test::PageTools> contains all the methods invoked by the test scripts that are not associated with instantiated classes.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Test::BulletinBoard;
use Bivio::Test::HTTPTools;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="quiet_visit"></a>

=head2 quiet_visit() : Page visitor with less output that returns the response.

This version of visit is meant to be used by modules that need to visit a page as part of a longer process.  It returns a reference to the response so it doesn't need to be gotten again by the caller.  It also checks the response for errors.

=cut

sub quiet_visit {
    my($proto, $uri) = @_;
    _trace("Current method is quiet_visit(). Current url is:", $uri, "\n")
	    if $_TRACE;

    my($response) = HTTPTools::http_href('URL', $uri);

    if (!defined $response) {
	_trace("Failed to get response from server for $uri.\n") if $_TRACE;
    }
    elsif ($response->{HTTP_RESPONSE}->is_success) {
	my ($board) = Bivio::Test::BulletinBoard->get_current();
	$board->put(response => $response);
	_trace("Visiting page: " , ($board->get('response'))->{TITLE} , "\n")
		if $_TRACE;
    }
    else {
	_trace("Error: Page did not load successfully.\n
                Text gotten was:\n$response\n") if $_TRACE;
    }
    return $response;
}

=for html <a name="visit"></a>

=head2 visit(Bivio::Test::BulletinBoard board, hash_ref uri) 

Visits the page specified by url (which may be dynamically passed) and returns the BulletinBoard object with new entries for response and current_url.

=cut

sub visit {
    my($proto, $uri) = @_;
    _trace("Current method is visit(). Current url is:", $uri, "\n")
	    if $_TRACE;

    my($response) = HTTPTools::http_href('URL', $uri);

    if ($response = undef) {
	Bivio::Test::Engine->print_later(
		"Failed to get response from server for $uri.\n");
    }
    elsif ($response->{HTTP_RESPONSE}->is_success) {
	my ($board) = Bivio::Test::BulletinBoard->get_current();
	$board->put(response => $response);
	Bivio::Test::Engine->print_later(
		"Visiting page: " , ($board->get('response'))->{TITLE} , "\n");
    }
    else {
	Bivio::Test::Engine->print_later(
		"Error: Page did not load successfully.\n");
      	_trace("Text gotten was: ", $response, "\n");
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
