# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::EditRowSelector;
use strict;
$Bivio::UI::HTML::Widget::EditRowSelector::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::EditRowSelector::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::EditRowSelector - row selector

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::EditRowSelector;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Image>

=cut

use Bivio::UI::HTML::Widget::Image;
@Bivio::UI::HTML::Widget::EditRowSelector::ISA = ('Bivio::UI::HTML::Widget::Image');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::EditRowSelector> row selector

=head1 ATTRIBUTES

=over 4

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::EditRowSelector

Creates a new editable table row selector.

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::Image::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Prepares the widget.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $self->put(src => 'selector', alt => '');
    $self->SUPER::initialize;
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the selector onto the buffer, if active.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($form) = $source->get_request->get_widget_value(@{$fields->{model}});
    my($selected_row) = $form->get('selected_row');
    if (defined($selected_row) && $selected_row == $source->get_cursor) {
	$self->SUPER::render($source, $buffer);
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
