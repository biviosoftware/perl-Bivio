# $Id$
package Bivio::UI::HTML::Widget::SubtractionHandler;
use strict;
$Bivio::UI::HTML::Widget::SubtractionHandler::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::SubtractionHandler::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::SubtractionHandler - takes a group of fields and an
initial field. Subtracts the field values from the initial field value.

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::SubtractionHandler;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::JavaScript>

=cut

use Bivio::UI::HTML::Widget::MathHandlerBase;
@Bivio::UI::HTML::Widget::SubtractionHandler::ISA = ('Bivio::UI::HTML::Widget::MathHandlerBase');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::SubtractionHandler>

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
    my($req) = $source->get_request;
    my($model) = $req->get($self->ancestral_get('form_class'));
    return ' onBlur="'. _function_name($self, $model) . '(this)"';
}

=for html <a name="render"></a>

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate widget
values. Renders the javascript code needed to perform math function. The
javascript simply takes the initial value and subtracts the values in the
supplied 'sub_fields' parameter.

=cut

sub render {
    my($self, $source, $buffer) = @_;
#    $self->SUPER::render($source, $buffer);
    my($req) = $source->get_request;
    my($model) = $req->get($self->ancestral_get('form_class'));
    return if Bivio::UI::HTML::Widget::JavaScript
	->has_been_rendered($source, _function_name($self, $model));
    my($form_name) = $self->ancestral_get('form_name');
    my($prefix) = "document.$form_name.";
    my($total) = $prefix . $model->get_field_name_for_html($self->get('sum_field'));
    my($sub_fields) = $self->get('sub_fields');
    my($initial_value) = $prefix . $model->get_field_name_for_html($self->get('initial_value'));
    Bivio::UI::HTML::Widget::JavaScript->render(
	$source, $buffer, _function_name($self, $model), <<"EOF"

function @{[_function_name($self, $model)]}(field)
{
    $total.value = $initial_value.value -
EOF
        # uses a double negative for addition to avoid string concatenation
	. join("\n- ",
	    map({
		$prefix . $model->get_field_name_for_html($_) . ".value";
	    } @$sub_fields)
	) . ";" . <<"EOF"

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
    my($self, $model) = @_;
    return 'csas_' . $self->ancestral_get('form_name')
	. '_' . $model->get_field_name_for_html($self->get('sum_field'));
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
