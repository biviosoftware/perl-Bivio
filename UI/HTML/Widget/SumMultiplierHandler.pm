# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::SumMultiplierHandler;
use strict;
$Bivio::UI::HTML::Widget::SumMultiplierHandler::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::SumMultiplierHandler::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::SumMultiplierHandler - adds to fields together and
allows a multiplier for the result. Derived from ColumnSumHandler

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::SumMultiplierHandler;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::JavaScript>

=cut

use Bivio::UI::HTML::Widget::MathHandlerBase;
@Bivio::UI::HTML::Widget::SumMultiplierHandler::ISA = ('Bivio::UI::HTML::Widget::MathHandlerBase');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::SumMultiplierHandler>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_html_field_attributes"></a>

=head2 get_html_field_attributes() : 



=cut

sub get_html_field_attributes {
    my($self, $field_name, $source) = @_;
    return ' onBlur="'. _function_name($self, $source) . '(this)"';
}

=for html <a name="render"></a>

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate
widget values.

=cut

sub render {
    my($self, $source, $buffer) = @_;
#    $self->SUPER::render($source, $buffer);
    return if Bivio::UI::HTML::Widget::JavaScript
	->has_been_rendered($source, _function_name($self, $source));
    my($req) = $source->get_request;
    my($form_name) = $self->ancestral_get('form_name');
    my($prefix) = "document.$form_name.";
    my($total) = $prefix . $source->get_field_name_for_html($self->get('sum_field'));
    my($multiplier) = $self->get('multiplier');
    my($vals) = $self->get('fields');
    Bivio::UI::HTML::Widget::JavaScript->render(
	$source, $buffer, _function_name($self, $source), <<"EOF"

function @{[_function_name($self, $source)]}(field)
{
    @{[$self->MATH_ROUND]}(field);
    $total.value =
EOF
        # uses a double negative for addition to avoid string concatenation
	. join("\n- -",
	    # ASSUMES: form names follow specific structure.
	    map({
		$prefix . $source->get_field_name_for_html($_) . ".value";
	    } @$vals)
	) . <<"EOF"

    $total.value = $total.value * $multiplier;
    @{[$self->MATH_ROUND]}($total);
}
EOF
    );
    return;
}

#=PRIVATE SUBROUTINES

# _function_name() : 
#
#
#
sub _function_name {
    my($self, $source) = @_;
    return 'csxm_' . $self->ancestral_get('form_name')
	. '_' . $source->get_field_name_for_html($self->get('sum_field'));
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
