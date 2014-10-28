# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::UICSS::ViewShortcuts;
use strict;
use Bivio::Base 'UICSS';
use Bivio::UI::ViewLanguageAUTOLOAD;


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
form input, form textarea, form select {
  padding: 5px;
}
td.label {
  padding-top: 3px;
}
a:link, a:visited, a:hover, a:active {
  text-decoration: none;
  color: blue;
}
a:hover {
  text-decoration: underline;
}
table.main {
  margin-top: 0;
}
div.main_body {
  margin-top: 0.5ex;
}
td.header_left {
  background: Icon('paw_logo'); left no-repeat;
  height: Icon(qw(paw_logo height));px;
  width: Icon(qw(paw_logo width));px;
}
td.header_left .logo_su .logo {
  text-align:left;
  display:block;
  height: Icon(qw(banner2 height));px;
  width: Icon(qw(banner2 width));px;
}
td.header_left a.logo {
  padding-left: Icon(qw(paw_logo width));px;
  margin-left: 1em;
}
.logo_title {
  font-size: 200%;
  font-weight: bold;
  ShadowAttr({
    text => 'rgba(0,0,0,0.2) 3px 3px 2px',
  });
}
.logo_demo {
  margin-left: 1em;
}
.header td {
  padding: 1ex 1em 0 0;
}
div.pet_categories {
  Color('category-background');
  padding: 1ex 1em;
  BorderAttr({
    radius => '10px',
  });
  ShadowAttr({
    box => '0 0 3px 1px #82cffa,inset 0 0 3px 0 #f0f9ff',
  });
  width: 80%;
}
div.pet_content {
  text-align: center;
  padding-top: 1ex;
  padding-left: 1em;
  padding-bottom: 2ex;
}
div.pet_content table.list, div.pet_content table.simple, table.pet_order {
  margin-left: auto;
  margin-right: auto;
}
div.pet_title {
  Font('title');
  text-align: left;
  white-space: nowrap;
}
.pet_heading {
  font-weight: bold;
  font-size: 120%;
}
.pet_order td {
  padding: 1ex;
}
.pet_small_pad td {
  padding: 0.5ex;
}
a.pet_category_link img {
  vertical-align: middle;
  Opacity('0.70');
}
a.pet_category_link:hover img {
  Opacity(1);
}
form .err_title {
 display: none;
}
EOF
}

1;
