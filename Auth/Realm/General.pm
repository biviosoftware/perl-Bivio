# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Realm::General;
use strict;
$Bivio::Auth::Realm::General::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Realm::General - defines the realm without an owner

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Auth::Realm::General;
    Bivio::Auth::Realm::General->new();

=cut

=head1 EXTENDS

L<Bivio::Auth::Realm>

=cut

use Bivio::Auth::Realm;
@Bivio::Auth::Realm::General::ISA = ('Bivio::Auth::Realm');

=head1 DESCRIPTION

C<Bivio::Auth::Realm::General> defines the "default" realm, i.e.
the one without a specific owner.

=cut

#=IMPORTS
use Bivio::IO::Config;

#=VARIABLES
my($_SELF);
my($_USE_PERMISSIONS) = 1;
Bivio::IO::Config->register({
    use_permissions => 1,
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Auth::Realm::General

=cut

sub new {
    my($proto) = @_;
    return Bivio::Auth::Realm::new($proto);
}

=head1 METHODS

=cut

=for html <a name="can_user_execute_task"></a>

=head2 can_user_execute_task(Bivio::Agent::Task task, Bivio::Agent::Request req) : boolean

Returns true if I<auth_user> of I<req> can execute I<task>.

=cut

sub can_user_execute_task {
    my($self, $task, $req) = @_;
    return 1 unless $_USE_PERMISSIONS;
    return $self->SUPER::can_user_execute_task($task, $req);
}

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::Auth::Realm::General

Returns the singleton instance of the general realm.

=cut

sub get_instance {
    my($proto) = @_;
    $_SELF = $proto->new unless $_SELF;
    return $_SELF;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item use_permissions : boolean [1]

Are GENERAL permissions checked prior to executing the task? This allows
avoiding a database call for apps which don't require one.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_USE_PERMISSIONS = $cfg->{use_permissions};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
