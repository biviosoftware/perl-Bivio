# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::TextContent;
use strict;
$Bivio::UI::XML::TextContent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::TextContent - contains the text of an element.

=head1 SYNOPSIS

    use Bivio::UI::XML::TextContent;
    my($text_content) = Bivio::UI::XML::TextContent->new();
    $text_content->add_text(string $text);
    $text_content->add_text(string_ref $text);
    $text_content->emit_xml_text(string_ref $text, string $indent);

=cut

use Bivio::UI::XML::ElementContent;
@Bivio::UI::XML::TextContent::ISA = ('Bivio::UI::XML::ElementContent');

=head1 DESCRIPTION

C<Bivio::UI::XML::TextContent>

=cut

#=IMPORTS
use Bivio::Type::XMLElementContent;
use Bivio::UI::XML::Strings;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_TEXT_CONTENT_TYPE_NAME) =
	Bivio::UI::XML::Strings::TEXT_CONTENT_TYPE_NAME();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::XML::TextContent



=cut

sub new {
    my($self) = Bivio::UI::XML::ElementContent::new($_[0],
	  Bivio::Type::XMLElementContent->from_name($_TEXT_CONTENT_TYPE_NAME));
    $self->{$_PACKAGE} = {
	text => ''
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_text"></a>

=head2 add_text(string $text)

=head2 add_text(string_ref $text)

Append the given text to any that this object already contains.

=cut

sub add_text {
    my($self, $input_text) = @_;
    my($fields) = $self->{$_PACKAGE};

    if (ref($input_text)) {
	$fields->{text} .= ${$input_text};
    }
    else {
	$fields->{text} .= $input_text;
    }

    return;
}

=for html <a name="emit_xml_text"></a>

=head2 emit_xml_text(string_ref $text, string $indent)

Append this object's text to the given string.

=cut

sub emit_xml_text {
    my($self, $xml_text_ref, $indent) = @_;
    my($fields) = $self->{$_PACKAGE};
    ${$xml_text_ref} .= $fields->{text};
    return;
}

=for html <a name="has_content"></a>

=head2 has_content() : boolean

See if this object has any content that emit_xml_text will emit.

=cut

sub has_content {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    if ('' eq $fields->{text}) {
	return 0;
    }
    else {
	return 1;
    }
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
