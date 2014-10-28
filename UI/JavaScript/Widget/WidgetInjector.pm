# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::JavaScript::Widget::WidgetInjector;
use strict;
use Bivio::Base 'JavaScriptWidget.ControlBase';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_JS) = b_use('HTMLWidget.JavaScript');
my($_V) = b_use('UI.View');
my($_QV) = b_use('JavaScriptWidget.QuotedValue');
my($_PN) = b_use('Type.PerlName');
my($_NULL) = b_use('Bivio.TypeError')->NULL;
my($_QUERY_VALUE_KEY) = __PACKAGE__ . '.query_value';
my($_D) = b_use('Bivio.Die');

sub NEW_ARGS {
    return [qw(view_class view_name_prefix view_name_suffix)];
}

sub control_off_render {
    my($self, $source, $buffer) = @_;
    $$buffer .= $_JS->strip(<<'EOF');
function b_injection_callback(element_id, element_html, element_javascript) {
    document.getElementById(element_id).innerHTML = element_html;
    if (element_javascript) {
        var script_obj = document.createElement("script");
        script_obj.setAttribute("type", "text/javascript");
        script_obj.appendChild(document.createTextNode(element_javascript));
        document.getElementsByTagName("head").item(0).appendChild(script_obj);
    }
}
var b_scripts = document.getElementsByTagName("script");
var b_script_uri = b_scripts[b_scripts.length - 1].src;
var b_prev_onload = window.onload;
window.onload = function () {
    if (b_prev_onload) {
        b_prev_onload();
    }
    var elements = document.getElementsByTagName("body")[0].getElementsByTagName("*");
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
    var uri = b_script_uri + query;
    var script_obj = document.createElement("script");
    script_obj.setAttribute("type", "text/javascript");
    script_obj.setAttribute("src", uri);
    document.getElementsByTagName("head").item(0).appendChild(script_obj);
};
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
 		my($id, $v, $j) = _render_view($self, $_, $source);
 		(
 		    "b_injection_callback('$id', ",
 		    $_QV->escape_value($v), ', ',
		    $_QV->escape_value($j),
 		    ");\n",
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

sub _do_render_view {
    my($self, $name, $source) = @_;
    return ${$_V->render(
	$self->render_simple_attr('view_class', $source),
	$self->render_simple_attr('view_name_prefix', $source)
	    . '_'
	    . $name
	    . '_'
	    . $self->render_simple_attr(
	    'view_name_suffix', $source),
	$source,
    )};
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
	    my($javascript);
	    $_D->catch_quietly(sub {
		$javascript = _do_render_view(
		    $self, $name . '_javascript', $source);
	    });
	    return (
		$id,
		_do_render_view($self, $name, $source),
		$javascript || '',
	    );
	},
    );
}

1;
