# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Auth::RoleSet;
use strict;
$Bivio::Auth::RoleSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Auth::RoleSet - role set for configuration forms

=head1 SYNOPSIS

    use Bivio::Auth::RoleSet;

=cut

=head1 EXTENDS

L<Bivio::Type::EnumSet>

=cut

use Bivio::Type::EnumSet;
@Bivio::Auth::RoleSet::ISA = ('Bivio::Type::EnumSet');

=head1 DESCRIPTION

C<Bivio::Auth::RoleSet> holds a set of valid roles, e.g. used by
L<Bivio::Biz::Model::RealmUser|Bivio::Biz::Model::RealmUser>.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_enum_type"></a>

=head2 get_enum_type() : Bivio::Type::Enum

Returns L<Bivio::Auth::Role|Bivio::Auth::Role>.

=cut

sub get_enum_type {
    return 'Bivio::Auth::Role';
}

=for html <a name="get_width"></a>

=head2 get_width() : int

Returns 10.

=cut

sub get_width {
    return 10;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
