# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmInstrumentValuationList;
use strict;
$Bivio::Biz::Model::RealmInstrumentValuationList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmInstrumentValuationList - lists local valuations

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmInstrumentValuationList;
    Bivio::Biz::Model::RealmInstrumentValuationList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::RealmInstrumentValuationList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmInstrumentValuationList> lists local valuations

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	order_by => [qw(
            RealmInstrumentValuation.date_time
	)],
	auth_id => [qw(RealmInstrumentValuation.realm_id)],
	primary_key => [
	    [qw(RealmInstrumentValuation.realm_instrument_id)],
	    [qw(RealmInstrumentValuation.date_time)],
	],
	other => [qw(
            RealmInstrumentValuation.price_per_share
        )],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
