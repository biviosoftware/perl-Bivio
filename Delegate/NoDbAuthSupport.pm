# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::NoDbAuthSupport;
use strict;
$Bivio::Delegate::NoDbAuthSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::NoDbAuthSupport::VERSION;

=head1 NAME

Bivio::Delegate::NoDbAuthSupport - auth support without a database

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::NoDbAuthSupport;

=cut

=head1 EXTENDS

L<Bivio::Delegate>

=cut

use Bivio::Delegate;
@Bivio::Delegate::NoDbAuthSupport::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::NoDbAuthSupport> provides support for authenication
without a database.  Always grants permissions to the user.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_auth_user"></a>

=head2 get_auth_user() : Bivio::Biz::Model

Returns C<undef>.  No auth user.

=cut

sub get_auth_user {
    return undef;
}

=for html <a name="load_permissions"></a>

=head2 load_permissions() : Bivio::Auth::PermissionSet

All permissions are true.

=cut

sub load_permissions {
    return Bivio::Auth::PermissionSet->get_max;
}

=for html <a name="task_permission_ok"></a>

=head2 task_permission_ok() : boolean

Returns true always.

=cut

sub task_permission_ok {
    return 1;
}

=for html <a name="unsafe_get_user_pref"></a>

=head2 static unsafe_get_user_pref() : boolean

No database, so no preferences.

=cut

sub unsafe_get_user_pref {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
