# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::SearchForm;
use strict;
use Bivio::Base 'XHTMLWidget.Form';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TI) = __PACKAGE__->use('Agent.TaskId');

sub initialize {
    my($self) = @_;
    $self->map_invoke(put_unless_exists => [
	[action => $_TI->SEARCH_LIST],
	[form_class => 'SearchForm'],
	[value => sub {
	    return Join([
		Text({field => 'search', size => 30}),
		ImageFormButton(qw(ok_button magnifier go)),
	    ]);
	}],
	[class => 'search'],
    ]);
    return shift->SUPER::initialize(@_);
}

1;
