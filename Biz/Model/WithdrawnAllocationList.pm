# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::WithdrawnAllocationList;
use strict;
$Bivio::Biz::Model::WithdrawnAllocationList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::WithdrawnAllocationList - withdrawal tax allocations

=head1 SYNOPSIS

    use Bivio::Biz::Model::WithdrawnAllocationList;
    Bivio::Biz::Model::WithdrawnAllocationList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::AllocationList>

=cut

use Bivio::Biz::Model::AllocationList;
@Bivio::Biz::Model::WithdrawnAllocationList::ISA = ('Bivio::Biz::Model::AllocationList');

=head1 DESCRIPTION

C<Bivio::Biz::Model::WithdrawnAllocationList> withdrawal tax allocations

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req, array_ref rows) : Bivio::Biz::Model::InstrumentSaleGainList

Creates a gain list with the specified row data.

=cut

sub new {
    my($proto, $req, $rows) = @_;
    # calling dynamic new, super class doesn't have one
    my($self) = $proto->SUPER::new($req);
    $self->{$_PACKAGE} = {
	rows => $rows,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(...) : array_ref

Returns the row data.

=cut

sub internal_load_rows {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($rows) = $fields->{rows};
    $self->internal_calculate_net_profit($rows);
    return $rows;
}

=for html <a name="prune_members"></a>

=head2 prune_members(string user_id, string date)

Removes all rows except the one identified by the specified user_id.

=cut

sub prune_members {
    my($self, $user_id, $date) = @_;
    my($rows) = $self->internal_get_rows;
    $date = Bivio::Type::Date->to_literal($date);
    for (my $i = int(@$rows); --$i >= 0; ) {
	my($row) = $rows->[$i];

#TODO: hacked, date isn't property, but does appear in name text
	next if $row->{user_id} eq $user_id && $row->{name} =~ /$date/;
	splice(@$rows, $i, 1);
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
