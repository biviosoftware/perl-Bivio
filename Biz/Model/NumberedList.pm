# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::NumberedList;
use strict;
$Bivio::Biz::Model::NumberedList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::NumberedList - for list forms which want to display blank fields

=head1 SYNOPSIS

    use Bivio::Biz::Model::NumberedList;
    Bivio::Biz::Model::NumberedList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::NumberedList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::NumberedList>

=cut


=head1 CONSTANTS

=cut

=for html <a name="PAGE_SIZE"></a>

=head2 PAGE_SIZE : int

Returns a size that is reasonable for a list form.

=cut

sub PAGE_SIZE {
    return 10;
}

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	primary_key => [
	    {
		name => 'index',
		type => 'Integer',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

Loads a list of I<count> numbers.

=cut

sub internal_load_rows {
    my($self, $query, $where, $params, $sql_support) = @_;
    my(@rows);
    foreach my $i (0..($query->get('count')-1)) {
	push(@rows, {index => $i});
    }
    return \@rows;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
