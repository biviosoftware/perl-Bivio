# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::FormFieldLabel;
use strict;
$Bivio::UI::HTML::Widget::FormFieldLabel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::FormFieldLabel - label which can check for errors

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::FormFieldLabel;
    Bivio::UI::HTML::Widget::FormFieldLabel->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Director>

=cut

use Bivio::UI::HTML::Widget::Director;
@Bivio::UI::HTML::Widget::FormFieldLabel::ISA = ('Bivio::UI::HTML::Widget::Director');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::FormFieldLabel> displays a string in
C<form_field_label>
or C<form_field_error_label> fonts.


=head1 ATTRIBUTES

=over 4

=item label : string (required)

Text to render for the visible label.
Will be passed to L<Bivio::Util::escape_html|Bivio::Util/"escape_html">
before rendering.

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::FormFieldLabel

Nothing here.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::Director::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Builds up the attributes for SUPER (Director). 

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{initialized};
    my($label, $field) = $self->get('label', 'field');
    my($model) = $self->ancestral_get('form_model');
    $self->put(
	control => [$model, '->get_field_error', $field],
	values => {},
	default_value => Bivio::UI::HTML::Widget::String->new({
	    value => $label,
	    string_font => 'form_field_error_label',
	    parent => $self,
	}),
	undef_value =>  Bivio::UI::HTML::Widget::String->new({
	    value => $label,
	    string_font => 'form_field_label',
	    parent => $self,
	}),
    );
    $self->SUPER::initialize;
    $fields->{initialized} = 1;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
