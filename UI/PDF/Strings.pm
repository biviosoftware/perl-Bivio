# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Strings;
use strict;
$Bivio::UI::PDF::Strings::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Strings - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Strings;
    Bivio::UI::PDF::Strings->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::Strings::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Strings>

=cut


=head1 CONSTANTS

=cut

=for html <a name="BASE_FILE"></a>

=head2 BASE_FILE : string

This string is the title of the section of data in a Form that contains a base
Pdf file's text.

=cut

sub BASE_FILE {
    return('PDF Base File');
}

=for html <a name="BASE_ROOT"></a>

=head2 BASE_ROOT : string

This string is the title of the section of data in a Form that contains the
root pointer of the base Pdf file.

=cut

sub BASE_ROOT {
    return('Base Root Pointer');
}

=for html <a name="BASE_SIZE"></a>

=head2 BASE_SIZE : string

This string is the title of the section of data in a Form that contains the
size of the base xref section.

=cut

sub BASE_SIZE {
    return('Base Size');
}

=for html <a name="BASE_XREF"></a>

=head2 BASE_XREF : string

This string is the title of the section of data in a Form that contains the
offset of the Base xref.

=cut

sub BASE_XREF {
    return('Base Xref Offset');
}

=for html <a name="DATA_END"></a>

=head2 DATA_END : string

This string is the title that indicates the end of data in the Form.pm file.

=cut

sub DATA_END {
    return('Data End');
}

=for html <a name="FIELD_TEXT"></a>

=head2 FIELD_TEXT : string

This string is the title of the section of data in a Form that contains the
name of a Pdf field.

=cut

sub FIELD_TEXT {
    return('Field Text');
}

=for html <a name="NULL_OBJ_VALUE"></a>

=head2 NULL_OBJ_VALUE : string



=cut

sub NULL_OBJ_VALUE {
    return 'null';
}

=for html <a name="XLATOR_SET"></a>

=head2 XLATOR_SET : string

This string is the title of the section of data in a Form that contains the
name of the XlatorSet class for the Form.

=cut

sub XLATOR_SET {
    return('Xlator Set Class');
}

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
