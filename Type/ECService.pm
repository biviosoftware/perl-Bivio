# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::ECService;
use strict;
$Bivio::Type::ECService::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::ECService::VERSION;

=head1 NAME

Bivio::Type::ECService - enum of EC services

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::ECService;

=cut

=head1 EXTENDS

L<Bivio::Type::EnumDelegator>

=cut

use Bivio::Type::EnumDelegator;
@Bivio::Type::ECService::ISA = ('Bivio::Type::EnumDelegator');

=head1 DESCRIPTION

C<Bivio::Type::ECService>

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile;

=head1 METHODS

=cut

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
