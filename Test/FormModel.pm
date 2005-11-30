# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::FormModel;
use strict;
$Bivio::Test::FormModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::FormModel::VERSION;

=head1 NAME

Bivio::Test::FormModel - 

=head1 RELEASE SCOPE

Bivio

=head1 SYNOPSIS

    use Bivio::Test::FormModel;

=cut

=head1 EXTENDS

L<Bivio::Test>

=cut

use Bivio::Test::ModelBase;
use Bivio::Test::Request;
@Bivio::Test::FormModel::ISA = ('Bivio::Test::ModelBase');

=head1 DESCRIPTION

C<Bivio::Test::FormModel>

=cut

#=IMPORTS

#=VARIABLES


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Test::FormModel

=cut

sub new {
    my($proto, $attrs) = @_;
    my($model) = ref($attrs) ? delete($attrs->{model}) : $attrs;
    $attrs = {}
	unless ref($attrs);
    my($req) = Bivio::Test::Request->get_instance();
    my($m) = Bivio::Biz::Model->get_instance($model);
    return $proto->SUPER::new({
	class_name => $m->package_name,
	create_object => sub {
	    my(undef, $object) = @_;
	    return $object->[0]->get_instance;
	},
	compute_params => sub {
	    my($case, $params, $method, $object) = @_;
	    return $params
		unless $method eq 'execute';
	    $req->put(task => Bivio::Collection::Attributes->new({
		form_model => ref($m),
		next => 'MY_SITE',
	    }));
	    unless (@$params) {
		$case->put('execute_empty' => 1);
		return [$req];
	    }
	    my($hash) = $params->[0];
	    return $params
		unless ref($hash) eq 'HASH';
	    return [$req->put(
		form => {
		    $m->VERSION_FIELD => $m->get_info('version'),
		    map(
			($m->get_field_name_for_html($_) => $m->get_field_type($_)
			     ->to_literal($hash->{$_})),
			keys(%$hash),
		    )},
	    )];
	},
	check_return => sub {
	    my($case, $actual, $expect) = @_;
	    return $expect
		unless $case->get('method') eq 'execute';
	    my($e) = $expect->[0];
	    return $expect
		unless ref($e) eq 'HASH' && @$expect == 1;
	    my($o) = $req->get($case->get('object')->package_name);
	    $e = _walk_tree_expect($case, $e);
	    if ($case->unsafe_get('execute_empty')) {
		$case->actual_return([
		    {map(($_ => $o->unsafe_get($_)), keys(%$e))}
		]);
	    }
	    elsif ($o->in_error) {
		$case->actual_return([
		    {map(($_ => $o->get_field_error($_) ?
			      $o->get_field_error($_)->get_name : undef),
			 keys(%$e))}
		]);
	    }
	    else {
		#confirm expected models are on request
		_walk_tree_actual($case, $e, []);
	    }
	    return $expect;
	},
	#TODO compute_return
	%$attrs,
    });
}

=head1 METHODS

=cut

=for html <a name="new_unit"></a>

=head2 new_unit(string class_name) : self

=cut

sub new_unit {
    Bivio::Test::Request->initialize_fully;
    return shift->SUPER::new_unit(@_);
}

#=PRIVATE SUBROUTINES

sub _walk_tree_actual {
    my($case, $e, $names) = @_;
    return ref($e) eq 'HASH'
	? {map(($_ => _walk_tree_actual($case, $e->{$_}, [@$names, $_])),
	       keys(%$e))}
	: Bivio::Test::Request->get_instance->get_nested(@$names);
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

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
