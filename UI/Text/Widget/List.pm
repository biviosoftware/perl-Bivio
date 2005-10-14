# Copyright (c) 2005 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Text::Widget::List;
use strict;
$Bivio::UI::Text::Widget::List::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Text::Widget::List::VERSION;

=head1 NAME

Bivio::UI::Text::Widget::List - Renders a list model in text

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Text::Widget::List;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Text::Widget::List::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Text::Widget::List>

=cut

#=IMPORTS

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
    my($name) = 0;
    $self->initialize_attr('list_class');
    foreach my $v (@{$self->get('columns')}) {
	$self->initialize_value($name++, $v);
    }
    return;
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
    my($cols) = $self->get('columns');
    $source->get_request()->get(
	'Model.'
        . ${$self->render_attr('list_class', $source)},
    )->do_rows(
        sub {
	    my($list) = @_;
	    my($name) = 0;
	    foreach my $c (@$cols) {
		unless (ref($c)) {
		    $self->initialize_value(
		        $name,
		        $c = Bivio::UI::HTML::WidgetFactory->create(
		             $list->simple_package_name . ".$c",
		        ),
		    );
		}
		$self->render_value($name, $c, $list, $buffer);
		$name++;
	    }
	    return 1;
	},
    );
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
