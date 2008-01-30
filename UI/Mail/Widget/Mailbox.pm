# Copyright (c) 2001-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Mail::Widget::Mailbox;
use strict;
use Bivio::Base 'UI.Widget';

# C<Bivio::UI::Mail::Widget::Mailbox> is a single RFC822 mailbox email
# address.  Groups and multiple addresses are not supported.
#
#
#
# email : any (required)
#
# Email address to render.  See
# L<Bivio::UI::Widget::render_attr|Bivio::UI::Widget/"render_attr">
# for allowed attribute types.
#
# name : any []
#
# Email address to render.  See
# L<Bivio::UI::Widget::render_attr|Bivio::UI::Widget/"render_attr">
# for allowed attribute types.

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
    return '"email" attribute must be defined'
	unless $email;
    return {
	email => $email,
	(defined($name) ? (name => $name) : ()),
	($attrs ? %$attrs : ()),
    };
}

sub render {
    my($self, $source, $buffer) = @_;
    my($b) = '';
    my($e) = $self->get_request->format_email(
	${$self->render_attr('email', $source)});
    $$buffer .= $self->unsafe_render_attr('name',  $source, \$b)
	    ? $_RFC->escape_header_phrase($b) . " <$e>"
	    : $e;
    return;
}

1;
