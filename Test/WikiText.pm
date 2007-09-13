# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::WikiText;
use strict;
use Bivio::Base 'Bivio::Test::Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new_unit {
    my($proto, $class_name, $args) = @_;
    my($new_params);
    $class_name => $proto->use('Type.WikiText');
    return $proto->SUPER::new_unit(
	$class_name,
	{
	    task_id => 'FORUM_WIKI_VIEW',
	    realm => 'fourem',
	    user => 'root',
	    create_object => sub {
		my($case, $params) = @_;
		$new_params = $params;
		return $class_name;
	    },
	    compute_params => sub {
		return [{
		    value => $new_params->[0],
		    name => 'inline',
		    req => Bivio::Test::Request->get_instance,
		}];
	    },
	    method_to_test => 'render_html',
	    %$args,
	},
    );
}

1;
