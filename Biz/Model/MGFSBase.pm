# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSBase;
use strict;
$Bivio::Biz::Model::MGFSBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSBase - base class of MGFS models

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSBase;
    Bivio::Biz::Model::MGFSBase->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel> is the base class of MGFS models. Its most
important method is L<from_mgfs|"from_mgfs">
which converts an MGFS flat record into
the fields required for our database.

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MGFSBase::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSBase> base class of MGFS models

=cut

=head1 CONSTANTS

=cut

=for html <a name="CREATE_ONLY"></a>

=head2 CREATE_ONLY : string

Flag for "try_to_update_or_create()". Indicates records should be created
only, not updated.

=cut

sub CREATE_ONLY {
    return '0';
}

=for html <a name="CREATE_OR_UPDATE"></a>

=head2 CREATE_OR_UPDATE : string

Flag for "try_to_update_or_create()". Indicates that records should be
updated if existant, or created otherwise.

=cut

sub CREATE_OR_UPDATE {
    return '1';
}

=for html <a name="UPDATE_ONLY"></a>

=head2 UPDATE_ONLY : string

Flag for "try_to_update_or_create()". Indicates that existing records
should be updated only, but never created.

=cut

sub UPDATE_ONLY {
    return '2';
}

#=IMPORTS
use Bivio::IO::ClassLoader;
use Bivio::HTML;
use Bivio::Agent::Request;
use Bivio::Auth::Realm;
use Bivio::Die;
use Bivio::Data::MGFS::Importer;
use Bivio::SQL::Connection;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Type::DateTime;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
# keyed by class name
my($_IMPORTER_MAP) = {};
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');

my($_OLD_TICKER_TAG) = '-D';


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request) : Bivio::Biz::Model::MGFSBase

Creates an instance of an MGFS Base model.

=cut

sub new {
#TODO: dangerous! PropertyModel doesn't have a new to super to.
    my($self) = &Bivio::Biz::Model::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="can_import_from"></a>

=head2 can_import_from(string file) : boolean

Returns true if this model can import itself from the specified MGFS data
file.

=cut

sub can_import_from {
    my($self, $file) = @_;
    my($format) = $self->internal_get_mgfs_import_format();
    return exists($format->{file}->{$file});
}

=for html <a name="from_mgfs"></a>

=head2 from_mgfs(string record, string file) : boolean

Creates/updates an MGFS model from the MGFS record format.
Bad records are written to <model>_reject and ignored.
Returns 1 on success, 0 on failure.
Failures should be rolled back.

=cut

sub from_mgfs {
    my($self, $record, $file) = @_;

    # lazy instantiation, kept in static map
    my($importer) = $_IMPORTER_MAP->{ref($self)};
    unless ($importer) {
	# the self is used only for type information
	$importer = Bivio::Data::MGFS::Importer->new($self,
		$self->internal_get_mgfs_import_format);
	$_IMPORTER_MAP->{ref($self)} = $importer;
    }
    my($values);
    my($die) = Bivio::Die->catch(
	    sub {
		$values = $importer->parse($record, $file);
	    });
    $die ||= $self->try_to_update_or_create($values,
	    $importer->is_update($file));
    if ($die) {
	$self->write_reject_record($die, $record);
	return 0;
    }
    return 1;
}

=for html <a name="internal_get_mgfs_import_format"></a>

=head2 abstract internal_get_mgfs_import_format() : hash_ref

Returns the defintion of the models MGFS import format.
The import format should be:
   {
       file => {
           <file name> => [<format index>, <update flag>],
           ...
       },
       format => [
           {
               <field> => [<type>, <offset>, <size>],
               ...
           },
           ...
       ],
   }

<format index> the index into the format array.
<update flag> one of the CREATE/UPDATE constants above
<file name> the prefix of the mgfs data file
<type> one of the Bivio::Data::MGFS::FieldType enum values
<offset> character offset into the data record
<size> length of the field in the data record

=cut

sub internal_get_mgfs_import_format {
    die("abstract method");
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

=for html <a name="try_to_update_or_create"></a>

=head2 Bivio::Die try_to_update_or_create(hash_ref values, int update_flag)

Attempts to update or create a model with the specified values.
See from_mgfs(). Returns undef on success, a Bivio::Die instance otherwise.

The update_flag should be one of the following constants:
CREATE_ONLY, CREATE_OR_UPDATE, UPDATE_ONLY defined above.

=cut

sub try_to_update_or_create {
    my($self, $values, $update_flag) = @_;

#TODO: probably better to have a handle_die() method?
    my($die) = Bivio::Die->catch(
	    sub {

		# get the key fields from values
		my($sql_support) = $self->internal_get_sql_support;
		my(@key_names) = $sql_support->get('primary_key_names');

		my(%key) = ();
#TODO: use the first key array?
		foreach my $k (@{$key_names[0]}) {
		    $key{$k} = $values->{$k};
		}

		# existence check, update if it already exists
		if ($self->unauth_load(%key)) {
		    return if $update_flag == CREATE_ONLY();
		    $self->update($values);
		    return;
		}

		return if $update_flag == UPDATE_ONLY();

		# otherwise create it
		$self->create($values);
	    });
    return $die;
}

=for html <a name="write_reject_record"></a>

=head2 write_reject_record(string record)

Writes the specified record to a reject file titled <model>_reject

=cut

sub write_reject_record {
    my($self, $die, $record) = @_;

    my($reject_file) = ref($self)."_reject";
#TODO: need a better way to open or create for append
    open(OUT, ">>$reject_file") || open(OUT, $reject_file)
	    || die("can't open file $reject_file");
    print(OUT $die->as_string."#\n#\n# invalid record\n$record");
    close(OUT);
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

# _resolve_symbol_clashes(Bivio::Agent::Request req)
#
# Ticker clashes are resolved by appending '-D' to defunct symbols.
#
sub _resolve_symbol_clashes {
    my($req) = @_;

    Bivio::IO::ClassLoader->simple_require('Bivio::Biz::Model::MGFSInstrument');
    my($mgfs_instrument) = Bivio::Biz::Model::MGFSInstrument->new($req);
    my($handled_ids) = {};
    my($sth) = Bivio::SQL::Connection->execute('
            SELECT a.mg_id, b.mg_id, a.symbol
            FROM mgfs_instrument_t a, mgfs_instrument_t b
            WHERE a.mg_id != b.mg_id
            AND a.symbol = b.symbol',
	    []);
    while (my $row = $sth->fetchrow_arrayref) {
	my($id, $id2, $symbol) = @$row;
	next if exists($handled_ids->{$id});
	my($sth2) = Bivio::SQL::Connection->execute('
                SELECT mg_id, MAX(date_time) dt
                FROM mgfs_daily_quote_t
                WHERE mg_id in (?,?)
                GROUP BY mg_id
                ORDER BY dt desc',
		[$id, $id2]);
	my($mg_id, $date) = @{$sth2->fetchrow_arrayref};
	my($mg_id2, $date2) = @{$sth2->fetchrow_arrayref};
	if ($date eq $date2) {
#TODO: handle this case by counting quotes if necessary
	    Bivio::IO::Alert->warn('unhandled ticker clash mg_id(',
		    $mg_id, ', ', $mg_id2, ')');
	}
	else {
	    # change the ticker on the one with the older quote date
	    $mgfs_instrument->load(mg_id => $mg_id2);
	    $mgfs_instrument->update({
		symbol => $symbol.$_OLD_TICKER_TAG
	    });
	}
	$handled_ids->{$id} = $id;
	$handled_ids->{$id2} = $id2;
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
