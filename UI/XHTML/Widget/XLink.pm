# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::XLink;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TI) = __PACKAGE__->use('Agent.TaskId');
my($_C) = b_use('IO.Config');

sub initialize {
    my($self) = @_;
    my($l) = $self->initialize_attr('facade_label');
    $self->put_unless_exists(
	tag => 'a',
	value => XLinkLabel($l),
	href => $_TI->is_valid_name($l) ? URI({
	    task_id => $_TI->from_name($l),
	    $_C->if_version(8 => sub {
	        return (
		    query => undef,
		    path_info => undef,
		);
	    }),
	}) : [sub {
		   my($source) = @_;
		   my($req) = $self->req;
		   return URI(
		       vs_constant(
			   $req,
			   'xlink_'
			   . $self->render_simple_attr(facade_label => $req),
		       ),
		   );
	       }],
	html_attrs => vs_html_attrs_merge([qw(href name link_target)]),
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(facade_label)], \@_);
}

1;
