# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::EntityAddress;
use strict;
$Bivio::PetShop::Model::EntityAddress::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::EntityAddress::VERSION;

=head1 NAME

Bivio::PetShop::Model::EntityAddress - an entity address

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::EntityAddress;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::PetShop::Model::EntityAddress::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::EntityAddress>

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
	table_name => 'entity_address_t',
	columns => {
            entity_id => ['Entity.entity_id', 'PRIMARY_KEY'],
	    location => ['EntityLocation', 'PRIMARY_KEY'],
	    addr1 => ['Line', 'NOT_NULL'],
	    addr2 => ['Line', 'NONE'],
	    city => ['Name', 'NOT_NULL'],
	    state => ['Name', 'NOT_NULL'],
	    zip => ['Name', 'NOT_NULL'],
	    country => ['Country', 'NOT_NULL'],
        },
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
