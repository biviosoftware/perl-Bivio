# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::CSS;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SITE) = join('', map({
    my($x) = \&{"_site_$_"};
    defined(&$x) ? $x->() : '';
} @{__PACKAGE__->use('Agent.TaskId')->included_components}));

sub internal_site_css {
    return $_SITE;
}

sub site_css {
    my($self) = @_;
    return $self->internal_body(Prose([sub {$self->internal_site_css}]));
}

sub _site_base {
    return <<"EOF";
/* Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved. */
blockquote, body, dd, div, dl, dt, fieldset, form, h1, h2, h3, h4,
h5, h6, input, li, ol, p, pre, td, textarea, th, ul {
  margin: 0;
  padding: 0;
  text-align: left;
@{[_v4(q{
  Font('normal');
  Font('body');
})]}
}
address, caption, cite, code, dfn, em, h1, h2, h3, h4, h5, h6, strong, th, var {
  Font('normal');
@{[_v4(q{
  Font('body');
})]}
}
ol, ul {
  margin-left: 2.5em;
}
ol {
  list-style-type: decimal;
}
ul {
  list-style-type: disc;
}
ul.none, ol.none {
  list-style-type: none;
}
abbr, acronym, fieldset, iframe, img, table {
  border-style: none;
  border: 0;
@{[_v4(q{
  Font('normal');
  Font('body');
})]}
}
a {
  Font('a_link');
}
a:hover {
  Font('a_hover');
}
body {
  Font('body');
  Color('body-background');
  margin: .5em;
  min-width: 50em;
}
caption, th {
  text-align: center;
}
code {
  Font('code');
}
em {
  Font('em');
}
h1, h2, h3, h4, h5, h6 {
  margin: 1ex 0 .5ex 0;
}
h1 {
  Font('h1');
}
h2 {
  Font('h2');
}
h3 {
  Font('h3');
}
h4 {
  Font('h4');
}
strong {
  Font('strong');
}
pre {
  line-height: 60%;
}
table {
  border-collapse: collapse;
  border-spacing: 0;
  margin: left;
}
th {
  padding: .5em;
}
th, th>a:link, th>a:visited, th>a:active, th>a:hover {
  Font('th');
}
.acknowledgement {
  margin: auto;
  text-align: center;
  margin-bottom: 2ex;
}
.acknowledgement .text {
  border: 2px solid;
  Color('acknowledgement-border');
  padding: .5em;
  text-align: center;
}
.trailer {
  margin: 1ex 0;
}
input.checkbox {
  padding: 0;
  margin: 0;
}
form .check {
  padding-left: .5em;
}
.acknowledgement, .err_title, .field_err, form .desc {
  width: 30em;
}
form .desc, .byline, .msg .forward {
  margin: .1em 0 0 0;
  font-size: 85%;
  Color('form_desc');
}
form table.simple {
  text-align: center;
}
form table.simple td.field  {
  text-align: left;
}
.field_err, .label_err, .err_title, .err {
  Color('err');
  vertical-align: top;
}
form .err, form .err_title {
  Font('form_err');
}
form .err_title {
  margin-bottom: 1ex;
}
form .field_err {
  Font('form_field_err');
}
form .label_ok, form .label_err, form .field {
  padding-bottom: 1em;
}
form .footer {
  Font('form_footer');
  margin-bottom: 1.0em;
}
form .label_ok, form .label_err, form .label {
  text-align: right;
  padding-right: .2em;
}
form .label_ok {
  Font('form_label_ok');
}
.label_err {
  vertical-align: middle;
  Font('form_label_err');
}
.list td, .paged_list td {
  padding: .5em;
}
.form_prose, .list_prose, .paged_list .empty {
  text-align: left;
  width: 40em;
  padding-bottom: .5ex;
}
table.header,
table.footer,
table.main {
  width: 100%;
  margin: auto;
}
table.main {
  margin-top: 1em;
  margin-bottom: 1em;
}
td.main_left, td.main_middle, td.main_right {
  vertical-align: top;
}
table.header {
  padding-bottom: 1ex;
}
table.footer {
  Font('footer');
  padding-bottom: 7ex;
  text-align: center;
}
td.header_left a.su {
  Color('header_su-background');
  Font('header_su');
  overflow: hidden;
  display: block;
  text-align: center;
  white-space: normal;
  vertical-align: middle;
}
td.header_left {
  background: Icon('logo'); left no-repeat;
  height: Icon(qw(logo height));px;
  width: Icon(qw(logo width));px;
}
td.header_left .logo_su .logo {
  text-align: left;
  display: block;
  height: Icon(qw(logo height));px;
  width: Icon(qw(logo width));px;
}
td.header_left .logo_su a.logo:hover {
  text-decoration: none;
}
td.header_right {
  width: 30%;
  text-align: right;
}
td.header_middle {
  width: 40%;
  text-align: center;
}
td.header_right {
  vertical-align: top;
  text-align: right;
}
td.footer_left {
  width: 30%;
}
td.footer_right {
  width: 30%;
  text-align: right;
}
td.footer_middle {
  width: 40%;
  vertical-align: top;
  text-align: center;
}
td.header_middle {
  vertical-align: top;
}
td.header_middle div.nav div.task_menu {
  Font('nav');
  text-align: center;
}
td.header_right {
  vertical-align: top;
  text-align: right;
}
div.main_bottom, div.main_top, div.main_body {
  float: left;
  clear: both;
  width: 100%;
}
div.main_top {
  text-align: right;
}
div.main_top .task_menu, div.main_top .pager {
  text-align: right;
}
div.main_bottom .pager, div.main_bottom .task_menu {
  text-align: left;
}
table.footer .task_menu, div.tools .task_menu a, div.tools .task_menu, div.pager {
  Font('tools');
}
div.main_body {
  margin-top: 1ex;
  margin-bottom: 1ex;
}
div.main_body {
  width: 100%;
  text-align: left;
  margin-top: 1ex;
  margin-bottom: 1ex;
}
div.main_top {
  margin-top: .5ex;
}
div.main_top div.topic,
div.main_top div.byline,
div.main_top div.byline2,
div.main_top div.selector,
div.main_top div.title {
  margin-bottom: .5ex;
  text-align: left;
}
div.main_top .topic {
  Font('topic');
}
div.main_top div.byline, div.main_top div.byline2  {
  Font('byline');
}
div.main_top div.title {
  Font('title');
}
div.main_top div.tools {
  text-align: right;
  float: right;
}
div.main_top div.selector {
  float: left;
  text-align: left;
}
div.alphabetical_chooser {
  display: inline;
}
.task_menu .selected, .alphabetical_chooser .selected {
  Font('selected');
}
table.footer {
  border-top: 1px solid;
  Color('footer-border-top');
  margin: .5ex 0 .5ex 0;
  padding-top: .5ex;
}
td.footer_right {
  text-align: right;
  vertical-align: top;
}
td.footer_left {
  text-align: left;
  vertical-align: top;
}
.task_menu a.want_sep,
.pager .next, .pager .list,
.alphabetical_chooser a.all,
.tools span.want_sep,
.tools div.sep {
  background: Icon('tools_sep'); left center no-repeat;
  padding-left: vs_add(Icon('tools_sep', 'width'), 4);px;
  margin-left: 4px;
}
.alphabetical_chooser a.all {
  text-transform: uppercase;
}
.alphabetical_chooser a.want_sep {
  margin-left: .2em;
}
.tools div.sep {
  display: inline;
}
.prose p, p.prose {
  text-indent: 2em;
  margin: 1ex 0 1ex 0;
}
form .sep {
  text-align: left;
  font-weight: normal;
  padding: .5ex 0 1.5ex 0;
  border-top: 1px solid;
  Color('form_sep-border');
}
.warn {
  Font('warn');
}
.standard_submit {
  text-align: center;
}
form .submit {
  margin: .5em;
  text-align: center;
}
.empty_list, .not_found {
  border: 2px solid;
  Color('empty_list-border');
  padding: .5em;
  width: 30em;
  text-align: center;
}
pre .text {
  Font('pre_text');
}
.pager .next, .pager .prev, .pager .list {
  Font('pager');
}
.pager .off {
  Font('off');
}
.pager .selected {
  Font('strong');
}
.pager .num {
  padding-left: 0.3em;
}
.tree_list {
  margin: 0;
}
.tree_list .node {
  white-space: nowrap;
}
.tree_list .node .name {
  padding-left: 4px;
  white-space: nowrap;
}
.tree_list .node .sp {
  padding-left: 20px;
}
.tree_list td {
  padding: .3ex .8em;
}
.even {
  Color('even-background');
}
.odd {
  Color('odd-background');
}
p {
  text-align: left;
}
.paged_detail table {
  padding-top: .5em;
}
.paged_detail td {
  padding-bottom: 1em;
}
.byline, .byline2 {
  white-space: nowrap;
}
.top_left {
  background-image: Icon('top_left');;
  background-repeat: no-repeat;
  background-position: top left;
}
.top_right {
  background-image: Icon('top_right');;
  background-repeat: no-repeat;
  background-position: top right;
}
.bottom_left {
  background-image: Icon('bottom_left');;
  background-repeat: no-repeat;
  background-position: bottom left;
}
.bottom_right {
  background-image: Icon('bottom_right');;
  background-repeat: no-repeat;
  background-position: bottom right;
  padding: 2px;
}
.rounded_box_body {
  width: 100%;
}
p.prose {
  text-indent: 2em;
  margin: 1ex 0 1ex 0;
}
td.item {
  text-align: left;
}
td.amount_cell {
  text-align: right;
}
div.user_state .dd_link {
  Font('user_state');
}
div.user_state .dd_menu {
  display:inline;
  position:absolute;
  width: 8em;
  visibility:hidden;
  Color('dd_menu-background');
  border:1px solid;
  Color('dd_menu-border');
}
div.user_state .dd_menu a {
  display: block;
  margin: .2em;
  Font('dd_menu');
  Color('dd_menu-background');
  text-decoration: none;
  z-index:1000;
  text-align: left;
  font-weight: normal;
}
div.user_state .dd_menu a:hover {
  Color('dd_menu_selected-background');
  Color('dd_menu_selected');
  text-decoration: none;
}
EOF
}

