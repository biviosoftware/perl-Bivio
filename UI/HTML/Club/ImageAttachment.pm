# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ImageAttachment;
use strict;
$Bivio::UI::HTML::Club::ImageAttachment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::ImageAttachment - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ImageAttachment;
    Bivio::UI::HTML::Club::ImageAttachment->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::IO::Trace;
use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::ImageAttachment::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ImageAttachment> handles displaying an image stored
as a MIME attachment in the file server. The MIME attachment was stored with
the MIME header information, an X-BivioNumParts custom field which defines how
many other MIME parts there are to this part, and the actual MIME data (if any).
In this case, we know the MIME data is an image (either image/jpeg or image/gif)
and need to satisfy a request for the image data (an IMG SRC= HTML tag is
being handled by the server).

=cut

#=IMPORTS
use Bivio::IO::Config;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
Bivio::IO::Config->register({
    'file_server' => Bivio::IO::Config->REQUIRED,
});

my($_FILE_CLIENT);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::ImageAttachment



=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() :

This execute method returns to the $request->reply object the stream of raw image
data needed to display the image.


=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($body);
    _trace('executing ImageAttachment.execute method. ') if $_TRACE;
    if (defined($req->get('query')) && defined($req->get('query')->{img})) {
	my($club_name) = $req->get('auth_realm')->get('owner_name');
	my($attachment_id) = $req->get('query')->{img};
	my($filename) = '/'.$club_name.'/messages/html/'.$attachment_id;
	die("couldn't get mime  body for $attachment_id. Error: $body")
	    unless $_FILE_CLIENT->get($filename, \$body);
	my($i) = index($body, "X-BivioNumParts: ");
	_trace('index of X-BivioNumParts is: ', $i) if $_TRACE;
	my($subtype) = _get_image_subtype(\$body);
	if(!$subtype){
	    die("Could not determine image subtype in ImageAttachment.execute(). Only handling JPEG and GIF now.");
	}
	_trace('subtype of this image is: ', $subtype) if $_TRACE;
	my($stream) = substr($body, $i);
	$i = index($stream, "\n");
	$stream = substr($stream, $i+1);
	_trace('writing the image data to the stream') if $_TRACE;
	_trace('output type: ', 'image/', $subtype) if $_TRACE;
	$req->get('reply')->set_output_type("image/".$subtype);
	$req->get('reply')->print($stream);
    }
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
    $_FILE_CLIENT = Bivio::File::Client->new($cfg->{file_server});
    return;
}

#=PRIVATE METHODS

# _get_image_subtype() : 
#
#
#
sub _get_image_subtype {
    my($buffer) = @_;
    my($i) = index($$buffer, "Content-Type:");
    my($substr) = substr($$buffer, $i, 255);
    $i = index($substr, "\n");
    $substr = substr($substr, 0, $i);
    if($substr =~ "image/jpeg"){
	return "jpeg";
    }
    if($substr =~ "image/gif"){
	return "gif";
    }
    else{
	return undef;
    }
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
