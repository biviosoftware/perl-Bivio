# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::FieldWidget;
use strict;
use Bivio::Base 'TestUnit.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_U) = __PACKAGE__->use('TestUnit.Unit');
my($_FTF) = __PACKAGE__->use('Model.FieldTestForm')->get_instance;

sub new_unit {
    my($proto, $class_name, $args, @rest) = @_;
    $args ||= {};
    $args->{task_id} ||= 'FIELD_TEST_FORM';
    Bivio::Die->die($args, ': field not specified')
        unless $args->{field};
    Bivio::Die->die($args, ': field not a regexp')
        unless ref($args->{parse_return_regex}) eq 'Regexp';
    my($hn) = $_FTF->get_field_name_for_html($args->{field});
    my($re) = "$args->{parse_return_regex}";
    $re =~ s/\bHTML_NAME\b/$hn/g;
    my($self);
    $args->{new_params} = sub {_new_params($self, @_)};
    $args->{parse_return} = sub {_parse_return($self, @_)};
    $self = $proto->SUPER::new_unit($class_name, $args, @rest);
    $self->put(
	field_name => $args->{field},
	parse_return_regex => qr{$re},
    );
    return $self;
}

sub test_value_as_html {
    my($self) = @_;
    return sub {
	my($case) = $self->current_case();
	return [
	    $_FTF->get_field_type($self->get('field_name'))
	        ->to_html($case->get('object')->get('test_value')),
	];
    };
}

sub _new_params {
    my($self, $case, $params) = @_;
    my($p) = $params->[0];
    Bivio::Die->die($p, ': missing test_value')
        unless exists($p->{test_value});
    my($f) = $self->get('field_name');
    $self->builtin_model('FieldTestForm', {$f => $p->{test_value}});
    return [{
	form_class => $_FTF->package_name,
	form_model => [$_FTF->package_name],
	field => $f,
	%$p,
    }];
}

sub _parse_return {
    my($self, $case, $actual) = @_;
    $self->builtin_assert_equals(
	$self->get('parse_return_regex'),
	$actual->[0],
    );
    return [join(
	';',
	map(
	    defined($_) ? $_ : '',
	    $actual->[0] =~ $self->get('parse_return_regex'),
	),
    )];
}

1;
