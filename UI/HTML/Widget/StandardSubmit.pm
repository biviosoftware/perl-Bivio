# Copyright (c) 1999 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::StandardSubmit;
use strict;
$Bivio::UI::HTML::Widget::StandardSubmit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::StandardSubmit - renders a submit button of a form

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::StandardSubmit;
    Bivio::UI::HTML::Widget::StandardSubmit->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

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
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_SEPARATION) = 10;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array_ref buttons, hash_ref attributes) : Bivio::UI::HTML::Widget::StandardSubmit

List of I<buttons> can be supplied with options I<attributes>.

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::StandardSubmit

Creates a new StandardSubmit widget from I<attributes>.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
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
    my($fields) = $self->[$_IDI];
    return if $fields->{initialized};
    $fields->{initialized} = 1;

    # load the grid with buttons
    my($values) = [];
    my($buttons) = $self->unsafe_get('buttons')
	    || ['ok_button', 'cancel_button'];

    my($factory) = 'Bivio::UI::HTML::WidgetFactory';
    Bivio::IO::ClassLoader->simple_require($factory);
    my($form) = Bivio::Biz::Model->get_instance(
	    $self->ancestral_get('form_class'));
    my($labels) = $self->unsafe_get('labels') || {};

    foreach my $button (reverse(@$buttons)) {
	unshift(@$values, $factory->create(ref($form).".$button", {
	    attributes => $form->get_field_type($button)->isa(
		    'Bivio::Type::CancelButton')
	            ? 'onclick="reset()"'
	            : '',
	    label => $_VS->vs_text($form->simple_package_name,
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

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $buttons, $attributes) = @_;
    return '"buttons" attribute must be defined' unless defined($buttons);
    return '"buttons" must be an array_ref' unless ref($buttons) eq 'ARRAY';
    return {
	buttons => $buttons,
	($attributes ? %$attributes : ()),
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
