# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::FacadeChildType;
use strict;
$Bivio::UI::FacadeChildType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
	# This list is stored as preferences, so don't change the numbers.
	# Leave space to allow to fill in holes.
	DEFAULT => [
	    0,
	    'Normal',
	],
	SMALL => [
	    10,
	    'Small',
	],
	LARGE => [
	    20,
	    'Large',
	],
	EXTRA_LARGE => [
	    30,
	    'Extra Large',
	],
       );

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

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
