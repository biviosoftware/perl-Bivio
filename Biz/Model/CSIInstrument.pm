# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIInstrument;
use strict;
$Bivio::Biz::Model::CSIInstrument::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::CSIInstrument::VERSION;

=head1 NAME

Bivio::Biz::Model::CSIInstrument - keeps instrument id and type

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSIInstrument;

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::CSIBase>

=cut

use Bivio::Biz::Model::CSIBase;
@Bivio::Biz::Model::CSIInstrument::ISA = ('Bivio::Biz::Model::CSIBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSIInstrument>

=cut

#=IMPORTS
use Bivio::Biz::Model::Instrument;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'csi_instrument_t',
	columns => {
	    csi_id => ['Bivio::Data::CSI::Id', 'PRIMARY_KEY'],
            instrument_id => ['PrimaryId', 'NOT_NULL'],
            instrument_type => ['InstrumentType', 'NOT_NULL'],
        },
    };
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values) : Bivio::Biz::Model::CSIInstrument

We don't allow updates for now.

=cut

sub update {
    my($self) = @_;
    Bivio::Die->die("no updates allowed (maybe, but let's see first...)");
    # DOES NOT RETURN
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
