# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeComponent::WidgetSubstitute;
use strict;
use Bivio::Base 'FacadeComponent.Constant';
b_use('IO.ClassLoaderAUTOLOAD');

my($_V) = b_use('UI.View');
my($_F) = b_use('UI.Facade');
my($_IDI) = __PACKAGE__->instance_data_index;

sub REGISTER_PREREQUISITES {
    return ['Constant'];
}

sub get_widget_substitute_value {
    my($proto, $widget, $source) = @_;
#    my($v) = $_V->unsafe_get_current;
    return undef
	unless my $facade = $_F->unsafe_get_from_source($source);
    my($map) = $proto->get_from_facade($facade)->[$_IDI];
    foreach my $n (
	$widget->b_widget_label,
	$widget->simple_package_name,
	$source->req('task_id')->get_name,
    ) {
	last
	    unless defined(my $m = $map->{lc($n)});
	return $m
	    unless ref($m);
	$map = $m;
    }
    return $map->{''} && $map->{''}->{value};
}

sub initialization_complete {
    my($self) = @_;
    my($map) = $self->[$_IDI] = {};
    foreach my $v (@{$self->internal_get_all}) {
	foreach my $n (@{$v->{names} || []}) {
	    my($l, $w, $t) = reverse(_split_label($self, $n));
	    ((($map->{$l} ||= {})->{$w || ''} ||= {})->{$t || ''}) = $v;
	}
    }
    return shift->SUPER::initialization_complete(@_);
}

sub make_facade_decl {
    my($proto, $value) = @_;
    return ($proto->simple_package_name => [map(
	{
	    my($v) = pop(@$_);
	    [_assert_label(@$_) => $v];
	}
	@$value,
    )]);
}

sub _assert_label {
    my($l) = _label(@_);
    b_die($l, ': must always have a label value')
	unless $l =~ /\blabel_\w+$/;
    return $l;
}

sub _join {
    return join(
	'.',
	map(
	    {
		my($x) = $_;
		$x =~ s/_View\./_/;
		$x =~ s/\W/_/g;
		$x;
	    }
	    @_,
	),
    );
}

sub _label {
#    my($prefixes) = [qw(task_ view_ widget_ label_)];
    my($prefixes) = [qw(task_ widget_ label_)];
    return _join(
	reverse(
	    map(
		pop(@$prefixes) . $_,
		reverse(@_),
	    ),
	),
    );
}

sub _split_label {
    my($self, $tag) = @_;
    return map((/^[a-z]+_(.*)/)[0], @{$self->split_tag($tag)});
}

1;
