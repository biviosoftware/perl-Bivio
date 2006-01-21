# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::ListModel;
use strict;
$Bivio::Test::ListModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::ListModel::VERSION;

=head1 NAME

Bivio::Test::ListModel - simplify testing of ListModels

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::ListModel;

=cut

=head1 EXTENDS

L<Bivio::Test>

=cut

use Bivio::Test::ModelBase;
@Bivio::Test::ListModel::ISA = ('Bivio::Test::ModelBase');

=head1 DESCRIPTION

C<Bivio::Test::ListModel>

=cut


#=IMPORTS
use Bivio::Biz::Model;
use Bivio::Test::Request;

#=VARIABLES


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string model) : Bivio::Test::ListModel

=head2 static new(hash_ref attrs) : Bivio::Test::ListModel

Simple model name, which is loaded.  Sets up create_object and compute_return.
I<model> will get mapped to I<class_name>.

=cut

sub new {
    my($proto, $attrs) = @_;
    my($model) = ref($attrs) ? delete($attrs->{model}) : $attrs;
    $attrs = {}
	unless ref($attrs);
    Bivio::Test::Request->get_instance();
    return $proto->SUPER::new({
	class_name => Bivio::Biz::Model->get_instance($model)->package_name,
	create_object => sub {
	    my(undef, $object) = @_;
	    return $object->[0]->new(Bivio::Test::Request->get_instance);
	},
	compute_return => sub {
	    my($case, $actual, $expect) = @_;
	    return $actual
		unless $case->get('method') =~ /^(?:unauth_)?load/
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
		unless @$expect != 1
		|| ref($expect->[0]) eq 'HASH' || !@$expect;
	    my($expect_copy) = [@$expect];
	    return $case->get('object')->map_rows(
		sub {
		    my($row) = shift->get_shallow_copy;
		    return {
			map(
			    ($_ => $row->{$_}),
			    keys(%{@$expect_copy == 1 ? $expect_copy->[0]
			        : shift(@$expect_copy)}),
			),
		    };
		},
	    );
	},
	%$attrs,
    });
}

=for html <a name="new_unit"></a>

=head2 new_unit(string class_name, hash_ref attrs) : self

Calls L<new|"new">.

=cut

sub new_unit {
    my($self, $class_name, $attrs) = @_;
    ($attrs ||= {})->{model} = $class_name;
    return $self->new($attrs);
}

=head1 METHODS

=cut

=for html <a name="unit"></a>

=head2 static unit(string model, array_ref method_groups)

=head2 static unit(hash_ref new_attrs, array_ref method_groups)

=head2 unit(array_ref method_groups)

Instantiates this class with I<model> or I<new_attrs> (which must include
I<model>), and calls the instance method form with I<method_groups>.

Wraps I<method_groups> in an object group, with a call to the list model's,
new.  See L<Bivio::Test::unit|Bivio::Test/"unit"> for details.

I<method_groups> are just like normal method groups with the exception that if
the expect is an array of hashes and the method begins with C<load>
or C<unauth_load)>, the actual return is the result of
L<Bivio::Biz::ListModel::map_rows|Bivio::Biz::ListModel/"map_rows">
filtered to only include the keys contained the first row of the expected
return.

=cut

sub unit {
    return shift->new(shift)->unit(shift)
	if @_ == 3;
    my($self, $method_groups) = @_;
    return $self->SUPER::unit([
	$self->get('class_name') => $method_groups,
    ]);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
