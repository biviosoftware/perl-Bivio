# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Model::Category;
use strict;
$Bivio::PetShop::Model::Category::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::Category::VERSION;

=head1 NAME

Bivio::PetShop::Model::Category - product category

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::Category;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::PetShop::Model::Category::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::Category>

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
	table_name => 'category_t',
	columns => {
	    category_id => ['Name', 'PRIMARY_KEY'],
	    name => ['Line', 'NONE'],
	    description => ['Text', 'NONE'],
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
