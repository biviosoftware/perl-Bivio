# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::Widget::Button;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

#TODO: derive these from the base button color
my($_COLORS) = {
    border => 0xb1b1b1,
    border_top => 0xbfbfbf,
    border_bottom => 0xaaaaaa,
    gradient_start => 0xfbfbfb,
    gradient_end => 0xe4e4e4,
    hover_border => 0x999999,
    hover_border_top => 0xbfbfbf,
    hover_border_bottom => 0x888888,
    hover_gradient_start => 0xfefefe,
    hover_gradient_end => 0xefefef,
    active_border =>  0x999999,
    active_border_top => 0xaaaaaa,
    active_border_bottom => 0x888888,
};

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(value => Prose(<<"EOF"));
input.submit, .b_button_link a{
  border: 1px solid;
  Border({
    radius => '3px',
  });
  text-align:center;
  padding:5px 16px;
  font-size:13px;
  font-weight:600;
  cursor:pointer;
  overflow:visible;
}
input.submit {
  border: 1px solid;
  Color('submit');
  border-color: vs_css_color($_COLORS->{border});;
  border-top-color: vs_css_color($_COLORS->{border_top});;
  border-bottom-color: vs_css_color($_COLORS->{border_bottom});;
  Gradient(@{[$_COLORS->{gradient_start}, ',', $_COLORS->{gradient_end}]});
  Shadow({
    box => '0 1px 0px #efefef,inset 0 1px 0px #fff',
    text => '#fff 0 1px 0',
  });
}
input.submit:hover {
  border-color: vs_css_color($_COLORS->{hover_border});;
  border-top-color: vs_css_color($_COLORS->{hover_border_top});;
  border-bottom-color: vs_css_color($_COLORS->{hover_border_bottom});;
  Gradient(@{[$_COLORS->{hover_gradient_start}, ',', $_COLORS->{hover_gradient_end}]});
}
input.submit:active {
  border-color: vs_css_color($_COLORS->{active_border});;
  border-top-color: vs_css_color($_COLORS->{active_border_top});;
  border-bottom-color: vs_css_color($_COLORS->{active_border_bottom});;
  Shadow({
    box => '0 1px 0 #fff,inset 0 1px 3px rgba(101,101,101,0.3)',
  });
}
EOF
    return;
}

1;
