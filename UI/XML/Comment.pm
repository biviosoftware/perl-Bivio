# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::XML::Comment;
use strict;
$Bivio::UI::XML::Comment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::XML::Comment - contains an XML comment.

=head1 SYNOPSIS

    use Bivio::UI::XML::Comment;
    my($comment) = Bivio::UI::XML::Comment->new();
    $comment->add_text(string $text);
    $comment->add_text(string_ref $text);
    $comment->emit_xml_text(string_ref $text, string $indent);

=cut

use Bivio::UI::XML::ElementContent;
@Bivio::UI::XML::Comment::ISA = ('Bivio::UI::XML::ElementContent');

=head1 DESCRIPTION

C<Bivio::UI::XML::Comment>

=cut

#=IMPORTS
use Bivio::Type::XMLElementContent;
use Bivio::UI::XML::Strings;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_BEGIN_COMMENT) = Bivio::UI::XML::Strings::BEGIN_COMMENT();
my($_COMMENT_TYPE_NAME) = Bivio::UI::XML::Strings::COMMENT_TYPE_NAME();
my($_END_COMMENT) = Bivio::UI::XML::Strings::END_COMMENT();
my($_EOL) = Bivio::UI::XML::Strings::EOL();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::XML::Comment



=cut

sub new {
    my($self) = Bivio::UI::XML::ElementContent::new($_[0],
	   Bivio::Type::XMLElementContent->from_name($_COMMENT_TYPE_NAME));
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

Add text to the comment.  Append it to any that already exists.

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

Append this comment's text to the given string.

=cut

sub emit_xml_text {
    my($self, $xml_text_ref, $indent) = @_;
    my($fields) = $self->{$_PACKAGE};

    ${$xml_text_ref} .= $indent;
    ${$xml_text_ref} .= $_BEGIN_COMMENT;
    ${$xml_text_ref} .= $fields->{text};
    ${$xml_text_ref} .= $_END_COMMENT;
    ${$xml_text_ref} .= $_EOL;

    return;
}

=for html <a name="has_content"></a>

=head2 has_content() : boolean

See if this object, or any of its children, has any content that emit_xml_text
will emit.  Assume that comments always have content.

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
