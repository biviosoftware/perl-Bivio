# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Util;
use strict;
$Bivio::PetShop::Util::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Util::VERSION;

=head1 NAME

Bivio::PetShop::Util - initializes and manages PetShop

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Util;

=cut

=head1 EXTENDS

L<Bivio::Util::SQL>

=cut

use Bivio::Util::SQL;
@Bivio::PetShop::Util::ISA = ('Bivio::Util::SQL');

=head1 DESCRIPTION

C<Bivio::PetShop::Util> are utilities for initializing and
managing your PetShop.

How to create the database.  As root:

   su - postgres
   createuser petuser
   createdb --username petuser --password petshop

As you:

   cd files/ddl
   b-petshop create_db

=cut

#=IMPORTS
use Bivio::Biz::Util::RealmRole;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_db"></a>

=head2 create_db()

Initializes petshop database.  Must be un from from C<files/ddl> directory,
which contains C<bOP-tables.sql>, C<petshop-tables.sql>, etc.

See L<destroy_db|"destroy_db"> to see how you'd undo this operation.

=cut

sub create_db {
    my($self) = shift;
    $self->SUPER::create_db(@_);
    _init_demo($self);
    return;
}

=for html <a name="ddl_files"></a>

=head2 ddl_files() : array_ref

Returns DDL SQL files used to create/destroy database.

=cut

sub ddl_files {
    return [map {
	my($base) = $_;
	map {
	    $base.'-'.$_.'.sql';
	} qw(tables constraints sequences);
    } qw(bOP petshop)];
}

#=PRIVATE METHODS

# _init_demo(self)
#
# Initializes demo data.
#
sub _init_demo {
    my($self) = @_;
    _init_demo_categories($self);
    _init_demo_products($self);
    _init_demo_items($self, _init_demo_suppliers($self));
    _init_demo_users($self);
    return;
}

# _init_demo_categories(self)
#
# Initializes Model.Category.
#
sub _init_demo_categories {
    my($self) = @_;
    my($model) = Bivio::Biz::Model->new($self->get_request, 'Category');
    foreach my $enum (Bivio::Type->get_instance('Category')->get_list) {
	# Don't create the '0' (UNKNOWN) case
	next if $enum->as_int == 0;
	$model->create({
	    category_id => $enum->get_name,
	    name => $enum->get_short_desc,
	    description => $enum->get_long_desc,
	});
    }
    return;
}

# _init_demo_items(array_ref suppliers)
#
# Init Model.Item and Model.inventory with rotating suppliers.
#
sub _init_demo_items {
    my($self, $suppliers) = @_;
    my($supplier) = 0;
    my($item) = Bivio::Biz::Model->new($self->get_request, 'Item');
    my($inventory) = Bivio::Biz::Model->new($self->get_request, 'Inventory');
    my($status) = Bivio::Type->get_instance('ItemStatus')->OK;
    foreach my $row (
	    'EST-1:FI-SW-01:16.5:10:Large',
	    'EST-2:FI-SW-01:16.5:10:Small',
	    'EST-3:FI-SW-02:18.5:12:Toothless',
	    'EST-4:FI-FW-01:18.5:12:Spotted',
	    'EST-5:FI-FW-01:18.5:12:Spotless',
	    'EST-6:K9-BD-01:18.5:12:Male Adult',
	    'EST-7:K9-BD-01:18.5:12:Female Puppy',
	    'EST-8:K9-PO-02:18.5:12:Male Puppy',
	    'EST-9:K9-DL-01:18.5:12:Spotless Male Puppy',
	    'EST-10:K9-DL-01:18.5:12:Spotted Adult Female',
	    'EST-11:RP-SN-01:18.5:12:Venomless',
	    'EST-12:RP-SN-01:18.5:12:Rattleless',
	    'EST-13:RP-LI-02:18.5:12:Green Adult',
	    'EST-14:FL-DSH-01:58.5:12:Tailless',
	    'EST-15:FL-DSH-01:23.5:12:With tail',
	    'EST-16:FL-DLH-02:93.5:12:Adult Female',
	    'EST-17:FL-DLH-02:93.5:12:Adult Male',
	    'EST-18:AV-CB-01:193.5:92:Adult Male',
	    'EST-19:AV-SB-02:15.5:2:Adult Male',
	    'EST-20:FI-FW-02:5.5:2:Adult Male',
	    'EST-21:FI-FW-02:5.29:1:Adult Female',
	    'EST-22:K9-RT-01:135.5:100:Adult Male',
	    'EST-23:K9-RT-01:145.49:100:Adult Female',
	    'EST-24:K9-RT-02:255.5:92:Adult Male',
	    'EST-25:K9-RT-02:325.29:90:Adult Female',
	   ) {
	my(@col) = split(/:/, $row);
	$item->create({
	    item_id => $col[0],
	    product_id => $col[1],
	    list_price => $col[2],
	    unit_cost => $col[3],
	    supplier_id => $suppliers->[$supplier++ % int(@$suppliers)],
	    status => $status,
	    attr1 => $col[4],
	});
	$inventory->create({
	    item_id => $col[0],
	    quantity => 10_000,
	});
    }
    return;
}

