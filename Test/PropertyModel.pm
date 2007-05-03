# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::PropertyModel;
use strict;
$Bivio::Test::PropertyModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::PropertyModel::VERSION;

=head1 NAME

Bivio::Test::PropertyModel - x

=head1 RELEASE SCOPE

Bivio

=head1 SYNOPSIS

    use Bivio::Test::PropertyModel;

=cut

=head1 EXTENDS

L<Bivio::Test>

=cut

@Bivio::Test::PropertyModel::ISA = ('Bivio::Test::Unit');

=head1 DESCRIPTION

C<Bivio::Test::PropertyModel>

=cut

#=IMPORTS
use Bivio::Test::Request;

#=VARIABLES
Bivio::Test::Request->initialize_fully;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Test::PropertyModel

=cut

sub new_unit {
    my($proto, $class, $attrs) = @_;
    $attrs = {}
	unless ref($attrs);
    my($m) = $class;
    return $proto->SUPER::new({
	class_name => $m->package_name,
	check_return => sub {
	    my($case, $actual, $expect) = @_;
	    return $expect
		unless $case->get('method') =~ /^(create|update|load)/;
	    my($e) = $expect->[0];
	    return $expect
		unless ref($e) eq 'HASH' && @$expect == 1;
	    my($o) = $case->get('object');
	    $e = _walk_tree_expect($case, $e);
	    $case->actual_return([_walk_tree_actual($case, $e, [])]);
	    return [$e];
	},
	%$attrs,
    });
}

=head1 METHODS

=cut

=for html <a name="unit"></a>

=head2 unit(array_ref case_group)

Example RealmMail.bunit.

=cut

sub run_unit {
    return shift->new(shift)->unit(shift)
	if @_ == 3;
    my($self, $method_groups) = @_;
    return $self->SUPER::run_unit([
	[Bivio::Test::Request->get_instance] => $method_groups,
    ]);
}

#=PRIVATE SUBROUTINES

sub _walk_tree_actual {
    my($case, $e, $names) = @_;
    my($o) = $case->get('object');
    return ref($e) eq 'HASH'
	? {map(($_ => _walk_tree_actual($case, $e->{$_}, [@$names, $_])),
	       keys(%$e))}
	: @$names == 1 && $o->has_fields($names->[0])
	? $o->get($names->[0])
	: Bivio::Test::Request->get_instance->unsafe_get_nested(@$names);
}

sub _walk_tree_expect {
    my($case, $e) = @_;
    return ref($e) eq 'HASH'
	? {map(($_ => _walk_tree_expect($case, $e->{$_})), keys(%$e))}
	: ref($e) eq 'CODE'
	    ? $e->($case)
	    : $e;
}

=head1 COPYRIGHT

Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
