# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ForumDropDown;
use strict;
use Bivio::Base 'XHTMLWidget.RealmDropDown';
use Bivio::UI::ViewLanguageAUTOLOAD;
my($_FORUM) = __PACKAGE__->use('Auth.RealmType')->FORUM;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub NEW_ARGS {
    return [];
}

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(realm_type => $_FORUM);
    return shift->SUPER::initialize(@_);
}

1;
