# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentValuation;
use strict;
$Bivio::Biz::Model::InstrumentValuation::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::InstrumentValuation::VERSION;

=head1 NAME

Bivio::Biz::Model::InstrumentValuation - provide daily quotes formats

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentValuation;
    Bivio::Biz::Model::InstrumentValuation->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::InstrumentValuation::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentValuation>

=cut

#=IMPORTS
use Bivio::Data::CSI::Quote;

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'instrument_valuation_t',
	columns => {
	    instrument_id => ['PrimaryId', 'PRIMARY_KEY'],
            closing_date => ['Date', 'PRIMARY_KEY'],
            closing_price => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
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
