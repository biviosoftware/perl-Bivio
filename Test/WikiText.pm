# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::WikiText;
use strict;
use Bivio::Base 'Bivio::Test::Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new_unit {
    my($proto, $class_name, $args) = @_;
    my($new_params);
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
		$new_params = $params;
		return $class_name;
	    },
	    view_class_map => 'XHTMLWidget',
	    view_shortcuts => 'Bivio::UI::XHTML::ViewShortcuts',
	    compute_params => sub {
		my($p) = $new_params->[0];
		return [{
		    ref($p) eq 'HASH' ? %$p : (value => $new_params->[0]),
		    name => 'inline',
		    req => Bivio::Test::Request->get_instance,
		}];
	    },
	    method_to_test => 'render_html',
	    $args ? %$args : (),
	},
    );
}

1;
