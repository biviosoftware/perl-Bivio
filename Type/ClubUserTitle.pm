# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::ClubUserTitle;
use strict;
$Bivio::Type::ClubUserTitle::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::ClubUserTitle - titles of club users

=head1 SYNOPSIS

    use Bivio::Type::ClubUserTitle;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::ClubUserTitle::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::ClubUserTitle> defines a list of club user titles.
These titles are not stored as an enum in the database.

Titles always map to a role.  See L<get_role|"get_role">.

=over 4

=item TREASURER

=item PRESIDENT

=item VICE_PRESIDENT

=item SECRETARY

=item ADMINISTRATOR

=item MEMBER

=item GUEST

=item WITHDRAWN

=back

=cut

#=IMPORTS
use Bivio::Auth::Role;
use Bivio::IO::Alert;

#=VARIABLES
__PACKAGE__->compile(
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
);
my(%_ROLE_MAP) = (
    TREASURER => 'ACCOUNTANT',
    PRESIDENT => 'ADMINISTRATOR',
    VICE_PRESIDENT => 'ADMINISTRATOR',
    SECRETARY => 'MEMBER',
    ADMINISTRATOR => 'ADMINISTRATOR',
    MEMBER => 'MEMBER',
    GUEST => 'GUEST',
    WITHDRAWN => 'WITHDRAWN',
);

# Fixup so real names
%_ROLE_MAP = map {
    (__PACKAGE__->$_(), Bivio::Auth::Role->from_name($_ROLE_MAP{$_}));
    } keys(%_ROLE_MAP);

=head1 METHODS

=cut

=for html <a name="as_sql_param"></a>

=head2 as_sql_param() : string

Overrides superclass.  Returns string

=cut

sub as_sql_param {
    return shift->get_short_desc;
}

=for html <a name="get_role"></a>

=head2 get_role() : Bivio::Auth::Role

Returns the role for this title.

=cut

sub get_role {
    my($self) = @_;
    Bivio::IO::Alert->die($self, ': not a ClubUserTitle')
		unless $_ROLE_MAP{$self};
    return $_ROLE_MAP{$self};
}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(Bivio::Type::Enum value) : string

Overrides superclass.  Returns string

=cut

sub to_sql_param {
    my($proto, $value) = @_;
    return undef unless defined($value);
    return $proto->from_any($value)->get_short_desc;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
