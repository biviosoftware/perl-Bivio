# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Mail::ComposeAction;
use strict;
$Bivio::Biz::Mail::ComposeAction::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::Mail::ComposeAction - A mail composition action

=head1 SYNOPSIS

    use Bivio::Biz::Mail::ComposeAction;
    Bivio::Biz::Mail::ComposeAction->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

@Bivio::Biz::Mail::ComposeAction::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Mail::ComposeAction>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string email, string description) : Bivio::Biz::Mail::ComposeAction



=cut

sub new {
    my($proto, $email, $description) = @_;
    my($self) = &Bivio::Biz::Action::new($proto,
	   'compose', 'Compose', $description, '/i/compose.gif');
    $self->{$_PACKAGE} = {
	email => $email
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="can_execute"></a>

=head2 can_execute(UNIVERSAL target) : boolean

Returns 1 if the action can execute, 0 otherwise.

=cut

sub can_execute {
    return 1;
}

=for html <a name="can_unexecute"></a>

=head2 can_unexecute(UNIVERSAL target) : boolean

Returns 1 if the action can be undone, 0 otherwise.

=cut

sub can_unexecute {
    return 0;
}

=for html <a name="execute"></a>

=head2 execute(UNIVERSAL target, Request req) : boolean

ComposeAction is client side only - never executed on the server.

=cut

sub execute {
    die("ComposeAction is a client side action");
}

=for html <a name="get_email"></a>

=head2 get_email() : string

Returns the target email address.

=cut

sub get_email {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{email};
}

=for html <a name="unexecute"></a>

=head2 unexecute(UNIVERSAL target, Request req) : boolean

ComposeAction is client side only and idempotent, not undoable.

=cut

sub unexecute {
    die("ComposeAction is a client side action");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
