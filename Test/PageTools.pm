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

=for html <a name="visit"></a>

=head2 visit(Bivio::Test::BulletinBoard board, hash_ref uri) 

Visits the page specified by url (which may be dynamically passed) and returns the BulletinBoard object with new entries for response and current_url.

=cut

sub visit {
    my($proto, $board, $uri) = @_;
    _trace("Current method is visit(). Current url is:", $uri, "\n")
	    if $_TRACE;
    $board->put(current_uri => $uri);  #change current_uri to uri?

    my($response) = HTTPTools::http_href('URL', $uri);

    if (!defined $response) {
	print("Failed to get response from server for $uri.\n");
    }
    elsif ($response->{HTTP_RESPONSE}->is_success) {
	$board->put(response => $response);
	print("Visiting page: " , ($board->get('response'))->{TITLE} , "\n");
    }
    else {
	print("Error: Page did not load successfully.\n");
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
