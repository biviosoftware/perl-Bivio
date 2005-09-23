# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormButton;
use strict;
$Bivio::UI::HTML::Widget::FormButton::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::FormButton::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::FormButton - a dynamic submit button

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::FormButton;
    Bivio::UI::HTML::Widget::FormButton->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::FormButton::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::FormButton> a form specific submit button.

Font is always C<FORM_SUBMIT>.

=head1 ATTRIBUTES

=over 4

=item attributes : string []

Attributes to be applied to the button.  C<StandardSubmit>
uses this to set "onclick=reset()".

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item label : string [Model.field]

String label to use.

=item label : array_ref

If specified, the button text will be determined by calling
L<get_widget_value|"get_widget_value"> on the rendering source.

=back

=cut

#=IMPORTS

#=VARIABLES

my($_IDI) = __PACKAGE__->instance_data_index;
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::FormButton

Creates a new Form Button widget.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->[$_IDI] = {};
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
    my($fields) = $self->[$_IDI];
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');

    my($label) = $self->has_keys('label') ? $self->get('label')
	: $_VS->vs_text(
	    $self->ancestral_get('form_class')->simple_package_name,
	    $fields->{field});
    $fields->{label} = ref($label) ? $label : Bivio::HTML->escape($label);
    return;
}

=for html <a name="internal_new_args"></a>

=head2 internal_new_args(string field) : any

=head2 internal_new_args(string field, hash_ref attributes) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my($proto, $field, $attributes) = @_;
    return {
	field => $field,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, Text_ref buffer)

Render the input field.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    # first render initialization
    my($p, $s) = Bivio::UI::Font->format_html('form_submit', $req);
    $$buffer .= $p.'<input type=submit name='
	    .$form->get_field_name_for_html($field).' value="'
	    .(ref($fields->{label})
		    ? Bivio::HTML->escape(
			    $source->get_widget_value(@{$fields->{label}}))
		    : $fields->{label})
	    .'" '.$self->get_or_default('attributes', '')
	    .' />'.$s;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
