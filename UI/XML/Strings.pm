# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::Strings;
use strict;
$Bivio::UI::XML::Strings::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::Strings - strings

=head1 SYNOPSIS

    use Bivio::UI::XML::Strings;

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::XML::Strings::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::XML::Strings>

=cut


=head1 CONSTANTS

=cut

=for html <a name="BEGIN_COMMENT"></a>

=head2 BEGIN_COMMENT : string

The string that begins a comment.

=cut

sub BEGIN_COMMENT {
    return '<!---';
}

=for html <a name="BEGIN_ENDING_ELEMENT_TAG"></a>

=head2 BEGIN_ENDING_ELEMENT_TAG : string

The string that begins an ending element tag.

=cut

sub BEGIN_ENDING_ELEMENT_TAG {
    return '</';
}

=for html <a name="BEGIN_START_ELEMENT_TAG"></a>

=head2 BEGIN_STARTING_ELEMENT_TAG : string

The string used to begin a starting element tag.

=cut

sub BEGIN_STARINGT_ELEMENT_TAG {
    return '<';
}

=for html <a name="COMMENT_TYPE_NAME"></a>

=head2 COMMENT_TYPE_NAME : string

The type name string of the comment value of Bivio::Type::XMLElementContent.

=cut

sub COMMENT_TYPE_NAME {
    return 'COMMENT';
}

=for html <a name="ELEMENT_TYPE_NAME"></a>

=head2 ELEMENT_TYPE_NAME : string

The type name string of the element value of Bivio::Type::XMLElementContent.

=cut

sub ELEMENT_TYPE_NAME {
    return 'ELEMENT';
}

=for html <a name="END_COMMENT"></a>

=head2 END_COMMENT : string

The string that ends a comment.

=cut

sub END_COMMENT {
    return '--->';
}

=for html <a name="EOL"></a>

=head2 EOL : string

The end of line string.

=cut

sub EOL {
    return "\r\n";
}

=for html <a name="FINISH_ELEMENT_TAG"></a>

=head2 FINISH_ELEMENT_TAG : string

The string used to finish an element tag.  This is the same for both starting
and ending element tags.

=cut

sub FINISH_ELEMENT_TAG {
    return '>';
}

=for html <a name="GZ_TYPE_NAME"></a>

=head2 GZ_TYPE_NAME : string

The type name string of the gz value of
Bivio::Type::ExportFileFormat.

=cut

sub GZ_TYPE_NAME {
    return 'GZ';
}

=for html <a name="INDENT"></a>

=head2 INDENT : string

The string used to indent one level.

=cut

sub INDENT {
    return '  ';
}

=for html <a name="LIST_MODEL_TYPE_NAME"></a>

=head2 LIST_MODEL_TYPE_NAME : string

The type name string of the list model value of Bivio::Type::XMLElementContent.

=cut

sub LIST_MODEL_TYPE_NAME {
    return 'LIST_MODEL_CONTENT';
}

=for html <a name="PROPERTY_MODEL_TYPE_NAME"></a>

=head2 PROPERTY_MODEL_TYPE_NAME : string

The type name string of the property model value of
Bivio::Type::XMLElementContent.

=cut

sub PROPERTY_MODEL_TYPE_NAME {
    return 'PROPERTY_MODEL_CONTENT';
}

=for html <a name="TEXT_CONTENT_TYPE_NAME"></a>

=head2 TEXT_CONTENT_TYPE_NAME : string

The type name string of the text content value of
Bivio::Type::XMLElementContent.

=cut

sub TEXT_CONTENT_TYPE_NAME {
    return 'TEXT_CONTENT';
}

=for html <a name="UNCOMPRESSED_TYPE_NAME"></a>

=head2 UNCOMPRESSED_TYPE_NAME : string

The type name string of the uncompressed value of
Bivio::Type::ExportFileFormat.

=cut

sub UNCOMPRESSED_TYPE_NAME {
    return 'UNCOMPRESSED';
}

=for html <a name="XML_DECLARATION"></a>

=head2 XML_DECLARATION : string

The current XML declaration string.  This will probably need to be broken up
into sub-parts.

=cut

sub XML_DECLARATION {
    return '<?xml version="1.0" encoding="UTF-8" ?>';
}

=for html <a name="ZIP_TYPE_NAME"></a>

=head2 ZIP_TYPE_NAME : string

The type name string of the ZIP value of
Bivio::Type::ExportFileFormat.

=cut

sub ZIP_TYPE_NAME {
    return 'ZIP';
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
