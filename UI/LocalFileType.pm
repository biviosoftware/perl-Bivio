# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::LocalFileType;
use strict;
$Bivio::UI::LocalFileType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::LocalFileType::VERSION;

=head1 NAME

Bivio::UI::LocalFileType - identifies local file trees

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::LocalFileType;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::UI::LocalFileType::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::UI::LocalFileType> identifies local file trees used within
a Facade.  See
L<Bivio::UI::Facade::get_local_file_name|Bivio::UI::Facade/"get_local_file_name">
for more details.

The following values are defined:

=over 4

=item PLAIN

Tree of all ordinary files to be returned to the user by name, e.g.  icons and
plain html.  No translation is performed.

=item VIEW

L<Bivio::UI::View|Bivio::UI::View> loads views from this tree.

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    'PLAIN' => [
    	1,
	'plain/',
    ],
    'VIEW' => [
	2,
	'view/',
    ],
]);

=head1 METHODS

=cut

=for html <a name="get_path"></a>

=head2 get_path() : string

Returns the path to be used to find this area from the local_file_root.
Always ends in a trailing slash.

=cut

sub get_path {
    return shift->get_short_desc;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
