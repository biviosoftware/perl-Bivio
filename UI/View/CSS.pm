# Copyright (c) 2007-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::CSS;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_C) = b_use('IO.Config');
my($_F) = b_use('UI.Facade');
my($_REQ_KEY) = __PACKAGE__ . 'css';
my($_SITE) = join('', map({
    my($x) = \&{"_site_$_"};
    defined(&$x) ? $x->() : '';
} @{b_use('Agent.TaskId')->included_components}));
my($_UIF) = b_use('UI.Facade');

sub add_to_css {
    my($proto, $widget, $selector, $class, $source) = @_;
    my($info) = $source->req->get_if_defined_else_put($_REQ_KEY => {
	render_order => [],
	visited => {},
    });
    my($name) = $widget->simple_package_name;
    my($key) = $selector . '[' . $name . ']';
    return if $info->{visited}->{$key};
    $info->{visited}->{$key} = 1;
    push(@{$info->{render_order}}, [$selector, $name, $class]);
    return;
}

sub internal_site_css {
    my($self, $source) = @_;
    return $_UIF->get_from_source($source)->if_2014style(
	'',
	$_SITE . $_F->if_html5(\&_html5_css, ''),
    );
}

sub render_2014style_css {
    return shift->internal_body(Prose(<<'EOF'));
! override bootstrap.css, allow mobile nav submenu to be larger
.navbar-collapse.in {
  overflow-y: inherit;
  max-height: none;
}
! hard-code search form in nav for chrome/safari
! probably could set col class on item instead
nav.navbar div.input-group {
  width: 250px;
}
@media (min-width: 768px) and (max-width: 991px) {
  nav.navbar div.input-group {
    width: 200px;
  }
}
@media (max-width: 767px) {
  nav.navbar div.input-group {
    width: 100%;
  }
}
! set btn min width
.standard_submit button.btn {
  min-width: 10em;
}
! admin submenu headings
.dropdown-header {
  white-space: nowrap;
}
!TODO: hacked radio display - ex. ?/member-edit
.b_radio .checkbox {
  display: inline;
}
input[type="checkbox"], input[type="radio"] {
  margin: 0.5ex;
}
! sticky footer
html, body {
  height: 100%;
  padding-top: 35px;
}
div.b_nav_and_content {
  height: auto;
  margin: 0 auto -CSS('footer_height');;
  min-height: 100%;
  padding: 0 0 CSS('footer_height');;
}
div.b_nav_and_footer {
  min-height: CSS('footer_height');;
}
div.b_footer {
  font-size: 90%;
  margin-top: 36px;
  margin-right: 1em;
}
! tighten up forum select widget to match tabbed view
div.b_forum_tabs div.form-group {
  margin-bottom: 8px;
}
! error bubble
.form-group .b_form_field_error:after {
  border-bottom: 6px solid CSS('error_background');;
  border-left: 6px solid CSS('empty_color');;
  border-right: 6px solid CSS('empty_color');;
  content: "";
  display: inline-block;
  left: 3px;
  position: absolute;
  top: -6px;
}
.form-group .b_form_field_error {
  background: none repeat scroll 0 0 padding-box CSS('error_background');;
  border-radius: 4px;
  Color('body_background');
  display: inline-block !important;
  font-size: 12px;
  font-weight: 600;
  list-style: none outside none;
  margin: 0;
  padding: 2px 10px;
  position: relative;
}
div.task_menu a {
  padding: 1ex;
}
div.b_logo {
  background: Icon('logo'); left no-repeat;
  height: Icon(qw(logo height));px;
  width: Icon(qw(logo width));px;
}
ul.ui-autocomplete {
! need to manage these somehow
  z-index: 10000;
}
.bivio_suggest_headline,
.bivio_suggest_excerpt {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.bivio_suggest_title {
  font-weight: bold;
}
.bivio_suggest_excerpt {
  color: rgba<(>0, 0, 0, 0.5<)>;
  display: inline;
}
@media (max-width: 768px) {
  .bivio_suggest_excerpt {
    display: block;
  }
}
input.b_input_file {
  padding: 6px;
}
!TODO: ComboBox, copied by css pre 2014, need to share def
! replaced ShadowAttr to match bootstrap .form-control:focus
div.dd_menu, div.cb_menu {
  ShadowAttr({
    box => 'inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(102, 175, 233, 0.6)',
  });
}
input.cb_text {
  padding-right: 20px;
}
div.cb_arrow {
  cursor: pointer;
  display: inline;
  position: absolute;
  border: 1px outset;
  Color('dd_menu-border');
  Color('body');
  -webkit-user-select: none;
  -moz-user-select: none;
  border: none;
  position: relative;
  left: -20px;
  margin-right: -15px;
  white-space: nowrap;
}
div.cb_menu {
  display: inline;
  position: absolute;
  visibility: hidden;
  Color('dd_menu-background');
  border: 1px solid;
  Color('dd_menu-border');
  width: 15em;
  max-height: 10em;
  overflow: auto;
  z-index: 1000;
  padding: 0.2ex 0.5ex;
}
div.cb_selected {
  Color('dd_menu_selected-background');
  Color('dd_menu_selected');
  text-decoration: none;
}
! override boostrap display: block
input.cb_text {
  display: inline;
}
!TODO: ComboBox carat not aligning correctly with IE (due to width: 100%)
! need to add nowrap container for ComboBox
.b_forum_name {
  margin-left: 1em;
  margin-right: 1em;
  font-size: 18px;
  white-space: nowrap;
}
div.b_forum_tabs {
  margin-bottom: 1ex;
}
div.b_forum_tabs form {
  margin-right: 15px;
}
div.b_alert {
  margin-bottom: 1ex;
}
h3.b_title {
  margin-top: 0;
}
img.b_profile_label_avatar {
  width: 36px;
  height: 36px
  display: block;
  If([sub {shift->req(qw(UI.Facade uri)) =~ 'mipi|c1787'}], Simple(q{
  border-top-left-radius: 18px;
  -webkit-border-top-left-radius: 18px;
  -moz-border-top-left-radius: 18px;
  border-bottom-right-radius: 18px;
  -webkit-border-bottom-right-radius: 18px;
  -moz-border-bottom-right-radius: 18px;
  border-radius: 18px;
  -webkit-border-radius: 18px;
  -moz-border-radius: 18px;
}));
! avatar position hack
  position: absolute;
  top: 7px;
}
@media (max-width: 767px) {
  img.b_profile_label_avatar {
    top: 2px;
  }
}

.table > tbody > tr > td.bivio_recent_date_cell {
  text-align: right;
  border: none;
  white-space: nowrap;
}
.table > tbody > tr > td.bivio_recent_update_cell {
  border: none;
!  word-break: break-all;
}
.bivio_recent_date {
  font-weight: bold;
}
.bivio_smart_date {
  white-space: nowrap;
}
.bivio_recent_owner,
.bivio_recent_model,
.bivio_recent_forum {
  color: #000;
}
.bivio_recent_action {
  color: #888;
}
.b_tree_node .b_sp {
  padding-left: 1em;
}
.tree_list .check {
  text-align: center;
}
.tree_list {
  margin: 2em 0 0 0;
}
.tree_list .node {
  white-space: nowrap;
}
.tree_list .node .name, td a span.name {
  padding-left: 4px;
  white-space: nowrap;
}
.tree_list .node .sp {
  padding-left: 20px;
}
.tree_list td, .tree_list th {
  padding: .3ex .8em;
}
.amount_cell {
  text-align: right;
}
td.b_msg_summary {
  CSS('msg_summary');
}
!TODO: class is mispelled in bOP, don't want fixed width anyway
!.b_msg_summary div.b_excerpt {
!  Font('msg_excerpt');
!}
.b_exerpt {
!  word-break: break-all;
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
table.table td a span.title {
  display: block;
  margin-bottom: .3ex;
}
table.table td a span.excerpt {
  display: block;
  margin-bottom: .5ex;
  Font('search_result_excerpt');
}
table.table td div.byline {
  margin-bottom: 1ex;
  Font('search_result_byline');
}
table.table td div.byline span.author {
  margin-right: 1em;
}
table.table div.date {
  display: inline;
  margin-right: 1em;
}
table.table div.uri {
  display: inline;
  margin-right: 1em;
}
div.main_top > div.selector {
  margin-bottom: 1ex;
}
textarea.b_no_resize_text {
  resize: none;
}
.cke_contents {
! have to override inline style for height with !important
  height: 28em !important;
}
.paged_list th,
.paged_list td {
  padding: .1em .5em;
}
[class^="b_icon_"]:before, [class*=" b_icon_"]:before {
  position: relative;
  top: 0;
  vertical-align: baseline;
  margin-left: 0;
  margin-right: 0;
}
#b_wysiwyg_editor {
  width: 100%;
  height: 30em;
}
EOF
}

sub site_css {
    my($self) = @_;
    return $self->internal_body(Join([
	Prose([sub {
	    my($source) = @_;
	    my($res) = '';
	    my($info) = $source->ureq($_REQ_KEY);
	    return ''
		unless $info;
	    my($facade) = $_F->get_from_source($source)->get('CSS');
	    foreach my $path (@{$info->{render_order}}) {
		my($selector, $widget, $class) = @$path;
		my($css) = $facade->unsafe_get_value($widget, $class);
		next unless $css;
		if (ref($css)) {
		    foreach my $pseudo_class (keys(%$css)) {
			$res .= join(':', $selector, $pseudo_class || ())
			    . ' {' . $css->{$pseudo_class} . "}\n";
		    }
		}
		else {
		    $res .= $selector . ' {' . $css . "}\n";
		}
	    }
	    return $res;
	}]),
	[sub {
	    my($css) = $self->internal_site_css(shift);
	    return ref($css) ? $css : Prose($css);
	}],
    ]));
}

sub _html5_css {
    return <<'EOF';
form .field_err {
 width: auto;
}
table.b_label_group {
  margin-top: 0.5ex;
}
form td.b_label_group {
 vertical-align: top;
}
form table.b_label_group {
  margin-right: 0;
  margin-left: auto;
  max-width: 25em;
  min-width: 20em;
}
form div.b_error_bubble {
 font-size: 95%;
 BorderAttr({
  radius => '3px',
 });
 padding: 0.5ex 0.5em;
 Color('error-background');
 border:1px solid;
 Color('error-border');
}
form div.b_error_arrow_holder {
 position: relative;
 margin-right: 1em;
}
form span.b_error_arrow_border{
 border-color:transparent;
 Color('error_arrow-border-left');
 border-style:solid;
 border-width:6px;
 font-size: 0;
 position: absolute;
 top: -4px;
}
form span.b_error_arrow{
 border-color:transparent;
 Color('error_background-border-left');
 border-style:solid;
 border-width:6px;
 font-size: 0;
 position: absolute;
 top: -4px;
 right: -10px;
}
td.b_error_arrow {
 padding-top: 2ex;
 vertical-align: top;
}
form input, form textarea, form select {
  border:1px solid;
  Color('input-border');
  CSS('b_input_field');
  BorderAttr({
    radius => '3px',
  });
  ShadowAttr({
    box => '0 0 0 #000, inset 0px 3px 3px #eee',
  });
}
form input:hover, form textarea:hover, form select:hover {
 border:1px solid;
 Color('input_focus-border');
}
form input:focus, form textarea:focus, form select:focus {
 border:1px solid;
 Color('input_focus-border');
}
table.list tr.b_heading_row, table.paged_list tr.b_heading_row {
  Color('list_heading-background');
  border: 1px solid;
  Color('list_heading-border');
  Color('list_heading-border-top');
  Color('list_heading-border-bottom');
  ShadowAttr({
    box => '0 1px 1px rgba(0,0,0,0.12),inset 0 0 0 #000',
  });
}
table.list tr.b_data_row:hover, table.paged_list tr.b_data_row:hover {
  Color('list_row_hover-background');
  border: 1px solid;
  Color('list_row_hover-border');
  border-width: 1px 0;
}
table.list th b, table.paged_list th b {
 font-weight: normal;
}
table.list tr, table.paged_list tr {
  border:1px solid;
  Color('list_row-border');
  border-width: 1px 0;
}
table.list .b_even_row, table.paged_list .b_even_row  {
  background-color: transparent;
}
div.dd_menu, div.cb_menu {
  ShadowAttr({
    box => '3px 3px 3px 3px rgba(102, 102, 102, 0.6)',
  });
  BorderAttr({
    radius => '3px',
  });
}
EOF
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
.acknowledgement .text a,
div.empty_list a,
div.page_error a,
form .desc a,
form .field_err a,
form .form_prose a,
form .label_err a,
form .label_ok a
form .sep a {
  Font('embedded_prose_link');
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
.field .checkbox {
  padding: 0;
  margin: 0;
}
span.checkbox_label {
  margin: .5em;
}
td.checkbox {
 text-align: center;
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
  padding-top: 1ex;
  padding-bottom: 0.5em;
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
.list td.paragraph_text,
.paged_list td.paragraph_text {
  Font('paragraph_text');
}
table.dock,
table.header,
table.footer,
table.main {
  CSS('b_three_part_page_tables');
}
table.dock {
  margin-top: 0;
  margin-bottom: 1ex;
}
table.main {
  CSS('b_table_main');
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
  CSS('b_td_header_left');
}
td.header_left .logo_su .logo {
  CSS('b_logo_su_logo');
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
  CSS('b_td_footer_center');
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
  width: 100%;
  text-align: left;
  margin-top: .5ex;
  margin-bottom: 1ex;
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
  Font('footer');
  CSS('b_table_footer');
}
td.footer_right {
  text-align: right;
  vertical-align: top;
}
td.footer_left {
  text-align: left;
  vertical-align: top;
}
div.want_sep,
.task_menu a.want_sep,
.pager .next,
.pager .list,
.alphabetical_chooser a.all,
.dock .want_sep,
.header_right .want_sep,
.tools span.want_sep,
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
.form_prose,
!TODO: Unused?
.list_prose,
.paged_list .empty {
  text-align: left;
  width: 40em;
  padding-bottom: .5ex;
}
.b_word_break_all {
  word-break: break-all;
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
input.cb_text {
  padding-right: 20px;
}
div.cb_arrow {
  cursor: pointer;
  display: inline;
  position: absolute;
  border: 1px outset;
  Color('dd_menu-border');
  Color('body');
  -webkit-user-select: none;
  -moz-user-select: none;
  border: none;
  position: relative;
  left: -20px;
  margin-right: -15px;
  white-space: nowrap;
}
div.cb_menu {
  display: inline;
  position: absolute;
  visibility: hidden;
  Color('dd_menu-background');
  border: 1px solid;
  Color('dd_menu-border');
  width: 15em;
  max-height: 10em;
  overflow: auto;
  z-index: 1000;
  padding: 0.2ex 0.5ex;
}
div.cb_selected {
  Color('dd_menu_selected-background');
  Color('dd_menu_selected');
  text-decoration: none;
}
div.b_rounded_box {
  BorderAttr({
    radius => '3px',
  });
  padding: 1ex 1em;
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
span.b_abtest a {
  Font('b_abtest_a');
  margin-left: .5em;
}
span.b_abtest a.selected {
  Font('b_abtest_a_selected');
}
div.b_mobile_toggler span.selected {
  Font('b_mobile_toggler_selected');
}
div.b_mobile_toggler a {
  Font('b_mobile_toggler_a');
}
a.list_action {
  Font('b_list_action');
}
img.date_picker {
  position: relative;
  bottom: -0.5ex;
  left: 0.3ex;
}
div.b_dp_hidden {
  display: none;
}
div.b_dp_visible {
  display: block;
}
div.b_dp_month {
  border: 1px solid #888;
  background-color: #fff;
  font-size: 100%;
  cursor: default;
  position: absolute;
  right: -Icon('date_picker', 'width');px;
  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -khtml-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;
}
div.b_dp_holder {
  display: inline;
  position: relative;
  left: 0.3ex;
  z-index: 1000;
}
div.b_dp_holder td {
  padding: 0;
  margin: 0;
}
div.b_dp_cell {
  padding: 0.5ex 1.0ex;
  background-color: #fff;
  font-size: 85%;
  text-align: center;
  cursor: default;
}
div.b_dp_month_label {
  background-color: #fff;
  font-weight: bold;
  font-size: 100%;
  cursor: default;
}
div.b_dp_arrow {
  background-color: #ddd;
  font-size: 100%;
  cursor: pointer;
}
div.b_dp_arrow:hover {
  background-color: #bbb;
}
div.b_dp_dow {
  background-color: #777;
  color: #fff;
}
div.b_dp_active_day:hover {
  background-color: #bbf;
  cursor: pointer;
  color: #fff;
}
div.b_dp_weekend {
  background-color: #e7e7e7;
}
div.b_dp_in_month {
  width: 2ex;
}
div.b_dp_not_in_month {
  color: #aaa;
  font-style: italic;
}
div.b_dp_inactive_day {
  color: #d2d2d2;
  cursor: default;
}
div.b_dp_today {
  outline: 1px solid #f00;
}
div.b_dp_selected {
  background-color: #88f;
  color: #fff;
}
EOF
}

sub _site_blog {
    return <<'EOF';
div.blog_title {
  Font('title');
  margin-bottom: 1ex;
}
div.blog {
  margin-left: 3em;
}
div.blog div.text {
  text-align: left;
  width: 50em;
}
div.blog div.list div.heading {
  Font('blog_list_heading');
  text-align: left;
  margin: 1ex 0 0 0;
}
div.blog_byline .blog_img {
  margin-right: 1em;
  float: left;
}
div.blog_byline .blog_author {
  Color('text_byline');
  float: left;
}
div.blog_byline .clear {
  clear: both;
}
EOF
}

sub _site_calendar {
    return <<'EOF';
table.b_month_calendar {
  border: 1px solid;
  width: 70em;
  Color('b_month_calendar_td-border');
}
.b_month_calendar td {
  vertical-align: top;
  width: 5em;
  padding: .5em;
  border: 1px solid;
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
.msg pre {
  white-space: pre-line;
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
td.b_msg_summary {
  CSS('msg_summary');
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

sub _site_motion {
    return <<'EOF';
td.vote_count {
  text-align: center;
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
a.help_wiki_page,
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
body.b_help_wiki td.main_right,
body.b_help_wiki td.main_left {
  CSS('b_help_wiki_main_left');
}
div.wiki {
  CSS('b_wiki_width');
  padding-top: .5ex;
  padding-bottom: .5ex;
}
.wiki .b_prose,
.wiki .prose {
  margin: 1ex 0 1ex 0;
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
! don't show the CKEditor until the skin is loaded
! avoids some of the page jumping around while loading
.cke_toolbar {
  display: none;
}

EOF
}

sub _site_xapian {
    return <<'EOF';
td.header_right form.search {
  margin-top: 1ex;
}
td.header_right form.search input.enabled, td.header_right form.search input.disabled  {
  padding-right: 20px;
}
td.header_right form.search input.go {
  border: none;
  position: relative;
  left: -20px;
  margin-right: -15px;
  ShadowAttr({
    box => '0px 0px 0px 0px',
  });
  BorderAttr({
    radius => '0px',
  });
  vertical-align: text-bottom;
  white-space: nowrap;
}
form.search div.b_realm_only {
  padding-top: .5ex;
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
table.b_search_results div.uri {
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
p {
  Font('p');
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
