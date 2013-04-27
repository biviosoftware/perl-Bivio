# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::UICSS::ViewShortcuts;
use strict;
use Bivio::Base 'UICSS';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub vs_groupware_css {
    my($self) = @_;
    return Prose(<<'EOF');
td.header_left {
  background: Icon('logo'); left no-repeat;
  height: Icon(qw(logo height));px;
  width: Icon(qw(logo width));px;
}
td.header_left .logo_su .logo {
  text-align:left;
  display:block;
  height: Icon(qw(logo height));px;
  width: Icon(qw(logo width));px;
}
EOF
}

sub vs_petshop_css {
    my($self) = @_;
    return Prose(<<'EOF');
a:link, a:visited, a:hover, a:active {
  text-decoration: none;
  color: blue;
}
a:hover {
  text-decoration: underline;
}
input.submit, .button_link a {
  Color('header-background');
  Font('submit');
  cursor: pointer;
  Color('submit-border');
  padding: 0 1em;
  margin: 0;
}
.button_link a {
  text-decoration: none;
  border: 2px solid;
  border-left: 2px solid #eee;
  border-top: 2px solid #eee;
}
table.main {
  margin-top: 0;
}
div.main_body {
  margin-top: 0.5ex;
}
td.header_left {
  background: Icon('banner2'); left no-repeat;
  height: Icon(qw(banner2 height));px;
  width: Icon(qw(banner2 width));px;
}
td.header_left .logo_su .logo {
  text-align:left;
  display:block;
  height: Icon(qw(banner2 height));px;
  width: Icon(qw(banner2 width));px;
}
.header td {
  Color('header-background');
  padding: 1ex 1em 0 0;
}
div.pet_categories {
  Color('category-background');
  padding: 1ex 1em;
}
div.pet_content {
  text-align: center;
}
div.pet_content table {
  margin-left: auto;
  margin-right: auto;
}
div.pet_title {
  float: left;
  Font('title');
  margin-left: 1em;
  margin-right: -1em;
  width: 0;
  white-space: nowrap;
}
.pet_order td {
  padding: 1ex;
}
.pet_small_pad td {
  padding: 0.5ex;
}
EOF
}

1;
