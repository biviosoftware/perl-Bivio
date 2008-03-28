# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::UserSettingsForm;
use strict;
use Bivio::Base 'XHTMLWidget.Link';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->map_invoke(put_unless_exists => [
	[value => sub {vs_text_as_prose('task_menu.title.USER_SETTINGS_FORM')}],
	[href => 'USER_SETTINGS_FORM'],
	[class => 'user_settings'],
	[control => ['user_state', '->eq_logged_in']],
    ]);
    return shift->SUPER::initialize(@_);
}

1;
