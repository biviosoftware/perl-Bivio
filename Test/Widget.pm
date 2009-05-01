# Copyright (c) 2003-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Widget;
use strict;
use Bivio::Base 'TestUnit.Unit';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub new_unit {
    my($proto, $class_name, $args) = @_;
    ($args ||= {})->{class_name} ||= $class_name;
    $args->{view_pre_compile} ||= sub {};
    $args->{task_id} ||= 'SHELL_UTIL';
    $args->{realm} ||= undef;
    $args->{user} ||= undef;
    $args->{method_to_test} ||= 'render';
    $args->{view_class_map} ||= 'HTMLWidget';
    $args->{view_shortcuts} ||= 'Bivio::UI::XHTML::ViewShortcuts';
    my($req) = $proto->builtin_req->initialize_fully;
    $req->set_realm_and_user(@$args{qw(realm user)});
    $req->initialize_fully($args->{task_id});
    $args->{compute_params} ||= sub {
	my($case, $params) = @_;
	return $params
	    unless _is_render($case);
	$args->{setup_render}->($req, @_)
	    if $args->{setup_render};
	my($x) = '';
	return [$req, \$x];
    };
    $args->{create_object} ||= sub {
	my($case, $params) = @_;
	my($object) = $case->get('class_name')->new(
	    @{$args->{new_params} ? $args->{new_params}->(@_) : $params},
	);
	return !Bivio::UI::Widget->is_blessed($object) ? $object
	    : $object->initialize_with_parent(undef);
    };
    $args->{compute_return} ||= sub {
	my($case, $actual) = splice(@_, 0, 2);
	return $actual
	    unless _is_render($case);
	$actual = [${$case->get('params')->[1]}];
	$proto->builtin_assert_not_equals(qr{\w+\(0x\w+\)}, $actual->[0]);
	return !$args->{parse_return} ? $actual
	    : $args->{parse_return}->($case, $actual, @_);
    };
    my($self) = $proto->new($class_name);
    $self->[$_IDI] = $args;
    return $self;
}

sub prose {
    return shift->vs_new(Prose => @_);
}

sub run_unit {
    return shift->SUPER::run_unit(@_)
	if @_ == 3;
    my($self, $cases) = @_;
    my($fields) = $self->[$_IDI];
    my($req) = Bivio::Test::Request->get_instance;
    my($i) = 0;
    my($res);
    my($pkg) = __PACKAGE__;
    $req->put(
	"$pkg.view_pre_compile" => $fields->{view_pre_compile},
	$pkg => sub {
	    $res = Bivio::Test->new({
		map($fields->{$_} ? ($_ => $fields->{$_}) : (), qw(
		    class_name
		    create_object
		    compute_params
		    compute_return
		    check_return
		)),
	    })->unit([map(
		$i++ % 2 && ref($_) ne 'ARRAY'
		    ? [$fields->{method_to_test} => [[] => $_]] : $_,
		@$cases,
	    )]);
	},
    );
    Bivio::UI::View->execute(\(<<"EOF"), $req);
view_class_map(q{$fields->{view_class_map}});
view_shortcuts(q{$fields->{view_shortcuts}});
(sub {
    my(\$req) = Bivio::Test::Request->get_instance;
    \$req->get('$pkg.view_pre_compile')->(
        Bivio::UI::ViewLanguage->unsafe_get_eval,
        \$req,
    );
    return;
})->();
view_main(SimplePage([
    sub {
	shift->get_request->get('$pkg')->();
	return '';
    },
]));
EOF
    return $res;
}

sub vs_new {
    my($self, $class, @args) = @_;
    my($fields) = $self->[$_IDI];
    $class = Bivio::IO::ClassLoader->map_require(
	$fields->{view_class_map}, $class
    ) unless $class =~ /::/;
    return $class->new(@args);
}

sub _is_render {
    return shift->get('method') eq 'render' ? 1 : 0;
}

1;
