# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::Widget::CreditCardExpiration;
use strict;
$Bivio::PetShop::Widget::CreditCardExpiration::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Widget::CreditCardExpiration::VERSION;

=head1 NAME

Bivio::PetShop::Widget::CreditCardExpiration - credit card expiration date widget

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Widget::CreditCardExpiration;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::PetShop::Widget::CreditCardExpiration::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::PetShop::Widget::CreditCardExpiration> implements a credit card
expiration date selection widget.

=cut

#=IMPORTS
use Bivio::PetShop::Type::CreditCardMonth;
use Bivio::Type::Date;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Performs any startup initialization.

=cut

sub initialize {
    my($self) = @_;
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the expiration date onto the buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($date) = $source->get_widget_value($self->get('value'));
    my($month) = Bivio::PetShop::Type::CreditCardMonth->from_int(
	    Bivio::Type::Date->get_part($date, 'month'));
    $$buffer .= $month->get_short_desc
	    .'/'.Bivio::Type::Date->get_part($date, 'year');
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
