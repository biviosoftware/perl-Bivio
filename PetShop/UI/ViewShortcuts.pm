# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::PetShop::UI::ViewShortcuts;
use strict;
$Bivio::PetShop::UI::ViewShortcuts::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::UI::ViewShortcuts::VERSION;

=head1 NAME

Bivio::PetShop::UI::ViewShortcuts - view convenience methods

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::UI::ViewShortcuts;

=cut

=head1 EXTENDS

L<Bivio::UI::ViewShortcutsBase>

=cut

use Bivio::UI::ViewShortcutsBase;
@Bivio::PetShop::UI::ViewShortcuts::ISA = ('Bivio::UI::ViewShortcutsBase');

=head1 DESCRIPTION

C<Bivio::PetShop::UI::ViewShortcuts>

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::PetShop::Type::Category;
use Bivio::UI::HTML::Widget::FormField;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::Widget::Join;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="vs_address_fields"></a>

=head2 static vs_address_fields(string form_name, string address_suffix) : array

Returns the address fields.

=cut

sub vs_address_fields {
    my($proto, $form_name, $address_suffix) = @_;

    my($address) = $form_name.'.EntityAddress'.$address_suffix;

    # state/zip are shown on one line
    my($state_zip) = [
	Bivio::UI::HTML::Widget::FormField->new(
		$address.'.state')->get_label_and_field,
	$proto->vs_space(3),
	Bivio::UI::HTML::Widget::FormField->new(
		$address.'.zip')->get_label_and_field,
    ];
    $state_zip = [$state_zip->[0],
	Bivio::UI::HTML::Widget::Grid->new({
	    values => [
		[(@$state_zip)[1..4]],
	    ],
	}),
    ];

    return (
	    [Bivio::UI::HTML::Widget::FormField->new(
		    $address.'.addr1')->get_label_and_field],
	    [$proto->vs_space, Bivio::UI::HTML::Widget::FormField->new(
		    $address.'.addr2')],
	    [Bivio::UI::HTML::Widget::FormField->new(
		    $address.'.city')->get_label_and_field],
	    $state_zip,
	    [Bivio::UI::HTML::Widget::FormField->new(
		    $address.'.country')->get_label_and_field],
	    [Bivio::UI::HTML::Widget::FormField->new(
		    $form_name.'.EntityPhone'.$address_suffix.'.phone')
		    ->get_label_and_field],
	   );
}

=for html <a name="vs_product_uri"></a>

=head2 static vs_product_uri(any category) : href

Creates a widget value which returns a URI which points to the I<PRODUCT> task
for I<category>.  See
L<Bivio::PetShop::Type::Category|Bivio::PetShop::Type::Category>.

=cut

sub vs_product_uri {
    my($proto, $category) = @_;
    return [
	# format_uri only works on the request
	['->get_request'],
	'->format_uri', Bivio::Agent::TaskId->PRODUCTS, {
	    # Product task is a list of all products in a category.
	    # The category is the list's parent_id.
	    'ListQuery.parent_id' =>
	    Bivio::PetShop::Type::Category->unsafe_from_any($category)
	    ->get_name(),
	}, undef, undef];
}

=for html <a name="vs_space"></a>

=head2 vs_space() : Bivio::UI::Widget

Returns a widget which renders a single &nbsp; value.

=head2 vs_space(int count) : Bivio::UI::Widget

Returns a widget which renders a series of &nbsp; values.

=cut

sub vs_space {
    my($self, $count) = @_;
    $count ||= 1;
    return Bivio::UI::Widget::Join->new(['&nbsp;' x $count]);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
