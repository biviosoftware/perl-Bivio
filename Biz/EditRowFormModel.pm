# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::EditRowFormModel;
use strict;
$Bivio::Biz::EditRowFormModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::EditRowFormModel::VERSION;

=head1 NAME

Bivio::Biz::EditRowFormModel - single row editor for list models

=head1 SYNOPSIS

    use Bivio::Biz::EditRowFormModel;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::EditRowFormModel::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::EditRowFormModel> single row editor for list models

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="copy_list_fields"></a>

=head2 copy_list_fields()

Copies the values of the selected row into the appropriate form
attributes. Does nothing if no row is selected.

=cut

sub copy_list_fields {
    my($self) = @_;

    return unless defined($self->get('selected_row'));

    my($list) = $self->get_list_model
	    ->set_cursor_or_die($self->get('selected_row'));

    foreach my $field (@{$self->get_keys}) {
	next unless $list->has_keys($field);
	$self->internal_put_field($field => $list->get($field));
    }

    $list->reset_cursor;
    return;
}

=for html <a name="get_list_field"></a>

=head2 get_list_field(string name) : string

Returns the value of the selected list row's field. Dies if no row has
been selected.

=cut

sub get_list_field {
    my($self, $name) = @_;
    die("no row selected") unless defined($self->get('selected_row'));

    return $self->get_list_model
	    ->set_cursor_or_die($self->get('selected_row'))
		    ->get($name);
}

=for html <a name="get_list_model"></a>

=head2 get_list_model() : Bivio::Biz::ListModel

Returns the list model used for data.

=cut

sub get_list_model {
    my($self) = @_;
    return $self->get_request->get($self->get_info('list_class'));
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

Subclasses must define the 'list_class' attribute.

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	hidden => [
	    {
		name => 'selected_row',
		type => 'Integer',
		constraint => 'NONE',
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
