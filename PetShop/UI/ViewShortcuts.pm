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
use Bivio::PetShop::Type::Category;
use Bivio::UI::HTML::Widget::FormFieldError;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::WidgetFactory;
use Bivio::UI::Text;
use Bivio::UI::Widget::Join;

#=VARIABLES
my($_WF) = 'Bivio::UI::HTML::WidgetFactory';

=head1 METHODS

=cut

=for html <a name="vs_address_fields"></a>

=head2 static vs_address_fields(string form_name, string address_suffix) : array

Returns the address fields.

=cut

sub vs_address_fields {
    my($proto, $form_name, $address_suffix) = @_;

    # state/zip are shown on one line
    my($state_zip) = [$proto->vs_form_field(
	    $form_name.'.EntityAddress'.$address_suffix.'.state'),
	$proto->vs_space(3),
	$proto->vs_form_field(
		$form_name.'.EntityAddress'.$address_suffix.'.zip'),
    ];
    $state_zip = [$state_zip->[0],
	Bivio::UI::HTML::Widget::Grid->new({
	    values => [
		[(@$state_zip)[1..4]],
	    ],
	}),
    ];

    return (
	    [$proto->vs_form_field(
		    $form_name.'.EntityAddress'.$address_suffix.'.addr1')],
	    [$proto->vs_form_field(
		    $form_name.'.EntityAddress'.$address_suffix.'.addr2', {
			label_on_field => 0,
		    })],
	    [$proto->vs_form_field(
		    $form_name.'.EntityAddress'.$address_suffix.'.city')],
	    $state_zip,
	    [$proto->vs_form_field(
		    $form_name.'.EntityAddress'.$address_suffix.'.country')],
	    [$proto->vs_form_field(
		    $form_name.'.EntityPhone'.$address_suffix.'.phone')],
	   );
}

=for html <a name="vs_form_field"></a>

=head2 vs_form_field(string name) : (Bivio::UI::HTML::Widget::String, Bivio::UI::Widget)

=head2 vs_form_field(string name, hash_ref attributes) : (Bivio::UI::HTML::Widget::String, Bivio::UI::Widget)

=head2 vs_form_field(string name, hash_ref attributes, array_ref row_control) : (Bivio::UI::HTML::Widget::String, Bivio::UI::Widget)

Returns the label/widget pair for the specified form field.

=cut

sub vs_form_field {
    my($proto, $name, $attributes, $row_control) = @_;

    my($model_name, $field_name) = $name =~ /^([^\.]+)\.(.+)$/;
    # strip out any suffix, not used for label lookup
    my($label_value) = $field_name;
    $label_value =~ s/_\d+(\.\w+)$/$1/;
    $label_value = [['->get_request'], 'Bivio::UI::Facade', 'Text',
	'->get_value', $label_value];

    my($label) = Bivio::UI::HTML::Widget::String->new({
	string_font => 'form_field_label',
	value => Bivio::UI::Widget::Join->new({
	    values => [
		Bivio::UI::HTML::Widget::String->new({
		    value => $label_value,
		}),
		': ',
	    ],
	}),
    });
    $label->put(row_control => $row_control)
	    if $row_control;

    my($widget) = $_WF->create($name, $attributes ? $attributes : ());
    return ($widget->get_or_default('label_on_field', 1)
	    ? $label : $proto->vs_space,
	    Bivio::UI::Widget::Join->new([
		Bivio::UI::HTML::Widget::FormFieldError->new({
		    field => $field_name,
		    label => $label_value,
		}),
		$widget,
	    ])
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
