# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Submit;
use strict;
$Bivio::UI::HTML::Widget::Submit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Submit - a submit input field

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Submit;
    Bivio::UI::HTML::Widget::Submit->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Submit::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Submit> is an input of type C<SUBMIT>.

Font is always C<FORM_SUBMIT>.

=head1 ATTRIBUTES

=over 4

=item attributes : string []

Attributes to be applied to the button.  C<StandardSubmit>
uses this to set "onclick=reset()".

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=item value : string (required)

The method on I<form_model> which returns the submit button value,
e.g. C<SUBMIT_OK> or C<SUBMIT_CANCEL>.

=item value : array_ref (required)

The value of the label to use.  Used only by forms which have
dynamic submit buttons.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::Submit

Creates a Submit widget.

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
    $fields->{value} = $self->get('value');
    $fields->{attributes} = $self->get_or_default('attributes', undef);
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the submit button.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($value) = $fields->{value};

    my($p, $s) = Bivio::UI::Font->as_html('form_submit');
    my($model) = $source->get_request->get_widget_value(@{$fields->{model}});
    $$buffer .= $p.'<input type=submit name="'.$model->SUBMIT().'" value="'
	    .Bivio::Util::escape_html(
		    ref($value) ? $source->get_widget_value(@$value)
		    : $model->$value())
	    .($fields->{attributes}
		    ? '" '.$fields->{attributes}.'>' : '">').$s;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
