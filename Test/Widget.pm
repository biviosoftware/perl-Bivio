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

sub run_unit {
    my($self, $cases) = @_;
    return $self->unit(
	$self->unsafe_get(qw(class_name setup_render compute_return new_params)),
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
    my($setup_render, $compute_return, $new_params) = @_;
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
	})->unit([map(
	    $i++ % 2 && ref($_) ne 'ARRAY' ? [render => [[] => $_]] : $_,
	    @$cases,
	)]);
    });
#TODO: Shouldn't be hardwired, can setup above.
    Bivio::UI::View->execute(\(<<"EOF"), $req);
view_class_map(q{@{[
    ref($self) && $self->unsafe_get('view_class_map') || 'HTMLWidget'
]}});
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

sub vs_new {
#TODO: Remove this after AUTOLOAD works
    shift;
    return Bivio::IO::ClassLoader->simple_require(
	'Bivio::UI::HTML::ViewShortcuts',
    )->vs_new(@_);
}

sub _is_render {
    return shift->get('method') eq 'render' ? 1 : 0;
}

1;
