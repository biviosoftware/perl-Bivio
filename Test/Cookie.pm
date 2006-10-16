# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Cookie;
use strict;
$Bivio::Test::Cookie::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Cookie::VERSION;

=head1 NAME

Bivio::Test::Cookie - mock cookie object

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Cookie;

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Test::Cookie::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Test::Cookie>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="assert_is_ok"></a>

=head2 assert_is_ok() : boolean

Always return true

=cut

sub assert_is_ok {
    return 1;
}

=for html <a name="execute_handle_cookie_in"></a>

=head2 execute_handle_cookie_in()

Call handle_cookie_in on all registered classes.

=cut

sub execute_handle_cookie_in {
    my($self, $req) = @_;
    Bivio::Agent::HTTP::Cookie::internal_notify_handlers($self, $req);
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
