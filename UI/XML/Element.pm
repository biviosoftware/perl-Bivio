# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::Element;
use strict;
$Bivio::UI::XML::Element::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::Element - contains the data for an XML element.

=head1 SYNOPSIS

    use Bivio::UI::XML::Element;
    my($element) = Bivio::UI::XML::Element->new(string $tag);
    $elemnt->add_child(Bivio::UI::XML::Element_ref $element);
    $elemnt->add_child(Bivio::UI::XML::Comment_ref $comment);
    $element->add_text(string_ref $text);
    $element->add_text(string $text);
    $element->emit_xml_text(string_ref $text, string $indent);

=cut

use Bivio::UI::XML::ElementContent;
@Bivio::UI::XML::Element::ISA = ('Bivio::UI::XML::ElementContent');

=head1 DESCRIPTION

C<Bivio::UI::XML::Element> contains text, child elements, or comments.

Text, child elements, and comments are emitted in the order in which they
were added.

=cut

#=IMPORTS

use Bivio::IO::Alert;
use Bivio::Type::XMLElementContent;
use Bivio::UI::XML::Strings;
use Bivio::UI::XML::TextContent;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_BEGIN_STARTING_ELEMENT_TAG) =
	Bivio::UI::XML::Strings::BEGIN_STARINGT_ELEMENT_TAG();
my($_BEGIN_ENDING_ELEMENT_TAG) =
	Bivio::UI::XML::Strings::BEGIN_ENDING_ELEMENT_TAG();
my($_ELEMENT_TYPE_NAME) = Bivio::UI::XML::Strings::ELEMENT_TYPE_NAME();
my($_TEXT_CONTENT_TYPE_NAME) =
	Bivio::UI::XML::Strings::TEXT_CONTENT_TYPE_NAME();
my($_EOL) = Bivio::UI::XML::Strings::EOL();
my($_FINISH_ELEMENT_TAG) = Bivio::UI::XML::Strings::FINISH_ELEMENT_TAG();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string $tag) : Bivio::UI::XML::Element



=cut

sub new {
    my($self) = Bivio::UI::XML::ElementContent::new($_[0],
	   Bivio::Type::XMLElementContent->from_name($_ELEMENT_TYPE_NAME));
    my(undef, $tag) = @_;
    $self->{$_PACKAGE} = {
	tag => $tag,
	children => []
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_child"></a>

=head2 add_child(Bivio::UI::XML::Element_ref $element)

Add a reference to another element to the list of children of this element.

=cut

sub add_child {
    my($self, $child) = @_;
    my($fields) = $self->{$_PACKAGE};
    push(@{$fields->{children}}, $child);
    return;
}

=for html <a name="add_comment"></a>

=head2 add_comment(Bivio::UI::XML::Comment_ref $comment)

Add a comment to this element.

=cut

sub add_comment {
    my($self, $comment) = @_;
    my($fields) = $self->{$_PACKAGE};

    push(@{$fields->{children}}, $comment);

    return;
}

=for html <a name="add_generated_children"></a>

=head2 add_generated_children(Bivio::UI::XML::ElementContent_ref)

Generate children from the given element content and add them as children to
this element.  The given element content object must support the
generate_children method.

=cut

sub add_generated_children {
    my($self, $element_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    $element_ref->generate_children($self);
    return;
}

=for html <a name="add_text"></a>

=head2 add_text(string_ref $text)

add_text(string $text)

Create another TextContent object and add it to this element's list of
sub-objects.

=cut

sub add_text {
    my($self, $input_text) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($text) = Bivio::UI::XML::TextContent->new();
    $text->add_text($input_text);
    push(@{$fields->{children}}, $text);

    return;
}

=for html <a name="emit_xml_text"></a>

=head2 emit_xml_text(string_ref $text, string $indent)

Emit this element's data into the given string.

=cut

sub emit_xml_text {
    my($self, $xml_text_ref, $indent) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($last_child_is_text);

    # Don't emit this element if it doesn't have any content.
    unless ($self->has_content()) {
	return;
    }

    # Sort this element's children by tag, if possible.
    $self->sort_children();

    # Emit the starting tag.
    ${$xml_text_ref} .= $_EOL;
    ${$xml_text_ref} .= $indent;
    ${$xml_text_ref} .= $_BEGIN_STARTING_ELEMENT_TAG . $fields->{tag} .
	    $_FINISH_ELEMENT_TAG;

    # Emit the children.
    map {
	# TextContent objects don't ever indent.
	$_->emit_xml_text($xml_text_ref,
		$indent . Bivio::UI::XML::Strings::INDENT());

	# Find out what type the last child is.
	if ($_TEXT_CONTENT_TYPE_NAME ne $_->type_name()) {
	    $last_child_is_text = 0;
	}
	else {
	    $last_child_is_text = 1;
	}
    } @{$fields->{children}};

    # Emit the ending tag.
    if ($last_child_is_text) {
	${$xml_text_ref} .= $_BEGIN_ENDING_ELEMENT_TAG . $fields->{tag} .
		$_FINISH_ELEMENT_TAG;
    }
    else {
	${$xml_text_ref} .= $_EOL;
	${$xml_text_ref} .= $indent;
	${$xml_text_ref} .= $_BEGIN_ENDING_ELEMENT_TAG . $fields->{tag} .
		$_FINISH_ELEMENT_TAG;
    }

    return;
}

=for html <a name="get_tag"></a>

=head2 get_tag() : string

Return the tag string.

=cut

sub get_tag {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{tag};
}

=for html <a name="has_content"></a>

=head2 has_content() : boolean

See if this object, or any of its children, has any content that emit_xml_text
will emit.

=cut

sub has_content {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    # See if the has_content flag has already been set for this object.
    my($has_content_flag) = $self->get_has_content();
    if (defined($has_content_flag)) {
	return $has_content_flag;
    }

    # Examine all the children.
    $has_content_flag = 0;
    map {
	$has_content_flag ||= $_->has_content();
    } @{$fields->{children}};

    # Set the has_content flag for future reference.
    $self->set_has_content($has_content_flag);

    return $has_content_flag;
}

=for html <a name="is_sortable"></a>

=head2 is_sortable() : boolean

Tell whether or not this element can be sorted along with other siblings.
An element can be sorted if it contains exactly one child that is a text
content object.

=cut

sub is_sortable {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    unless (0 == $#{$fields->{'children'}}) {
	# Not exactly one child.
	return 0;
    }
    if ($_TEXT_CONTENT_TYPE_NAME eq ${$fields->{children}}[0]->type_name()) {
	return 1;
    }
    return 0;
}

=for html <a name="sort_children"></a>

=head2 sort_children()

Sort this element's children by tag name, if possible.

=cut

sub sort_children {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    # Make sure all the children are sortable.
    map {
	unless ($_->is_sortable()) {
	    return;
	}
    } @{$fields->{children}};

    # If we got here, they are all sortable.
    my(@sorted_children) = sort {$a->get_tag() cmp $b->get_tag()}
	    @{$fields->{children}};
    $fields->{children} = \@sorted_children;

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
