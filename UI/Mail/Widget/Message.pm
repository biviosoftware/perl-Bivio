# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Mail::Widget::Message;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::Die;
use Bivio::IO::Log;
use Bivio::Mail::Address;
use Bivio::Mail::Outgoing;

# C<Bivio::UI::Mail::Widget::Message> creates and enqueues a plain text
# mail message.  Eventually, this widget will be expanded to support
# attachments and other content types.
#
# See L<Bivio::Mail::Outgoing|Bivio::Mail::Outgoing>.
#
#
# All attributes are rendered identically.  They may be widget values,
# constants, widgets, or widget values which return widgets.
#
#
# body : any []
#
# The body of the message.
#
# cc : any []
#
# The Cc: address(es) in the header.  See I<recipients> for
# the actual send-to addresses.
#
# from : any (required)
#
# The From: address in the header.
#
# headers : any []
#
# I<Deprecated>
# Any additional headers.  Returns a string in RFC 822 header format.  Each
# header appears on its own line.
#
# log_file : any []
#
# Where to log the message, if defined.  Calls
# L<Bivio::IO::Log::write|Bivio::IO::Log/"write"> with the formatted
# message.
#
# recipients : any (required)
#
# The recipients is a string of addresses separated by a comma.
# Use a L<Bivio::UI::Widget::Join|Bivio::UI::Widget::Join> with
# a comma separator if you have more than one address.
#
# subject : any []
#
# The Subject: address in the header.
#
# to : any []
#
# The To: address(es) in the header.  See I<recipients> for
# the actual send-to addresses.
#
# want_aol_munge : boolean [true]
#
# munge body by wrapping urls and email addresses in HTMl.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($self, $req) = @_;
    # Creates and sends a mail message.
    my($msg) = Bivio::Mail::Outgoing->new();
    my($from) = $self->render_attr('from', $req);
    $msg->set_header('From', $$from);
    my($email) = Bivio::Mail::Address->parse($$from);
    $self->die('from', $req, 'no email in From: ', $$from)
	unless $email;
    $msg->set_envelope_from($email);

    my($recipients) = '';
    $self->unsafe_render_attr('recipients', $req, \$recipients);
    my(@recips) = ();

    foreach my $header (qw(to cc subject)) {
	my($value) = '';

	if ($self->unsafe_render_attr($header, $req, \$value) && $value) {
	    $msg->set_header(ucfirst($header), $value);
	    push(@recips, $value) unless $header eq 'subject';
	}
    }
    $msg->set_recipients($recipients || \@recips, $req);
    $msg->set_header('X-Originating-IP', $req->get('client_addr'))
	    if $req->has_keys('client_addr');

    #Body must be rendered first in case the widget has mail headers.
    my($body) = $self->render_attr('body', $req);

    #Deprecated attribute
    my($b) = '';
    $self->die($self, ': headers attribute is deprecated')
	if $self->unsafe_render_attr('headers', $req, \$b) && $b;

    my($body_widget) = $self->unsafe_resolve_widget_value(
        $self->get('body'), $req);
    if (UNIVERSAL::can($body_widget, 'mail_headers')) {
	_add_mail_headers($self, $msg, $body_widget->mail_headers($req));
    }

    #TODO: Eliminate
    if ($self->get_or_default('want_aol_munge', 1)
	&&  $recipients =~ /\@(?:aol|compuserve|cs).com$/i) {
	# AOL and compuserv are totally brain dead.
	$body = _text_to_aol($body);
    }

    $msg->set_body($$body);
    $msg->enqueue_send($req);

    my($lf);
    Bivio::IO::Log->write($lf, $msg->as_string)
        if $self->unsafe_render_attr('log_file', $req, \$lf) && $lf;
    return;
}

sub initialize {
    my($self) = @_;
    # Initializes child widgets.
    $self->initialize_attr('from');
    foreach my $f (qw(recipients body cc to subject headers log_file)) {
	$self->unsafe_initialize_attr($f);
    }
    return;
}

sub new {
    # Create a widget.
    return shift->SUPER::new(@_);
}

sub render {
    # This widget is not renderable.
    # This method must be here to satisfy ->can('render').
    Bivio::Die->die('This widget is only executable, it cannot be rendered');
    # DOES NOT RETURN
}

sub _add_mail_headers {
    my($self, $msg, $headers) = @_;
    # Sets headers
    foreach my $header (@$headers) {
	$msg->set_header(@$header);
    }
    return;
}

sub _text_to_aol {
    my($text) = @_;
    # Generates something that AOL's mail reader can understand.  AOL
    # does not highlight links unless they are in an <a href>.  It also
    # doesn't understand all tags.  The tags it does understand, it strips.
    my($html) = "<html>\n";
    foreach my $line (split(/\n/, $$text)) {
	# Put in minimal tags to generate links.  Don't replace anything
	# else.
	$line =~ s/(https?:\S+\w)/<a href="$1">$1<\/a>/g;
	$line =~ s/(\w\S+@\S+\w)/<a href="mailto:$1">$1<\/a>/g;
	$html .= $line ."\n";
    }
    $html .= "</html>\n";
    return \$html;
}

1;
