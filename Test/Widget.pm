# Copyright (c) 2003-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Widget;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';
use Bivio::Test::Request;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    my($req) = Bivio::Test::Request->initialize_fully;
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
	    : $object->put_and_initialize(parent => undef);
    };
    $args->{compute_return} ||= sub {
	my($case, $actual) = splice(@_, 0, 2);
	return $actual
	    unless _is_render($case);
	$actual = [${$case->get('params')->[1]}];
	return !$args->{parse_return} ? $actual
	    : $args->{parse_return}->($case, $actual, @_);
    };
    return $proto->new($args);
}

sub prose {
    return shift->vs_new(Prose => @_);
}

sub run_unit {
    my($self, $cases) = @_;
    return $self->unit($cases);
}

sub unit {
    my($self, $cases) = @_;
    # Must be same hash as above new_unit
    my($args) = $self->internal_get;
    my($req) = Bivio::Test::Request->get_instance;
    my($i) = 0;
    my($res);
    my($pkg) = __PACKAGE__;
    $req->put(
	"$pkg.view_pre_compile" => $args->{view_pre_compile},
	$pkg => sub {
	    $res = Bivio::Test->new({
		map($args->{$_} ? ($_ => $args->{$_}) : (), qw(
		    class_name
		    create_object
		    compute_params
		    compute_return
		    check_return
		)),
	    })->unit([map(
		$i++ % 2 && ref($_) ne 'ARRAY'
		    ? [$args->{method_to_test} => [[] => $_]] : $_,
		@$cases,
	    )]);
	},
    );
    Bivio::UI::View->execute(\(<<"EOF"), $req);
view_class_map(q{@{[$self->get('view_class_map')]}});
view_shortcuts(q{@{[$self->get('view_shortcuts')]}});
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
    $class = Bivio::IO::ClassLoader->map_require(
	$self->get('view_class_map'), $class
    ) unless $class =~ /::/;
    return $class->new(@args);
}

sub _is_render {
    return shift->get('method') eq 'render' ? 1 : 0;
}

1;
