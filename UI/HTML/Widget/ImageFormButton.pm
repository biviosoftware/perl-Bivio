# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ImageFormButton;
use strict;
$Bivio::UI::HTML::Widget::ImageFormButton::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::ImageFormButton - renders an input type=image

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ImageFormButton;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::ImageFormButton::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ImageFormButton> renders a input of type
image.

=head1 ATTRIBUTES

=over 4

=item alt : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get string to use (see below).

=item alt : string (required)

Literal text to use for C<ALT> attribute of C<IMG> tag.
Will be passed to L<Bivio::HTML->escape|Bivio::Util/"escape_html">
before rendering.

May be C<undef>.

=item field : string (required)

Name of the field.  If not supplied, is assumed to be 'submit'.

=item form_model : array_ref (required, inherited, get_request)

Which form instance are we dealing with.

=item image : string (required, get_request)

Icon name.

=back

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::ImageFormButton

Creates a new ImageFormButton.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.  In this case, prefix and suffix
field values.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->unsafe_get('field');
    $fields->{image} = $self->get('image');
    $fields->{prefix} = '<input type=image border=0';
    my($alt) = $self->get('alt');
    if (ref($alt)) {
	$fields->{alt} = $alt;
    }
    elsif (defined($alt)) {
	$fields->{prefix} .= ' alt="'.Bivio::HTML->escape($alt).'"';
    }
    $fields->{prefix} .= ' name="';
    return;
}

=for html <a name="render"></a>

=head2 render(any source, Text_ref buffer)

Render the input field.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field}
	    ? $form->get_field_name_for_html($fields->{field})
		    : 'submit';

    $$buffer .= $fields->{prefix}.$field.'"';
    $$buffer .= ' alt="'.Bivio::HTML->escape(
	    $source->get_widget_value(@{$fields->{alt}})).'"'
		    if $fields->{alt};
    $$buffer .= ' src="'
	    .Bivio::UI::Icon->get_value($fields->{image}, $req)->{uri}.'">';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
