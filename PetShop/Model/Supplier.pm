# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Supplier;
use strict;
$Bivio::PetShop::Model::Supplier::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::Supplier::VERSION;

=head1 NAME

Bivio::PetShop::Model::Supplier - item supplier

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::Supplier;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::PetShop::Model::Supplier::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::Supplier>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values) : self

Creates an I<Model.Entity> if I<entity_id> is not set.

=cut

sub create {
    my($self, $values) = @_;
    $values->{supplier_id} = Bivio::Biz::Model->new(
	    $self->get_request, 'Entity'
	)->create
	->get('entity_id')
    	unless $values->{supplier_id};
    return $self->SUPER::create($values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'supplier_t',
	columns => {
            supplier_id => ['Entity.entity_id', 'PRIMARY_KEY'],
	    name => ['Line', 'NOT_NULL'],
	    status => ['SupplierStatus', 'NOT_NULL'],
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
