# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::MessageAttachment;
use strict;
$Bivio::UI::HTML::Club::MessageAttachment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::MessageAttachment - Displays a MIME encoded part of an email

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::MessageAttachment;
    Bivio::UI::HTML::Club::MessageAttachment->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::MessageAttachment::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::MessageAttachment> shows a window with a MIME part in it.
It also displays links to other, nested MIME parts.

=cut

#=IMPORTS
use Bivio::IO::Config;
#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Model::MailMessage;
use Bivio::DieCode;
use Bivio::File::Client;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;


#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_FILE_CLIENT);
Bivio::IO::Config->register({
    'file_server' => Bivio::IO::Config->REQUIRED,
});


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::MessageAttachment



=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
#    $fields->{content} = Bivio::UI::HTML::Widget::Join->new({
#	value => ['body'],
#	});
    $fields ->{content} = Bivio::UI::HTML::Widget::Indirect->new({
 	      value => 0,
	      cell_rowspan => 1,
	      cell_compact => 1,
	      cell_align => 'N',
 	    });
    $fields->{content}->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() : 



=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($body);
    my($fh);
    my($filename);
    my($s);
    my($esc) = 1;
    if (defined($req->get('query')) && defined($req->get('query')->{att})) {
	my($club_name) = $req->get('auth_realm')->get('owner_name');
	my($attachment_id) = $req->get('query')->{att};
	$filename = '/'.$club_name.'/messages/html/'.$attachment_id;
	die("couldn't get mime  body for $attachment_id. Error: $body")
	    unless $_FILE_CLIENT->get($filename, \$body);
#	$s = _numparts(\$s); 
	my $ctypestr = _content_type(\$body);
	if($ctypestr =~ 'text/plain'){$esc = 1;}
	#everything we get from the file server should be text/html
	if($ctypestr =~ 'text/html'){$esc = 0;}
	if($ctypestr =~ "image/"){
	    $esc = 0;
	    $s = "\n<IMG SRC=".$req->format_uri(
		Bivio::Agent::TaskId::CLUB_COMMUNICATIONS_MESSAGE_IMAGE_ATTACHMENT(),
		"img=".$attachment_id).">";
	}
	my($str) = Bivio::UI::HTML::Widget::String->new({
		value => $s,
	        escape_text => $esc
	    });
#	$req->put(body => $s);
#	$fields->{content}->put( body => $s);
	$fields->{content}->put(value => $str);
	$str->initialize();
    }
    $req->put(
	    page_subtopic => "", 
	    page_heading => "", 
	    page_content => $fields->{content},
	    page_action_bar => 0,
	    );
#	    body => $s,
    Bivio::UI::HTML::Club::Page->execute($req);
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

# _content_type() : 
#
#
#
sub _content_type {
    my($body) = @_;
    my $i = index($$body, 'Content-Type: ');
    my($ctypestr) = substr($$body, $i);
    $i = index($ctypestr, "\n");
    $ctypestr = substr($ctypestr, 0, $i);
    return $ctypestr;
}

# _numparts() : 
#
#
#
sub _numparts {
    my($body) = @_;
    my($i) = index($$body, 'X-BivioNumParts: ');
    my($s) = substr($$body, $i);
    $i = index($s, "\n");
    $s = substr($s, $i);
    return $s;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
