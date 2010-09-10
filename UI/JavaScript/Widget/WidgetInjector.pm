# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::JavaScript::Widget::WidgetInjector;
use strict;
use Bivio::Base 'JavaScriptWidget.ControlBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_JS) = b_use('HTMLWidget.JavaScript');
my($_V) = b_use('UI.View');
my($_QV) = b_use('JavaScriptWidget.QuotedValue');
my($_PN) = b_use('Type.PerlName');
my($_NULL) = b_use('Bivio.TypeError')->NULL;
my($_QUERY_VALUE_KEY) = __PACKAGE__ . '.query_value';

sub NEW_ARGS {
    return [qw(view_class view_name_prefix view_name_suffix)];
}

sub control_off_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= $_JS->strip(<<'EOF');
(function () {
    var prev_onload = window.onload;
    window.onload = function () {
        if (prev_onload) {
            prev_onload();
        }
	var elements = document.getElementsByTagName("script");
	elements = document.getElementsByTagName("body")[0].getElementsByTagName("*");
	var query = '';
	var sep = '?';
	for (i = 0; i < elements.length; i++) {
	    var id = elements[i].id;
	    if (id && /^bivio_/.test(id)) {
		query = query + sep + escape(id) + '=';
		sep = '&';
	    }
	}
	if (!query) {
	    return;
	}
	var req = (function () {
	    try {return new XMLHttpRequest();} catch (e) {}
	    try {return new ActiveXObject("Msxml2.XMLHTTP.6.0");} catch (e) {}
	    try {return new ActiveXObject("Msxml2.XMLHTTP.3.0");} catch (e) {}
	    try {return new ActiveXObject("Msxml2.XMLHTTP");} catch (e) {}
	    return;
	})();
	if (!req) {
	    return;
	} 
	req.onreadystatechange = function () {
	    if (req.readyState == 4 && req.status == 200) {
		eval(req.responseText);
	    }
	    return;
	};
	var scripts = document.getElementsByTagName("script");
	var uri = scripts[scripts.length-1].src;
	req.open("GET", uri + query, true);
	req.send(null);
	return;
    };
})();
EOF
    return;
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($query) = $source->req('query');
    Join([
	map(
	    {
		$source->req->put($_QUERY_VALUE_KEY => $query->{$_});
		my($id, $v) = _render_view($self, $_, $source);
		(
		    'document.getElementById("',
		    $id,
		    '").innerHTML = ',
		    $_QV->escape_value($v),
		    ";\n",
		);
	    }
	    sort(keys(%$query)),
	),
    ])->initialize_and_render($source, $buffer);
    return;
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(control => [qw(->req query)]);
    $self->map_invoke(initialize_attr => $self->NEW_ARGS);
    return shift->SUPER::initialize(@_);
}

sub query_value {
    my(undef, $source) = @_;
    return $source->req($_QUERY_VALUE_KEY);
}

sub _render_view {
    my($self, $id, $source) = @_;
    my($req) = $source->req;
    return $req->with_attributes(
	{$req->REQUIRE_ABSOLUTE_GLOBAL => 1},
	sub {
	    my($name, $err) = $_PN->from_literal($id =~ m{^bivio_(.+)});
	    $source->req->throw_die(NOT_FOUND => {
		entity => $id,
		message => 'not a Type.PerlName: ' . ($err || $_NULL)->get_name,
	    }) unless $name;
	    return (
		$id,
		${$_V->render(
		    $self->render_simple_attr('view_class', $source),
		    $self->render_simple_attr('view_name_prefix', $source)
			. '_'
			. $name
			. '_'
			. $self->render_simple_attr('view_name_suffix', $source),
		    $source,
		)},
	    );
	},
    );
}

1;