# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::TaxK1;
use strict;
$Bivio::Biz::Model::TaxK1::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::TaxK1 - IRS K-1 tax parameters

=head1 SYNOPSIS

    use Bivio::Biz::Model::TaxK1;
    Bivio::Biz::Model::TaxK1->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::TaxK1::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::TaxK1> IRS K-1 tax parameters

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_default"></a>

=head2 create_default(string user_id, string fiscal_end_date, Bivio::Type::F1065IRSCenter irs_center)

Creates a K1 model for the current realm with default values.

=cut

sub create_default {
    my($self, $user_id, $fiscal_end_date, $irs_center) = @_;

    $self->create({
	realm_id => $self->get_request->get('auth_id'),
	user_id => $user_id,
	fiscal_end_date => $fiscal_end_date,
	entity_type => Bivio::Type::F1065Entity->INDIVIDUAL,
	irs_center => $irs_center,
	partner_type => Bivio::Type::F1065Partner->GENERAL,
	foreign_partner => 0,
    });
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'tax_k1_t',
	columns => {
	    realm_id => ['PrimaryId', 'PRIMARY_KEY'],
	    user_id => ['PrimaryId', 'PRIMARY_KEY'],
	    fiscal_end_date => ['Date', 'PRIMARY_KEY'],
	    entity_type => ['F1065Entity', 'NOT_NULL'],
	    irs_center => ['F1065IRSCenter', 'NOT_NULL'],
	    partner_type => ['F1065Partner', 'NOT_NULL'],
	    foreign_partner => ['Boolean', 'NOT_NULL'],
        },
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
