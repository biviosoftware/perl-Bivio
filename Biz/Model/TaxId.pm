# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::TaxId;
use strict;
$Bivio::Biz::Model::TaxId::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::TaxId::VERSION;

=head1 NAME

Bivio::Biz::Model::TaxId - interface to tax_id_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::TaxId;
    Bivio::Biz::Model::TaxId->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::TaxId::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::TaxId> is the create, read, update,
and delete interface to the C<tax_id_t> table.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'tax_id_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    # We currently only allow SSNs and EINs, but we could
	    # change this type dynamically.
            tax_id => ['USTaxId', 'NONE'],
        },
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
