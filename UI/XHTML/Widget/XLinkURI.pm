# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::XLinkURI;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_TI) = b_use('Agent.TaskId');

sub NEW_ARGS {
    return [qw(facade_label)];
}

sub initialize {
    my($self) = @_;
    my($l) = $self->initialize_attr('facade_label');
    $self->initialize_attr(_uri =>
	$_TI->is_valid_name($l) ? URI({
	    task_id => $_TI->from_name($l),
	    query => undef,
	    path_info => undef,
	}) : [sub {
	    my($source) = @_;
	    my($req) = $self->req;
	    return URI(
		vs_constant(
		    $req,
		    $self->qualify_label(
			$self->render_simple_attr(facade_label => $req)),
	        ),
	    );
	}],
    );
    return;
}

sub qualify_label {
    my(undef, $label) = @_;
    return "xlink_$label";
}

sub render {
    shift->render_attr(_uri => @_);
    return;
}

1;
