# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::MathHandlerBase;
use strict;
$Bivio::UI::HTML::Widget::MathHandlerBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::MathHandlerBase::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::MathHandlerBase - math funcs.

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::MathHandlerBase;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::MathHandlerBase::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::MathHandlerBase>

=cut


=head1 CONSTANTS

=cut

=for html <a name="MATH_MULTIPLIER_VALUE"></a>

=head2 MATH_MULTIPLIER_VALUE : string



=cut

sub MATH_MULTIPLIER_VALUE {
    return '1';
}

=for html <a name="MATH_ROUND"></a>

=head2 MATH_ROUND : string

returns name of javascript function for rounding.

=cut

sub MATH_ROUND {
    return 'mhb_round';
}

=for html <a name="MATN_MULTIPLY"></a>

=head2 MATH_MULTIPLY : string



=cut

sub MATH_MULTIPLY {
    return 'mhb_multiply';
}


#=IMPORTS
use Bivio::UI::HTML::Widget::JavaScript;

#=VARIABLES
my($_FUNCS) = Bivio::UI::HTML::Widget::JavaScript->strip(<<"EOF");

// Converts the value to a rounded d+.dd form if possible
function @{[__PACKAGE__->MATH_ROUND]}(field)
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
// multiplies the value by a given constant
function @{[__PACKAGE__->MATH_MULTIPLY]}(field)
{
  return field.value * @{[__PACKAGE__->MATH_MULTIPLIER_VALUE]};
}

EOF

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate
widget values.

Derived classes should call this first.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    Bivio::UI::HTML::Widget::JavaScript->render(
	$source, $buffer, $self->MATH_ROUND, $_FUNCS);
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
