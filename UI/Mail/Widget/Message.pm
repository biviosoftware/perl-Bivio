# Copyright (c) 2001-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Mail::Widget::Message;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_O) = __PACKAGE__->use('Mail.Outgoing');
my($_A) = __PACKAGE__->use('Mail.Address');
my($_L) = __PACKAGE__->use('IO.Log');

sub execute {
    my($self, $req) = @_;
    my($msg) = _render($self, $req);
    $msg->enqueue_send($req);
    my($lf);
    $_L->write($lf, $msg->as_string)
        if $self->unsafe_render_attr('log_file', $req, \$lf) && $lf;
    return;
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('from');
    $self->map_invoke(unsafe_initialize_attr => [qw(
	body
	cc
	headers_object
	recipients
	subject
	to
    )]);
    return;
}

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= _render($self, $source->req)->as_string;
    return;
}

sub _render {
    my($self, $req) = @_;
    $self->map_invoke(obsolete_attr => [qw(headers want_aol_munge)]);
    my($msg) = $_O->new;
    my($from) = $self->render_simple_attr('from', $req);
    $msg->set_header('From', $from);
    $self->die('from', $req, 'no email in From: ', $from)
	unless my $email = ($_A->parse($from))[0];
    $msg->set_envelope_from($email);
    my($recips) = [];
    $msg->set_header('X-Originating-IP', $req->get('client_addr'))
	if $req->has_keys('client_addr');
    foreach my $header (qw(to cc subject)) {
	my($value) = '';
	if ($self->unsafe_render_attr($header, $req, \$value) && $value) {
	    $msg->set_header(ucfirst($header), $value);
	    push(@$recips, $value)
		unless $header eq 'subject';
	}
    }
    $msg->set_recipients(
	$self->render_simple_attr('recipients', $req) || $recips,
	$req,
    );
    # Body must be rendered first in case the widget has mail headers.
    # However, must resolve to widget first, in case widget is dynamically
    # created by body attribute.
    my($b) = $self->unsafe_resolve_widget_value($self->get('body'), $req);
    my($body) = $self->render_value(body => $b, $req);
    $msg->map_invoke(set_header => $b->mail_headers($req))
	if $b && UNIVERSAL::can($b, 'mail_headers');
    # Allow headers_object to override any headers
    my($o) = $self->unsafe_get('headers_object');
    $msg->map_invoke(set_header => $o->mail_headers($req))
	if $o and $o = $self->unsafe_resolve_widget_value($o, $req);
    $msg->set_body($$body);
    $msg->add_missing_headers($req, $email);
    return $msg;
}

1;
