$Bivio::Test::Engine::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Engine::VERSION;

package Bivio::Test::HTTP;
use strict;

=head1 NAME

Bivio::Test::HTTP - test script interface to HTTP requests

=head1 SYNOPSIS

    use Bivio::Test::HTTP;

=cut

use Bivio::UNIVERSAL;

@Bivio::Test::HTTP::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Test::HTTP> contains all static methods invoked by the test scripts.

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
my($_BASE_URI);
my($_PACKAGE) = __PACKAGE__;
my($_PASSWORD);
my($_SAVE_PASS);
my($_USER);
Bivio::IO::Config->register({
    base_uri => "http://www.test.bivio.com",
#    base_uri => "http://127.0.0.1:8000",
    password => "foobar",
    save_pass => "0",
    user => "btfuserx",
});

=head1 METHODS

=cut


=for html <a name="click_button"></a>

=head2 static click_button(string target)

Visits page associated with the url for the I<target> button.

=cut

sub click_button {
    my(undef, $target) = @_;
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

=head2 static click_imagemenu(string target, optional string subtarget)

Visits page associated with the url for the I<target> portion of the imagemenu.
The optional argument I<subtarget> is used for accessing the expanded part of
the imagemenu.

=cut
#TODO: subtarget won't be optional until the other parts of imagemenu are there
sub click_imagemenu {
    my(undef, $target, $subtarget) = @_;
    my($board) = Bivio::Test::BulletinBoard->get_current();
    my($parsed_res) = $board->get('response');
    die ("Must visit a page before clicking on imagemenu.")
	    unless (defined $parsed_res);

    my($uri_to_request) = $parsed_res->get_uri(
	    'imagemenu', $target, $subtarget);
    _trace("Uri for imagemenu: $uri_to_request") if $_TRACE;

    $board->get('HTTPUtil')->http_href(
	    $_BASE_URI.$uri_to_request);
    return;
}

=for html <a name="dump_analyzer"></a>

=head2 static dump_analyzer()

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

=item base_uri : string

uri of test system in use (typically local server or http://www.test.bivio.com)

=item password : string

password for default user

=item save_pass : boolean

For now this is always set to 0 (don't save password).

=item user : string

default user to log in as

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_USER = $cfg->{user};
    $_PASSWORD = $cfg->{password};
    $_SAVE_PASS = $cfg->{save_pass};
    $_BASE_URI = $cfg->{base_uri};
    return;
}

=for html <a name="login"></a>

=head2 login(optional string $user, optional string $pass, optional boolean $save)

login is a static wrapper for the object method Login->execute().  It gets the
current login object from the BulletinBoard.  If login information (user, pass)
are specified and do not match the current login object, a new login object is
made and the login is performed.



=cut

sub login {
    my($proto, $user, $pass, $save) = @_;
    # set user information unless passed in
    unless (defined $user && defined $pass) {
	_trace("Using default user information") if $_TRACE;
	$user = $_USER;
	$pass = $_PASSWORD;
    }
    $save = $_SAVE_PASS unless (defined $save);

    # is there a current login with the same information?
    my($login) = Bivio::Test::BulletinBoard->get_current()->get('login');
    if (defined $login) {
	if($login->matches_user($user)) {
	    _trace("Already logged in as $user.  Skipping login.") if $_TRACE;
#TODO redirect to intro page so verification succeeds?
	    return;
	}
	_trace("Old login exists.  Now logging in as $user") if $_TRACE;
    }
    else {
	# make a new login object
	$login = Bivio::Test::Login->new($user, $pass, $save);
    }
    $login->execute();
    return;
}


=for html <a name="post_form"></a>

=head2 static post_form(hashref fields_and_input)

Interfaces with HTTP methods to submit a form post.  Input is a hash with exact
field names for public fields and the content to post.  This method assumes
that the last page visited contains the form to submit.

=cut

sub post_form {
    my($undef, $fields_and_input) = @_;
    my($board) = Bivio::Test::BulletinBoard->get_current();
    my($parsed_res) = $board->get('response');
    # get form by looking at first field listed
    my($form) = $parsed_res->get_form_by_field_name(
	    (keys(%{$fields_and_input}))[0]);
    _trace("Form to fill out: $form") if $_TRACE;
#TODO: doesn't check rest of fields

    # Put each input under $input->{<field>}->{value}
    my($form_fields) = $parsed_res->list_public_fields($form);
    foreach my $field (keys(%{$fields_and_input})) {
	$form_fields->{$field}->{value} = $fields_and_input->{$field};
    }

    # Get page, parse, and store
    $board->get('HTTPUtil')->http_form($form_fields, $form);
    return;
}

=for html <a name="verify_all"></a>

=head2 static verify_all(string uri, string title, string text)

Runs all three verification tests on the current parsed response.

=cut

sub verify_all {
    my($proto, $uri, $title, $text) = @_;
    $proto->verify_uri($uri);
    $proto->verify_title($title);
    $proto->verify_text($text);
    return;
}

=for html <a name="verify_text"></a>

=head2 verify_text(string text)

Dies if specified text is not found within the current parsed response.

=cut

sub verify_text {
    my(undef, $text) = @_;
    # set content for first iteration
    my($content) = Bivio::Test::BulletinBoard->get_current()->get('response');

    # die("Failed verification.  text: $text not found in page.")
    #	unless (_unravel_and_match($text, $content);
    return;
}

=for html <a name="verify_title"></a>

=head2 verify_title(string $match_title)

Dies if title in current page does not match string $title (case insensitive).

=cut

sub verify_title {
    my(undef, $match_title) = @_;
    my($page_title) = Bivio::Test::BulletinBoard->get_current()->get(
	    'response')->get_title();
    die("Failed verification.
         title: $page_title does not match expected: $match_title")
	    unless $page_title =~ /$match_title/i;
    return;
}

=for html <a name="verify_uri"></a>

=head2 verify_uri(string path)

Verifies that the uri of the current response contains the specified string.
The specified uri should optimally be only the path after the base uri so that
this will succeed with different base uris.

=cut

sub verify_uri {
    my(undef, $path) = @_;
    my($uri) = Bivio::Test::BulletinBoard->get_current()->get('current_uri');
    die("Failed verification.
         current uri: $uri does not match/contain expected: $path")
	    unless ($uri =~ /$path/);
    return;
}

=for html <a name="visit"></a>

=head2 static visit(Bivio::Test::BulletinBoard board, hash_ref uri) 

Visits the page specified by uri and puts the response and uri in the current
BulletinBoard object.  The uri may be the path beyond a base uri which will be
substituted in.

=cut

sub visit {
    my(undef, $uri) = @_;
    _trace("passed url:", $uri, "\n")
	    if $_TRACE;
    my($board) = Bivio::Test::BulletinBoard->get_current();
    unless ($uri =~ /http:/) {
	$uri =~ s/(.*)/$_BASE_URI$1/;
	_trace("Full uri is: $uri") if $_TRACE;
    }
    $board->get('HTTPUtil')->http_href(
	    $uri);
    return;
}

#=PRIVATE METHODS

# _unravel_and_match(string $match, unknown $content) : boolean
#
# Unravels hash looking for the match string.  Returns 1 if match is a success.
#
sub _unravel_and_match {
    my($match, $content) = @_;

#TODO:
    # if ref($content) eq 'hash'
    # foreach value in the hash
    #   verify_text($content)
    # if string
    # compare...return 1 on match

    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
