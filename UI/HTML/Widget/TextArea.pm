# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::TextArea;
use strict;
$Bivio::UI::HTML::Widget::TextArea::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::TextArea - large text input field

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::TextArea;
    Bivio::UI::HTML::Widget::TextArea->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::TextArea::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::TextArea> draws a C<INPUT> tag with
attribute C<TYPE=TEXTAREA>.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item rows : int (required)

The number of rows to show.

=item cols : int (required)

The number of character columns to show.

=item wrap : string (optional) [OFF]

The text wrapping mode.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::TextArea

Creates a new TextArea widget.

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

Initializes from attribute settings.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    ($fields->{field}, $fields->{rows}, $fields->{cols}) = $self->get(
	    'field', 'rows', 'cols');
    $fields->{wrap} = $self->get_or_default('wrap', 'off');
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the input field.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($form) = $source->get_request->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    # need first time initialization to get field name from form model
    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
#TODO: need get_width or is it something else?
	$fields->{prefix} = '<textarea'
		.' rows='.$fields->{rows}
		.' cols='.$fields->{cols}
		.' wrap='.$fields->{wrap}
		.' name=';
	$fields->{initialized} = 1;
    }
    $$buffer .= $fields->{prefix}
	    .$form->get_field_name_for_html($field)
	    .'>'.
	    $form->get_field_as_html($field).'</textarea>';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
