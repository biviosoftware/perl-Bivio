# Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Mail::Widget::Mailbox;
use strict;
$Bivio::UI::Mail::Widget::Mailbox::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Mail::Widget::Mailbox::VERSION;

=head1 NAME

Bivio::UI::Mail::Widget::Mailbox - single mail address formatted for a header

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Mail::Widget::Mailbox;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Mail::Widget::Mailbox::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Mail::Widget::Mailbox> is a single RFC822 mailbox email
address.  Groups and multiple addresses are not supported.

=head1 ATTRIBUTES

=over 4

=item email : any (required)

Email address to render.  See
L<Bivio::UI::Widget::render_attr|Bivio::UI::Widget/"render_attr">
for allowed attribute types.

=item name : any []

Email address to render.  See
L<Bivio::UI::Widget::render_attr|Bivio::UI::Widget/"render_attr">
for allowed attribute types.

=back

=cut

#=IMPORTS
use Bivio::Mail::RFC822;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes child widgets.

=cut

sub initialize {
    my($self) = @_;
    $self->initialize_attr('email');
    $self->unsafe_initialize_attr('name');
    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any args, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut


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

=for html <a name="render"></a>

=head2 render(any source, string buffer)

Renders I<email> and I<name> in I<buffer> retrieving values from
I<source>.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($b) = '';
    my($e) = $self->get_request->format_email(
	${$self->render_attr('email', $source)});
    $$buffer .= $self->unsafe_render_attr('name',  $source, \$b)
	    ? Bivio::Mail::RFC822->escape_header_phrase($b) . " <$e>"
	    : $e;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
