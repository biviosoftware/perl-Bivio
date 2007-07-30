# Copyright (c) 2003-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Widget;
use strict;
use Bivio::Base 'Bivio::Collection::Attributes';
use Bivio::UI::Widget::Join;
use Bivio::Test::Request;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($AUTOLOAD);

sub new_unit {
    my($proto, $class_name, $attrs) = @_;
    ($attrs ||= {})->{class_name} ||= $class_name;
    Bivio::Agent::Task->initialize;
    Bivio::Test::Request->setup_facade;
    return $proto->new($attrs);
}

sub prose {
    return shift->vs_new(Prose => @_);
}

sub run_unit {
    my($self, $cases) = @_;
    return $self->unit(
	$self->unsafe_get(qw(class_name setup_render compute_return new_params check_return)),
	$cases,
    );
}

sub unit {
    my($self) = shift;
    Bivio::Agent::Task->initialize;
    my($req) = Bivio::Test::Request->setup_facade;
    my($i) = 0;
    my($class_name) = shift;
    my($cases) = pop;
    my($setup_render, $compute_return, $new_params, $check_return) = @_;
    my($res);
    $req->put('Bivio::Test::Widget' => sub {
	$res = Bivio::Test->new({
	    create_object => sub {
		my($case, $params) = @_;
		return $case->get('class_name')->new(
		    @{$new_params ? $new_params->(@_) : $params}
		)->put_and_initialize(parent => undef);
	    },
	    class_name => $class_name,
	    compute_params => sub {
		my($case, $params) = @_;
		return $params
		    unless _is_render($case);
		$setup_render->($req, @_)
		    if $setup_render;
		my($x) = '';
		return [$req, \$x];
	    },
	    compute_return => sub {
		my($case, $actual) = splice(@_, 0, 2);
		return $actual
		    unless _is_render($case);
		$actual = [${$case->get('params')->[1]}];
		return $compute_return ? $compute_return->($case, $actual, @_)
		    : $actual;
	    },
	    $check_return ? (check_return => $check_return) : (),
	})->unit([map(
	    $i++ % 2 && ref($_) ne 'ARRAY' ? [render => [[] => $_]] : $_,
	    @$cases,
	)]);
    });
#TODO: Shouldn't be hardwired, can setup above.
    Bivio::UI::View->execute(\(<<"EOF"), $req);
view_class_map(q{@{[$self->view_class_map]}});
view_shortcuts('Bivio::UI::HTML::ViewShortcuts');
view_main(SimplePage([
    sub {
	shift->get_request->get('Bivio::Test::Widget')->();
	return '';
    },
]));
EOF
    return $res;
}

sub view_class_map {
    my($self) = @_;
    return ref($self) && $self->unsafe_get('view_class_map') || 'HTMLWidget';
}

sub vs_new {
#TODO: Remove this after AUTOLOAD works
    my($self, $class, @args) = @_;
    $class = Bivio::IO::ClassLoader->map_require($self->view_class_map, $class)
        unless $class =~ /::/;
    return $class->new(@args);
}

sub _is_render {
    return shift->get('method') eq 'render' ? 1 : 0;
}

1;