sub _site_blog {
    return <<'EOF';
div.blog div.list div.menu {
  text-align: right;
  text-transform: lowercase;
}
div.blog div.list div.text {
  text-align: left;
}
div.blog .list {
  margin: 1ex;
}
div.blog div.list div.heading {
  Font('blog_list_heading');
  text-align: left;
  margin: 1ex 0 0 0;
}
div.blog div.list p.prose {
  margin: .5ex 0 .5ex 0;
}
table.simple td.blog_textarea {
  margin: 0;
  padding: 0;
}
div.blog .sidebar ul {
  margin: 0;
  padding: 0;
  list-style-type: none;
}
EOF
}

sub _site_mail {
    return <<'EOF';
.msg {
  margin-top: 1ex
  margin-bottom: 1ex
}
.msg_sep {
  height: 3ex;
}
.msg .text_plain {
  Font('pre_text');
}
.msg .attachment {
  margin-top: 1ex;
  border-top: 1px dashed;
  Color('form_sep-border');
}
.msg .parts .forward, .msg .parts .byline {
  margin-top: 1ex;
  margin-bottom: 1ex;
}
.msg .parts {
  border-top: 2px solid;
  border-left: 2px solid;
  padding-left: 1em;
  padding-bottom: 1em;
  Color('msg_parts-border');
}
.msg .parts .byline {
  Font('msg_byline');
}
.msg .parts .forward .label {
  padding-right: .5em;
}
.msg .parts {
  margin-bottom: 1em;
}
.msg .actions .task_menu a.want_sep {
  background: none;
  padding-left: 0;
  margin-left: 2em;
}
.msg .actions {
  Color('even-background');
  width: 20em;
}
.msg .actions .rounded_box_body  {
  margin: 1ex 1em;
}
.msg_compose .textarea .label {
  vertical-align: top;
}
EOF
}

