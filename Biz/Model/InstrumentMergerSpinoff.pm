# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InstrumentMergerSpinoff;
use strict;
$Bivio::Biz::Model::InstrumentMergerSpinoff::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::InstrumentMergerSpinoff::VERSION;

=head1 NAME

Bivio::Biz::Model::InstrumentMergerSpinoff - merger/spin-off info

=head1 SYNOPSIS

    use Bivio::Biz::Model::InstrumentMergerSpinoff;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::InstrumentMergerSpinoff::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InstrumentMergerSpinoff> merger/spin-off info

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
	table_name => 'instrument_merger_spinoff_t',
	columns => {
	    action_date => ['Date', 'PRIMARY_KEY'],
	    action => ['InstrumentAction', 'PRIMARY_KEY'],
	    source_instrument_id => ['PrimaryId', 'PRIMARY_KEY'],
	    new_instrument_id => ['PrimaryId', 'PRIMARY_KEY'],
	    remaining_basis => ['Amount', 'NOT_NULL'],
	    new_shares_ratio => ['Amount', 'NOT_NULL'],
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
