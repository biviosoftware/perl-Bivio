# Copyright (c) 1999-2005 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::TextArea;
use strict;
$Bivio::UI::HTML::Widget::TextArea::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::TextArea::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::TextArea - large text input field

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::TextArea;
    Bivio::UI::HTML::Widget::TextArea->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::HTML::Widget::ControlBase;
@Bivio::UI::HTML::Widget::TextArea::ISA = ('Bivio::UI::HTML::Widget::ControlBase');

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

=item readonly : boolean (optional) [0]

Don't allow text-editing

=item wrap : string (optional) [VIRTUAL]

The text wrapping mode.

=back

=cut

#=IMPORTS

#=VARIABLES

my($_IDI) = __PACKAGE__->instance_data_index;
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::TextArea

Creates a new TextArea widget.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] ||= {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, string_ref buffer)

Render the input field.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $self->SUPER::control_on_render($source, $buffer);
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    # need first time initialization to get field name from form model
    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	my($attributes) = '';
	$self->unsafe_render_attr('edit_attributes', $source, \$attributes);
#TODO: need get_width or is it something else?
	$fields->{prefix} = '<textarea' . $attributes
	    . ($_VS->vs_html_attrs_render($self, $source) || '')
	    . join('', map(qq{ $_="$fields->{$_}"}, qw(rows cols wrap)));
        $fields->{prefix} .= ' readonly="1"'
	    if $fields->{readonly};
	$fields->{initialized} = 1;
    }
    my($p, $s) = Bivio::UI::Font->format_html('input_field', $req);
    $$buffer .= $p.$fields->{prefix}
	    . ' name="'
	    . $form->get_field_name_for_html($field)
	    . '">'
	    . $form->get_field_as_html($field)
	    . '</textarea>'
	    . $s;
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes from attribute settings.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{model};
    $self->unsafe_initialize_attr('edit_attributes');
    $fields->{model} = $self->ancestral_get('form_model');
    ($fields->{field}, $fields->{rows}, $fields->{cols}) = $self->get(
	    'field', 'rows', 'cols');
    $fields->{wrap} = $self->get_or_default('wrap', 'virtual');
    $fields->{readonly} = $self->get_or_default('readonly', 0);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
