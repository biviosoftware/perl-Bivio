# Copyright (c) 2001 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::Agent::TaskIdSet;
use strict;
$Bivio::Agent::TaskIdSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::TaskIdSet::VERSION;

=head1 NAME

Bivio::Agent::TaskIdSet - useful for grouping tasks

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Agent::TaskIdSet;

=cut

=head1 EXTENDS

L<Bivio::Type::EnumSet>

=cut

use Bivio::Type::EnumSet;
@Bivio::Agent::TaskIdSet::ISA = ('Bivio::Type::EnumSet');

=head1 DESCRIPTION

C<Bivio::Agent::TaskIdSet> is useful for grouping tasks.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;

#=VARIABLES
__PACKAGE__->initialize();

=head1 METHODS

=cut

=head1 METHODS

=cut

=for html <a name="get_enum_type"></a>

=head2 get_enum_type() : Bivio::Type::Enum

Returns L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

=cut

sub get_enum_type {
    return 'Bivio::Agent::TaskId';
}

=for html <a name="get_width"></a>

=head2 get_width() : int

Returns 60.  That's 480 tasks.

=cut

sub get_width {
    return 60;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
