# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::CSIBase;
use strict;
$Bivio::Biz::Model::CSIBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::CSIBase - base class of CSI models

=head1 SYNOPSIS

    use Bivio::Biz::Model::CSIBase;
    Bivio::Biz::Model::CSIBase->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel> is the base class of CSI models. Its most
important method is L<from_mgfs|"from_mgfs">
which converts an CSI flat record into
the fields required for our database.

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::CSIBase::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::CSIBase> base class of CSI models

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmOwner;
use Bivio::Data::CSI::RecordType;
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');
# keyed by Data::CSI::RecordType
my(%_RECORD_HANDLERS);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request) : Bivio::Biz::Model::CSIBase

Creates an instance of an CSI Base model.

=cut

sub new {
    my($self) = Bivio::Biz::PropertyModel::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="from_mgfs"></a>

=head2 from_mgfs(string record, string file) : boolean

Creates/updates an CSI model from the CSI record format.
Bad records are written to <model>_reject and ignored.
Returns 1 on success, 0 on failure.
Failures should be rolled back.

=cut

sub from_mgfs {
    my($self, $record, $file) = @_;

    # lazy instantiation, kept in static map
#    my($importer) = $_IMPORTER_MAP->{ref($self)};
#    unless ($importer) {
#	# the self is used only for type information
#	$importer = Bivio::Data::CSI::Importer->new($self,
#		$self->internal_get_mgfs_import_format);
#	$_IMPORTER_MAP->{ref($self)} = $importer;
#    }
#    my($values);
#    my($die) = Bivio::Die->catch(
#	    sub {
#		$values = $importer->parse($record, $file);
#	    });
#    $die ||= $self->try_to_update_or_create($values,
#	    $importer->is_update($file));
#    if ($die) {
#	$self->write_reject_record($die, $record);
#	return 0;
#    }
#    return 1;
}

=for html <a name="handleRecord"></a>

=head2 handleRecord(string date, array_ref fields) : 



=cut

sub handleRecord {
    my($self) = shift;
    my($date, $type) = @_;
    my($record_type) = Bivio::Data::CSI::RecordType->from_any($type);
    Bivio::Die->die('No handler for record type ', $record_type)
                unless exists($_RECORD_HANDLERS{$record_type});
    my($handler) = $self->get_instance($_RECORD_HANDLERS{$record_type});
    $handler->processRecord(@_);
    return;
}

=for html <a name="internal_register_handler"></a>

=head2 static internal_register_handler(Bivio::Biz::Model::CSIBase class, Bivio::Data::CSIRecordType types)

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
        $_RECORD_HANDLERS{$type} = $class;
    }
    return;
}

=for html <a name="post_import"></a>

=head2 static post_import()

Performs post-import processing.
Commits changes after processing.

=cut

sub post_import {

    my($req) = Bivio::Agent::Request->get_current_or_new;

    _resolve_symbol_clashes($req);
    _audit_last_import_date($req);

    Bivio::SQL::Connection->commit;
    return;
}

=for html <a name="processRecord"></a>

=head2 processRecord(string date, string type, array_ref fields) : 



=cut

sub processRecord {
    my($self, $date, $fields) = @_;
    _trace();
    return;
}

#=PRIVATE METHODS

# _audit_last_import_date(Bivio::Agent::Request req)
#
# Audits any club's which have used the latest import dtae as a valuation date.
#
sub _audit_last_import_date {
    my($req) = @_;

    # get the most recent daily quote date
    my($date_param) = Bivio::Type::DateTime->from_sql_value(
	    'mgfs_daily_quote_t.date_time');
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT MAX($date_param)
            FROM mgfs_daily_quote_t", []);
    my($date);
    while (my $row = $sth->fetchrow_arrayref) {
	$date = $row->[0];
    }

    # find all clubs using that date for valuations
    $sth = Bivio::SQL::Connection->execute("
            SELECT DISTINCT(realm_id)
            FROM member_entry_t
            WHERE valuation_date = $_SQL_DATE_VALUE", [$date]);

    # audit that books from the date forward
    my($realm) = Bivio::Biz::Model::RealmOwner->new($req);
    while (my $row = $sth->fetchrow_arrayref) {
	my($realm_id) = $row->[0];
	$realm->unauth_load_or_die(realm_id => $realm_id);
	$realm->get_request->set_realm(Bivio::Auth::Realm->new($realm));

	# print a message to the logs. Don't use warn, because we
	# don't know how many of these messages we might get.
	Bivio::IO::Alert->info('auditing ', $realm_id, ' after import');
	$realm->audit_units($date);
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
