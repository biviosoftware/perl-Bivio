# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::Document;
use strict;
$Bivio::UI::XML::Document::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::Document - a complete XML document.

=head1 SYNOPSIS

    use Bivio::UI::XML::Document;
    my($document) = Bivio::UI::XML::Document->new();
    my($xml_text_ref) = $document->emit_xml_text(string $indent);

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::XML::Document::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::XML::Document> encapsulates the data for an XML document.

Bivio::UI::XML::Document->emit_xml_text() produces a text version of the
document which is well formed but not valid.  It is not valid because it
lacks a Document Type Definition(DTD).

=cut

#=IMPORTS

use Bivio::IO::Alert;
use Bivio::UI::XML::Body;
use Bivio::UI::XML::Prolog;
use Bivio::UI::XML::Strings;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_EOL) = Bivio::UI::XML::Strings::EOL();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::XML::Document

Create a new, empty document that will need to have a Bivio::UI::XML::Prolog,
a Bivio::UI::XML::Body, and a Bivio::UI::XML::Epilog added.

=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	prolog => undef,
	body => undef,
	epilog => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_body"></a>

=head2 add_body(Bivio::UI::XML::Body_ref body)

Add the given body to this Bivio::UI::XML::Document.  Die if there is already
a body.

=cut

sub add_body {
    my($self, $body) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($fields->{body})) {
	Bivio::IO::Alert->die("XLM document already has a body");
    }
    $fields->{body} = $body;
    return;
}

=for html <a name="add_epilog"></a>

=head2 add_epilog(Bivio::UI::XML::Epilog_ref epilog)

Add the given epilog to this Bivio::UI::XML::Document.  Die if there is
already an epilog.

=cut

sub add_epilog {
    my($self, $epilog) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($fields->{epilog})) {
	Bivio::IO::Alert->die("XLM document already has a epilog");
    }
    $fields->{epilog} = $epilog;
    return;
}

=for html <a name="add_prolog"></a>

=head2 add_prolog(Bivio::UI::XML::Prolog_ref prolog)

Add the given prolog to this Bivio::UI::XML::Document.  Die if there is
already a prolog.

=cut

sub add_prolog {
    my($self, $prolog) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($fields->{prolog})) {
	Bivio::IO::Alert->die("XLM document already has a prolog");
    }
    $fields->{prolog} = $prolog;
    return;
}

=for html <a name="emit_xml_text"></a>

=head2 emit_xml_text(string $indent) : string_ref text

Produce the text representation of this document.  Die if either the prolog
or body is missing, but ignore a missing epilog, since it doesn't seem to
be necessary.

=cut

sub emit_xml_text {
    my($self, $indent) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($text) = '';

    unless (defined($fields->{prolog})) {
	Bivio::IO::Alert->die("XLM document has no Prolog");
    }
    unless (defined($fields->{body})) {
	Bivio::IO::Alert->die("XLM document has no body");
    }

    $fields->{prolog}->emit_xml_text(\$text, $indent);
    $fields->{body}->emit_xml_text(\$text, $indent);
    if (defined($fields->{epilog})) {
	$fields->{epilog}->emit_xml_text(\$text, $indent);
    }

    $text .= $_EOL;

    return(\$text);
}

=for html <a name="has_content"></a>

=head2 has_content() : boolean

See if this object, or any of its children, has any content that emit_xml_text
will emit.  Assume that documents always have content.

=cut

sub has_content {
    return 1;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
