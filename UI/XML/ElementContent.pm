# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::ElementContent;
use strict;
$Bivio::UI::XML::ElementContent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::ElementContent - base class for element content objects.

=head1 SYNOPSIS

    use Bivio::UI::XML::ElementContent;
    Bivio::UI::XML::ElementContent->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::XML::ElementContent::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::XML::ElementContent> is the base class for XML element content
objects.  An element content object is one that can be contained by an XML
element.  See L<Bivio::Type::XMLElementContent> for the various possible
types of element content.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Type::XLMElementContent $type) :
	Bivio::UI::XML::ElementContent


=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    my(undef, $type) = @_;
    $self->{$_PACKAGE} = {
	type => $type,
	has_content => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="emit_xml_text"></a>

=head2 abstract emit_xml_text(string_ref $text, string $indent)

Append this object's text to the given string.

=cut

sub emit_xml_text {
    die("abstract method");
}

=for html <a name="generate_children"></a>

=head2 abstract generate_children(Bivio::UI::XML::Element_ref)

Generate elements and add them as children to the given element.

=cut

sub generate_children {
    die("Abstract method");
}

=for html <a name="get_has_content"></a>

=head2 get_has_content() : boolean

Get the value of the has_content flag.

=cut

sub get_has_content {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{has_content};
}

=for html <a name="has_content"></a>

=head2 abstract has_content() : boolean

See if this object, or any of its children, has any content that emit_xml_text
will emit.

=cut

sub has_content {
    die("abstract method");
}

=for html <a name="is_sortable"></a>

=head2 is_sortable() : boolean

Tell whether or not this element can be sorted along with other siblings.
An element can be sorted if it contains exactly one child that is a text
content object.  This method should be overridden by those classes than
can be sorted.

=cut

sub is_sortable {
    return 0;
}

=for html <a name="set_has_content"></a>

=head2 set_has_content(boolean $has_content)

Set a flag that tells whether or not this object, or any of its children,
has any content that emit_xml_text will emit.  The value of this flag may
be undefined, in which case the child object will have to determine its
value.

=cut

sub set_has_content {
    my($self, $has_content) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{has_content} = $has_content;
    return;
}

=for html <a name="type_name"></a>

=head2 type_name() : string

Get the name of the type(L<Bivio::Type::XMLElementContent>) of this object.

=cut

sub type_name {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{type}->get_name();
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
