# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::ViewShortcuts;
use strict;
$Bivio::UI::ViewShortcuts::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::ViewShortcuts::VERSION;

=head1 NAME

Bivio::UI::ViewShortcuts - common helper routines for Views and Widgets

=head1 SYNOPSIS

    use Bivio::UI::ViewShortcuts;

=cut

=head1 EXTENDS

L<Bivio::UI::ViewShortcutsBase>

=cut

use Bivio::UI::ViewShortcutsBase;
@Bivio::UI::ViewShortcuts::ISA = ('Bivio::UI::ViewShortcutsBase');

=head1 DESCRIPTION

C<Bivio::UI::ViewShortcuts> is a collection of common helper routines.  Typical
applications will subclass this class.

=cut

#=IMPORTS
use Bivio::UI::Text;
use Bivio::UI::HTML;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="vs_html"></a>

=head2 static vs_html(string attr) : array_ref

Returns a widget value to retrieve I<attr> using
L<Bivio::UI::HTML::get_value|Bivio::UI::HTML/"get_value">.

=cut

sub vs_html {
    my(undef, $attr) = @_;
    return [['->get_request'], 'Bivio::UI::Facade', 'HTML',
	'->get_value', $attr];
}

=for html <a name="vs_text"></a>

=head2 vs_text(string tag_part, ...) : array_ref

=head2 vs_text(array_ref tag_widget_value) : array_ref

Splits I<tag> and I<prefix>es into its base parts, checking for syntax.

=cut

sub vs_text {
    my($self, @tag) = @_;
    return [['->get_request'], 'Bivio::UI::Facade', 'Text', '->get_value',
	Bivio::UI::Text->join_tag(@tag)] if !ref($tag[0]);
    # Repackage tag_widget_value with Text as (dynamic) formatter.
    # The only way this works properly is if Bivio::UI::Text is a
    # static formatter (which looks up req_or_facade) from itself.
    return [@{$tag[0]}, 'Bivio::UI::Text'],
	    if ref($tag[0]) eq 'ARRAY';
    Bivio::Die->die(\@tag, ': tag must be a list of strings or array_ref');
    # DOES NOT RETURN
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
