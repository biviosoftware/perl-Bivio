# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::RealmUser;
use strict;
$Bivio::Biz::PropertyModel::RealmUser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::RealmUser - user settings related to a specific club

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::RealmUser;
    Bivio::Biz::PropertyModel::RealmUser->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::RealmUser::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::RealmUser>

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::SQL::Support;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    my($property_info) = {
	'realm_id' => ['Club Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'user_id' => ['User Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'role' => ['Role',
		Bivio::Biz::FieldDescriptor->lookup('ROLE', 2)],
    };
    return [$property_info,
	    Bivio::SQL::Support->new('realm_user_t', keys(%$property_info)),
	    ['realm_id', 'user_id']];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
