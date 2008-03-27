# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::FieldWidget;
use strict;
use Bivio::Base 'TestUnit.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_U) = __PACKAGE__->use('TestUnit.Unit');
my($_FTF) = __PACKAGE__->use('Model.FieldTestForm')->get_instance;

sub html_field_name {
    return shift->get('html_field_name');
}

sub new_unit {
    my($proto, $class_name, $args, @rest) = @_;
    $args ||= {};
    $args->{task_id} ||= 'FIELD_TEST_FORM';
    Bivio::Die->die($args, ': field not specified')
        unless $args->{field};
    my($self);
    $args->{new_params} = sub {_new_params($self, @_)};
    $self = $proto->SUPER::new_unit($class_name, $args, @rest);
    $self->put(
	field_name => $args->{field},
	html_field_name => $_FTF->get_field_name_for_html($args->{field}),
    );
    return $self;
}

sub _new_params {
    my($self, $req, $case, $params) = @_;
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

1;
