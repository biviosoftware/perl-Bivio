# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIImport;
use strict;
$Bivio::Biz::Model::CSIImport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::CSIImport - record CSI data file updates

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSIImport;

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::CSIBase>

=cut

use Bivio::Biz::Model::CSIBase;
@Bivio::Biz::Model::CSIImport::ISA = ('Bivio::Biz::Model::CSIBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSIImport> records CSI data file updates.

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
	table_name => 'csi_import_t',
	columns => {
	    file_name => ['Name', 'PRIMARY_KEY'],
	    import_date => ['Date', 'NOT_NULL'],
        },
    };
}

=for html <a name="process_record"></a>

=head2 process_record(string date, Bivio::Data::CSI::RecordType type, array_ref fields)

=head2 process_record(string date, array_ref type, array_ref fields)

Process various non-essential records

=cut

sub process_record {
    my($self, $date, $type, $fields) = @_;
    if (ref($type) eq 'ARRAY') {
        # Is an error correction record
        $type = $type->[0];
    }
    if ($type eq Bivio::Data::CSI::RecordType::FILE_HEADER_TRAILER()) {
        # no-op
    }
    elsif ($type eq Bivio::Data::CSI::RecordType::TEXT_MESSAGE()) {
        Bivio::IO::Alert->info(join(',', @$fields));
    }
    elsif ($type eq Bivio::Data::CSI::RecordType::STOCK_EXCHANGE_STATISTICS()) {
        # no-op
    }
    elsif ($type eq Bivio::Data::CSI::RecordType::MOST_ACTIVE_STOCKS()) {
        # no-op
    }
    else {
        Bivio::Die->die('Cannot process record type: ',
                Bivio::Data::CSI::RecordType->to_string($type));
    }
}

#=PRIVATE METHODS

# _initialize()
#
# Register record types
#
sub _initialize {
    Bivio::Biz::Model::CSIBase->internal_register_handler($_PACKAGE,
            Bivio::Data::CSI::RecordType::FILE_HEADER_TRAILER(),
            Bivio::Data::CSI::RecordType::TEXT_MESSAGE(),
            Bivio::Data::CSI::RecordType::STOCK_EXCHANGE_STATISTICS(),
            Bivio::Data::CSI::RecordType::MOST_ACTIVE_STOCKS());
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
