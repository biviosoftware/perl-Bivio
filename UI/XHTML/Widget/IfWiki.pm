# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::IfWiki;
use strict;
use Bivio::Base 'XHTMLWidget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(page_regexp control_on_value ?control_off_value)];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	realm_id => vs_constant('site_realm_id'),
	control => [sub {
	    my($source) = @_;
	    my($t, $a, $p) = map(
		$_ || '',
		$source->req->unsafe_get(qw(task_id auth_id path_info)));
	    my($pr) = $self->render_simple_attr(page_regexp => $source);
	    return $t->get_name =~ /WIKI_VIEW/
		&& $a eq $self->render_simple_attr(realm_id => $source)
	        && $p =~ qr{^$pr$}is
	        ? 1 : 0;
	}],
    );
    $self->initialize_attr(qw(page_regexp realm_id));
    return shift->SUPER::initialize(@_);
}

1;
