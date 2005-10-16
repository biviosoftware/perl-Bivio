# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
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

L<Bivio::UI::HTML::Widget::ControlBase>

=cut

use Bivio::UI::HTML::Widget::ControlBase;
@Bivio::UI::HTML::Widget::FormButton::ISA = ('Bivio::UI::HTML::Widget::ControlBase');

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

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = shift;
    return $self->put_unless_exists(label => sub {
	    $_VS->vs_text(
		$self->ancestral_get('form_class')->simple_package_name,
		$self->get('field'),
	    );
	},
    )->map_invoke(
	initialize_attr => [qw(label attributes)],
    );
    return $self->SUPER::initialize(@_);
}

=for html <a name="internal_new_args"></a>

=head2 internal_new_args(string field) : any

=head2 internal_new_args(string field, hash_ref attributes) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    return shift->SUPER::internal_new_args([qw(field)], \@_);
}

=for html <a name="control_on_render"></a>

=head2 control_on_render(any source, Text_ref buffer)

Render the input field.

=cut

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($p, $s) = Bivio::UI::Font->format_html('form_submit', $source);
    $$buffer .= $p
	. '<input type="submit" name="'
	. $self->resolve_ancestral_attr('form_model', $source->get_request)
	    ->get_field_name_for_html($self->get('field'))
	. '" value="'
	. Bivio::HTML->escape($self->render_simple_attr('label', $source))
	. '" '
	. $self->render_simple_attr('attributes', $source);
    $self->SUPER::control_on_render($source, $buffer);
    $buffer .= " />$s";
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
