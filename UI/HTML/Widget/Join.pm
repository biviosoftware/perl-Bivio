# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Join;
use strict;
$Bivio::UI::HTML::Widget::Join::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Join - renders a sequence of widgets and html

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Join;
    Bivio::UI::HTML::Widget::Join->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Join::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Join> is a sequence of widgets
and literal text (no escaping).

=head1 ATTRIBUTES

=over 4

=item values : array_ref (required)

The widgets and text which will be rendered as a part of the sequence.
The rendered values are unmodified.  If all the values are constant,
the result of this widget will be constant.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Join

Creates a new Join widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static inJoination.

=cut

sub initialize {
    my($self, $source) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{values};
    $fields->{values} = $self->get('values');
    $fields->{is_first_render} = 1;
    my($v);
    foreach $v (@{$fields->{values}}) {
	next unless ref($v);
	$v->put(parent => $self);
	$v->initialize;
    }
    return;
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Is this instance a constant?


=cut

sub is_constant {
    my($fields) = shift->{$_PACKAGE};
    Carp::croak('can only be called after first render')
		if $fields->{is_first_render};
    return $fields->{is_constant};
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= $fields->{value}, return if $fields->{is_constant};
    if ($fields->{is_first_render}) {
	my($buf) = '';
	$fields->{is_constant} = 1;
	for (my($i) = 0; $i < int(@{$fields->{values}}); $i++) {
	    my($v) = $fields->{values}->[$i];
	    if (ref($v)) {
		my($s) = '';
		$v->render($source, \$s);
		# Optimize case when some widgets are constant
		$v->is_constant ? ($fields->{values}->[$i] = $s)
			: ($fields->{is_constant} = 0);
		$buf .= $s;
	    }
	    else {
		$buf .= $v;
	    }
	}
	if ($fields->{is_constant}) {
	    $fields->{value} = $buf;
	    delete($fields->{values});
	}
	$$buffer .= $buf;
	$fields->{is_first_render} = 0;
    }
    else {
	my($v);
	foreach $v (@{$fields->{values}}) {
	    ref($v) ? $v->render($source, $buffer) : ($$buffer .= $v);
	}
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
