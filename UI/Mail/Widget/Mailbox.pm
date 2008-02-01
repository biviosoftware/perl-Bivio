# Copyright (c) 2001-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Mail::Widget::Mailbox;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RFC) = __PACKAGE__->use('Mail.RFC822');

sub initialize {
    my($self) = @_;
    $self->initialize_attr('email');
    $self->unsafe_initialize_attr('name');
    return;
}

sub internal_new_args {
    my(undef, $email, $name, $attrs) = @_;
    return {
	email => $email,
	(defined($name) ? (name => $name) : ()),
	($attrs ? %$attrs : ()),
    };
}

sub render {
    my($self, $source, $buffer) = @_;
    $$buffer .= $_RFC->format_mailbox(
	$self->req->format_email(${$self->render_attr('email', $source)}),
	$self->render_simple_attr('name',  $source),
    );
    return;
}

1;
