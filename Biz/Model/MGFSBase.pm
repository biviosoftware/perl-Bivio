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
important method is L<from_mgfs> which converts an MGFS flat record into
the fields required for our database.

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MGFSBase::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSBase>

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::Data::MGFS::Importer;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
# keyed by class name
my($_IMPORTER_MAP) = {};


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

=for html <a name="from_mgfs"></a>

=head2 from_mgfs(string record, hash_ref values, boolean update)

Creates/updates an MGFS model from the MGFS record format. If the update
parameter is true, then an attempt will be made to update an existing model
with the same mg_id. On failure to find the specified existing model, a new one
will be created.
If the update parameter is false, then a full import on an empty database
is assumed, and no existance check will be made before the create.
Bad records are written to <model>_reject and ignored.

=cut

sub from_mgfs {
    my($self, $record, $values, $update) = @_;

    # lazy instantiation, kept in static map
    my($importer) = $_IMPORTER_MAP->{ref($self)};
    unless ($importer) {
	# the self is used only for type information
	$importer = Bivio::Data::MGFS::Importer->new($self,
		$self->internal_get_mgfs_import_format);
	$_IMPORTER_MAP->{ref($self)} = $importer;
    }

    # copy the imported values into the values hash
    my($parsed_values) = $importer->parse($record);
    foreach my $field (keys(%$parsed_values)) {
	$values->{$field} = $parsed_values->{$field};
    }

    my($die) = $self->try_to_update_or_create($values, $update);
    if ($die) {
	$self->write_reject_record($die, $record);
    }
    return;
}

=for html <a name="try_to_update_or_create"></a>

=head2 Bivio::Die try_to_update_or_create(hash_ref values, boolean update)

Attempts to update or create a model with the specified values.
See from_mgfs(). Returns undef on success, a Bivio::Die instance otherwise.

=cut

sub try_to_update_or_create {
    my($self, $values, $update) = @_;

#TODO: probably better to have a handle_die() method?
    my($die) = Bivio::Die->catch(
	    sub {
		if ($update) {
		    # get the key fields from values
		    my($sql_support) = $self->internal_get_sql_support;
		    my(@key_names) = $sql_support->get('primary_key_names');

#		    use Data::Dumper;
#		    $Data::Dumper::Indent = 1;
#		    print(Dumper($values));

		    my(%key) = ();
#TODO: use the first key array?
		    foreach my $k (@{$key_names[0]}) {
			$key{$k} = $values->{$k};
		    }

		    # existence check, update if it already exists
		    if ($self->unauth_load(%key)) {
			$self->update($values);
			return;
		    }
		    # otherwise drop through and create it
		}
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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
