# Copyright (c) 2000 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIBase;
use strict;
$Bivio::Biz::Model::CSIBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::CSIBase::VERSION;

=head1 NAME

Bivio::Biz::Model::CSIBase - base class of CSI models

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSIBase;
    Bivio::Biz::Model::CSIBase->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::CSIBase::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSIBase> is the base class for all CSI models.
It handles data records downloaded from CSI or read from a data CD.
CSI models need to register record types with this base class, so
the records can be properly dispatched for processing.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmOwner;
use Bivio::Data::CSI::RecordType;
use Bivio::Type::DateTime;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
# keyed by Data::CSI::RecordType
my(%_RECORD_HANDLERS);

=head1 FACTORIES

=cut

=head1 METHODS

=cut

=for html <a name="create_or_update"></a>

=head2 create_or_update(hash_ref new_values, Bivio::Data::CSI::RecordType record_type) : Bivio::Biz::Model::CSIBase

=head2 create_or_update(hash_ref new_values, array_ref record_type) : Bivio::Biz::Model::CSIBase

If I<record_type> is an array_ref, try to update the model,
otherwise create a new one.

=cut

sub create_or_update {
    my($self, $new_values, $record_type) = @_;
    return ref($record_type) eq 'ARRAY'
            ? $self->SUPER::create_or_update($new_values)
                    : $self->create($new_values);
}

=for html <a name="handleRecord"></a>

=head2 static handleRecord(string date, string type, array_ref fields)

Handle a CSI record by dispatching it to the appropriate model
based on the record type.

Handle ERROR_CORRECTION records directly, by unpacking
the correction record before passing it on to the handler.

=cut

sub handleRecord {
    my($proto, $req, $date, $type, $fields) = @_;
    my($record_type) = Bivio::Data::CSI::RecordType->from_any($type);
    my($error_correction)
            = $record_type eq Bivio::Data::CSI::RecordType::ERROR_CORRECTION();
    if ($error_correction) {
        my($c_date, $c_type, @c_fields) = @$fields;
        $date = $c_date;
        $record_type = Bivio::Data::CSI::RecordType->from_any($c_type);
        $fields = \@c_fields;
    }
    Bivio::Die->die('No handler for record type ', $record_type)
                unless exists($_RECORD_HANDLERS{$record_type});
    my($handler) = $_RECORD_HANDLERS{$record_type};
    unless (ref($handler)) {
        $handler = $proto->get_instance($handler)->new($req);
        $_RECORD_HANDLERS{$record_type} = $handler;
    }
    $record_type = [$record_type] if $error_correction;
    $handler->process_record($date, $record_type, $fields);
    return;
}

=for html <a name="internal_register_handler"></a>

=head2 static internal_register_handler(Bivio::Biz::Model::CSIBase class, array types)

Register class I<class> to handle record types I<types>.

=cut

sub internal_register_handler {
    my(undef, $class, @types) = @_;
    foreach my $type (@types) {
        if (exists($_RECORD_HANDLERS{$type})) {
            return if $_RECORD_HANDLERS{$type} eq $class;
            Bivio::Die->die('Attempt to re-register record type ', $type,
                    ' with class ', $class);
        }
        Bivio::Die->die('Missing ', $class, '::process_record')
                    unless $class->can('process_record');
        $_RECORD_HANDLERS{$type} = $class;
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
