# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::ABTest;
use strict;
use Bivio::Base 'Widget.Director';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_KEY) = 'b_abtest';
my($_DEFAULT);

sub choice_links {
    my($proto, @choices) = @_;
    return SPAN_b_abtest(
	Join([
	    map(
		Link(
		    $_,
		    URI({
			query => [
			    sub {
				my($source, $which) = @_;
				my($q) = $source->ureq('query') || {};
				$q->{$_KEY} = $which;
				return $q;
			    },
			    $_,
			],
		    }),
		    [
			sub {
			    my($source, $which) = @_;
			    return $which eq (shift->ureq(__PACKAGE__) || $_DEFAULT)
				? 'selected' : '';
			},
			$_,
		    ],
		),
		@choices,
	    ),
	]),
    );
}

sub global_init {
    my($proto, $default) = @_;
    b_die($default, ': default must be defined')
	unless defined($_DEFAULT = $default);
    b_use('Agent.Request')->register_handler($proto);
    b_use('Agent.Task')->register($proto);
    return;
}

sub handle_format_uri_named {
    my($proto, $named, $req) = @_;
    # NOTE: if $named->{uri} set, this won't work
    if (defined($named->{query})) {
	$named->{query} = b_use('AgentHTTP.Query')->parse($named->{query})
	    unless ref($named->{query});
    }
    $named->{query} = {}
	unless defined($named->{query});
    $named->{query}->{$_KEY} ||= $req->get_or_default(__PACKAGE__, $_DEFAULT);
    return;
}

sub handle_pre_execute_task {
    my($proto, undef, $req) = @_;
    my($v) = $req->ureq('query', $_KEY) || $_DEFAULT;
    $req->put_durable(__PACKAGE__, $v);
    return;
}

sub handle_server_redirect {
    return shift->handle_format_uri_named(@_);
}

sub hidden_form_field {
    return INPUT({
	NAME => $_KEY,
	VALUE => ['->ureq', __PACKAGE__],
	TYPE => 'hidden',
    });
}

sub internal_new_args {
    my(undef, @args) = @_;
    my($attrs) = ref($args[$#args]) eq 'HASH' ? pop(@args) : undef;
    my($default) = @args % 2 == 1 ? pop(@args) : ();
    return {
	control => ['->req', __PACKAGE__],
	values => {@args},
	default_value => $default || '',
	undef_value => '',
	($attrs ? %$attrs : ()),
    };
}

1;
