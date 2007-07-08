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
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    my($self, $req) = @_;
    $self->map_invoke(obsolete_attr => [qw(headers want_aol_munge)]);
    my($msg) = Bivio::Mail::Outgoing->new;
    my($from) = $self->render_simple_attr('from', $req);
    $msg->set_header('From', $from);
    my($email) = (Bivio::Mail::Address->parse($from))[0]
	|| $self->die('from', $req, 'no email in From: ', $from);
    $msg->set_envelope_from($email);
    my($recips) = [];
    foreach my $header (qw(to cc subject)) {
	my($value) = '';
	if ($self->unsafe_render_attr($header, $req, \$value) && $value) {
	    $msg->set_header(ucfirst($header), $value);
	    push(@$recips, $value)
		unless $header eq 'subject';
	}
    }
    $msg->set_recipients(
	$self->render_simple_attr('recipients', $req) || $recips, $req);
    $msg->set_header('X-Originating-IP', $req->get('client_addr'))
	if $req->has_keys('client_addr');
    # Body must be rendered first in case the widget has mail headers.
    my($body) = $self->render_attr('body', $req);
    if (my $w = $self->unsafe_resolve_widget_value($self->get('body'), $req)) {
	$msg->map_invoke(set_header => $w->mail_headers($req))
	    if UNIVERSAL::can($w, 'mail_headers');
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
    $self->initialize_attr('from');
    $self->map_invoke(unsafe_initialize_attr =>
	[qw(recipients body cc to subject headers log_file)]);
    return;
}

sub render {
    # This widget is not renderable.
    # This method must be here to satisfy ->can('render').
    Bivio::Die->die('This widget is only executable, it cannot be rendered');
}

1;
