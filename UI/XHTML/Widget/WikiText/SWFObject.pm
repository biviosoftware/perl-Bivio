# Copyright (c) 2008 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::SWFObject;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub handle_register {
    return ['b-swfobject'];
}

sub render_html {
    my($proto, $args) = @_;
    my($width) = _delete_or_default($args, 'width', 780);
    my($height) = _delete_or_default($args, 'height', 420);
    my($data) = _delete_or_default($args, 'data');
    Bivio::Die->die(
	$args->{attrs}, ': only accepts "height", "width", and',
        ' "data" attributes',
    ) if %{$args->{attrs}};
    Bivio::Die->die('requires "height", "width", and "data" attributes')
            unless defined($height) && defined($width) && defined($data);
    #http://code.google.com/p/swfobject/wiki/documentation
    return <<"EOF";
<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="$width" height="$height">
  <param name="movie" value="$data" />
  <!--[if !IE]>-->
  <object type="application/x-shockwave-flash" data="$data" width="$width" height="$height">
  <!--<![endif]-->
    <p>This content requires Flash. <a href="http://www.adobe.com/go/getflashplayer" target="_top">Please download the Flash Player.</a></p>
  <!--[if !IE]>-->
  </object>
  <!--<![endif]-->
</object>
EOF
}

sub _delete_or_default {
    my($args, $key, $default) = @_;
    return delete($args->{attrs}->{$key}) || $default;
}

1;
