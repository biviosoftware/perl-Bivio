# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::Body;
use strict;
$Bivio::UI::XML::Body::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::Body - contains the data of the body of a
Bivio::UI::XML::Document.

=head1 SYNOPSIS

    use Bivio::UI::XML::Body;
    my($body) = Bivio::UI::XML::Body->new();
    $body->add_document_element(Bivio::UI::XML::Body_ref $document_element);
    $body->emit_xml_text(string_ref $text, string $indent);

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::XML::Body::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::XML::Body>

=cut

#=IMPORTS

use Bivio::IO::Alert;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::XML::Body



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	document_element => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_document_element"></a>

=head2 add_document_element(Bivio::UI::XML::Element_ref $element)

Add the document element to the body.  Die if there is already a document
element.  The document element is the "root" element of the element tree of
the document.  Apparently there is also a thing called the "document root",
which is different.  See "Professional XML", Martin et al, Wrox Press, p38.

=cut

sub add_document_element {
    my($self, $document_element) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($fields->{document_element})) {
	Bivio::IO::Alert->die("XLM document already has a document element");
    }
    $fields->{document_element} = $document_element;
    return;
}

=for html <a name="emit_xml_text"></a>

=head2 emit_xml_text(string_ref $text, string $indent)

Append the text rendering of this body to the given string.  Die if there
is no document element.

=cut

sub emit_xml_text {
    my($self, $xml_text_ref, $indent) = @_;
    my($fields) = $self->{$_PACKAGE};
    unless (defined($fields->{document_element})) {
	Bivio::IO::Alert->die("XLM document has no document element");
    }
    $fields->{document_element}->emit_xml_text($xml_text_ref, $indent);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
