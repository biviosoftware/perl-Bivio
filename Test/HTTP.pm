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
my($_PACKAGE) = __PACKAGE__;
my($_PASSWORD);
my($_SAVE_PASS);
my($_USER);
Bivio::IO::Config->register({
    password => "foobar",
    save_pass => "0",
    user => "btfuserx",
});

=head1 METHODS

=cut


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
    return;
}

=for html <a name="link"></a>

=head2 static link(string label)

Visits the href associated with I<label> on the current page or dies.

=cut

sub link {
    my($proto, $label) = @_;
    my($scraper) = Bivio::Test::BulletinBoard->get_current()->get('response');


    my($uri) = ($scraper->get('links'))->{$label}->{href};

    die("Label: $label not found amoung page links.") unless (defined $uri);
    _trace("Label: $label corresponds to: $uri") if $_TRACE; 
  #  $proto->visit('/'.$uri);
    return;
}

=for html <a name="login"></a>

=head2 static login(string $user, string $pass, boolean $save)

=cut

=head2 static login(string $user, string $pass)

=cut

=head2 static login()

login is a static wrapper for the object method Login->execute().  It gets the
current login object from the C<Bivio::Test::BulletinBoard>.  If login
information (I<user>, I<pass>) are specified and do not match the current login
object, a new login object is made and the login is performed.

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

=head2 static verify_text(string text)

Dies if I<text> is not found within the current parsed response.

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

=head2 static verify_title(string $match_title)

Dies if title in current page does not match I<$match_title> (case
insensitive).

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

=head2 static verify_uri(string path)

Verifies that the uri of the current response contains I<path>.  The specified
uri should optimally be only the path after the base uri so that this will
succeed with different base uris.

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

Visits the page specified by I<uri> and puts the response and uri in the
current C<Bivio::Test::BulletinBoard> object.  The uri may be the path beyond a
base uri which will be substituted in.

=cut

sub visit {
    my(undef, $uri) = @_;
    _trace("passed url:", $uri, "\n")
	    if $_TRACE;
    Bivio::Test::BulletinBoard->get_current()->get('HTTPUtil')->http_href(
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
