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

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'account_sync_t',
	columns => {
            realm_transaction_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
	    sync_key => ['Line', 'NOT_NULL'],
	    import_date => ['Date', 'NOT_NULL'],
        },
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
