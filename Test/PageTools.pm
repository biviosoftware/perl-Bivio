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

    # Store current location in the bulletin board
    $board->put(current_uri => $uri);

    my($response) = 'error';
    #($response) = HTTPTools::http_href('URL', $uri);

    #_trace("Page gotten (response) is:", $response, "\n") if $_TRACE;
    #die ("Page hit did not succeed\n")
	#    unless ($response->{HTTP_RESPONSE}->is_success);

    $board->put(response => $response);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
