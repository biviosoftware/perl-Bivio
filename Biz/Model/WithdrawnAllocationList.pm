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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
