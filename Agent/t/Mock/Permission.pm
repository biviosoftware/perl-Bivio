# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Agent::t::Mock::Permission;
use strict;
$Bivio::Agent::t::Mock::Permission::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::t::Mock::Permission::VERSION;

=head1 NAME

Bivio::Agent::t::Mock::Permission - unit test permissions

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Agent::t::Mock::Permission;

=cut

use Bivio::Delegate::SimplePermission;
@Bivio::Agent::t::Mock::Permission::ISA = ('Bivio::Delegate::SimplePermission');

=head1 DESCRIPTION

C<Bivio::Agent::t::Mock::Permission>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 get_delegate_info() : array_ref

Returns the application permissions.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return [
	@{$proto->SUPER::get_delegate_info},
	TEST_PERMISSION1 => [21],
	TEST_PERMISSION2 => [22],
    ];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
