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
use Bivio::IO::Trace;
use Bivio::File::Client;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::DateTime;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;


#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_FILE_CLIENT);
Bivio::IO::Config->register({
    'file_server' => Bivio::IO::Config->REQUIRED,
});
use vars qw($_TRACE);
Bivio::IO::Trace->register;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::MessageAttachment



=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{attachment} = Bivio::UI::HTML::Widget::Indirect->new({
	value => 0,
	cell_rowspan => 1,
	cell_compact => 1,
	cell_align => 'NW',
    });
    $fields ->{content} = Bivio::UI::HTML::Widget::Join->new({
	values => [
	    '<center>by ',
	    Bivio::UI::HTML::Widget::Link->new({
		href => ['->format_mailto',
		    ['Bivio::Biz::Model::MailMessage', 'from_email'],
		    ['reply_subject'],
		],
		value => Bivio::UI::HTML::Widget::String->new({
		    value => ['Bivio::Biz::Model::MailMessage', 'from_name'],
		}),
	    }),
	    ' on ',
	    Bivio::UI::HTML::Widget::DateTime->new({
		mode => 'DATE_TIME',
		value => ['Bivio::Biz::Model::MailMessage',
		    'date_time']
	    }),
	    '</center><p><div align=left>',
	    $fields->{attachment},
	    '</div>',
	]
    });
    $fields->{content}->initialize;
    $fields->{action_bar} = Bivio::UI::HTML::Widget::ActionBar->new({
	values => Bivio::UI::HTML::ActionButtons->get_list(
	    'club_compose_message', 'club_reply_message'),
    });
    $fields->{action_bar}->initialize;
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
    my($filename) = '';
    my($html) = '';
    my($s) = '';
    my($esc) = 1;
    my($str) = '';
    $req->die(Bivio::DieCode::CORRUPT_QUERY()) unless
	    defined($req->get('query')) && defined($req->get('query')->{att});
    my($club_name) = $req->get('auth_realm')->get('owner_name');
	my($attachment_id) = $req->get('query')->{att};
    my($msg_id, $header_id) = $attachment_id =~ /^(\d+)_(\w+)/;
    $header_id =~ s/_/./g;
    my($msg) = Bivio::Biz::Model::MailMessage->new($req);
    $msg->load(mail_message_id => $msg_id);
    $filename = '/'.$club_name.'/messages/html/'.$attachment_id;
    $msg->die(Bivio::DieCode::NOT_FOUND())
	    unless $_FILE_CLIENT->get($filename, \$body);
    my($numparts) = _numparts(\$body);
    if ($numparts eq(0)) {
	_trace('there are zero numparts for this MIME part') if $_TRACE;
	my $ctypestr = _content_type(\$body);
	if ($ctypestr =~ 'text/plain') {
	    $esc = 1;
	}
	#everything we get from the file server should be text/html
	if ($ctypestr =~ 'text/html') {
	    $esc = 0;
	}
	if ($ctypestr =~ "image/") {
	    $esc = 0;
	    $html = "\n<IMG SRC=".$req->format_uri(
		    Bivio::Agent::TaskId::CLUB_COMMUNICATIONS_MESSAGE_IMAGE_ATTACHMENT(),
		    "img=".$attachment_id).">";
	}
	else {
#TODO: This is totally wrong, I suspect.  If no index found, then a total
#      hack.
#TODO: More hackery to fix text/plain being incorrect here.  It is already
#      been converted to html, but the header still has text/plain...
	    my($s) = substr($body, index($body, "\n\n") + 1);
	    $html = $s =~ /^\s*\<!DOC/i ? $s
		    : $esc ? Bivio::Util::escape_html($s) : $s;
	}
	$str = Bivio::UI::HTML::Widget::Join->new({
	    values => [$html],
	});
	$str->initialize();
	$fields->{attachment}->put(value => $str);
    }
    else {
	my(@urls);
	for (my $i = 0; $i < $numparts; $i++) {
	    my($attachment) = $attachment_id."_$i";
	    push(@urls,
		    Bivio::UI::HTML::Widget::Link->new({
			href  => $req->format_uri(
				Bivio::Agent::TaskId::CLUB_COMMUNICATIONS_MESSAGE_ATTACHMENT(),
				"att=".$attachment),
			value => Bivio::UI::HTML::Widget::String->new({
			    value => 'Attachment '.$i}),
		    }));
	    push(@urls, "<BR>");
	}
	my($mime_urls) = Bivio::UI::HTML::Widget::Join->new({
	    values => \@urls});
	$mime_urls->initialize;
	$fields->{attachment}->put(value => $mime_urls);
    }
    my($subject) = $msg->get('subject');
    my($reply_subject) =
	    Bivio::UI::HTML::Format::ReplySubject->get_widget_value($subject);
    $req->put(
	    page_subtopic => "Attachment $header_id",
	    page_heading => "Attachment $header_id: $subject",
	    page_content => $fields->{content},
	    page_action_bar => $fields->{action_bar},
#TODO: Should really be detail with a list generate of attachments...
	    page_type => Bivio::UI::PageType::NONE(),
	    reply_subject => $reply_subject,
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
    return $$body =~ /^(Content-Type:\s*\S+)/
	    ? $1 : 'Content-Type: text/plain';
}

# _numparts(scalar_ref) : int
#
# Returns the number of sub-parts for this MIME part.
#
sub _numparts {
    my($body) = @_;
    $$body =~ /(X-BivioNumParts: *)(\d+)/;
    if(!$1){
	return 0;
    }
    else{
	return $2;
    }
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
