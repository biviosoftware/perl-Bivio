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

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::PetShop::Util::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::PetShop::Util> are utilities for initializing and
managing your PetShop.

=cut


=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:
  usage: b-petshop [options] command [args...]
  commands:
      create_db -- initializes database (must be run from files/ddl directory)
      destroy_db -- drops all the tables, indexes, and sequences created

=cut

sub USAGE {
    return <<'EOF';
usage: b-petshop [options] command [args...]
commands:
    create_db -- initializes database (must be run from files/ddl directory)
    destroy_db -- drops all the tables, indexes, and sequences created
EOF
}

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my(@_DATA);
my(@_SQL_FILES) = map {
    my($base) = $_;
    map {
	$base.'-'.$_.'.sql';
    } qw(tables constraints sequences);
} qw(bOP petshop);

=head1 METHODS

=cut

=for html <a name="create_db"></a>

=head2 create_db()

Initializes petshop database.  Must be un from from C<files/ddl> directory,
which contains C<bOP-tables.sql>, C<petshop-tables.sql>, etc.

See L<destroy_db|"destroy_db"> to see how you'd undo this operation.

=cut

sub create_db {
    my($self) = @_;
    my($req) = $self->get_request;
    my($sql) = $self->new_other('Bivio::Util::SQL');
    $self->usage('must be run in files/ddl directory')
	    unless -r $_SQL_FILES[0];
    foreach my $file (@_SQL_FILES) {
	# Set up new file so read_input returns new value each time
	$self->print('Executing ', $file, "\n");
	$sql->put(input => $file);
	$sql->run;
    }
    Bivio::Biz::Model->new($req, 'RealmOwner')->init_db;
    _init_realm_role($self);
    _init_demo($self);
    return;
}

=for html <a name="destroy_db"></a>

=head2 destroy_db()

Undoes the operations of L<create_db|"create_db">.

=cut

sub destroy_db {
    my($self) = @_;
    $self->usage('must be run in files/ddl directory')
	    unless -r $_SQL_FILES[0];
    $self->get_request;
    my($sql) = $self->new_other('Bivio::Util::SQL');
    # We drop in opposite order.  Some constraint drops will
    # fail, but that's ok.  We need to drop the foreign key
    # constraints so we can drop the tables.
    foreach my $file (reverse(@_SQL_FILES)) {
	$self->print('Dropping ', $file, "\n");
	$sql->put(input => $file);
	$sql->drop;
    }
    return;
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
	    'K9-BD-01:DOGS:Corgi:corgi:Friendly dog from England',
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

# _init_realm_role(self)
#
# Initializes the database with the values from __DATA__ section
# in this file.
#
sub _init_realm_role {
    my($self) = @_;
    unless (@_DATA) {
	# Cache so the command is idempotent.
	@_DATA = <DATA>;
	chomp(@_DATA);
	# Avoids error messages which point to <DATA>.
	close(DATA);
    }
    my($cmd);
    my($rr) = $self->new_other('Bivio::Biz::Util::RealmRole');
    foreach my $line (@_DATA) {
	# Skip comments and blank cmds
	next if $line =~ /^\s*(#|$)/;
	$cmd .= $line;

	# Continuation char at end of line?
	next if $cmd =~ s/\\$/ /;

	# Parse command
	my(@args) = split(' ', $cmd);

	# Delete the b-realm-role at the front of the configuration
	shift(@args);

	# Don't want a user to be loaded, so we use the default user
	$rr->main('-u', 'user', @args);
        $cmd = '';
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
__DATA__
# The following is used by _init_realm_role, but could also be run as
# a shell script.
#
# GENERAL Permissions
#
b-realm-role -r GENERAL edit ANONYMOUS - \
    +ANYBODY \
    +DATA_READ
b-realm-role -r GENERAL edit USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role -r GENERAL edit WITHDRAWN - \
    +USER
b-realm-role -r GENERAL edit GUEST - \
    +WITHDRAWN
b-realm-role -r GENERAL edit MEMBER - \
    +DATA_WRITE
b-realm-role -r GENERAL edit ACCOUNTANT - \
    +MEMBER
b-realm-role -r GENERAL edit ADMINISTRATOR - \
    +ACCOUNTANT

#
# USER Permissions
#
b-realm-role -r USER edit ANONYMOUS - \
    +ANYBODY
b-realm-role -r USER edit USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role -r USER edit WITHDRAWN - \
    +USER
b-realm-role -r USER edit GUEST - \
    +WITHDRAWN
b-realm-role -r USER edit MEMBER - \
    +DATA_READ \
    +DATA_WRITE
b-realm-role -r USER edit ACCOUNTANT - \
    +MEMBER
b-realm-role -r USER edit ADMINISTRATOR - \
    +ACCOUNTANT

#
# CLUB Permissions
#
b-realm-role -r CLUB edit ANONYMOUS - \
    +ANYBODY
b-realm-role -r CLUB edit USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role -r CLUB edit WITHDRAWN - \
    +USER
b-realm-role -r CLUB edit GUEST - \
    +WITHDRAWN
b-realm-role -r CLUB edit MEMBER - \
    +DATA_READ \
    +DATA_WRITE
b-realm-role -r CLUB edit ACCOUNTANT - \
    +MEMBER
b-realm-role -r CLUB edit ADMINISTRATOR - \
    +ACCOUNTANT
