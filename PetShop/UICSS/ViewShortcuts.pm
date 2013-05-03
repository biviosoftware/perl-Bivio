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
input.submit, .button_link a{
 -webkit-border-radius:3px;
 -moz-border-radius:3px;
 -ms-border-radius:3px;
 -o-border-radius:3px;
 border-radius:3px;
 text-align:center;
 padding:2px 10px;
 font-size:13px;
 font-weight:600;
 cursor:pointer;
 overflow:visible;
}
input.submit {
 color:#777;
 border:1px solid #b1b1b1;
 border-top-color:#bfbfbf;
 border-bottom-color:#aaa;
 background:#e4e4e4;
 filter:progid:DXImageTransform.Microsoft.gradient<(>startColorstr="#fbfbfb", endColorstr="#e4e4e4");
 background:-webkit-gradient<(>linear, left top, left bottom, from<(>#fbfbfb), to<(>#e4e4e4));
 background:-moz-linear-gradient<(>top, #fbfbfb, #e4e4e4);
 -moz-box-shadow:0 1px 0px #efefef,inset 0 1px 0px #fff;
 -webkit-box-shadow:0 1px 0px #efefef,inset 0 1px 0px #fff;
 box-shadow:0 1px 0px #efefef,inset 0 1px 0px #fff;
 text-shadow:#fff 0 1px 0;
 -webkit-text-shadow:#fff 0 1px 0;
 -moz-text-shadow:#fff 0 1px 0;
}
input.submit:hover {
 border:1px solid #999;
 border-top-color:#bfbfbf;
 border-bottom-color:#888;
 background:#efefef;
 filter:progid:DXImageTransform.Microsoft.gradient<(>startColorstr="#fefefe", endColorstr="#efefef");
 background:-webkit-gradient<(>linear, left top, left bottom, from<(>#fefefe), to<(>#efefef));
 background:-moz-linear-gradient<(>top, #fefefe, #efefef);
}
input.submit:active {
 border:1px solid #999;
 border-top-color:#aaa;
 border-bottom-color:#888;
 -moz-box-shadow:0 1px 0px #fff,inset 0 1px 3px rgba<(>101,101,101,0.2);
 -webkit-box-shadow:0 1px 0px #fff,inset 0 1px 3px rgba<(>101,101,101,0.2);
 box-shadow:0 1px 0px #fff,inset 0 1px 3px rgba<(>101,101,101,0.2);
}

.standard_submit input.submit, .button_link a{
 color:#fff;
 padding:5px 16px;
 border:1px solid #1c74b3;
 border-top-color:#2c8ed1;
 border-bottom-color:#0d5b97;
 background:#2181cf;
 filter:progid:DXImageTransform.Microsoft.gradient<(>startColorstr="#37a3eb", endColorstr="#2181cf");
 background:-webkit-gradient<(>linear, left top, left bottom, from<(>#37a3eb), to<(>#2181cf));
 background:-moz-linear-gradient<(>top, #37a3eb, #2181cf);
 -moz-box-shadow:0 1px 0 #ddd,inset 0 1px 0 rgba<(>255,255,255,0.2);
 -webkit-box-shadow:0 1px 0 #ddd,inset 0 1px 0 rgba<(>255,255,255,0.2);
 box-shadow:0 1px 0 #ddd,inset 0 1px 0 rgba<(>255,255,255,0.2);
 text-shadow:rgba<(>0,0,0,0.2) 0 1px 0;
 -webkit-text-shadow:rgba<(>0,0,0,0.2) 0 1px 0;
 -moz-text-shadow:rgba<(>0,0,0,0.2) 0 1px 0;
}
.standard_submit input.submit:hover, .button_link a:hover{
 border:1px solid #1c74b3;
 border-top-color:#2c8ed1;
 border-bottom-color:#0d5b97;
 background:#2389dc;
 filter:progid:DXImageTransform.Microsoft.gradient<(>startColorstr="#3baaf4", endColorstr="#2389dc");
 background:-webkit-gradient<(>linear, left top, left bottom, from<(>#3baaf4), to<(>#2389dc));
 background:-moz-linear-gradient<(>top, #3baaf4, #2389dc);
}
.button_link a:hover{
 text-decoration: none;
}
td.button_link {
 text-align: right;
}
.standard_submit input.submit:active, .button_link a:active {
 border:1px solid #1c74b3;
 border-bottom-color:#0d5b97;
 background:#2181cf;
 filter:progid:DXImageTransform.Microsoft.gradient<(>startColorstr="#37a3eb", endColorstr="#2181cf");
 background:-webkit-gradient<(>linear, left top, left bottom, from<(>#37a3eb), to<(>#2181cf));
 background:-moz-linear-gradient<(>top, #37a3eb, #2181cf);
 -moz-box-shadow:0 1px 0 #fff,inset 0 1px 3px rgba<(>101,101,101,0.3);
 -webkit-box-shadow:0 1px 0 #fff,inset 0 1px 3px rgba<(>101,101,101,0.3);
 box-shadow:0 1px 0 #fff,inset 0 1px 3px rgba<(>101,101,101,0.3);
}
.standard_submit input.submit:focus, .button_link a:focus {
 -moz-box-shadow:0 0 3px 1px #33a0e8,inset 0 0 3px 0 #35bff4;
 -webkit-box-shadow:0 0 3px 1px #33a0e8,inset 0 0 3px 0 #35bff4;
 box-shadow:0 0 3px 1px #33a0e8,inset 0 0 3px 0 #35bff4;
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

form table.label_group {
  margin-right: 0;
  margin-left: auto;
  max-width: 25em;
  min-width: 20em;
}
form div.error_bubble {
 font-size: 95%;
 -webkit-border-radius:3px;
 -moz-border-radius:3px;
 -ms-border-radius:3px;
 -o-border-radius:3px;
 border-radius:3px;
 padding: 0.5ex 0.5em;
 background-color:#fff4f4;
 border:1px solid #d58a8a;
 margin: 2px 0;
}
form .field_err {
 width: auto;
}
form div.error_arrow_holder {
 position: relative;
 margin-right: 1em;
}
form span.error_arrow_border{
 border-color:transparent transparent transparent #d58a8a;
 border-style:solid;
 border-width:6px;
 font-size: 0;
 position: absolute;
 top: -6px;
}
form span.error_arrow{
 border-color:transparent transparent transparent #fff4f4;
 border-style:solid;
 border-width:6px;
 font-size: 0;
 position: absolute;
 top: -6px;
 right: -10px;
}
td.error_arrow {
 padding-top: 2ex;
 vertical-align: top;
}
form input, form textarea, form select{
 -webkit-border-radius:3px;
 -moz-border-radius:3px;
 -ms-border-radius:3px;
 -o-border-radius:3px;
 border-radius:3px;
 -moz-box-shadow:0 0 0 #000,
 inset 0px 3px 3px #eee;
 -webkit-box-shadow:0 0 0 #000,
 inset 0px 3px 3px #eee;
 box-shadow:0 0 0 #000,
 inset 0px 3px 3px #eee;
 border:1px solid #bfbfbf;
 padding:5px
}
form input:hover, form textarea:hover, form select:hover{
 border:1px solid #a0a0a0
}
form input:focus, form textarea:focus, form select:focus{
 border:1px solid #a0a0a0
}
.standard_submit, form .submit {
 text-align: right;
}
form .err_title {
 display: none;
}

table.list tr.b_heading_row, table.paged_list tr.b_heading_row  {
 -moz-box-shadow:0 1px 1px rgba<(>0,0,0,0.12),inset 0 0 0 #000;
 -webkit-box-shadow:0 1px 1px rgba<(>0,0,0,0.12),inset 0 0 0 #000;
 box-shadow:0 1px 1px rgba<(>0,0,0,0.12),inset 0 0 0 #000;
 border-top:1px solid #82cffa;
 border-bottom:1px solid #96c4ea;
 border-left:1px solid #e7f2fb;
 border-right:1px solid #e7f2fb;
 background:#f0f9ff;
}
table.list th b, table.paged_list th b {
 font-weight: normal;
}
table.list tr, table.paged_list tr {
  border:1px solid #edf1f5;
  border-width:1px 0;
}
table.list .b_even_row, table.paged_list .b_even_row  {
 background-color: transparent;
}

div.pet_categories {
  Color('category-background');
  padding: 1ex 1em;
}
div.pet_content {
  text-align: center;
}
div.pet_content table.list {
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
