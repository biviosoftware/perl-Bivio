# Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Mail::Widget::UserMailbox;
use strict;
$Bivio::UI::Mail::Widget::UserMailbox::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Mail::Widget::UserMailbox::VERSION;

=head1 NAME

Bivio::UI::Mail::Widget::UserMailbox - Mailbox for a User

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Mail::Widget::UserMailbox;

=cut

=head1 EXTENDS

L<Bivio::UI::Mail::Widget::Mailbox>

=cut

use Bivio::UI::Mail::Widget::Mailbox;
@Bivio::UI::Mail::Widget::UserMailbox::ISA = ('Bivio::UI::Mail::Widget::Mailbox');

=head1 DESCRIPTION

C<Bivio::UI::Mail::Widget::UserMailbox> single user's mailbox

=head1 ATTRIBUTES

=over 4

=item user_id : any (required)

User to render.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes child widgets.

=cut

sub initialize {
    my($self) = @_;
    $self->initialize_attr('user_id');
    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any args, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut


sub internal_new_args {
    my(undef, $user_id, $attrs) = @_;
    return '"user_id" attribute must be defined'
	unless $user_id;
    return {
        user_id => $user_id,
	($attrs ? %$attrs : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, string buffer)

Sets email and name and calls superclass.

=cut

sub render {
    my($self, $source) = @_;
    my($user_id) = $self->render_attr('user_id', $source);
    my($user) = Bivio::Biz::Model->new($source->get_request, 'User')
        ->unauth_load_or_die({
            user_id => $$user_id,
        });
    $self->put(name => $user->format_full_name);
    $self->put(email => $user->new_other('Email')->unauth_load_or_die({
        realm_id => $$user_id,
    })->get('email'));
    shift->SUPER::render(@_);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
