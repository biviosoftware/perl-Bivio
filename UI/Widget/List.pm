# Copyright (c) 2005-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Widget::List;
use strict;
$Bivio::UI::Widget::List::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::List::VERSION;

=head1 NAME

Bivio::UI::Widget::List - Renders a list model

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Widget::List;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Widget::List::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Widget::List>

=item empty_list_widget : Bivio::UI::Widget []

If set, the widget to display instead of the list when the
list_model is empty.

The I<source> will be the original source, not the list_model.

=cut

#=IMPORTS
use Bivio::UI::HTML::WidgetFactory;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes child widgets.

=cut

sub initialize {
    my($self) = @_;
    my($class) = Bivio::Biz::Model->get_instance($self->get('list_class'))
	->simple_package_name;
    my($name) = 0;
    $self->put(
	columns => [map({
	    $_  = ref($_) ? $_
		: Bivio::UI::HTML::WidgetFactory->create("$class.$_");
	    $self->initialize_value($name++, $_);
	    $_;
	} @{$self->get('columns')})],
    );
    $self->unsafe_initialize_attr('empty_list_widget');
    return;
}

=for html <a name="internal_as_string"></a>

=head2 static internal_as_string(any arg, ...) : any

Widget description.

=cut

sub internal_as_string {
    return shift->unsafe_get('list_class');
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $list_class, $columns, $attributes) = @_;
    return '"list_class" must be a defined scalar'
	unless defined($list_class) && !ref($list_class);
    return '"columns" must be an array_ref'
	unless ref($columns) eq 'ARRAY';
    return {
	list_class => $list_class,
	columns => $columns,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate
widget values.

=cut

sub render {
    my($self, $source, $buffer) = @_;

    my($list) = $source->get_request()
	->get('Model.' . $self->get('list_class'));

    # check for an empty list
    if ($list->get_result_set_size == 0
        && $self->unsafe_get('empty_list_widget')) {
	$self->unsafe_render_attr('empty_list_widget', $source, $buffer);
    }
    else {
	$list->do_rows(sub {
	    my($list) = @_;
	    my($name) = 0;
	    foreach my $c (@{$self->get('columns')}) {
		$self->render_value($name++, $c, $list, $buffer);
	    }
	    return 1;
	});
    }

    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
