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

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::ImageAttachment::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ImageAttachment>

=cut

#=IMPORTS
use Bivio::IO::Config;

#=VARIABLES
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
#    $fields ->{content} = Bivio::UI::HTML::Widget::Indirect->new({
# 	      value => 0,
#	      cell_rowspan => 1,
#	      cell_compact => 1,
#	      cell_align => 'N',
# 	    });
#    $fields->{content}->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() :

Placeholder for checking into cvs


=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($body);
    if (defined($req->get('query')) && defined($req->get('query')->{img})) {
	my($club_name) = $req->get('auth_realm')->get('owner_name');
	my($attachment_id) = $req->get('query')->{img};
	my($filename) = '/'.$club_name.'/messages/html/'.$attachment_id;
	die("couldn't get mime  body for $attachment_id. Error: $body")
	    unless $_FILE_CLIENT->get($filename, \$body);
	my($i) = index($body, "X-BivioNumParts: ");
	my($subtype) = _get_image_subtype(\$body);
	if(!$subtype){
	    die("Could not determine image subtype in ImageAttachment.execute()");
	}
	my($stream) = substr($body, $i);
	$i = index($stream, "\n");
	$stream = substr($stream, $i);
	$req->get('reply')->set_output_type("image/$subtype");
	$req->get('reply')->print($stream);
	$req->get('reply')->flush();
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
