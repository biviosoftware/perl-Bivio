# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::ListModel;
use strict;
use Bivio::Base 'Bivio::Test::Unit';
use Bivio::Biz::Model;
use Bivio::Test::Request;

# C<Bivio::Test::ListModel>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new {
    my($proto, $attrs) = @_;
    # Simple model name, which is loaded.  Sets up create_object and compute_return.
    # I<model> will get mapped to I<class_name>.
    my($model) = $attrs->{class_name};
    return $proto->SUPER::new({
	class_name => Bivio::Biz::Model->get_instance($model)->package_name,
	create_object => sub {
	    my(undef, $object) = @_;
	    return $object->[0]->new(Bivio::Test::Request->get_instance);
	},
	compute_return => sub {
	    my($case, $actual, $expect) = @_;
	    return $actual
		unless $case->get('method') =~ /^(?:(?:unauth_)?load|find_row_by)/
		&& ref($expect) eq 'ARRAY';
	    if (ref($expect->[0]) eq 'ARRAY' && @$expect == 1
		&& (!@{$expect->[0]} || ref($expect->[0]->[0]) eq 'HASH')) {
		Bivio::IO::Alert->warn(
		    $case,
		    ': has too many square brackets for the expect, unwrapping one level',
		);
		@$expect = @{$expect->[0]};
	    }
	    return $actual
		unless @$expect != 1 || ref($expect->[0]) eq 'HASH';
	    my($expect_copy) = [@$expect];
	    my($extract) = sub {
		my($row) = shift->get_shallow_copy;
		return {
		    map(
			($_ => $row->{$_}),
			keys(%{@$expect_copy == 1 ? $expect_copy->[0]
			    : shift(@$expect_copy) || {}}),
		    ),
		};
	    };
	    my($o) = $case->get('object');
	    return $case->get('method') =~ /^find_row_by/ ? [$extract->($o)]
		: $o->map_rows($extract);
	},
	%$attrs,
    });
}

sub new_unit {
    # Calls L<new|"new">.
    Bivio::Test::Request->get_instance;
    return shift;
}

sub run_unit {
    # Instantiates this class with I<model> or I<new_attrs> (which must include
    # I<model>), and calls the instance method form with I<method_groups>.
    #
    # Wraps I<method_groups> in an object group, with a call to the list model's,
    # new.  See L<Bivio::Test::unit|Bivio::Test/"unit"> for details.
    #
    # I<method_groups> are just like normal method groups with the exception that if
    # the expect is an array of hashes and the method begins with C<load>
    # or C<unauth_load)>, the actual return is the result of
    # L<Bivio::Biz::ListModel::map_rows|Bivio::Biz::ListModel/"map_rows">
    # filtered to only include the keys contained the first row of the expected
    # return.
    return shift->SUPER::run_unit(@_)
	if @_ == 3;
    my($self, $method_groups) = @_;
    return $self->SUPER::run_unit([
	$self->builtin_class => $method_groups,
    ]);
}

1;
