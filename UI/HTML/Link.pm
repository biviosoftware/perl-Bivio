# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Link;
use strict;
$Bivio::UI::HTML::Link::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::Link - a fancy iconic url link

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

use Bivio::UI::Renderer;
@Bivio::UI::HTML::Link::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Link> is a renderer for link icons on views.

=cut

=head1 CONSTANTS

=cut

=for html <a name="BACK_ICON"></a>

=head2 BACK_ICON : string

The string form of back.gif

=cut

sub BACK_ICON {
    return '"/i/back.gif" height=31 width=31 border=0';
}

=for html <a name="EMPTY_ICON"></a>

=head2 EMPTY_ICON : string

Returns the string form of the navigation place-holder.

=cut

sub EMPTY_ICON {
    return '"/i/dot.gif" height=31 width=31 border=0';
}

=for html <a name="NEXT_IA_ICON"></a>

=head2 NEXT_IA_ICON : string

Returns the string form of the next_ia.gif (inactive).

=cut

sub NEXT_IA_ICON {
    return '"/i/next_ia.gif" height=31 width=31 border=0';
}

=for html <a name="NEXT_ICON"></a>

=head2 NEXT_ICON : string

Returns the string form of the next.gif

=cut

sub NEXT_ICON {
    return '"/i/next.gif" height=31 width=31 border=0';
}

=for html <a name="PREV_IA_ICON"></a>

=head2 PREV_IA_ICON : string

Returns the string form of the prev_ia.gif (inactive).

=cut

sub PREV_IA_ICON {
    return '"/i/prev_ia.gif" height=31 width=31 border=0';
}

=for html <a name="PREV_ICON"></a>

=head2 PREV_ICON : string

Returns the string form of the prev.gif

=cut

sub PREV_ICON {
    return '"/i/prev.gif" height=31 width=31 border=0';
}

=for html <a name="SCROLL_DOWN_IA_ICON"></a>

=head2 SCROLL_DOWN_IA_ICON : string

Returns the string form of the scroll_down_ia.gif (inactive)

=cut

sub SCROLL_DOWN_IA_ICON {
    return '"/i/scroll_down_ia.gif" height=31 width=31 border=0';
}

=for html <a name="SCROLL_DOWN_ICON"></a>

=head2 SCROLL_DOWN_ICON : string

Return the string form of the scroll_down.gif

=cut

sub SCROLL_DOWN_ICON {
    return '"/i/scroll_down.gif" height=31 width=31 border=0';
}

=for html <a name="SCROLL_UP_IA_ICON"></a>

=head2 SCROLL_UP_IA_ICON : string

Returns the string form of the scroll_up_ia.gif (inactive).

=cut

sub SCROLL_UP_IA_ICON {
    return '"/i/scroll_up_ia.gif" height=31 width=31 border=0';
}

=for html <a name="SCROLL_UP_ICON"></a>

=head2 SCROLL_UP_ICON : string

Returns the string form of the scroll_up.gif

=cut

sub SCROLL_UP_ICON {
    return '"/i/scroll_up.gif" height=31 width=31 border=0';
}

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name, string icon, string url, string text, string description) : Bivio::UI::HTML::Link

Creates a link with the specified lookup name, icon, url, display text,
and hover discription.

=cut

sub new {
    my($proto, $name, $icon, $url, $text, $description) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	name => $name,
	icon => $icon,
	url => $url,
	text => $text,
	description => $description
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_name"></a>

=head2 get_name() : string

Returns the link's lookup name.

=cut

sub get_name {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{name};
}

=for html <a name="render"></a>

=head2 render(Model m, Request req)

Draws the link onto the request's output stream.

=cut

sub render {
    my($self, $model, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($url) = $fields->{url};
    my($icon) = $fields->{icon};
    my($description) = $fields->{description};
    my($text) = $fields->{text};

    if ($url) {
	$req->print('<a href="'.$url.'">');
    }
    if ($icon) {
	$req->print('<img src='.$icon.' alt="'.$description.'"><br>');
    }
    if ($text) {
	$req->print($text);
    }
    if ($url) {
	$req->print('</a>');
    }
}

=for html <a name="set_description"></a>

=head2 set_description(string description)

Sets the hover description for the link. (Alt text).

=cut

sub set_description {
    my($self, $description) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{description} = $description;
}

=for html <a name="set_icon"></a>

=head2 set_icon(string icon)

Sets the icon to a new value. A '' value will show now icon.

=cut

sub set_icon {
    my($self, $icon) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{icon} = $icon;
}

=for html <a name="set_text"></a>

=head2 set_text(string text)

Sets the display text for the link. A '' value will show no text.

=cut

sub set_text {
    my($self, $text) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{text} = $text;
}

=for html <a name="set_url"></a>

=head2 set_url(string url)

Sets the url link to a new value. A '' value will not link anywhere.

=cut

sub set_url {
    my($self, $url) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{url} = $url;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