sub _site_user_auth {
    return <<'EOF';
div.user_state {
  vertical-align: top;
  text-align: right;
  display: inline;
  white-space: nowrap;
}
div.user_state a {
  Font('user_state');
}
EOF
}

sub _site_wiki {
    return <<'EOF';
.help_wiki {
  Color('help_wiki-background');
}
.help_wiki table {
  font-size: 100%;
}
.help_wiki .tools {
  text-align: right;
  padding-top: .5ex;
  padding-right: .5em;
  float: right;
}
.help_wiki .tools a {
  Font('help_wiki_tools');
}
.help_wiki .tools .edit {
  padding-right: .5em;
}
body.help_wiki_iframe_body {
  margin: 0;
  min-width: 0;
  Font('help_wiki_iframe_body');
}
.help_wiki_iframe {
  Color('help_wiki-background');
  position: absolute;
  visibility: hidden;
  right: .5em;
  width: 41em;
  z-index: 1;
}
div.user_state a.settings,
a.help_wiki_open,
a.help_wiki_add {
  Font('user_state');
  background: Icon('tools_sep'); right center no-repeat;
  padding-right: vs_add(Icon('tools_sep', 'width'), 4);px;
  margin-right: 4px;
}
.help_wiki .header {
  padding-bottom: .5ex;
  Font('help_wiki_header');
}
.help_wiki .header,
.help_wiki .help_wiki_body {
  text-align: left;
  padding-right: .5em;
  padding-left: .5em;
}
.help_wiki .footer {
  padding-top: .5ex;
  padding-bottom: .5ex;
  text-align: center;
}
.help_wiki .help_wiki_body {
  Font('help_wiki_body');
}
div.wiki {
  padding-top: .5ex;
  padding-bottom: .5ex;
}
.wiki .prose {
  text-indent: 2em;
  margin: 1ex 0 1ex 0;
}
EOF
}

sub _v4 {
    my($text) = @_;
    return Bivio::IO::Config->if_version(
	4 => sub {$text},
	sub {''},
    );
}

1;
