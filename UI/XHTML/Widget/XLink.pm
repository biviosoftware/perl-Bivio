# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::XLink;
use strict;
use Bivio::Base 'HTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    my($l) = $self->get('facade_label');
    $self->put_unless_exists(
	tag => 'a',
	value => Prose(vs_text(xlink => $l)),
	href => Bivio::Agent::TaskId->is_valid_name($l) ? URI({
	    task_id => Bivio::Agent::TaskId->from_name($l),
	    query => undef,
	}) : [sub {
	    my($source, $uri) = @_;
	    my($b);
	    $self->initialize_value('uri', URI($uri))->render($source, \$b);
	    return $b;
	}, vs_constant([sub {"xlink_$_[1]"}, $l])],
#TODO: event_handler
#TODO: link_target
	html_attrs => vs_html_attrs_merge([qw(href name link_target)]),
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(facade_label)], \@_);
}

1;
