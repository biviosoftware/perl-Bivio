# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
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
    return $self->internal_body(Prose([sub {$self->internal_site_css(shift)}]));
}

sub _site_base {
    return <<'COPY' . _tag_reset() . _tag_style() . <<'EOF';
/* Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved. */
COPY
ol.none,
ul.none {
  list-style-type: none;
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
.b_align_n {
  text-align: center;
  vertical-align: top;
}
.b_align_ne {
  text-align: right;
  vertical-align: top;
}
.b_align_e {
  text-align: right;
  vertical-align: middle;
}
.b_align_se {
  text-align: right;
  vertical-align: bottom;
}
.b_align_s {
  text-align: center;
  vertical-align: bottom;
}
.b_align_sw {
  text-align: left;
  vertical-align: bottom;
}
.b_align_w {
  text-align: left;
  vertical-align: middle;
}
.b_align_nw {
  text-align: left;
  vertical-align: top;
}
.b_align_n {
  text-align: center;
  vertical-align: top;
}
.b_align_center {
  text-align: center;
}
.b_align_left {
  text-align: left;
}
.b_align_right {
  text-align: right;
}
.b_align_top {
  vertical-align: top;
}
.b_align_bottom {
  vertical-align: bottom;
}
.b_literal {
  white-space: pre-wrap;
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
.simple .label_ok,
.simple .label_err,
.simple .field,
form .label_ok,
form .label_err,
form .field {
  padding-top: 0.5em;
  padding-bottom: 0.5em;
}
.simple .field,
form .field {
  padding-top: 0.5ex;
}
form .footer {
  Font('form_footer');
  margin-bottom: 1.0em;
}
.simple .label_ok,
.simple .label_err,
.simple .label,
form .label_ok,
form .label_err,
form .label {
  text-align: right;
  padding-right: .5em;
}
.simple .label_ok,
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
td.main_center,
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
td.dock_left {
  width: 35%
}
td.dock_middle {
  width: 30%
}
td.dock_right {
  width: 35%
}
td.dock_center,
td.dock_middle {
  text-align: center;
}
td.dock_right,
.dock_right .task_menu {
  text-align: right;
}
td.dock_left,
td.dock_center,
td.dock_middle,
td.dock_right {
  vertical-align: top;
}
table.dock a {
  Font('dock');
}
td.header_left {
  width: 30%;
  text-align: left;
}
td.header_right {
  width: 30%;
  text-align: right;
}
td.header_center,
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
td.footer_center,
td.footer_middle {
  width: 40%;
  vertical-align: top;
  text-align: center;
  font-size: 100%;
}
td.header_center div.nav div.task_menu,
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
    CSS('table_footer');
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
.tools div.want_sep,
.tools div.sep {
  CSS('menu_want_sep');
}
.alphabetical_chooser a.want_sep {
  margin-left: .2em;
}
.selector, .task_menu_wrapper {
  position: relative;
}
div.task_menu_wrapper,
.tools div.sep {
  display: inline;
}
.b_prose p,
p.b_prose,
.prose p,
p.prose {
  CSS('b_prose');
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
.b_even_row {
  Color('even-background');
}
.b_odd_row {
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
  top: 3ex;
  left: 0;
  visibility: hidden;
  Color('dd_menu-background');
  border: 1px solid;
  Color('dd_menu-border');
  width: 15em;
  z-index: 1000;
}
.tools div.dd_menu a,
div.dd_menu a,
.tools div.dd_menu a.want_sep,
div.dd_menu a.want_sep {
  background: none;
  margin-left: 0;
  padding: 0 .2em;
  border-left: none;
}
.tools div.dd_menu a,
div.dd_menu a {
  display: block;
  padding: 0 .2em;
  Font('dd_menu');
  Color('dd_menu-background');
  text-decoration: none;
  text-align: left;
  font-weight: normal;
}
div.dd_visible {
  visibility: visible;
}
div.dd_hidden {
  visibility: hidden;
}
.tools div.dd_menu a:hover,
div.dd_menu a:hover {
  Color('dd_menu_selected-background');
  Color('dd_menu_selected');
  text-decoration: none;
}
div.cb_menu {
  display: inline;
  position: absolute;
  visibility: hidden;
  Color('dd_menu-background');
  border: 1px solid;
  Color('dd_menu-border');
  width: 15em;
  z-index: 1000;
}
div.cb_selected {
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
.b_round_1,
.b_round_2,
.b_round_3,
.b_round_4,
.b_round_5,
.b_round_6,
.b_round_7,
.b_round_8,
.b_round_9,
.b_round_10,
.b_round_11,
.b_round_12,
.b_round_13,
.b_round_14 {
  display: block;
  height: 1px;
  font-size: 1px;
  overflow: hidden;
}
.b_round_1 {margin: 0 1px;}
.b_round_2 {margin: 0 2px;}
.b_round_3 {margin: 0 3px;}
.b_round_4 {margin: 0 4px;}
.b_round_5 {margin: 0 5px;}
.b_round_6 {margin: 0 6px;}
.b_round_7 {margin: 0 7px;}
.b_round_8 {margin: 0 8px;}
.b_round_9 {margin: 0 9px;}
.b_round_10 {margin: 0 10px;}
.b_round_11 {margin: 0 11px;}
.b_round_12 {margin: 0 12px;}
.b_round_13 {margin: 0 13px;}
.b_round_14 {margin: 0 14px;}
.b_round_15 {margin: 0 15px;}
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
img.b_clear_dot {
  border: none;
  width: 1px;
  height: 1px;
}
span.b_progress_img {
  display: block;
  float: left;
  border: 1px solid;
  Color('b_progress_bar-border');
  width: 10em;
}
.b_progress_bar span.b_text {
  padding-left: 1em;
}
.b_progress_img img.b_clear_dot {
  height: 1em;
  Color('b_progress_bar-background');
}
span.b_sort_arrow {
  Font('b_sort_arrow');
}
.italics,
.italic {
  font-style: italic;
}
.bold {
  font-weight: bold;
}
.underline {
  text-decoration: underline;
}
.b_selector div.b_item {
  display: inline;
  padding-right: 1em;
}
form.b_selector {
  padding-top: 1ex;
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
table.b_month_calendar {
  width: 70em;
}
.b_month_calendar td {
  vertical-align: top;
  width: 5em;
  padding: .5em;
  border: 2px solid;
  Color('b_month_calendar_td-border');
}
.b_month_calendar th {
  Font('b_month_calendar_th');
  Color('b_month_calendar_th-background');
}
.b_month_calendar .b_date_this_month,
.b_month_calendar .b_date_other_month {
  Color('b_month_calendar-background');
}
.b_month_calendar .b_date_other_month {
  Color('b_date_other_month-background');
}
.b_month_calendar .b_day_of_month {
  display: block;
  float: left;
  margin-bottom: .5em;
  Font('b_month_calendar_day_of_month');
}
.b_month_calendar .b_date_other_month .b_day_of_month {
  Font('b_date_other_month');
}
.b_month_calendar .b_is_today .b_day_of_month {
  border: 1px solid;
  Color('b_month_calendar_is_today-border');
}
.b_month_calendar a.b_event_name {
  display: block;
  padding-left: 2.5em;
  Font('b_event_name');
}
.b_list_calendar td.b_datetime {
  Font('b_datetime');
}
a.b_day_of_month_create,
a.b_day_of_month_create:visited,
a.b_day_of_month_create:link {
  display: block;
  margin: auto;
  width: 5em;
!See View.Calendar calculation for height
  padding: .5ex .5em;
  Font('b_day_of_month_create_hidden');
  text-align: center;
}
.b_date_other_month a.b_day_of_month_create,
.b_date_other_month a.b_day_of_month_create:visited,
.b_date_other_month a.b_day_of_month_create:link {
  Color('b_day_of_other_month_create_hidden');
}
a.b_day_of_month_create:active,
a.b_day_of_month_create:hover,
.b_date_other_month a.b_day_of_month_create:active,
.b_date_other_month a.b_day_of_month_create:hover {
  Font('b_day_of_month_create_visible');
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
  margin-top: 1ex;
  margin-bottom: 1ex;
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
.msg .parts .byline {
  Font('msg_byline');
}
.msg .byline .date {
  display: inline;
}
.msg .parts {
  border-top: 2px solid;
  border-left: 2px solid;
  padding-left: 1em;
  padding-bottom: 1em;
  Color('msg_parts-border');
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
.b_msg_summary div.b_excerpt {
  Font('msg_excerpt');
}
.b_msg_summary .byline,
.b_msg_summary .date {
  display: inline;
}
.b_msg_summary span.author,
.b_msg_summary div.date {
  padding-right: 1em;
}
.b_msg_summary div.byline {
  Font('msg_summary_byline');
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
.wiki blockquote .b_prose,
.wiki blockquote ul li .b_prose,
.wiki dd .b_prose,
.wiki td .b_prose,
.wiki li .b_prose {
  text-indent: 0;
}
.same, .different {
  width: 100%;
  float: left;
  position: relative;
}
.same {
  Color('same-background');
}
.different {
  padding: 1ex 0 0 0;
  Color('different-background');
}
.different .top {
  padding: 1ex 0 1ex 0;
  background-color: #FFFF99;
}
.different .bottom {
  padding: 1ex 0 1ex 0;
  background-color: #33FF66;
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
  margin-top: 1ex;
}
td.header_right form.search input.go {
  margin-left: .3em;
}
form.search div.b_realm_only {
  padding-top: .5ex;
  padding-right: vs_add(Icon('magnifier', 'width'), 2);px;
  text-align: right;
}
form.search div.b_realm_only input {
  margin-right: .5em;
}
table.b_search_results td a:hover span.title {
  Font('a_hover');
}
table.b_search_results td a span.title {
  display: block;
  margin-bottom: .3ex;
  Font('search_result_title');
}
table.b_search_results td a span.excerpt {
  display: block;
  margin-bottom: .5ex;
  Font('search_result_excerpt');
}
table.b_search_results td div.byline {
  margin-bottom: 1ex;
  Font('search_result_byline');
}
table.b_search_results td div.byline span.author {
  margin-right: 1em;
}
table.b_search_results div.date {
  display: inline;
  margin-right: 1em;
}
table.b_search_results tr.b_even_row,
table.b_search_results tr.b_odd_row {
  Color('search_results-background');
}
EOF
}

sub _tag_reset {
    return <<'EOF'
blockquote, body, dd, div, dl, dt, fieldset, form, h1, h2, h3, h4, h5, h6, input, li, ol, p, pre, td, textarea, th, ul {
  Font('reset_body');
}
abbr, acronym, fieldset, img {
  Font('reset_abbr');
}
address, button, caption, cite, code, dfn, em, input, optgroup, optgroup, option, select, strong, textarea, th, var {
  Font('reset_address');
}
caption, td, th {
  Font('reset_caption');
}
ol {
  Font('reset_ol');
}
pre {
  Font('reset_pre');
}
table {
  Font('reset_table');
}
textarea {
  Font('reset_textarea');
}
ul {
  Font('reset_ul');
}
EOF
}

sub _tag_style {
    return <<'EOF';
a {
  Font('a_link');
}
a:hover {
  Font('a_hover');
}
body {
  Font('body');
  Color('body-background');
}
caption {
  Font('caption');
}
code {
  Font('code');
}
em {
  Font('em');
}
h1, h2, h3, h4, h5, h6 {
  Font('hn');
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
h5 {
  Font('h5');
}
h6 {
  Font('h6');
}
strong {
  Font('strong');
}
table {
  Font('table');
}
th {
  Font('th');
}
th>a:link, th>a:visited, th>a:active, th>a:hover {
  Font('th_a');
}
EOF
}

sub _v {
    my($num, $text) = @_;
    return $_C->if_version($num => sub {$text});
}

1;
