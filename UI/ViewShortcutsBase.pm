# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::ViewShortcutsBase;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

# C<Bivio::UI::ViewShortcutsBase> is subclassed by classes which implement view
# helper methods called from L<Bivio::UI::ViewLanguage|Bivio::UI::ViewLanguage>.
#
# The methods are available from views and
# L<Bivio::UI::Widget::Prose|Bivio::UI::Widget::Prose>.  All methods defined here
# must begin with C<vs_> (view shortcut) and be static.  This is enforced by this
# module.
#
# You may specify the shortcuts by
# L<Bivio::UI::ViewLanguage::view_shortcuts|Bivio::UI::ViewLanguage/"view_shortcuts">.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub new {
    # (proto) : undef
    # Dies.  You can't instantiate a ViewShortcut.
    Bivio::Die->die(
	"you can't instantiate a ViewShortcut; perhaps you meant vs_new()?");
    # DOES NOT RETURN
}

sub view_autoload {
    # (self, string, array_ref) : any
    # Called as last resort when the method doesn't match the
    # standard ViewLanguage patterns (vs_*, view_*, SomeWidget).
    my(undef, $method, $args) = @_;
    Bivio::Die->die("$method invalid view function, widget, or shortcut.");
    # DOES NOT RETURN
}

1;
