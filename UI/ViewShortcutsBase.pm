# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::ViewShortcutsBase;
use strict;
$Bivio::UI::ViewShortcutsBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::ViewShortcutsBase::VERSION;

=head1 NAME

Bivio::UI::ViewShortcutsBase - site specific helper methods for templates and views

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::ViewShortcutsBase;

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::ViewShortcutsBase::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::ViewShortcutsBase> is subclassed by classes which implement view
helper methods called from L<Bivio::UI::ViewLanguage|Bivio::UI::ViewLanguage>.

The methods are available from views and
L<Bivio::UI::Widget::Prose|Bivio::UI::Widget::Prose>.  All methods defined here
must begin with C<vs_> (view shortcut) and be static.  This is enforced by this
module.

You may specify the shortcuts by
L<Bivio::UI::ViewLanguage::view_shortcuts|Bivio::UI::ViewLanguage/"view_shortcuts">.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;

