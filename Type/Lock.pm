# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::Lock;
use strict;
$Bivio::Type::Lock::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::Lock - lock_t types

=head1 SYNOPSIS

    use Bivio::Type::Lock;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::Lock::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::Lock> lock_t lock types

The following types are defined:

=over 4

=item ACCOUNTING_IMPORT

accounting import lock

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    'ACCOUNTING_IMPORT' => [
    	1,
	'accounting import',
    ],
);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
