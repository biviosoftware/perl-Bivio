# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIAdmin;
use strict;
$Bivio::Biz::Model::CSIAdmin::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::CSIAdmin::VERSION;

=head1 NAME

Bivio::Biz::Model::CSIAdmin - provide daily quotes formats

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSIAdmin;
    Bivio::Biz::Model::CSIAdmin->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::CSIBase>

=cut

use Bivio::Biz::Model::CSIBase;
@Bivio::Biz::Model::CSIAdmin::ISA = ('Bivio::Biz::Model::CSIBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSIAdmin>

=cut

#=IMPORTS
use Bivio::Data::CSI::Id;
use Bivio::Data::CSI::Quote;
use Bivio::Data::CSI::RecordType;
use Bivio::IO::Trace;

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DATES) = 'a8' x 265;
my($_AMOUNTS) = 'a6' x 265;
_initialize();

=head1 FACTORIES

=cut

=head1 METHODS

=cut

=for html <a name="internal_get_mgfs_import_format"></a>

=head2 internal_get_mgfs_import_format() : hash_ref

Returns the defintion of the models CSI import format.

=cut

sub internal_get_mgfs_import_format {
    return {
	file => {
# no longer used, QSPVSD files only update once a month
#	    qspvsd => [0, Bivio::Biz::Model::CSIBase::CREATE_ONLY()],
#	    qcpvsd => [0, Bivio::Biz::Model::CSIBase::CREATE_ONLY()],
	    indb02 => [1, Bivio::Biz::Model::CSIBase::CREATE_ONLY()],
	    chgdb02 => [1, Bivio::Biz::Model::CSIBase::CREATE_ONLY()],
	},
	format => [
	    {
		# handled internally by this class
	    },
	    {
		# skips sign from id, always +
		mg_id => ['ID', 44, 8],
		date_time => ['CHAR', 82, 9],
		close => ['DOLLARS', 91, 8],
		high => ['DOLLARS', 99, 8],
		low => ['DOLLARS', 107, 8],
		volume => ['HUNDREDS', 1287, 10],
	    }
	],
    };
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'mgfs_daily_quote_t',
	columns => {
	    csi_id => ['Bivio::Data::CSI::Id', 'PRIMARY_KEY'],
            date_time => ['Date', 'PRIMARY_KEY'],
	    high => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
            low => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
            close => ['Bivio::Data::CSI::Quote', 'NOT_NULL'],
            volume => ['Bivio::Data::CSI::Amount', 'NOT_NULL'],
        },
    };
}

#=PRIVATE METHODS

# _add_decimal(array_ref values)
#
# Iterates each value and inserts a '.' before the second-to-last digit.
#
sub _add_decimal {
    my($values) = @_;
    foreach my $value (@$values) {
	$value =~ s/^(.*)(..)$/$1\.$2/;
    }
}

# _initialize()
#
#
#
sub _initialize {
    Bivio::Biz::Model::CSIBase->internal_register_handler($_PACKAGE,
            Bivio::Data::CSI::RecordType::FILE_HEADER_TRAILER(),
            Bivio::Data::CSI::RecordType::ERROR_CORRECTION(),
            Bivio::Data::CSI::RecordType::TEXT_MESSAGE());
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
