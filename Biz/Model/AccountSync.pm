# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AccountSync;
use strict;
$Bivio::Biz::Model::AccountSync::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::AccountSync::VERSION;

=head1 NAME

Bivio::Biz::Model::AccountSync - account sync transaction identifier

=head1 SYNOPSIS

    use Bivio::Biz::Model::AccountSync;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::AccountSync::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AccountSync> account sync transaction identifier

=cut

#=IMPORTS
use Bivio::SQL::Connection;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="delete_all"></a>

=head2 delete_all(hash query) : int

Overrides delete_all to null out fields, not delete them when deleting
records for a specific transaction. That way delete transactions don't
keep getting reimported.

Returns the number of rows affected.

=cut

sub delete_all {
    my($self, $query) = @_;

    my($count) = 0;
    if (exists($query->{realm_transaction_id})) {

	# Sever any links to account sync entries (not deleted)
	my($sth) = Bivio::SQL::Connection->execute('
                UPDATE account_sync_t
                SET realm_transaction_id = NULL
                WHERE realm_transaction_id=?
                AND realm_id=?',
		[$query->{realm_transaction_id},
		    $self->get_request->get('auth_id')]);
	$count += $sth->rows;
	$sth->finish;
    }

    # OK to call super either way - the realm_transaction_id is
    # severed above
    $count += $self->SUPER::delete_all($query);
    return $count;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'account_sync_t',
	columns => {
#TODO: this is not really a primary key - there are none for this table
            realm_transaction_id => ['RealmTransaction.realm_transaction_id',
		'PRIMARY_KEY'],
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
	    sync_key => ['Line', 'NOT_NULL'],
	    import_date => ['Date', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
