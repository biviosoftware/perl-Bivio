# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimplePermission;
use strict;
$Bivio::Delegate::SimplePermission::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::SimplePermission::VERSION;

=head1 NAME

Bivio::Delegate::SimplePermission - default permissions

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::SimplePermission;

=cut

use Bivio::Delegate;
@Bivio::Delegate::SimplePermission::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::SimplePermission>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the task declarations.

=cut

sub get_delegate_info {
    return [
    DOCUMENT_READ => [13],
    ANY_USER => [17],
    ];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
