# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSSplitList;
use strict;
$Bivio::Biz::Model::MGFSSplitList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSSplitList - list of splits

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSSplitList;
    Bivio::Biz::Model::MGFSSplitList->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::MGFSSplitList::ISA = qw(Bivio::Biz::ListModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSSplitList> is list of splits.

=cut

#=IMPORTS

#=VARIABLES

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
            MGFSSplit.date_time
	)],
	primary_key => [
	    'MGFSSplit.date_time',
	],
	other => [
	    ['MGFSSplit.mg_id', 'MGFSInstrument.mg_id'],
            'MGFSSplit.factor',
	],
    };
}

=for html <a name="internal_search"></a>

=head2 internal_search(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Returns the where clause and params associated as the result of a
"search".

=cut

sub internal_search {
    my($self, $query, $support, $params) = @_;
#TODO: throw corrupt_query?
    push(@$params, $query->get('search'));
    return 'mgfs_instrument_t.symbol = ?';
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
