# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleFacadeChildType;
use strict;
$Bivio::Delegate::SimpleFacadeChildType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::SimpleFacadeChildType::VERSION;

=head1 NAME

Bivio::Delegate::SimpleFacadeChildType - default facades variations

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::SimpleFacadeChildType;

=cut

use Bivio::Delegate;
@Bivio::Delegate::SimpleFacadeChildType::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::SimpleFacadeChildType>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 get_delegate_info() : array_ref

Defines the configuration used.

=cut

sub get_delegate_info {
    # There must be a DEFAULT.
    return [
	DEFAULT => [
	    0,
	    'Normal',
	],
    ];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
