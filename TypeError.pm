# Copyright (c) 1999,2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::TypeError;
use strict;
$Bivio::TypeError::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::TypeError::VERSION;

=head1 NAME

Bivio::TypeError - enum of errors in converting values

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::TypeError;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::TypeError::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::TypeError>

=cut

#=IMPORTS

#=VARIABLES

__PACKAGE__->compile(
	Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__));

=head1 METHODS

=cut

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : false

Task Ids aren't continuous.  Tasks can go away.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
