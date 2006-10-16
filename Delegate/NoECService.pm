# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Delegate::NoECService;
use strict;
$Bivio::Delegate::NoECService::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::NoECService::VERSION;

=head1 NAME

Bivio::Delegate::NoECService - Empty enumerated type.

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::NoECService;

=cut

=head1 EXTENDS

L<Bivio::Delegate>

=cut

use Bivio::Delegate;
@Bivio::Delegate::NoECService::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::NoECService>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 get_delegate_info() : array_ref

Returns an enumerated type with one value, UNKNOWN.

=cut

sub get_delegate_info {
    return [
	UNKNOWN => [0],
    ];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
