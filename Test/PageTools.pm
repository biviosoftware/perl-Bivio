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

C<Bivio::Test::PageTools> contains all the methods invoked by the test scripts
that are not associated with instantiated classes.

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::Test::BulletinBoard;
use Bivio::Test::HTTPUtil;
use Data::Dumper ();
#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_BASE_URI);
Bivio::IO::Config->register({
    base_uri => 'http://www.test.bivio.com',
});

=head1 METHODS

=cut


=for html <a name="click_button"></a>

=head2 click_button(string label)

Visits page associated with the url for the named button.

=cut

sub click_button {
    my($proto, $label) = @_;
    my($parsed_res) = Bivio::Test::BulletinBoard->get_current->get('response');
    die ("Must visit a page before clicking on a button.")
	    unless (defined $parsed_res);
    my($uri_to_visit) = $parsed_res->get_button_uri($label);
    _trace("Uri for button: $uri_to_visit") if $_TRACE;
    $proto->visit($_BASE_URI.$uri_to_visit);
    return;
}

=for html <a name="dump_analyzer"></a>

=head2 dump_analyzer()

for debugging purposes only.

=cut

sub dump_analyzer {
    my($proto) = @_;
    Bivio::Test::Login->execute();
    my($parsed_res) = Bivio::Test::BulletinBoard->get_current()->get(
	    'response');
    my($dd) = Data::Dumper->new([$parsed_res]);
    $dd->Indent(1);
    $dd->Terse(1);
    $dd->Deepcopy(1);
    print($dd->Dumpxs());

    return;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item <required> : <type> (required)

=item <optional> : <type> [<default>]

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_BASE_URI = $cfg->{base_uri};
    return;
}

=for html <a name="visit"></a>

=head2 visit(Bivio::Test::BulletinBoard board, hash_ref uri) 

Visits the page specified by url (which may be dynamically passed) and puts the
response and url in the current BulletinBoard object.

=cut

sub visit {
    my($proto, $uri) = @_;
    _trace("Current method is visit(). Current url is:", $uri, "\n")
	    if $_TRACE;
    Bivio::Test::BulletinBoard->get_current->get('HTTPUtil')->http_href(
	    $uri);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
