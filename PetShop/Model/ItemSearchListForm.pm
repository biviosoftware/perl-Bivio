# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::ItemSearchListForm;
use strict;
$Bivio::PetShop::Model::ItemSearchListForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::ItemSearchListForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::ItemSearchListForm - search results

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::ItemSearchListForm;

=cut

=head1 EXTENDS

L<Bivio::PetShop::Model::ItemListForm>

=cut

use Bivio::PetShop::Model::ItemListForm;
@Bivio::PetShop::Model::ItemSearchListForm::ISA = ('Bivio::PetShop::Model::ItemListForm');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::ItemSearchListForm>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	list_class => 'ItemSearchList',
    });
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
