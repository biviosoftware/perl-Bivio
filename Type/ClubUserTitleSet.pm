# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Type::ClubUserTitleSet;
use strict;
$Bivio::Type::ClubUserTitleSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::ClubUserTitleSet - lists of valid titles for club users

=head1 SYNOPSIS

    use Bivio::Type::ClubUserTitleSet;
    Bivio::Type::ClubUserTitleSet->new();

=cut

=head1 EXTENDS

L<Bivio::Type::EnumSet>

=cut

use Bivio::Type::EnumSet;
@Bivio::Type::ClubUserTitleSet::ISA = ('Bivio::Type::EnumSet');

=head1 DESCRIPTION

C<Bivio::Type::ClubUserTitleSet>

=cut


=head1 CONSTANTS

=cut

=for html <a name="MEMBERS"></a>

=head2 MEMBERS : string

Returns set of titles for members.

=cut

#TODO: hacked - had to move import and var above constants
use Bivio::Type::ClubUserTitle;
my($_MEMBERS) = '';

sub MEMBERS {
    return $_MEMBERS;
}

#=IMPORTS

#=VARIABLES
__PACKAGE__->set(\$_MEMBERS,
	Bivio::Type::ClubUserTitle::TREASURER(),
	Bivio::Type::ClubUserTitle::PRESIDENT(),
	Bivio::Type::ClubUserTitle::VICE_PRESIDENT(),
	Bivio::Type::ClubUserTitle::SECRETARY(),
	Bivio::Type::ClubUserTitle::ADMINISTRATOR(),
	Bivio::Type::ClubUserTitle::MEMBER(),
);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
