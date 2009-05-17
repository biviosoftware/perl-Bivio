# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::CSS;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = b_use('IO.Config');
my($_SITE) = join('', map({
    my($x) = \&{"_site_$_"};
    defined(&$x) ? $x->() : '';
} @{b_use('Agent.TaskId')->included_components}));

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
@{[_v(4, q{
  Font('normal');
  Font('body');
})]}
}
textarea {
  white-space: pre;
}
address, caption, cite, code, dfn, em, h1, h2, h3, h4, h5, h6, strong, th, var {
  Font('normal');
@{[_v(4, q{
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
abbr, acronym, fieldset, iframe, img, table {
  border-style: none;
  border: 0;
@{[_v(4, q{
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
  margin-top: 0;
  margin-bottom: 0;
  margin-right: .5em;
  margin-left: .5em;
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
ol.none,
ul.none {
  list-style-type: none;
}
pre {
  line-height: 60%;
  white-space: pre;
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
.left {
 text-align: left;
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
span.checkbox_label {
  margin: .5em;
}
td.checkbox {
 text-align: center;
}
form .check {
  padding-left: .5em;
}
.acknowledgement,
.err_title,
.field_err,
form .desc {
  width: 30em;
}
form .desc,
.byline,
.msg .forward {
  margin: .1em 0 0 0;
  font-size: 85%;
  Color('form_desc');
}
form table.simple {
  text-align: center;
}
form table.simple td.field  {
  text-align: left;
  vertical-align: top;
}
td.label {
  vertical-align: top;
}
.field_err,
.label_err,
.err_title,
.err {
  Color('err');
}
form .err,
form .err_title {
  Font('form_err');
}
form .err_title {
  margin-bottom: 1ex;
}
form .field_err {
  Font('form_field_err');
}
form .label_ok,
form .label_err,
form .field {
  padding-top: 0.5em;
  padding-bottom: 0.5em;
}
form .footer {
  Font('form_footer');
  margin-bottom: 1.0em;
}
form .label_ok,
form .label_err,
form .label {
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
tr td .line_cell  {
  padding: 0;
}
.list td,
.paged_list td {
  padding: .5em;
}
.form_prose,
.list_prose,
.paged_list .empty {
  text-align: left;
  width: 40em;
  padding-bottom: .5ex;
}
table.dock,
table.header,
table.footer,
table.main {
  width: 100%;
  margin: auto;
}
table.dock {
  margin-top: 0;
  margin-bottom: 1ex;
}
table.main {
  margin-top: 1em;
  margin-bottom: 1em;
}
td.main_left,
td.main_middle,
td.main_right {
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
td.dock_middle {
  text-align: center;
}
td.dock_right,
.dock_right .task_menu {
  text-align: right;
}
td.dock_left,
td.dock_middle,
td.dock_right {
  vertical-align: td;
}
table.dock a {
  Font('dock');
}
td.header_right {
  width: 30%;
  text-align: right;
}
td.header_middle {
  width: 40%;
  vertical-align: top;
  text-align: center;
}
td.header_right {
  vertical-align: top;
  text-align: right;
}
td.footer_left {
  width: 30%;
  font-size: 100%;
}
td.footer_right {
  width: 30%;
  text-align: right;
  font-size: 100%;
}
td.footer_middle {
  width: 40%;
  vertical-align: top;
  text-align: center;
  font-size: 100%;
}
td.header_middle div.nav div.task_menu {
  Font('nav');
  text-align: center;
}
td.header_right {
  vertical-align: top;
  text-align: right;
}
div.main_bottom,
div.main_top,
div.main_body {
  width: 100%;
}
div.main_top {
  text-align: right;
}
div.main_top .task_menu,
div.main_top .pager {
  text-align: right;
}
div.main_bottom .pager,
div.main_bottom .task_menu {
  text-align: left;
}
table.footer .task_menu,
div.tools .task_menu a,
div.tools .task_menu,
div.pager {
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
div.main_top div.byline,
div.main_top div.byline2  {
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
  text-align: left;
}
div.alphabetical_chooser {
  display: inline;
  margin-right: 1em;
}
.task_menu .selected,
.alphabetical_chooser .selected {
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
.pager .next,
.pager .list,
.alphabetical_chooser a.all,
.dock .want_sep,
.header_right .want_sep,
.tools span.want_sep,
.tools div.sep {
  padding-left: .3em;
  margin-left: .3em;
  border-left: 1px solid;
  Color('form_sep-border');
}
.alphabetical_chooser a.want_sep {
  margin-left: .2em;
}
.tools div.sep {
  display: inline;
}
.b_prose p,
p.b_prose,
.prose p,
p.prose {
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
.standard_submit,
form .submit {
  margin: .5em;
  padding: 0 .5em;
  text-align: center;
}
.empty_list,
.page_error {
  border: 2px solid;
  Color('empty_list-border');
  padding: .5em;
  width: 30em;
  text-align: center;
}
pre .text {
  Font('pre_text');
}
.pager .next,
.pager .prev,
.pager .list {
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
.tree_list .node,
.tree_list .node a {
  white-space: nowrap;
}
.tree_list .node .name {
  padding-left: 4px;
  white-space: nowrap;
  Font('a_link');
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
.byline,
.byline2 {
  white-space: nowrap;
}
p.prose,
p.b_prose {
  text-indent: 2em;
  margin: 1ex 0 1ex 0;
}
td.item {
  text-align: left;
}
td.amount_cell {
  text-align: right;
  white-space: nowrap;
}
div.dd_link {
  Font('user_state');
}
div.dd_menu {
  display: inline;
  position: absolute;
  visibility: hidden;
  Color('dd_menu-background');
  border: 1px solid;
  Color('dd_menu-border');
  width: 15em;
  z-index: 1000;
}
div.dd_menu a,
div.dd_menu a.want_sep {
  background: none;
  margin-left: 0;
  padding: 0 .2em;
  border-left: 0;
}
div.dd_menu a {
  display: block;
  padding: 0 .2em;
  Font('dd_menu');
  Color('dd_menu-background');
  text-decoration: none;
  text-align: left;
  font-weight: normal;
}
div.dd_menu a:hover {
  Color('dd_menu_selected-background');
  Color('dd_menu_selected');
  text-decoration: none;
}
.b_rounded_box_1,
.b_rounded_box_2,
.b_rounded_box_3,
.b_rounded_box_4 {
  font-size: 1px;
  overflow: hidden;
  display: block;
}
span.b_rounded_box_1 {
  height: 1px;
  margin: 0 5px;
}
span.b_rounded_box_2 {
  height: 1px;
  margin: 0 3px;
}
span.b_rounded_box_3 {
  height: 1px;
  margin: 0 2px;
}
span.b_rounded_box_4 {
  height: 2px;
  margin: 0 1px;
}
form input.disabled {
  Color('disabled');
}
form input.enabled {
  Color('body');
}
a.b_thumbnail_popup {
  border: 1pt solid white;
  position: relative;
}
a.b_thumbnail_popup:hover {
  border: 1pt solid blue;
}
.b_hide {
  display: none;
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
div.blog div.list p.b_prose,
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

sub _site_calendar {
    return <<'EOF';
.month_selection td {
  padding-left: .5em;
}
.month_calendar td {
  width: 14%;
  vertical-align: top;
  border: 2px solid #FFFFFF;
  padding: .3em;
}
.month_calendar .day_of_week {
  padding-bottom: .5em;
  background-color: #C8C8C8;
  text-align: center;
}
.month_calendar .date_this_month, .month_calendar .date_other_month {
  height: 6em;
  background-color: #EEEEEE;
}
.month_calendar .date_other_month {
  background-color: #E6E6E6;
}
.month_calendar .date_other_month .day_of_month {
  color: gray;
}
.month_calendar .day_of_month {
  font-weight: bold;
  margin-bottom: .5em;
}
.month_calendar .event {
  font-size: 85%;
  padding-left: 20px;
  text-align: left;
  line-height: 16px;
}
EOF
}

sub _site_file {
    return <<'EOF';
.hidden_file_field {
   display: none;
}
.visible_file_field {
   display: table-row;
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
  margin-top: 2ex;
  border-top: 1px dashed;
  Color('form_sep-border');
  padding-top: 1ex;
}
.msg .attachment .download .label {
  margin-right: .5em;
}
.msg .parts .forward,
.msg .parts .byline {
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
  border: none;
  padding-left: 0;
  margin-left: 2em;
}
.msg .actions {
  Color('even-background');
  width: 40em;
}
.msg .actions .rounded_box_body  {
  margin: 1ex 1em;
}
.msg_compose .textarea .label {
  vertical-align: top;
}
EOF
}

sub _site_site_admin {
    return <<'EOF';
table.task_log .super_user {
    Color('super_user');
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
a.help_wiki_open,
a.help_wiki_add {
  Font('user_state');
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
.wiki .b_prose,
.wiki .prose {
  text-indent: 2em;
  margin: 1ex 0 1ex 0;
}
.same, .different {
  margin: 1ex 0 1ex 0;
}
.same {
  Color('odd-background');
}
.different {
  Color('even-background');
}
div.b_main_errors {
  margin-left: 1em;
}
div.b_main_errors * {
  Font('err');
}
.b_main_errors .b_entity {
  margin-left: 1em;
}
.b_main_errors .b_item {
  margin-left: 2em;
}

EOF
}

sub _site_xapian {
    return <<'EOF';
td.header_right form.search {
  text-align: right;
  margin-top: 1ex;
}
td.header_right form.search input.go {
  margin-left: .3em;
}
table.search_results td a:hover span.title {
  Font('a_hover');
}
table.search_results td a span.title {
  display: block;
  margin-bottom: .3ex;
  Font('search_result_title');
}
table.search_results td a span.excerpt {
  display: block;
  margin-bottom: .5ex;
  Font('search_result_excerpt');
  width: 80%;
}
table.search_results td a span.byline {
  display: block;
  margin-bottom: 1ex;
  Font('search_result_byline');
}
table.search_results td a span.byline span.author {
  margin-right: .5em;
}
table.search_results tr.even,
table.search_results tr.odd {
  Color('search_results-background');
}

EOF
}

sub _v {
    my($num, $text) = @_;
    return $_C->if_version($num => sub {$text});
}

1;
