# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::CancelButton;
use strict;
$Bivio::Type::CancelButton::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::CancelButton - cancel button

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::CancelButton;

=cut

=head1 EXTENDS

L<Bivio::Type::FormButton>

=cut

use Bivio::Type::FormButton;
@Bivio::Type::CancelButton::ISA = ('Bivio::Type::FormButton');

=head1 DESCRIPTION

C<Bivio::Type::CancelButton> cancel button

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
