# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::NoCookie;
use strict;
$Bivio::Delegate::NoCookie::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::NoCookie::VERSION;

=head1 NAME

Bivio::Delegate::NoCookie - no cookie management

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::NoCookie;

=cut

use Bivio::Collection::Attributes;
@Bivio::Delegate::NoCookie::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Delegate::NoCookie> is a placeholder for
L<Bivio::Agent::HTTP::Cookie|Bivio::Agent::HTTP::Cookie>.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="assert_is_ok"></a>

=head2 assert_is_ok(Bivio::Agent::Request req) : boolean

This cookie is always OK.

=cut

sub assert_is_ok {
    return 1;
}

=for html <a name="header_out"></a>

=head2 header_out(Bivio::Agent::Request req, Apache::Request r) : boolean

Does nothing.

=cut

sub header_out {
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
