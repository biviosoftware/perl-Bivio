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
use Bivio::Test::HTTPUtil;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="visit"></a>

=head2 visit(Bivio::Test::BulletinBoard board, hash_ref uri) 

Visits the page specified by url (which may be dynamically passed) and puts the response in the current BulletinBoard object.

=cut

sub visit {
    my($proto, $uri) = @_;
    _trace("Current method is visit(). Current url is:", $uri, "\n")
	    if $_TRACE;

    my($util) = (Bivio::Test::BulletinBoard->get_current)->get('HTTPUtil');
    my($http_res) = $util->get_response($uri);
    _trace("****Content = ". $http_res->content) if $_TRACE;

    if (!defined $http_res) {
	_trace("Failed to get HTTP Response from server for $uri.\n")
		if $_TRACE;
    }
    elsif ($http_res->{HTTP_RESPONSE}->is_success) {
	my ($board) = Bivio::Test::BulletinBoard->get_current();
	$board->put(response => $http_res);
	_trace("PageVisit Response is:\n*****\n*****" . $http_res->content)
		if $_TRACE;
    }
    else {
      	_trace("Error: Page did not load successfully.
                \nText gotten was: ", $http_res, "\n");
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
