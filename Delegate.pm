# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate;
use strict;
$Bivio::Delegate::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::VERSION;

=head1 NAME

Bivio::Delegate - delegate info superclass

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate;

=cut

use Bivio::UNIVERSAL;
@Bivio::Delegate::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Delegate>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
