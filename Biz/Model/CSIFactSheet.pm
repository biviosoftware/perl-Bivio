# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIFactSheet;
use strict;
$Bivio::Biz::Model::CSIFactSheet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::CSIFactSheet::VERSION;

=head1 NAME

Bivio::Biz::Model::CSIFactSheet - keeps conversion factors and symbol changes

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSIFactSheet;

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::CSIBase>

=cut

use Bivio::Biz::Model::CSIBase;
@Bivio::Biz::Model::CSIFactSheet::ISA = ('Bivio::Biz::Model::CSIBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSIFactSheet>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
_initialize();

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'csi_fact_sheet_t',
	columns => {
	    csi_id => ['Bivio::Data::CSI::Id', 'PRIMARY_KEY'],
            date_time => ['Date', 'PRIMARY_KEY'],
            function => ['Bivio::Data::CSI::FactSheetFunction', 'NOT_NULL'],
            symbol => ['Name', 'NOT_NULL'],
            name => ['Line', 'NOT_NULL'],
            instrument_type => ['InstrumentType', 'NOT_NULL'],
            conversion_factor => ['Number', 'NOT_NULL'],
        },
    };
}

#=PRIVATE METHODS

# _initialize()
#
#
#
sub _initialize {
    Bivio::Biz::Model::CSIBase->internal_register_handler($_PACKAGE,
            Bivio::Data::CSI::RecordType::FACT_SHEET_MODIFICATION());
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
