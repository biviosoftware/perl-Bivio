# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::WikiText;
use strict;
use Bivio::Base 'TestUnit.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new_unit {
    my($proto, $class_name, $args) = @_;
    my($create_params);
    $class_name = $proto->use('XHTMLWidget.WikiText');
    return $proto->SUPER::new_unit(
	$class_name,
	{
	    task_id => 'FORUM_WIKI_VIEW',
	    realm => 'fourem',
	    user => 'root',
	    class_name => $class_name,
	    create_object => sub {
		my($case, $params) = @_;
		$create_params = $params;
		return $class_name;
	    },
	    view_class_map => 'XHTMLWidget',
	    view_shortcuts => 'Bivio::UI::XHTML::ViewShortcuts',
	    compute_params => sub {
		my($p) = $create_params->[0];
		my($req) = b_use('Test.Request')->get_instance;
		return [{
		    ref($p) eq 'HASH' ? %$p : (value => $create_params->[0]),
		    req => $req,
		}];
	    },
	    method_to_test => 'render_html',
	    $args ? %$args : (),
	},
    );
}

sub wiki_uri_to_req {
    my($self, $name) = @_;
    return $self->builtin_req->put(uri => $self->builtin_req->format_uri({
	realm => 'fourem',
	task_id => 'FORUM_WIKI_VIEW',
	path_info => $name,
    }));
}

1;
