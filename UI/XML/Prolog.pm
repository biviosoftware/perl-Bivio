# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::Prolog;
use strict;
$Bivio::UI::XML::Prolog::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::Prolog - contains the data of the prolog part of a
Bivio::UI::XML::Document.

=head1 SYNOPSIS

    use Bivio::UI::XML::Prolog;
    my($prolog) = Bivio::UI::XML::Prolog->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::XML::Prolog::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::XML::Prolog> contains the data of the prolog part of a
Bivio::UI::XML::Document.  It has an XML declaration compiled in:

<?xml version="1.0" encoding="UTF-8" ?>

=cut

#=IMPORTS
use Bivio::UI::XML::Strings;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_EOL) = Bivio::UI::XML::Strings::EOL();
my($_XML_DECLARATION) = Bivio::UI::XML::Strings::XML_DECLARATION();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::XML::Prolog



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	xml_declaration => $_XML_DECLARATION
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="emit_xml_text"></a>

=head2 emit_xml_text(string_ref $text, string $indent)

Append the text rendering of this prolog to the given string.

=cut

sub emit_xml_text {
    my($self, $xml_text_ref, $indent) = @_;
    my($fields) = $self->{$_PACKAGE};
    ${$xml_text_ref} .= $indent;
    ${$xml_text_ref} .= $fields->{xml_declaration};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
