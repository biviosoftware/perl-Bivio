# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Radio;
use strict;
$Bivio::UI::HTML::Widget::Radio::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Radio - a radio input field

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Radio;
    Bivio::UI::HTML::Widget::Radio->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Radio::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Radio> is an input of type C<RADIO>.
It always has a label, but the label may be a string or widget.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=item label : string (required)

String label to use.

=item value : Bivio::Type::Enum (required)

Value of button.

=back

=cut

#=IMPORTS
use Bivio::UI::Font;
use Bivio::Util;

#=VARIABLES
my($_FONT_PREFIX, $_FONT_SUFFIX) = Bivio::UI::Font->as_html('RADIO');
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::Radio

Creates a Radio widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');
    $fields->{value} = $self->get('value');
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the date field on the specified buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($form) = $source->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};
    my($value) = $fields->{value};

    # first render initialization
    unless ($fields->{initialized}) {
	$fields->{prefix} = '<nobr><input name=';
	$fields->{suffix} = ' type=radio value="'
		.$value->to_html($value)."\">\n&nbsp;"
		.$_FONT_PREFIX. Bivio::Util::escape_html($self->get('label'))
		.$_FONT_SUFFIX.'</nobr>';
	$fields->{initialized} = 1;
    }

    $$buffer .= $fields->{prefix}
	    .$form->get_field_name_for_html($field)
#TODO: is_equal?
	    .($value eq $form->get($field) ? ' checked' : '')
	    .$fields->{suffix};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
