# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ColumnSumHandler;
use strict;
$Bivio::UI::HTML::Widget::ColumnSumHandler::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::ColumnSumHandler::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::ColumnSumHandler - sums a column in a table.

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ColumnSumHandler;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::ColumnSumHandler::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ColumnSumHandler> sums a column and updates a sum
field. Only works on numbers with two fraction digits.

=head1 ATTRIBUTES

=over 4

=item field : string (required, inherited)

The field to sum.

=item form_name : string (required, inherited)

Name of the form which can be used within JavaScript.

=item sum_field : string (required)

The name of the field that holds the sum.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::Widget::JavaScript;

#=VARIABLES
my($_FUNCS) = Bivio::UI::HTML::Widget::JavaScript->strip(<<"EOF");

// Normalize the number and calculate the grand total

// Converts the value to a rounded d+.dd form if possible
function csh_norm(field)
{
  // numeric coercion
  field.value = parseFloat(field.value);
  if (isNaN(field.value)) {
    field.value = '';
    return;
  }

  // round to the penny
  field.value = Math.round(field.value * 100) / 100;

  // add trailing and leading 0 if necessary
  dotIndex = field.value.indexOf('.');
  if (dotIndex == -1)
    field.value += ".00";
  else if (field.value.length - dotIndex == 2)
    field.value += "0";
  if (dotIndex == 0)
    field.value = "0" + field.value;
}
EOF

=head1 METHODS

=cut

=for html <a name="get_html_field_attributes"></a>

=head2 get_html_field_attributes(string field_name, ref source) : string

Returns the inlined source for this method.

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
    return if Bivio::UI::HTML::Widget::JavaScript
	->has_been_rendered($source, _function_name($self, $source));
    my($req) = $source->get_request;
    my($form_name) = $self->ancestral_get('form_name');
    my($prefix) = "document.$form_name.";
    my($total) = $prefix . $source->get_field_name_for_html($self->get('sum_field'));
    $prefix .= $source->get_field_name_for_html($self->ancestral_get('field'));
    $prefix =~ s/(?<=_)0$//
	or die($prefix, ': not well formed html field for ', $self->ancestral_get('field'));
    Bivio::UI::HTML::Widget::JavaScript->render(
	$source, $buffer, 'csh_norm', $_FUNCS);
    Bivio::UI::HTML::Widget::JavaScript->render(
	$source, $buffer, _function_name($self, $source), <<"EOF"

function @{[_function_name($self, $source)]}(field)
{
    csh_norm(field);
    $total.value =
EOF
        # uses a double negative for addition to avoid string concatenation
	. join("\n- -",
	    # ASSUMES: form names follow specific structure.
	    map({
		"$prefix$_.value";
	    } 0..($source->get_result_set_size - 1))
	) . <<"EOF"
    ;csh_norm($total);
}
EOF
    );
    return;
}

#=PRIVATE SUBROUTINES

# _function_name(self, any source) : string
#
# returns name of field-based function
#
sub _function_name {
    my($self, $source) = @_;
    return 'csh_' . $self->ancestral_get('form_name')
	. '_' . $source->get_field_name_for_html($self->get('sum_field'));
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
