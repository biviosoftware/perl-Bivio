# Copyright (c) 2001 bivio Inc.  All rights reserved.
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
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attrs) : Bivio::UI::Mail::Widget::Mailbox

=head2 static new(any email, any name) : Bivio::UI::Mail::Widget::Mailbox

Creates a new Mailbox widget.  I<email> and I<name> will be set
to the attributes by the same names.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(_new_args(@_));
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes child widgets.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{email} = $self->initialize_attr('email');
    $fields->{name} = $self->unsafe_initialize_attr('name');
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string buffer)

Renders I<email> and I<name> in I<buffer> retrieving values from
I<source>.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($b) = '';
    if ($self->unsafe_render_value('name', $fields->{name}, $source, \$b)) {
	$$buffer .= Bivio::Mail::RFC822->escape_header_phrase($b).' <';
#TODO: Check syntax??
	$self->render_value('email', $fields->{email}, $source, $buffer);
	$$buffer .= '>';
    }
    else {
	# No <> if no phrase.
#TODO: Check syntax??
	$self->render_value('email', $fields->{email}, $source, $buffer);
    }
    return;
}

#=PRIVATE METHODS

# _new_args(proto, any email, ...) : array
#
# Returns arguments to be passed to Attributes::new.
#
sub _new_args {
    my($proto, $email, $name) = @_;
    return ($proto, $email) if ref($email) eq 'HASH';
    return ($proto, {
	email => $email,
	name => $name,
    }) if defined($email);
    Bivio::Die->die('invalid arguments to new (missing email)');
    # DOES NOT RETURN
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
