# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::ListAction;
use strict;
use Bivio::Base 'HTMLWidget.Link';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_TI) = b_use('Agent.TaskId');

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(class => 'list_action');

    if (! ref($self->get('href'))
	&& $_TI->is_valid_name($self->get('href'))) {
	$self->put_unless_exists(control => $self->get('href'));
	$self->put(href => URI({
	    query_type => $self->get('query_type'),
	    task_id => $self->get('href'),
	})) if $self->unsafe_get('query_type');
    }
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(value href ?query_type)], \@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($realm) = $self->render_simple_attr('realm', $source);
    
    if ($realm) {
	my(undef, @args) = @_;
	return $source->req->with_realm($realm, sub {
            return $self->SUPER::render(@args);
	});
    }
    return shift->SUPER::render(@_);
}

1;
