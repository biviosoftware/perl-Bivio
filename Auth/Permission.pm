# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::Permission;
use strict;
$Bivio::Auth::Permission::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::Permission - used to define task access requirements

=head1 SYNOPSIS

    use Bivio::Auth::Permission;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Auth::Permission::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Auth::Permission> is used to specify a task's access
permissions.  See L<Bivio::Agent::Task|Bivio::Agent::Task> for
how the permissions are defined.

NOTE: When you add a new permission, you must update the
      corresponding table (realm_role_t) in the database.
      Use tool b-realm-role for this.

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    # DO NOT CHANGE the numbers in this list, the values are
    # stored in the database.
    UNKNOWN => [0],
    DEBUG_ACTION => [1],
    ACCOUNTING_READ => [2],
    ACCOUNTING_WRITE => [3],
    MAIL_READ => [4],
    MAIL_WRITE => [5],
    FINANCIAL_DATA_READ => [6],
    MOTION_READ => [7],
    MOTION_WRITE => [8],
    MEMBER_READ => [9],
    MEMBER_WRITE => [10],
    ADMIN_READ => [11],
    ADMIN_WRITE => [12],
    DOCUMENT_READ => [13],
    LOGIN => [14],
    MAIL_RECEIVE => [15],
    DOCUMENT_WRITE => [16],
    ANY_USER => [17],
    MAIL_ADMIN => [18],
    MAIL_FORWARD => [19],
);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
