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
    my($proto, $target) = @_;
    my($board) = Bivio::Test::BulletinBoard->get_current();
    my($parsed_res) = $board->get('response');
    die ("Must visit a page before clicking on a button.")
	    unless (defined $parsed_res);
    my($uri_to_request) = $parsed_res->get_uri('buttons', $target);
    _trace("Uri for button: $uri_to_request") if $_TRACE;
    $board->get('HTTPUtil')->http_href($_BASE_URI.$uri_to_request);
    return;
}

=for html <a name="click_imagemenu"></a>

=head2 click_imagemenu(string target, optional string subtarget)

Visits page associated with the url for the target portion of the imagemenu.
The optional argument subtitle is used for accessing the expanded part of the
imagemenu.

=cut
#TODO: subtarget won't be optional until the other parts of imagemenu are there
sub click_imagemenu {
    my($proto, $target, $subtarget) = @_;
    my($board) = Bivio::Test::BulletinBoard->get_current();
    my($parsed_res) = $board->get('response');
    die ("Must visit a page before clicking on imagemenu.")
	    unless (defined $parsed_res);

    my($uri_to_request) = $parsed_res->get_uri(
	    'imagemenu', $target, $subtarget);
    _trace("Uri for imagemenu: $uri_to_request") if $_TRACE;

    $board->get('HTTPUtil')->http_href($_BASE_URI.$uri_to_request);
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

=for html <a name="post_form"></a>

=head2 post_form(hashref fields_and_input)

Interfaces with HTTP methods to submit a form post.  Input is a hash with exact
field names for public fields and the content to post.  This method assumes
that the last page visited contains the form to submit.

=cut

sub post_form {
    my($proto, $fields_and_input) = @_;
    my($board) = Bivio::Test::BulletinBoard->get_current();
    my($parsed_res) = $board->get('response');
    #get form by looking at first field listed
    my($form) = $parsed_res->get_form_by_field_name(
	    (keys(%{$fields_and_input}))[0]);
    _trace("Form to fill out: $form") if $_TRACE;
    #TODO: doesn't check rest of fields

    #Put each input under $input->{<field>}->{value}
    my($form_fields) = $parsed_res->list_public_fields($form);
    foreach my $field (keys(%{$fields_and_input})) {
	$form_fields->{$field}->{value} = $fields_and_input->{$field};
    }

    #Get page, parse, and store
    $board->get('HTTPUtil')->http_form($form_fields, $form);
    return;
}

=for html <a name="visit"></a>

=head2 visit(Bivio::Test::BulletinBoard board, hash_ref uri) 

Visits the page specified by uri and puts the response and uri in the current
BulletinBoard object.  The uri may be the path beyond a base uri which will be
substituted in.

=cut

sub visit {
    my($proto, $uri) = @_;
    _trace("Current method is visit(). Current url is:", $uri, "\n")
	    if $_TRACE;
    unless ($uri =~ /http:/) {
	$uri =~ s/(.*)/$_BASE_URI$1/;
	_trace("Full uri is: $uri") if $_TRACE;
    }
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