# _init_demo_products(self)
#
# Initializes Model.Product.
#
sub _init_demo_products {
    my($self) = @_;
    my($cat) = Bivio::Type->get_instance('Category');
    my($model) = Bivio::Biz::Model->new($self->get_request, 'Product');
    foreach my $row (
	    'FI-SW-01:FISH:Angelfish:angelfish:Salt Water fish from Australia',
	    'FI-SW-02:FISH:Tiger Shark:tigershark:Salt Water fish from Australia',
	    'FI-FW-01:FISH:Koi:koi:Fresh Water fish from Japan',
	    'FI-FW-02:FISH:Goldfish:reeffish:Fresh Water fish from China',
	    'K9-BD-01:DOGS:Corgi:corgi:Friendly dog from Wales',
	    'K9-PO-02:DOGS:Poodle:poodle:Cute dog from France',
	    'K9-DL-01:DOGS:Dalmation:dalmation:Great dog for a Fire Station',
	    'K9-RT-01:DOGS:German Shepard:shepard:Great family dog',
	    'K9-RT-02:DOGS:Labrador Retriever:lab:Great hunting dog',
	    'RP-SN-01:REPTILES:Rattlesnake:rattlesnake:Doubles as a watch dog',
	    'RP-LI-02:REPTILES:Iguana:iguana:Friendly green friend',
	    'FL-DSH-01:CATS:Manx:manx:Great for reducing mouse populations',
	    'FL-DLH-02:CATS:Persian:persian:Friendly house cat, doubles as a princess',
	    'AV-CB-01:BIRDS:Amazon Parrot:parrot:Great companion for up to 75 years',
	    'AV-SB-02:BIRDS:Finch:finch:Great stress reliever') {

	my(@col) = split(/:/, $row);
	$model->create({
	    product_id => $col[0],
	    category_id => $cat->from_name($col[1])->get_name,
	    name => $col[2],
	    image_name => $col[3],
	    description => $col[4],
	});
    }
    return;
}

# _init_demo_suppliers(self) : array_ref
#
# Initializes suppliers.  Returns the supplier ids.
#
sub _init_demo_suppliers {
    my($self) = @_;
    my(@id);
    my($model) = Bivio::Biz::Model->new($self->get_request, 'Supplier');
    my($status) = Bivio::Type->get_instance('SupplierStatus')->PREFERRED;
    foreach my $name ('XYZ Pets', 'ABC Pets') {
	$model->create({
	    name => $name,
	    status => $status,
	});
	push(@id, $model->get('supplier_id'));
    }
    return \@id;
}

# _init_demo_users(self)
#
# Creates user demo@bivio.biz with password "password".  Creates user
# root@bivio.biz.
#
sub _init_demo_users {
    my($self) = @_;
    my($req) = $self->get_request;
    foreach my $u ('demo', ($req->is_production ? () : ('root'))) {
	$self->print("Created user $u\@bivio.biz\n");
	Bivio::Biz::Model->get_instance('UserAccountForm')->execute($req, {
	    'User.first_name' => 'Demo',
	    'User.last_name' => 'User',
	    'Email.email' => "$u\@bivio.biz",
	    'EntityAddress.addr1' => '1313 Mockingbird Lane',
	    'EntityAddress.addr2' => undef,
	    'EntityAddress.city' => 'Boulder',
	    'EntityAddress.state' => 'CO',
	    'EntityAddress.zip' => '80304',
	    'EntityAddress.country' => 'US',
	    'EntityPhone.phone' => '555-1212',
	    'RealmOwner.password' => 'password',
	    force_create => 1,
	});
	# demo accounts have real names, for ease of logging in
	$req->get('auth_user')->update({
	    name => $u,
	});
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
