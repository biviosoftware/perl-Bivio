# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::Widget::OKButton;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

#TODO: derive these from the base button color
my($_COLORS) = {
    border => 0x1c74b3,
    border_top => 0x2c8ed1,
    border_bottom => 0x0d5b97,
    gradient_start => 0x37a3eb,
    gradient_end => 0x2181cf,
    hover_gradient_start => 0x3baaf4,
    hover_gradient_end => 0x2389dc,
};

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(value => Prose(<<"EOF"));
input.b_ok_button, .b_button_link a{
  Color('ok_button');
  border-color: vs_css_color($_COLORS->{border});;
  border-top-color: vs_css_color($_COLORS->{border_top});;
  border-bottom-color: vs_css_color($_COLORS->{border_bottom});;
  Gradient(@{[$_COLORS->{gradient_start}, ',', $_COLORS->{gradient_end}]});
  Shadow({
    box => '0 1px 0 #ddd,inset 0 1px 0 rgba(255,255,255,0.2)',
    text => 'rgba(0,0,0,0.2) 0 1px 0',
  });
}
input.b_ok_button:hover, .b_button_link a:hover{
  border-color: vs_css_color($_COLORS->{border});;
  border-top-color: vs_css_color($_COLORS->{border_top});;
  border-bottom-color: vs_css_color($_COLORS->{border_bottom});;
  Gradient(@{[$_COLORS->{hover_gradient_start}, ',', $_COLORS->{hover_gradient_end}]});
}
input.b_ok_button:active,.b_button_link a:active {
  border-color: vs_css_color($_COLORS->{border});;
  border-top-color: vs_css_color($_COLORS->{border_top});;
  border-bottom-color: vs_css_color($_COLORS->{border_bottom});;
  Gradient(@{[$_COLORS->{hover_gradient_start}, ',', $_COLORS->{hover_gradient_end}]});
}
input.b_ok_button:focus, .b_button_link a:focus {
  Shadow({
    box => '0 0 3px 1px #33a0e8,inset 0 0 3px 0 #35bff4',
  });
}
.b_button_link a:hover{
 text-decoration: none;
}
td.b_button_link {
 text-align: right;
}
EOF
    return;
}

1;
