# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::StandardSubmit;
use strict;
$Bivio::UI::HTML::Widget::StandardSubmit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::StandardSubmit - renders a submit button of a form

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::StandardSubmit;
    Bivio::UI::HTML::Widget::StandardSubmit->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget::Grid;
@Bivio::UI::HTML::Widget::StandardSubmit::ISA = ('Bivio::UI::HTML::Widget::Grid');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::StandardSubmit> Draws buttons associated with
the form. By default, the ok_button and cancel_button are rendered. Use
the buttons attribute to display an alternative.

=head1 ATTRIBUTES

=over 4

=item buttons : array_ref []

The buttons to render. If not specified, then ok_button and cancel_button
are rendered.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=item labels : hash_ref []

Mapping of button field names to labels. A button label defaults to its
field name.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::Widget::ClearDot;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SEPARATION) = 10;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::StandardSubmit

Creates a new StandardSubmit widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::Grid::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initialize grid.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{initialized};
    $fields->{initialized} = 1;

    # load the grid with buttons
    my($values) = [];
    my($buttons) = $self->unsafe_get('buttons')
	    || ['ok_button', 'cancel_button'];

    my($factory) = 'Bivio::UI::HTML::WidgetFactory';
    my($form) = Bivio::Biz::Model->get_instance(
	    $self->ancestral_get('form_class'));
    my($labels) = $self->unsafe_get('labels') || {};

    foreach my $button (reverse(@$buttons)) {
	unshift(@$values, $factory->create(ref($form).".$button", {
	    attributes => $form->get_field_type($button)->isa(
		    'Bivio::Type::CancelButton')
	            ? 'onclick="reset()"'
	            : '',
	    label => Bivio::UI::Label->get_simple(
		    $labels->{$button} || $button),
	}));
	unshift(@$values,
		Bivio::UI::HTML::Widget::ClearDot->as_html($_SEPARATION))
		unless $button eq $buttons->[0];
    }

    $self->put(values => [$values]);
    $self->SUPER::initialize;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
