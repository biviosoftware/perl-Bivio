# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::UserAccount;
use strict;
$Bivio::PetShop::Model::UserAccount::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::UserAccount::VERSION;

=head1 NAME

Bivio::PetShop::Model::UserAccount - user account for ordering

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::UserAccount;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::PetShop::Model::UserAccount::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::UserAccount>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'user_account_t',
	columns => {
            user_id => ['User.user_id', 'PRIMARY_KEY'],
            entity_id => ['Entity.entity_id', 'NOT_NULL'],
	    status => ['UserStatus', 'NOT_NULL'],
	    user_type => ['UserType', 'NOT_NULL'],
	    last_cart_id => ['Cart.cart_id', 'NONE'],
	},
	auth_id => 'user_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
