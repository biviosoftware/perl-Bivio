# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::t::EnumDelegator::I1;
use strict;
$Bivio::Type::t::EnumDelegator::I1::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::t::EnumDelegator::I1::VERSION;

=head1 NAME

Bivio::Type::t::EnumDelegator::I1 - implemenation of i1

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::t::EnumDelegator::I1;

=cut

=head1 EXTENDS

L<Bivio::Delegate>

=cut

use Bivio::Delegate;
@Bivio::Type::t::EnumDelegator::I1::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Type::t::EnumDelegator::I1>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the task declarations.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return [
	N1 => [1],
    ];
}

=for html <a name="inc_value"></a>

=head2 inc_value(int i)

Returns true if name is N1.

=cut

sub inc_value {
    return shift->as_int + shift;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
