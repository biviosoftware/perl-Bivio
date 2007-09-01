# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::CSS;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PROSE) = {
    map({
	my($which) = $_;
	($which => join('', map({
	    my($x) = \&{"_${which}_$_"};
	    defined(&$x) ? __PACKAGE__->internal_compress($x->()) : '',
	} @{Bivio::Agent::TaskId->included_components})));
    } qw(site realm)),
};

sub internal_compress {
    my(undef, $v) = @_;
    $v =~ s/^\!.*\n//mg;
    $v =~ s/^\s+//mg;
    # IE BUG: Don't include ';', because "Icon('bla'); left" will get convereted to
    # "Icon('bla');left" which then becomes "url(/i/bla.gif)left" which IE doesn't
    # interpret properly and doesn't render the image
    $v =~ s/(?<!\))(?<=[\,\:\{])\s+//mg;
    return $v;
}

sub realm_css {
    my($self) = @_;
    return $self->internal_body(Prose($self->internal_realm_css));
}

sub internal_realm_css {
    view_pre_execute(sub {
	my($req) = shift->get_request;
	# Just need a few, and load_all could technically be too many
	Bivio::Biz::Model->new($req, 'RealmLogoList')->load_page
	    unless $req->unsafe_get('Model.RealmLogoList');
    });
    return $_PROSE->{realm};
}

sub internal_site_css {
    return $_PROSE->{site};
}

sub site_css {
    my($self) = @_;
    return $self->internal_body(Prose($self->internal_site_css));
}

# If(public RealmFile exists /Public/logo.gif/jpg/png)
# Need to size it.  ViewShortcut.
# td.header_left {
#   background: url (String([qw(Model.RealmLogoList ->get_uri)]);) left no-repeat;
#   height: String([qw(Model.RealmLogoList ->get_height)]);px;
#   width: String([qw(Model.RealmLogoList ->get_width)]);px;
# }
sub _realm_base {
    return <<'EOF';
/* Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved. */
If([qw(Model.RealmLogoList ->is_ok_to_render)],
   Prose(q{
td.header_left {
  background: url<<(>>String<(>['Model.RealmLogoList', 'uri'])<;>) left no-repeat;
  height: String<(>['Model.RealmLogoList', 'height'])<;>px;
  width: String<(>['Model.RealmLogoList', 'width'])<;>px;
}}));
EOF
}

sub _site_base {
    return <<'EOF';
/* Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved. */
blockquote, body, dd, div, dl, dt, fieldset, form, h1, h2, h3, h4,
h5, h6, input, li, ol, p, pre, td, textarea, th, ul {
  margin: 0;
  padding: 0;
  text-align: left;
}
address, caption, cite, code, dfn, em, h1, h2, h3, h4, h5, h6, strong, th, var {
  Font('normal');
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
}
a:link, a:visited, a:active {
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
! CLASSES
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
form .desc, .byline {
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
.prose, .form_prose, .list_prose, .paged_list .empty {
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
.footer .task_menu, div.tools .task_menu a, div.tools .task_menu, div.pager {
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
.footer {
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
  text-transform: lowercase;
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
.empty_list {
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
  background: Icon('top_left'); top left no-repeat;
  float: left;
}
.top_right {
  background: Icon('top_right'); top right no-repeat;
  float: right;
}
.bottom_left {
  background: Icon('bottom_left'); bottom left no-repeat;
  float: left;
}
.bottom_right {
  background: Icon('bottom_right'); bottom right no-repeat;
  float: right;
}
.top_left, .top_right, .bottom_right, .bottom_left {
  width: 2px;
  height: 2px;
}
p.prose {
  text-indent: 2em;
  margin: 1ex 0 1ex 0;
}
td.item {
  text-align: left;
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
.mail_msg .header {
  width: 100%;
  padding-bottom: 1ex;
}
.mail_msg .line {
  clear: both;
  padding-bottom: .3ex;
}
.mail_msg .label {
  text-align: right;
  float: left;
  width: 4em;
  padding-right: .5em;
}
.mail_msg .field {
  Font('mail_msg_field');
  text-align: left;
}
.mail_msg {
  padding-bottom: 1ex;
}
.mail_msg .part {
  padding-bottom: 1ex;
}
EOF
}

sub _site_user_auth {
    return <<'EOF';
td.header_right div.user_state {
  vertical-align: top;
  text-align: right;
}
td.header_right div.user_state a {
  Font('user_state');
}
EOF
}

sub _site_wiki {
    return <<'EOF';
.help_link {
  Color('help_wiki-background');
  padding-left: .5em;
  padding-right: .5em;
  text-align: center;
}
.wiki .prose {
  text-indent: 2em;
  margin: 1ex 0 1ex 0;
}
#help_wiki_iframe {
  position: absolute;
  visibility: hidden;
  right: 1ex;
  width: 40em;
  z-index: 1;
}
div.help_wiki {
  Color('help_wiki-background');
}
.help_wiki table {
  font-size: 100%;
}
.help_wiki .help_wiki_body {
  text-align: left;
  font-size: 95%;
  padding-right: .5em;
  padding-left: .5em;
}
.help_wiki .header {
  margin: 0;
  padding-top: 0;
  padding-bottom: .5ex;
  text-align: center;
  font-weight: bold;
  font-size: 120%;
}
.help_wiki .footer {
  padding-top: .5ex;
  padding-bottom: .5ex;
  text-align: center;
}
div.wiki {
  padding-top: .5ex;
  padding-bottom: .5ex;
}
.help_close {
  text-align: right;
  padding-right: .5ex;
  font-size: 90%;
}
EOF
}

1;
