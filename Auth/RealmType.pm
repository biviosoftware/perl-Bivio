# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::RealmType;
use strict;
$Bivio::Auth::RealmType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Auth::RealmType::VERSION;

=head1 NAME

Bivio::Auth::RealmType - enum of authentication realm types

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Auth::RealmType;

=cut


=head1 EXTENDS

L<Bivio::Type::EnumDelegator>

=cut

use Bivio::Type::EnumDelegator;
@Bivio::Auth::RealmType::ISA = ('Bivio::Type::EnumDelegator');

=head1 DESCRIPTION

C<Bivio::Auth::RealmType> defines the kinds of realms in which
requests are authenticated.

=cut

#=IMPORTS

#=VARIABLES

#=PRIVATE METHODS
__PACKAGE__->compile;

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : boolean

Overrides should start at number 20.

=cut

sub is_continuous {
    return 0;
}

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
