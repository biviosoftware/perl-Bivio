# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Honorific;
use strict;
$Bivio::Type::Honorific::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Honorific::VERSION;

=head1 NAME

Bivio::Type::Honorific - titles of club users

=head1 SYNOPSIS

    use Bivio::Type::Honorific;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::Honorific::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::Honorific> defines a list of club user titles.

Honors always map to a role.  See L<get_role|"get_role">.

=over 4

=item TREASURER

=item PRESIDENT

=item VICE_PRESIDENT

=item SECRETARY

=item ADMINISTRATOR

=item MEMBER

=item GUEST

=item WITHDRAWN

=item SELF

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::Auth::Role;

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [
	0,
	'Unspecified',
    ],
    TREASURER => [
	1,
    ],
    PRESIDENT => [
	2,
    ],
    VICE_PRESIDENT => [
	3,
    ],
    SECRETARY => [
	4,
    ],
    ADMINISTRATOR => [
	5,
    ],
    MEMBER => [
	6,
    ],
    GUEST => [
	7,
    ],
    WITHDRAWN => [
	8,
    ],
    SELF => [
	9,
    ],
]);
my(%_ROLE_MAP) = (
    TREASURER => 'ACCOUNTANT',
    PRESIDENT => 'ADMINISTRATOR',
    VICE_PRESIDENT => 'ADMINISTRATOR',
    SECRETARY => 'MEMBER',
    ADMINISTRATOR => 'ADMINISTRATOR',
    MEMBER => 'MEMBER',
    GUEST => 'GUEST',
    WITHDRAWN => 'WITHDRAWN',
    SELF => 'ADMINISTRATOR',
);

# Fixup so real names
%_ROLE_MAP = map {
    (__PACKAGE__->$_(), Bivio::Auth::Role->from_name($_ROLE_MAP{$_}));
    } keys(%_ROLE_MAP);

=head1 METHODS

=cut

=for html <a name="get_role"></a>

=head2 get_role() : Bivio::Auth::Role

Returns the role for this honor.

=cut

sub get_role {
    my($self) = @_;
    Bivio::Die->die($self, ': not a Honorific')
		unless $_ROLE_MAP{$self};
    return $_ROLE_MAP{$self};
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
