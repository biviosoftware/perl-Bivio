# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::FacadeChildType;
use strict;
$Bivio::UI::FacadeChildType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::FacadeChildType::VERSION;

=head1 NAME

Bivio::UI::FacadeChildType - list of facade children supported

=head1 SYNOPSIS

    use Bivio::UI::FacadeChildType;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::UI::FacadeChildType::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::UI::FacadeChildType> defines the list of facade children.
See L<Bivio::UI::Facade|Bivio::UI::Facade>.

The implementation is delegated.  There must be a delegate entry for
I<FacadeChildType> in
L<Bivio::IO::ClassLoader|Bivio::IO::ClassLoader>'s configuration.

Delegates must define a DEFAULT type, which is usually enum value zero (0).

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    Bivio::IO::ClassLoader->delegate_require_info(__PACKAGE__));

=head1 METHODS

=cut

=for html <a name="get_default"></a>

=head2 get_default() : Bivio::UI::FacadeChildType

Returns C<DEFAULT>.

=cut

sub get_default {
    return __PACKAGE__->DEFAULT;
}

=for html <a name="is_continuous"></a>

=head2 is_continuous() : boolean

Returns false.

=cut

sub is_continuous {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
