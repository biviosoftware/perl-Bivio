# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::LockType;
use strict;
$Bivio::Type::LockType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::LockType - lock_t lock types

=head1 SYNOPSIS

    use Bivio::Type::LockType;
    use Bivio::Biz::Model::Lock;

    my($lock) = Bivio::Type::Lock->new($req);
    if ($lock->aquire(Bivio::Type::LockType::ACCOUNTING_IMPORT())) {
        # locked
    }

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::LockType::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::LockType> lock_t lock types

The following types are defined:

=over 4

=item UNKNOWN

invalid type

=item ACCOUNTING_IMPORT

accounting import lock

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    'UNKNOWN' => [
    	0,
	'unknown',
    ],
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
