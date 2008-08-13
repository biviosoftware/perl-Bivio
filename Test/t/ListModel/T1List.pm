# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::t::ListModel::T1List;
use strict;
$Bivio::Test::t::ListModel::T1List::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::t::ListModel::T1List::VERSION;

=head1 NAME

Bivio::Test::t::ListModel::T1List - test

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::t::ListModel::T1List;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Test::t::ListModel::T1List::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Test::t::ListModel::T1List>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns config.

=cut

sub internal_initialize {
    return {
	version => 1,
	shift->local_field(other => [
	    qw(f1 f2),
	], 'Integer', 'NONE'),
    };
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows() : array_ref

Returns number of rows as specified by count

=cut

sub internal_load_rows {
    my($self) = @_;
    return [
	map(({f1 => $_, f2 => $_}),
	    1 .. $self->get_query->get('count')),
    ];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
