# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSISplit;
use strict;
$Bivio::Biz::Model::CSISplit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::CSISplit - provide split format

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSISplit;
    Bivio::Biz::Model::CSISplit->new();

=cut

=head1 EXTENDS

L<Bivio::Biz:Model::CSIBase>

=cut

use Bivio::Biz::Model::CSIBase;
@Bivio::Biz::Model::CSISplit::ISA = ('Bivio::Biz::Model::CSIBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSISplit>

=cut

#=IMPORTS
use Bivio::Data::CSI::Amount;
use Bivio::Data::CSI::Id;

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
	table_name => 'csi_split_t',
	columns => {
	    csi_id => ['Bivio::Data::CSI::Id', 'PRIMARY_KEY'],
	    split_date => ['Date', 'PRIMARY_KEY'],
	    new_shares => ['Integer', 'NOT_NULL'],
	    old_shares => ['Integer', 'NOT_NULL'],
	},
    };
}

=for html <a name="processRecord"></a>

=head2 processRecord()

DFXI,40202,20010116,3,2
DCTG,40402,20010116,3,1
PDCI,40596,20010116,105,100
SCHL,4034,20010117,2,1
ALBY,33330,20010117,10,7
FTCH,33712,20010117,1,6
MBWM,33750,20010117,105,100
BIFP,40039,20010117,1,14
IDPH,9222,20010118,3,1
TALX,18191,20010122,3,2

=cut

sub processRecord {
    my($self, $date, $type, $fields) = @_;
    my($values) = {
        csi_id => Bivio::Data::CSI::Id->from_literal($fields->[1]),
        split_date => Bivio::Type::Date->from_literal($fields->[2]),
        new_shares => Bivio::Type::Integer->from_literal($fields->[3]),
        old_shares => Bivio::Type::Integer->from_literal($fields->[4]),
    };
    $self->create($values);
    return;
}

#=PRIVATE METHODS

# _initialize()
#
# Register for certain record types to process
#
sub _initialize {
    Bivio::Biz::Model::CSIBase->internal_register_handler($_PACKAGE,
            Bivio::Data::CSI::RecordType::SPLIT());
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
