# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::TableSummaryCell;
use strict;
$Bivio::UI::HTML::Widget::TableSummaryCell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::TableSummaryCell::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::TableSummaryCell - row summary cell for a table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::TableSummaryCell;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::AmountCell>

=cut

use Bivio::UI::HTML::Widget::AmountCell;
@Bivio::UI::HTML::Widget::TableSummaryCell::ISA = ('Bivio::UI::HTML::Widget::AmountCell');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::TableSummaryCell>

=head1 ATTRIBUTES

=over 4

=item list_class : string (required, inherited)

The list model class.

=item field : string (required)

The summary field.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::Format::Amount;
use Bivio::UI::HTML::Widget::AmountCell;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Startup initialization.

=cut

sub initialize {
    my($self) = @_;

    my($field_name) = $self->get('field');
    $self->put(field_name => $field_name);
    my($list) = Bivio::Biz::Model->get_instance(
	    $self->ancestral_get('list_class'));

    unless ($list->has_fields($field_name)) {
	$list = Bivio::Biz::Model->get_instance($list->get_list_class);
    }
    my($type) = $list->get_field_type($field_name);

    $self->put(decimals => $type->get_decimals)
	    unless $self->has_keys('decimals');

    $self->put(field => [['->get_request'], ref($self).$field_name]);

    $self->SUPER::initialize;
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Computes and displays the row summary value.

=cut

sub render {
    my($self, $source, $buffer) = @_;

    my($total) = 0;
    my($list) = $source->get_list_model;
    my($type) = $list->get_field_type($self->get('field_name'));
    $list->reset_cursor;

    while ($list->next_row) {
	$total = $type->add($total, $list->get($self->get('field_name')));
    }

    $source->get_request->put(ref($self).$self->get('field_name') => $total);
    $self->SUPER::render($source, $buffer);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
