# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::RealmName;
use strict;
$Bivio::Type::RealmName::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::RealmName::VERSION;

=head1 NAME

Bivio::Type::RealmName - realm owner name

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::RealmName;

=cut

=head1 EXTENDS

L<Bivio::Delegator>

=cut

use Bivio::Delegator;
@Bivio::Type::RealmName::ISA = ('Bivio::Delegator');

=head1 DESCRIPTION

C<Bivio::Type::RealmName> is the name of a realm's owner.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
