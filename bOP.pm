# Copyright (c) 2001-2014 bivio Software, Inc.  All Rights reserved. 
# $Id$
package Bivio::bOP;
use strict;
use base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::bOP - bivio OLTP Platform (bOP) overview and version

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::bOP;

=head1 DESCRIPTION

C<bOP> is a multi-dimensional, application framework.  At the highest level,
bOP provides support for web-delivered applications based on a
Model-View-Controller (MVC) architecture.  At the lowest level, bOP provides a
cohesive infrastructure for any Perl application.

We'll be writing more here later.  Please visit
http://www.bivio.biz for more info.

=head1 CHANGES

  $Log$
  Revision 13.38  2014/07/17 22:18:46  moeller
  * Bivio::PetShop::BConf
    disable use_file_manager
  * Bivio::Type::CacheTagFilePath
    fixed from_local_path() when not use_cached_path
  * Bivio::UI::Bootstrap::ViewShortcuts
    add seo links during vs_put_pager()
  * Bivio::UI::FacadeBase
    added microformat to Mail byline
  * Bivio::UI::View::Mail
    added microformat tags to message board
  * Bivio::UI::View::ThreePartPage
    added xhtml_seo_head_links view attr
  * Bivio::UI::XHTML::ViewShortcuts
    added vs_put_seo_list_links() to add pager and canonical head links
  * Bivio::UI::XHTML::Widget::MailBodyHTML
    added ITEMPROP attr for microformats
  * Bivio::UI::XHTML::Widget::MailBodyPlain
    set ITEMPROP="text" for microformats

  Revision 13.37  2014/07/15 16:58:52  moeller
  * Bivio::Type::CacheTagFilePath
    added use_cached_path config value to enable cached paths
  * Bivio::UI::HTML::Widget::Table
    added rel="nofollow" attribute to column sorting links

  Revision 13.36  2014/07/11 17:05:55  moeller
  * Bivio::Agent::HTTP::Reply
    added always_cache arg to set_cache_max_age() to force caching
    for tagged files running on dev
  * Bivio::BConf
    removed duplicate_threshold_seconds config
  * Bivio::Biz::Action::LocalFilePlain
    strip cache tag and set far-future max age (if applicable)
    pass "never_expire" boolean to Reply->set_cache_max_age() for tagged files
  * Bivio::Biz::Model::MailReceiveDispatchForm
    moved duplicate mail detection to Mail.Incoming
  * Bivio::Mail::Incoming
    moved duplicate checking from Model.MailReceiveDispatchForm
    looks through last 10 messages for duplicate match,
    comparing body and message date_time
  * Bivio::Mail::Outgoing
    changed b_die() to die FORBIDDEN for missing or invalid from header
  * Bivio::Test::HTMLParser::Forms
    strip cache tag from submit icon src
  * Bivio::Test::Reload
    use get_local_plain_file_name
  * Bivio::Type::CacheTag
  * Bivio::Type::CacheTagFilePath
    NEW
  * Bivio::UI::FacadeComponent::Icon
    add get_favicon_uri, use cache tag for icon uris
  * Bivio::UI::Facade
    join_with_local_file_plain -> get_local_plain_file_name
  * Bivio::UI::HTML::Widget::LocalFileLink
    use cache tagged uris
  * Bivio::UI::View::ThreePartPage
    add favicon link to head
  * Bivio::Util::Project
    join_with_local_file_plain moved to get_local_plain_file_name
  * Bivio::Util::RealmMail
    added clear_duplicate_messages()
  * Bivio::Util::SendmailHTTP
    changed server error to EX_SOFTWARE

  Revision 13.35  2014/07/08 21:02:31  nagler
  * Bivio::Mail::Common
    rewrite_from_domain: need to clear rewrite_from_domains for acceptance
    tests so they don't rewrite on sends to the server
  * Bivio::Mail::Outgoing
    moved _rewrite_from moved into send() so all From (and Return-Path,
    envelope_from, and Reply-To) get (re)written for alias sends and
    generated emails
  * Bivio::Test::Language::HTTP
    rewrite_from_domain: call Mail.Outgoing test_language_setup so that it
    gets a chance to modify configuration
  * Bivio::UI::HTML::Widget::Script
    removed trailing ',' from javascript hash to avoid errors
    in MSIE browsers with compatibility mode turned on

  Revision 13.34  2014/07/02 20:01:16  moeller
  * Bivio::HTML::Scraper
    allow setting Accept-Encoding header for websites which only return
    gzip data.
  * Bivio::MIME::Calendar
    ignore x-google- extensions

  Revision 13.33  2014/06/27 15:19:06  moeller
  * Bivio::MIME::Calendar
    ignore x-cost
  * Bivio::UI::HTML::Widget::TableBase
    don't include old html table attrs for 2014 style
  * Bivio::UI::View::ThreePartPage
    don't show "top" tag for 2014 style
    added xhtml_tag_attrs
  * Bivio::Util::SendmailHTTP
    added LWP timeout

  Revision 13.32  2014/06/17 20:05:57  moeller
  * Bivio::Biz::Model::RealmMailBounceList
    replace execute with execute_load_page_for_parent
  * Bivio::Mail::Common
    #984 fix rewrite_from_domains_re
    handle_config: need to group domains in re so that [@.] is required
    prior to domain
  * Bivio::ShellUtil
    fix uninitialized value if lock file is missing for stat()
  * Bivio::UI::FacadeBase
    moved arrow icon to icon named back_to_list
    Mail/CRM detail pages use back_to_list icon
  * Bivio::UI::View::Mail
    added label for "back to list"
  * Bivio::UI::XHTML::Widget::FeatureTaskMenu
    added task_menu_no_wrap option for 2014style
  * Bivio::UI::XHTML::Widget::RealmDropDown
    only wrap in DIV_task_menu_wrapper() for non 2014style
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    unwrapped DIV around TaskMenu

  Revision 13.31  2014/06/06 17:52:18  moeller
  * Bivio::Delegate::Cookie
    #874 set HttpOnly tag on Set-Cookie
  * Bivio::Type::EmailVerifyKey
    #880 if SUPER returns error, return (undef, $err)
  * Bivio::Type::String
    #873 remove common repeating symbols from excerpt
  * Bivio::UI::FacadeBase
    #908 added missing label for EmailAliasListForm

  Revision 13.30  2014/06/02 15:25:53  moeller
  * Bivio::Biz::Action::MailForward
    added support for REWRITE_FROM_DOMAIN_REFLECTOR task
  * Bivio::Delegate::TaskId
    added REWRITE_FROM_DOMAIN_REFLECTOR to handle
    user*<realm_id>@<mail_host> emails
  * Bivio::Mail::Common
    added yahoo and aol as rewrite_from_domains
  * Bivio::Mail::Outgoing
    added _rewrite_from for REWRITE_FROM_DOMAIN support
    modularized _inc_forward_header() to be clearer
  * Bivio::PetShop::Delegate::Location
    make subclass of Type.EnumDelegate so missing call errors are clearer
  * Bivio::PetShop::Util::SQL
    support testing rewrite-from-domain.test
  * Bivio::Test::Language::HTTP
    verify_mail: improve error message when emails don't match.  Printing
    the hash was the wrong thing, because the number is confusing
    (meaningless, actually, except as a boolean)
  * Bivio::Type::Location
    added first_alternative_location
  * Bivio::UI::FacadeBase
    added REWRITE_FROM_DOMAIN_REFLECTOR

  Revision 13.29  2014/05/28 18:05:29  moeller
  * Bivio::Biz::Model::UserRegisterForm
    internal_create_models() may return undef and set error,
    stop execution in execute_ok() if that happens
  * Bivio::Biz::Model::WikiForm
    catch constraint errors during "Save" button
  * Bivio::Biz::Model
    improved "missing key" warning
  * Bivio::Util::HTTPLog
    ignore missing error file if missing in first 5 minutes of the day
  * Bivio::Util::Spider
    don't persist cookie file

  Revision 13.28  2014/05/23 00:21:41  moeller
  * Bivio::Biz::Model::MailForm
    don't set In-Reply-To if subject has changed
  * Bivio::Biz::Model::MailThreadRootList
    order by most recent reply
  * Bivio::Biz::Model::RealmMail
    don't set threaded values if mail subject has changed
  * Bivio::Type::MailSubject
    added subject_lc_matches()
  * Bivio::UI::View::Mail
    show date of most recent reply in formatted message

  Revision 13.27  2014/05/22 19:47:43  moeller
  * Bivio::Biz::Action::Acknowledgement
    quietly catch invalid task ids from uri value
    made exists_in_facade() public
  * Bivio::Biz::Action::JSONReply
    catch JSON parse errors quietly during execute_javascript_log_error()
  * Bivio::Biz::Model::MailReceiveDispatchForm
    ignore messages with the "no-message-id" message id
  * Bivio::MIME::JSON
    guard against uninitialized $terminator
  * Bivio::UI::XHTML::Widget::Acknowledgement
    don't die if the acknowldgement label is invalid, could be a bad uri.
    warn instead

  Revision 13.26  2014/05/12 21:15:21  schellj
  * Bivio::UI::XHTML::Widget::ModalDialog
    make all content sections optional, standardize

  Revision 13.25  2014/05/10 02:38:23  schellj
  * Bivio::UI::XHTML::Widget::ModalDialog
    give ID to header and footer

  Revision 13.24  2014/05/10 02:21:39  schellj
  * Bivio::UI::XHTML::Widget::ModalDialog
    set body ID

  Revision 13.23  2014/05/09 21:49:56  schellj
  * Bivio::BConf
    added named config "none" for Bivio::Ext::DBI so can call from command line
  * Bivio::UI::Bootstrap::Widget::FormButton
    generally only the ok_button should be a "submit" button
    revert last commit (incorrect)
    allow instances to set their TYPE
  * Bivio::UI::XHTML::Widget::ModalDialog
    NEW

  Revision 13.22  2014/04/25 03:01:55  schellj
  * Bivio::UI::XHTML::ViewShortcuts
    added CANVAS html element
  * Bivio::UI::XHTML::Widget::NavContainer
    support altering NAV and container div classes

  Revision 13.21  2014/04/19 00:09:08  schellj
  * Bivio::UI::CSS::Widget::TransformAttr
    NEW

  Revision 13.20  2014/04/18 17:55:09  moeller
  Release notes:
  * Bivio::Type::UserAgent
    added BROWSER_MSIE_9 and BROWSER_MSIE_10
  * Bivio::UI::View::ThreePartPage
    moved msie8shim to a separate LocalFileAggregator to avoid missing CSS
    in IE8

  Revision 13.19  2014/04/15 20:16:01  moeller
   * Bivio::Util::SendmailHTTP
     translate "200 Assumed OK" response to a server error
     added local_agent and local_agent_args handling
     use EX_TEMPFAIL for most errors
   * Bivio::UI::Bootstrap::ViewShortcuts
     allow setting edit_col_class on form attrs
   * Bivio::Util::RealmAdmin
     need to set subscription if join_user with MAIL_RECIPIENT
   * Bivio::Biz::Model::RealmUserAddForm
     make _set_subscription public for use in Util.RealmAdmin
   * Bivio::Test::Util
     include %s in _mail_receive url

  Revision 13.18  2014/04/11 17:05:17  moeller
  * Bivio::Util::SendmailHTTP
    fpc

  Revision 13.17  2014/04/11 16:25:54  moeller
  * Bivio::BConf
    turn off use_wysiwyg in 2014style
  * Bivio::Biz::Model::WikiForm
    remove debug
  * Bivio::Biz::Util::RealmRole
    added audit_feature_categories() to detect incorrectly enabled realm features
  * Bivio::UI::View::CSS
    set size of wysiwyg_editor in 2014style
  * Bivio::UI::View::Wiki
    give editor an id, set args based on use_wysiwyg and 2014style
  * Bivio::Util::SendmailHTTP
    NEW, replaces b-sendmail-http.c

  Revision 13.16  2014/04/01 16:13:44  moeller
  * Bivio::UI::Bootstrap::Widget::SearchSuggestAddon
    removed
  * Bivio::UI::XHTML::Widget::SearchSuggestAddon
    moved from Bootstrap widget path because XHTML apps need the widget available

  Revision 13.15  2014/04/01 15:56:34  moeller
  * Bivio::BConf
    ignore duplicate cookie errors
    add IS_2014STYLE, update UIXHTML & XHTMLWidget maps
    default to use_wysiwyg editor if 2014style
  * Bivio::Biz::Action::JSONReply
    only warn on javascript errors if json has errorMsg, url and linNumber
  * Bivio::Biz::Model::MailReceiveDispatchForm
    fix to filter google calendar notifications in the form "Sender: Google
    Calendar <calendar-notification@google.com>"
  * Bivio::Biz::Model::WikiForm
    remove b_debug
  * Bivio::Delegate::TaskId
    View.WysiwygFile -> View.WYSIWYGFile
  * Bivio::Ext::MIMEParser
    catch warnings from MIME::Parser for uninitialized values
  * Bivio::Mail::Outgoing
    fixed uninitialized warning in set_headers_for_forward() with invalid "from"
  * Bivio::UI::Bootstrap::Widget::ButtonGroup
    NEW
  * Bivio::UI::Bootstrap::Widget::DropDownIconButton
    NEW
  * Bivio::UI::Bootstrap::Widget::FormButton
    _class moved to Tag->internal_class_with_additional
  * Bivio::UI::Bootstrap::Widget::IconButton
    NEW
  * Bivio::UI::Bootstrap::Widget::SearchSuggestAddon
    NEW
  * Bivio::UI::Bootstrap::Widget::Tag
    add internal_class_with_additional
  * Bivio::UI::Bootstrap::Widget::WYSIWYGEditor
    NEW
  * Bivio::UI::HTML::Widget::CKEditor
    removed
  * Bivio::UI::HTML::Widget::InputBase
    need to subclass from XHTMLWidget.Tag to allow for bootstrap override
  * Bivio::UI::HTML::Widget::LocalFileLink
    look in app, then common, die if not found
  * Bivio::UI::HTML::Widget::WYSIWYGEditor
    NEW
  * Bivio::UI::View::Search
    glyphicon -> b_icon
  * Bivio::UI::View::ThreePartPage
    update file paths, move jquery-ui into SearchSuggestAddon
  * Bivio::UI::View::Wiki
    CKEditor renamed to WYSIWYGEditor, don't pass params if_2014style
  * Bivio::UI::View::WysiwygFile
    removed
  * Bivio::UI::View::WYSIWYGFile
    NEW
  * Bivio::UI::XHTML::Widget::SearchSuggestAddon
    removed
  * Bivio::Util::Backup
    fixed piped_exec() with ignored && clause, split into two parts
  * Bivio::Util::Project
    use javascript-install path

  Revision 13.14  2014/03/13 18:59:34  schellj
  * Bivio::Biz::Action::AssertClient
    added assert_is_dev for TaskId
  * Bivio::Biz::Action::Bootstrap
    removed
  * Bivio::Biz::Model::MailReceiveDispatchForm
    allow bounce* address to get past oof filter so RealmMailBounce is created
  * Bivio::Delegate::SimpleAuthSupport
    added DEV_TRANSIENT
  * Bivio::Delegate::SimplePermission
    added DEV_TRANSIENT
  * Bivio::Delegate::TaskId
    info_dev now holds all DEV_* tasks and asserts dev
    remove GENERATE_BOOTSTRAP_CSS
  * Bivio::Mail::Common
    added "Auto-Submitted: auto-replied" to bounce header to simulate
    the mail server response
  * Bivio::Test::Reload
    generate bootstrap css if needed
  * Bivio::UI::Bootstrap::Widget::DropDown
    add space between label and caret
    fix for space between caret and label
  * Bivio::UI::FacadeBase
    added _cfg_dev to group all dev tasks
    remove GENERATE_BOOTSTRAP_CSS
    glyphicon -> b_icon
  * Bivio::UI::Facade
    fix for using with_setup_request when a facade isn't on the request yet
  * Bivio::UI::View::CSS
    remove left and right margin for b_icons
    adjust vertical alignment of b_icons
  * Bivio::UI::View::File
    added 2014 style file change view
  * Bivio::UI::View::ThreePartPage
    now generating bootstrap css in Test.Reload
    add fontello b_icon.css
  * Bivio::UI::XHTML::Widget::LinkIcon
    remove glyphicon class
  * Bivio::Util::HTTPConf
    added AddOutputByFileType DEFLATE
    turn off TraceEnable
  * Bivio::Util::HTTPD
    added DEFLATE filter for json data
  * Bivio::Util::Project
    bootstrap moved to src/javascript

  Revision 13.13  2014/02/28 00:41:21  moeller
  * Bivio::UI::View::ThreePartPage
    fixed missing _center_replaces_middle()

  Revision 13.12  2014/02/27 19:37:05  moeller
  * Bivio::Biz::Action::API
    fixed missing method
  * Bivio::Biz::Action::Bootstrap
    NEW
  * Bivio::Delegate::TaskId
    add GENERATE_BOOTSTRAP_CSS
  * Bivio::HTML::Scraper
    removed quoted cookie cleanup, breaks some html scrapers
  * Bivio::IO::Config
    add assert_dev
  * Bivio::ShellUtil
    add assert_dev
  * Bivio::UI::FacadeBase
    add GENERATE_BOOTSTRAP_CSS
    added 2014style attrs
    added 2014style copyright
    added icons for each category
  * Bivio::UI::Facade
    add want_generate_bootstrap_css config, if_want_generate_bootstrap_css
    remove want_generate_bootstrap_css config
  * Bivio::UI::View::CSS
    added render_2014style_css()
    2014style doesn't use site css
  * Bivio::UI::View::Mail
    added WANT_BOARD_ONLY_OPTION for subclasses
  * Bivio::UI::View::ThreePartPage
    use bootstrap css generation or local file
    remove want_generate_bootstrap_css config
    added 2014style head tags
    added 2014style layout items
  * Bivio::UI::XHTML::ViewShortcuts
    added stub for vs_placeholder_form()
  * Bivio::UI::XHTML::Widget::LinkIcon
    NEW
  * Bivio::UI::XHTML::Widget::NavContainer
    NEW
  * Bivio::UI::XHTML::Widget::TaskMenuOverride
    NEW
  * Bivio::Util::HTTPConf
    generate maintenance.html and set ErrorDocument on VirtualHost
    don't write the header if begins with <html
  * Bivio::Util::Project
    add generate_bootstrap_css
    better modularization
    add bootstrap_css_path, bootstrap_less_path

  Revision 13.11  2014/02/12 17:52:09  moeller
  * Bivio::Agent::TaskId
    bunit_validate_all() now allows for hash TaskId def
  * Bivio::Biz::Action::JSONReply
    use $req->warn() for javascript errors so realm/user info is logged
  * Bivio::SQL::Statement
    deprecated SELECT_AS()

  Revision 13.10  2014/02/11 03:49:24  moeller
  * Bivio::Agent::TaskId
    use JSONReply instead of EmptyReply
  * Bivio::Biz::FormModel
    form_is_json is true either if the CONTENT_TYPE_FIELD is json or
    if_req_is_json. jQuery sends url-encoded for ajax requests so we need
    to tell FormModel to use json_form_name_map instead of normal names
    removed cruft (_get_form)
  * Bivio::UI::HTML::Widget::Table
    remove debug
  * Bivio::Util::HTTPConf
    remove SSLLogLevel, not supported; set LogLevel to info to reduce
    logging noise

  Revision 13.9  2014/02/10 21:59:30  moeller
  * Bivio::Agent::HTTP::Form
    remove form_is_json (not correct)
    json support: put_req_is_json if _parse_json
  * Bivio::Agent::HTTP::Reply
    factored out send_append_header, which calls $r->headers_out->add(),
    which allows you to have multiple headers with the same name.
    Remove _add_additional_http_headers(), unused
    Fixed a bug in $r handling in send() -- client_redirection clears all
    attributes before calling send() so need to pull $r from $req
    cleaned up $status setting including using constants always
    Only have one call to _cookie_check()
    removed the dependency with stat(_) since the comment indicated an
    over-optimization
  * Bivio::Agent::Request
    json support: if_req_is_json and put_req_is_json
  * Bivio::Agent::TaskId
    json support: if_task_is_json and internal_json_decl
  * Bivio::Biz::Action::API
    NEW
  * Bivio::Biz::Action::EmptyReply
    empty HTTP_OK replies need to return HTTP_NO_CONTENT, because jQuery complain
  s
    with 'syntax error unexpected end of file'
  * Bivio::Biz::Action::Error
    json support: call JSONReply->execute_check_req_is_json on all
    execute, because just want to reply with the error, not a wiki page or
    other error page
    execute_from_javascript => JSONReply->execute_javascript_log_error
  * Bivio::Biz::Action::JSONReply
    NEW
  * Bivio::Biz::FormModel
    json support: if_req_is_json then different _task_result()
  * Bivio::Biz::Model::FileChangeForm
    added override_mode which allows form to post mode outside hidden value
  * Bivio::Biz::Model::FullCalendarForm
    NEW
  * Bivio::Biz::Model::FullCalendarList
    all events are editable
  * Bivio::Delegate::Cookie
    add domain to prior tags
    factored out _clear_prior_tags with handling duplicate and missing
    domains as well as setting Expires to a past date which will force the
    cookie to expire.
    append cookie header values in _clear_prior_tags(), don't replace
    changed cookie append hack to use $r->headers_out->add()
    always call headers_out->add
    call $reply->send_append_header which allows multiple Set-Cookie headers
  * Bivio::Delegate::SimpleRealmName
    added check_reserved_name() so can lock out names like api, pub, etc.
    check_reserved_name can't be called from_literal
  * Bivio::Delegate::TaskId
    doc dependency with TaskId.t
    json support: internal_json_decl around all json requests
    added FULL_CALENDAR_FORM_JSON
    added execute_check_req_is_json on certain tasks (errors) which don't
    go through Action.Error->execute (which calls execute_check_req_is_json)
  * Bivio::MIME::JSON
    to_text: do not escape ' (single quote)
    JSON is strict with escaping.  However some servers return single
    quoted strings (disallowed) so we have to be flexible to accept them.
    Improved error when backslash followed by unknown char
    to_text must be supplied a $value argument
    to_text(undef) returns 'null'
  * Bivio::Test::Bean
    the old mode of return values passed as first argument is no longer
    valid.  Added test_bean_register_callback to allow dynamic additions
    to the interface without having to know the argument syntax.
  * Bivio::Test::Reply
    added send_append_header, simulating what HTTP::Reply does
  * Bivio::Test::Request
    r->headers_out() returns a Test.Bean (same one each time)
    need "add()" callback on $reply->headers_out since Reply->send_append_header
    uses headers_out()->add() now
    fix order of subs
  * Bivio::Type::UserAgent
    added is_msie_8_or_before
  * Bivio::UI::FacadeBase
    added FULL_CALENDAR_FORM_JSON
    renamed JAVASCRIPT_LOG_ERROR to JAVASCRIPT_LOG_ERROR_JSON
    added API_JSON
  * Bivio::UI::Facade
    make if_2014style work correctly with no args
  * Bivio::UI::HTML::Widget::LocalFileAggregator
    cruft
  * Bivio::UI::View::CRM
    uses new vs_inline_form() for selector
  * Bivio::UI::View::File
    made _last_updated() public for subclasses
  * Bivio::UI::View::Mail
    added internal_reply_links() and internal_thread_list() for subclasses
    hide empty mail headings only for 2014style
    put root list task before form task for standard tools if_2014style
  * Bivio::UI::View::Wiki
    make wiki editor wider if 2014style
  * Bivio::UI::Widget::Prose2
    NEW
  * Bivio::UI::Widget
    better doc a "widget name may not contain underscore"
  * Bivio::UI::XHTML::ViewShortcuts
    wrap smart date in bivio_smart_date span
    fix singular text for 'hours' and 'minutes'
    added vs_inline_form()
  * Bivio::UI::XHTML::Widget::ClearOnFocus
    fixed another double-quoted value
  * Bivio::UI::XHTML::Widget::ComboBox
    added internal_cb_size() for subclasses
  * Bivio::Util::Backup
    use need to use --apparent-size on du, because file systems can compress
  * Bivio::Util::HTTPConf
    SSLLogLevel needs to be set for v2, because it outputs "info" by default
  * Bivio::Util::TaskLog
    response_code is successful if matches 2xx or 3xx
  * Bivio::Util::TestMail
    make $_SUBJECTS a sub so that it can be overridden

  Revision 13.8  2014/02/03 13:51:44  nagler
  * Bivio::UI::View::File
    use vs_smart_date if_2014style
  * Bivio::UI::View::Mail
    use vs_smart_date if_2014style
  * Bivio::UI::View::Search
    use vs_smart_date if_2014style, fix placement of paging arrows
  * Bivio::UI::XHTML::ViewShortcuts
    add vs_smart_date

  Revision 13.7  2014/02/03 05:21:22  nagler
  * Bivio::Biz::Model::FullCalendarList
    JSON conversion has to happen as TypeValues, because boolean and integer have to appear as literals, not strings
  * Bivio::MIME::JSON
    JSON conversion has to happen as TypeValues, because boolean and integer have to appear as literals, not strings
  * Bivio::Type::Array
    to_json must not escape by default
    JSON conversion has to happen as TypeValues, because boolean and integer have to appear as literals, not strings
  * Bivio::Type::Boolean
    to_json must not escape by default
  * Bivio::Type::DateTime
    to_json must not escape by default
    JSON conversion has to happen as TypeValues, because boolean and integer have to appear as literals, not strings
  * Bivio::Type::Email
    JSON conversion has to happen as TypeValues, because boolean and integer have to appear as literals, not strings
  * Bivio::Type::Enum
    to_json must not escape by default
    JSON conversion has to happen as TypeValues, because boolean and integer have to appear as literals, not strings
  * Bivio::Type::Integer
    JSON conversion has to happen as TypeValues, because boolean and integer have to appear as literals, not strings
  * Bivio::Type
    to_json must not escape by default
    JSON conversion has to happen as TypeValues, because boolean and integer have to appear as literals, not strings
  * Bivio::UI::View::Calendar
    JSON conversion has to happen as TypeValues, because boolean and integer have to appear as literals, not strings

  Revision 13.6  2014/02/03 04:00:23  nagler
  * Bivio::UI::HTML::Widget::Table
    column_control is called with render_simple_value so you can have a
    widget as the value
  * Bivio::UI::XHTML::ViewShortcuts
    pass options attrs to vs_simple_form() in vs_list_form()

  Revision 13.5  2014/02/02 16:29:15  nagler
  * Bivio::Biz::Model::CRMForm
    superfluous return
  * Bivio::Biz::Model::FullCalendarList
    NEW
  * Bivio::Biz::Model::SearchList
    simplify format_uri_params_with_row, add result_type
  * Bivio::Biz::Model::SearchSuggestList
    NEW
  * Bivio::bOP
    RCS file: /home/cvs/perl/Bivio/bOP.pm,v
    Working file: Bivio/bOP.pm
    head: 13.4
    branch:
    locks: strict
    access list:
    symbolic names:
    keyword substitution: kv
    total revisions: 1139;	selected revisions: 0
    description:
  * Bivio::Delegate::TaskId
    add SEARCH_SUGGEST_LIST_JSON, GROUP_SEARCH_SUGGEST_LIST_JSON
    added FULL_CALENDAR_LIST_JSON
    fix FULL_CALENDAR_LIST_JSON
  * Bivio::Search::Xapian
    allow results from partial queries
  * Bivio::Type::CalendarEventRecurrence
    extend period of valid dates
  * Bivio::Type::DateTime
    test from_unix() arg validaity
    add to_local
  * Bivio::Type::Email
    added to_json
  * Bivio::Type
    added to_json which defaults to_xml
  * Bivio::TypeValue
    added as_json
  * Bivio::UI::CSS::Widget::MockStylus
    NEW
  * Bivio::UI::CSS::Widget::VendorPrefixBase
    NEW
  * Bivio::UI::FacadeBase
    add IS_2014STYLE, if_2014style
    moved 2014STYLE to superclass
    added ECCreditCardPayment text
    add SEARCH_SUGGEST_LIST_JSON, GROUP_SEARCH_SUGGEST_LIST_JSON
    use get_local_file_plain_app_uri to set LOCAL_FILE_PLAIN uri for /f/
    define is_2014style as constant
    added FULL_CALENDAR_LIST_JSON
  * Bivio::UI::Facade
    moved is_2014style() from FacadeBase
    added get_local_file_plain_app_uri used by LocalFileLink
    if_2014style uses is_2014style() so modular
    is_2014style gets facade from source if possible
  * Bivio::UI::HTML::Widget::DateTime
    fix for am/pm when time % 12 == 0
  * Bivio::UI::HTML::Widget::DateYearHandler
    when defaulting year, use 300 day window so entering a Dec date in Jan
    defaults to the previous year
  * Bivio::UI::HTML::Widget::InlineCSS
    NEW
  * Bivio::UI::HTML::Widget::InlineJavaScript
    NEW
  * Bivio::UI::HTML::Widget::JavaScriptString
    Put in "" so uses don't have to
  * Bivio::UI::HTML::Widget::LocalFileAggregator
    NEW
  * Bivio::UI::HTML::Widget::LocalFileLink
    NEW
  * Bivio::UI::HTML::Widget::Page
    use html5 doctype for is_2014style()
    use if_2014style and get_from_source
  * Bivio::UI::HTML::Widget::Script
    don't first-focus to the SearchForm.search field
  * Bivio::UI::HTML::Widget::Select
    removed default size=1, only show size if != 1
    added "class" attr
  * Bivio::UI::HTML::Widget::TextArea
    refactored, now derived from InputBase
  * Bivio::UI::View::Base
    add json
    doc
  * Bivio::UI::View::Calendar
    added full_calendar_list_json
  * Bivio::UI::View::CSS
    if internal_site_css returns a reference, then don't add it to Prose,
    just interpret literally
  * Bivio::UI::View::Mail
    don't show_headings for Mail list
  * Bivio::UI::View::Search
    add suggest_list_json
    adjust column classes for suggest title - bootstrap doesn't display
    col-xs-1 and col-xs-11 well at small sizes
    tweak look and feel of search suggest
    replace star with paperclip for wiki pages
    fix image regex
  * Bivio::UI::View::ThreePartPage
    added xhtml_body_last
    added internal_xhtml_tools() hook for subclasses
  * Bivio::UI::ViewShortcuts
    vs_local_file_plain_common_uri
  * Bivio::UI::Widget::If2014Style
    NEW
  * Bivio::UI::Widget::WidgetSubstitute
    NEW
  * Bivio::UI::XHTML::ViewShortcuts
    added NAV tag
    added hook for subclasses - vs_simple_form_container()
  * Bivio::UI::XHTML::Widget::ClearOnFocus
    JavaScriptString now puts in ""
  * Bivio::UI::XHTML::Widget::ComboBox
    added internal_cb_text_class() for subclasses
  * Bivio::UI::XHTML::Widget::JSONValueLabelPairList
    NEW
  * Bivio::UI::XHTML::Widget::SearchSuggestAddon
    NEW
  * Bivio::UI::XHTML::Widget::StandardSubmit
    added space between buttons
  * Bivio::UI::XHTML::Widget::TaskMenu
    made selected class configurable
    added hooks internal_drop_down_widget() and internal_wrap_widget()
    for subclasses
  * Bivio::Util::HTTPConf
    added request_read_timeout constant as header=5 so produces RequestReadTimeout header=5
  * Bivio::Util::HTTPD
    added $ENV{BIVIO_IS_2014STYLE} lookup so can override without checking in
  * Bivio::Util::Release
    _get_update_list: added defaulting of $version and $rpm
  * Bivio::Util::Shell
    added u_prefix_path_env

  Revision 13.4  2014/01/03 02:38:01  schellj
  * Bivio::Biz::Action::MotionBase
    NEW
  * Bivio::Biz::Action::MotionList
    NEW
  * Bivio::Biz::Action::Motion
    NEW
  * Bivio::Biz::Model::MailReceiveDispatchForm
    make ooo filter configurable
    remove b_debug
  * Bivio::Delegate::TaskId
    redirect to FORUM_MOTION_IS_CLOSED when attempting to vote or comment
    on a closed motion
  * Bivio::Mail::Incoming
    add grep_headers
  * Bivio::Test::Language::HTTP
    add get_link_in_table
  * Bivio::UI::FacadeBase
    add FORUM_MOTION_IS_CLOSED
  * Bivio::UI::View::Motion
    add is_closed
  * Bivio::UI::Widget
    commented-out deprecated warning for widget with "_" in name

  Revision 13.3  2013/12/12 18:50:34  schellj
  * Bivio::Biz::Action::ClientRedirect
    add execute_query_redirect
  * Bivio::Delegate::TaskId
    add LOGGED_QUERY_REDIRECT
  * Bivio::MIME::Calendar
    allow date values which are mislabeled as date-time
  * Bivio::PetShop::Util::TestData
    reset calendar_btest_user's time zone
  * Bivio::Test::Language::HTTP
    decode html emails
    fix for getting uri from html emails
    uri_and_local_mail: use different regex for html vs plain text email
  * Bivio::UI::FacadeBase
    add LOGGED_QUERY_REDIRECT, grammar in no cookies text
  * Bivio::UI::View::UserAuth
    alphabetize subs
  * Bivio::Util::TestMail
    print every 100 generated test messages

  Revision 13.2  2013/12/06 21:29:59  moeller
  * Bivio::Biz::Model::CalendarEventForm
    default the time-zone to the user's time-zone creating.
    save user time-zone from event time-zone if user tz is tz default
  * Bivio::Biz::Model::CalendarEventList
    format time with Type.Time
  * Bivio::Biz::Model::CalendarEventWeekList
    #855 fix daylight savings iterate bug
  * Bivio::Biz::Model::RealmMail
  * Bivio::Mail::Incoming
    renamed Type.MailSubject trim_literal() to clean_and_trim()
  * Bivio::Type::DateTimeWithTimeZone
    use Type.Date and Type.Time when formatting literal
  * Bivio::Type::MailSubject
    combined trim_literal() and clean_and_trim()
  * Bivio::Type::String
    trim utf8 strings to correct byte length
  * Bivio::Type::Time
    added time_format_24 config value, default is 1
    allows literal form with am/pm
  * Bivio::UI::FacadeBase
    updated calendar border color
  * Bivio::UI::View::CSS
    improved calendar border

  Revision 13.1  2013/11/27 17:06:00  moeller
  * Bivio::Biz::Model::MailReceiveDispatchForm
    exempt messages from calendar-notification@google.com from
    out-of-office filter
  * Bivio::Type::CountryCode
    added new countries from ISO 3166-1-alpha-2 code list
  * Bivio::Util::Search
    don't destroy db if resuming rebuild_db

  Revision 13.0  2013/11/25 17:34:05  nagler
  Rollover to 13.0

  Revision 12.97  2013/11/25 16:56:25  moeller
  * Bivio::Util::NamedConf
    allow DKIM1 TXT records to be added using kdim1 config value
  * Bivio::Util::Search
    make rebuild_db, audit_db resumable

  Revision 12.96  2013/11/20 21:44:27  moeller
  * Bivio::BConf
    ignore no-message-id errors
  * Bivio::Biz::Action::Error
    fixed error in execute_from_javascript() for GET requests
  * Bivio::Biz::Model::CRMThreadRootList
    postgres performance - replaced left joins with subselects
    removed customer.RealmOwner
  * Bivio::Biz::Model::ForumTreeList
    parent_and_children: don't assume that user has access to parent forum
  * Bivio::Biz::Model::MailThreadRootList
    added missing realm_id to subselect
  * Bivio::UI::HTML::Widget::Script
    window.onerror() wrap whole method in try/catch
  * Bivio::Util::Search
    commit every document, sleep after every 10 documents

  Revision 12.95  2013/11/03 22:11:55  moeller
  * Bivio::BConf
    added more ignore errors
  * Bivio::Biz::FormModel
    put task_id back on response during redirect, fixes workflow cancel
  * Bivio::Biz::Model::BlogList
    return NOT_FOUND for missing this
  * Bivio::Biz::Model::ForumUserEditDAVList
    override_default_subscription when create/edit
  * Bivio::Biz::Model::MailReceiveDispatchForm
    don't let ooo filter ignore bugzilla messages
  * Bivio::PetShop::Util::SQL
    pass query to delete_all()
  * Bivio::ShellUtil
    refactored lock_action to reuse cleanup
    use rm_rf so any junk is cleaned, too
    use catch_and_rethrow
  * Bivio::UI::View::Blog
    added extra args to WikiText()
  * Bivio::UI::View::SiteAdmin
    fixed checkbox on remote_copy_form
  * Bivio::Util::RealmMail
    assert_not_root for import methods
  * Bivio::Util::Search
    add sleep parameter to audit_db, audit_realm, rebuild_db, rebuild_realm
    clarify command descriptions
  * Bivio::Util::Wiki
    include all_txt in validate_all_realms result

  Revision 12.94  2013/10/29 23:34:11  moeller
  * Bivio::Biz::Model::BlogCreateForm
  * Bivio::Biz::Model::BlogEditForm
  * Bivio::Biz::Model::BlogList
    renamed body field to content to match WikiForm
  * Bivio::Biz::Model::Bulletin
    override delete_all(), delete all bulletins in db - no auth_id
  * Bivio::Biz::Model::RealmFile
    ensure there are query args to SUPER::delete_all()
  * Bivio::Biz::PropertyModel
    added deprecated warning to delete_all() if no query is passed
    don't call delete_all() from cascade_delete() if no child keys match
  * Bivio::UI::FacadeBase
    changed Blog.body to Blog.content
  * Bivio::UI::View::Blog
    moved edit() code to View.Wiki
  * Bivio::UI::View::CSS
    wiki config - hide .cke_toolbar until CKEditor skin is loaded
  * Bivio::UI::View::Wiki
    combined edit() and edit_wysiwyg(), now shares with View.Blog
  * Bivio::Util::RealmMail
    delete_message_id: call cascade_delete on loaded model to ensure
    children get deleted correctly

  Revision 12.93  2013/10/28 20:16:01  moeller
  * Bivio::Agent::TaskEvent
    added TASK_EXECUTE_STOP (clearer marker than 1)
    added form_model_state
  * Bivio::Biz::FormModel
    support from_is_json
  * Bivio::Biz::Model::BlogList
    removed render_html(), replaced by UI widget
    added unsafe_get_author_image_uri()
  * Bivio::Biz::Model::RealmFile
    export TXN_FILE_PATTERN_RE
  * Bivio::Delegate::TaskId
    removed config v3 tasks for Blog/Wiki
  * Bivio::Die
    eval should $_CATCH_QUIETLY
  * Bivio::IO::File
    added do_find
  * Bivio::Search::Xapian
    acquire_lock after computing postings
  * Bivio::UI::FacadeBase
    removed config v3 tasks for Blog/Wikig
  * Bivio::UI::Facade
    added if_html5
  * Bivio::UI::View::Base
    removed unused xhtml_menu
  * Bivio::UI::View::Blog
    new layout for blog list and detail pages
    removed old v3 config
  * Bivio::UI::View::CSS
    use if_html5
    reformat blog css
  * Bivio::UI::WidgetOutput
    return $self
  * Bivio::Util::RealmAdmin
    added verify_realm_owners()

  Revision 12.92  2013/10/22 19:02:56  schellj
  * Bivio::Biz::Model::MailReceiveDispatchForm
    tighten unsubscribe filtering to subjects with "unsubscribe" as only text
  * Bivio::Biz::Model::RealmUserAddForm
    add override_default_subscription for forms that have an explicit
    is_subscribed field, otherwise use default
  * Bivio::UI::HTML::Widget::JavaScript
    render common code on the root request (for embedded items)
  * Bivio::UI::HTML::Widget::Script
    call encodeURIComponent() on JSON uri data

  Revision 12.91  2013/10/19 01:37:15  schellj
  Release notes:
  * Bivio::Biz::Action::Error
    added execute_from_javascript()
  * Bivio::Biz::Model::ForumUserEditDAVList
    is_subscribed now a field in RealmUserAddForm, use it instead of dont_add_subscription
  * Bivio::Biz::Model::RealmUserAddForm
    add is_subscribed field in addition to dont_add_subscription, these
    need to be separate
  * Bivio::Delegate::TaskId
    added JAVASCRIPT_LOG_ERROR task
  * Bivio::UI::FacadeBase
    added JAVASCRIPT_LOG_ERROR task
  * Bivio::UI::HTML::Widget::Script
    added b_log_errors script
  * Bivio::UI::View::ThreePartPage
    added v_log_errors script

  Revision 12.90  2013/10/17 23:17:54  moeller
  * Bivio::Biz::Model::MailReceiveDispatchForm
    add more rules for filtering out of office messages
    added automatic unsubscribe handling
    loosened out-of-office match
  * Bivio::Biz::Model::MailUnsubscribeForm
    added unsubscribe()
  * Bivio::Type::UserAgent
    BROWSER_ANDROID -> BROWSER_ANDROID_STOCK, add BROWSER_CHROME_PHONE, BROWSER_C
  HROME_TABLET
    more mobile browsers
  * Bivio::Util::RealmAdmin
    include UserRealmSubscription info in users()
  * Bivio::Util::User
    show UserRealmSubscription info in realms()

  Revision 12.89  2013/10/09 18:20:00  schellj
  * Bivio::UI::HTML::Widget::SlideOutSearchForm
    NEW

  Revision 12.88  2013/10/09 18:12:02  schellj
  * Bivio::Type::UserAgent
    add BROWSER_ANDROID
  * Bivio::UI::HTML::Widget::Script
    add JAVASCRIPT_B_SLIDE_OUT_SEARCH_FORM
  * Bivio::UI::XHTML::Widget::ClearOnFocus
    allow specification of ONFOCUS attribute

  Revision 12.87  2013/10/07 20:51:02  moeller
    * b-sendmail-http converts a 503 to EX_TEMPFAIL rather than mailbox full

  Revision 12.86  2013/09/30 21:44:48  moeller
  * Bivio::Biz::Model::CRMForm
    added want_status_email config value
  * Bivio::Biz::Model::MailUnsubscribeForm
    don't unsubscribe unless it is a bulletin realm
  * Bivio::Mail::Incoming
    fixed uninitialized warning
  * Bivio::MIME::Word
    encode WINDOWS-1252
  * Bivio::Test::Unit::Unit
    call_process_cleanup at the end of unit tests
  * Bivio::Type::DisplayName
    fixed uninitialized value
  * Bivio::UI::HTML::Widget::SourceCode
    loosened module name match so TaskId renders item links
  * Bivio::Util::HTTPConf
    ssl_mdc is gone
    ssl_only wasn't working for hosts for which it wasn't set globally

  Revision 12.85  2013/08/26 16:43:25  moeller
  * Bivio::Biz::Model::CRMThread
    set modified_by_user_id using from_email on create
  * Bivio::MIME::Word
    detect and decode UTF-8 encoding
  * Bivio::Type::MailSubject
    decode RFC 2047 subjects during trim_literal()
  * Bivio::UI::HTML::Widget::Script
    only call onchange() if the function is defined
  * Bivio::UI::View::CRM
    added column class for word breaks to CRM subject
  * Bivio::UI::View::CSS
    added b_word_break_all

  Revision 12.84  2013/08/22 20:13:32  moeller
  * Bivio::UI::HTML::Widget::Tag
    no longer eval class for parent selector path, don't know the source
  * Bivio::UI::View::CSS
    added rounded bounder and shadow to dd_menu for html5

  Revision 12.83  2013/08/21 22:17:20  moeller
  * Bivio::Biz::Action::DAV
    set DAV header to "1,2", allows "mount -t davfs" to work
  * Bivio::Biz::Model::TreeList
    parse "expand" query arg and throw a CORRUPT_QUERY if invalid
  * Bivio::MIME::Calendar
    ignore x-published-*
  * Bivio::PetShop::BConf
    fancy_input --> is_html5
  * Bivio::UI::CSS::ViewShortcuts
    removed vs_css_color()
    added vs_color() and vs_lighter_color()
  * Bivio::UI::CSS::Widget::BorderAttr
    added color attr
  * Bivio::UI::CSS::Widget::Button
  * Bivio::UI::CSS::Widget::OKButton
  * Bivio::UI::HTML::Widget::FormFieldLabel
  * Bivio::UI::HTML::Widget::StandardSubmit
    removed
  * Bivio::UI::CSS::Widget::ShadowAttr
    added gradient attr
  * Bivio::UI::FacadeBase
    added _html5_css() definition
  * Bivio::UI::Facade
    added is_html5 config attr
  * Bivio::UI::HTML::Widget::FormField
    moved "fancy_input" config value to UI.Facade->is_html5
  * Bivio::UI::HTML::Widget::Tag
    register widget CSS selector with View.CSS
  * Bivio::UI::View::CSS
    added add_to_css() for registering widget css during render()
  * Bivio::UI::XHTML::Widget::FormFieldLabel
    moved html5 config to UI.Facade

  Revision 12.82  2013/08/12 16:47:11  moeller
  * Bivio::PetShop::UICSS::ViewShortcuts
    renamed Shadow to ShadowAttr
    renamed Border to BorderAttr

  Revision 12.81  2013/08/12 16:38:19  moeller
  * Bivio::UI::CSS::Widget::Button
    renamed Border to BorderAttr
  * Bivio::UI::CSS::Widget::ShadowAttr
    renamed Border to BorderAttr

  Revision 12.80  2013/08/12 16:30:40  moeller
  * Bivio::UI::CSS::Widget::BorderAttr
    renamed from Bivio::UI::CSS::Widget::Border
  * Bivio::UI::CSS::Widget::Button
    renamed Shadow to ShadowAttr
  * Bivio::UI::CSS::Widget::OKButton
    renamed Shadow widget to ShadowAttr
  * Bivio::UI::CSS::Widget::ShadowAttr
    renamed from Bivio::UI::CSS::Widget::Shadow
  * Bivio::UI::HTML::Widget::ClearDot
    fixed initialize_with_parent() call
  * Bivio::UI::HTML::Widget::FormButton
    removed default class and is_primary
  * Bivio::UI::View::CSS
    renamed Border to BorderAttr, Shadow to ShadowAttr
  * Bivio::UI::XHTML::Widget::StandardSubmit
    put button class back

  Revision 12.79  2013/08/10 00:59:52  schellj
  * Bivio::Biz::Model::RealmEmailList
    add internal_is_subscribed
  * Bivio::Biz::Model::UserRealmSubscription
    fix bug for assigning default is_subscribed when given value is 0
  * Bivio::Delegate::SimpleWidgetFactory
    don't default FormButton label
  * Bivio::MIME::Calendar
    ignore x-from- tags
    ignore exrule
  * Bivio::UI::CSS::Widget::Button
    combined input.submit def
  * Bivio::UI::FacadeBase
    add fancy data row hover highlight
    moved input_field Font to CSS section
  * Bivio::UI::HTML::Widget::FormButton
    now derived from InputBase
    moved NEW_ARGS() into internal_new_args() used by superclass
    added is_primary attribute
  * Bivio::UI::View::CSS
    add fancy data row hover highlight
    moved input_field Font to CSS
    added nowrap to combo and search buttons
  * Bivio::UI::XHTML::Widget::StandardSubmit
    moved default button class to FormButton
    call initialize_with_parent() on button list
  * Bivio::Util::SQL
    rework internal_upgrade_db_user_realm_subscription to only process
    realms with an existing MAIL_RECIPIENT, handle ISTO forums that allow
    GUEST subscribers

  Revision 12.78  2013/08/05 18:24:09  schellj
  * Bivio::Util::SQL
    internal_upgrade_db_user_realm_subscription category_role_group
    already array ref

  Revision 12.77  2013/08/05 18:13:19  schellj
  * Bivio::Util::SQL
    internal_upgrade_db_user_realm_subscription new_other -> model

  Revision 12.76  2013/08/05 17:58:09  schellj
  * Bivio::Biz::Model::Forum
    delete subscriptions when deleting children
  * Bivio::Biz::Model::ForumTreeListForm
    user UserRealmSubscription instead of MAIL_RECIPIENT
  * Bivio::Biz::Model::ForumTreeList
    use UserRealmSubscription
  * Bivio::Biz::Model::ForumUserEditDAVList
    mail_recipient -> is_subscribed
  * Bivio::Biz::Model::ForumUserList
    mail_recipient -> is_subscribed, use UserRealmSubscription instead of MAIL_RECIPIENT
  * Bivio::Biz::Model::GroupUserForm
    updates for UserRealmSubscription
  * Bivio::Biz::Model::GroupUserList
    left join UserRealmSubscription, update privileges calculation
  * Bivio::Biz::Model::GroupUserQueryForm
    replace MAIL_RECIPIENT with UserRealmSubscription.is_subscribed
  * Bivio::Biz::Model::MailUnsubscribeForm
    updates for UserRealmSubscription
  * Bivio::Biz::Model::RealmBase
    add internal_set_default_values so subclasses don't have to repeat
    code when overriding create
  * Bivio::Biz::Model::RealmEmailList
    left join UserRealmSubscription.is_subscribed, update get_recipients
    to return addresses of users that are UserRealmSubscription.is_subscribed
  * Bivio::Biz::Model::RealmOwnerBase
    add UserRealmSubscription, UserDefaultSubscription to cascade_delete_model_list
  * Bivio::Biz::Model::RealmUserAddForm
    set subscription, always add MAIL_RECIPIENT
  * Bivio::Biz::Model::UnapprovedApplicantList
    need to add RealmOwner.creation_date_time to group_by with left join
    on UserRealmSubscription in GroupUserList
  * Bivio::Biz::Model::UserDefaultSubscription
    NEW
  * Bivio::Biz::Model::UserRealmSubscription
    NEW
  * Bivio::Biz::Model::UserSettingsListForm
    add UserDefaultSubscription, update to use UserRealmSubscription
    instead of MAIL_RECIPIENT for forum subscriptions
  * Bivio::Biz::Model::UserSubscriptionList
    left join UserRealmSubscription.is_subscribed
  * Bivio::PetShop::UICSS::ViewShortcuts
    overrides for larger petshop field padding
  * Bivio::PetShop::Util::SQL
    add fourem-sub3, fourem-sub4
  * Bivio::SQL::DDL
    add user_realm_subscription_t, user_default_subscription_t
  * Bivio::UI::FacadeBase
    added input_field font def
    MAIL_RECIPIENT -> UserRealmSubscription.is_subscribed
  * Bivio::UI::HTML::Widget::Script
    combo box dropdown now sizes to text width, dropdown arrow now within bounds
  * Bivio::UI::View::CSS
    form input now uses input_field facade font def
    moved combo box arrow within text field bounds
    moved search button within search field bounds
    added combobox dropdown shading
  * Bivio::UI::View::GroupAdmin
    user_form GroupUserForm.mail_recipient -> GroupUserForm.is_subscribed
  * Bivio::UI::View::Tuple
    center checkbox
  * Bivio::UI::View::UserAuth
    settings_form add UserDefaultSubscription.subscribed_by_default
  * Bivio::UI::XHTML::Widget::ComboBox
    text field now has cb_text class
  * Bivio::Util::Forum
    not_mail_recipient -> dont_add_subscription
  * Bivio::Util::RealmAdmin
    add subscribe_user_to_realm, unsubscribe_user_from_realm
  * Bivio::Util::SQL
    add internal_upgrade_db_user_realm_subscription

  Revision 12.75  2013/07/31 23:09:16  moeller
  * Bivio::Biz::Action::LocalFilePlain
    added execute_apple_touch_icon()
  * Bivio::Biz::FailoverWorkQueue
    renamed failover_work_queue_t primary id
  * Bivio::Biz::Model::FileChangeForm
    changed name and rename_name fields to NonHiddenFileName type
  * Bivio::Biz::Model::SearchList
    filter out rows where the RealmMail record is missing
  * Bivio::Cache
    use nfreeze() for 64 bit compatibility
  * Bivio::Delegate::SimpleTypeError
    added FILE_NAME_LEADING_DOT
  * Bivio::Delegate::TaskId
    added APPLE_TOUCH_ICON task
  * Bivio::SQL::DDL
    rename failover_work_queue_t primary id
  * Bivio::Type::NonHiddenFileName
    NEW
  * Bivio::UI::FacadeBase
    added APPLE_TOUCH_ICON task
  * Bivio::Util::FailoverWorkQueue
    renamed failover_work_queue_t primary id
  * Bivio::Util::Release
    download_file wasn't passing correct param to http_get
  * Bivio::Util::SQL
    added db upgrade to fix failover_work_queue_t primary key

  Revision 12.74  2013/07/10 20:11:01  moeller
  * Bivio::Biz::Action::ECCreditCardProcessor
    map error code 54 (invalid credit) to a failure status
  * Bivio::Biz::Model::ECCreditCardPayment
    use is_bad() rather than eq_declined() to determine if payment/credit failed
  * Bivio::UI::HTML::Widget::NewEmptyRowHandler
    match_name() now works for dev or prod form field names
  * Bivio::UI::HTML::Widget::Script
    made get_sibling() public as b_get_sibling()
    combo box saves selected on tab key
    combo box calls field.onchange() when saved
  * Bivio::UI::XHTML::Widget::ComboBox
    added text_attrs value
  * Bivio::Util::Disk
    added --portability so wouldn't break lines with long directory names

  Revision 12.73  2013/07/03 15:47:37  moeller
  * Bivio::Biz::Model::MailReceiveDispatchForm
    add out of office filtering
  * Bivio::Mail::Outgoing
    add X-Auto-Response-Supress: OOF to set_headers_for_list_send
  * Bivio::PetShop::Util::SQL
    fourem-mail-filtering -> mail_forum-filtering
  * Bivio::UI::HTML::Widget::GoogleAnalytics
    NEW

  Revision 12.72  2013/06/21 17:25:10  schellj
  * Bivio::Type::DisplayName
    add from_names
  * Bivio::UI::JavaScript::Widget::WidgetInjector
    fix uninitialized value in concatenation error when javascript view not present
  * Bivio::UI::XHTML::ViewShortcuts
    don't include colspan, labelless items are aligned under fields

  Revision 12.71  2013/06/14 16:51:38  moeller
  * Bivio::Biz::Action::MailForward
    use email_alias_incoming to pass to set_headers_for_forward so that
    the sender is set.  This may help mitigate SPF problesm with forwarding
  * Bivio::Biz::Model::MailReceiveDispatchForm
    set email_alias_incoming so that MailForward can set Sender
  * Bivio::Mail::Outgoing
    set_headers_for_forward now sets Sender:
  * Bivio::Type::Secret
    fixed uninitialized warning if decryption fails

  Revision 12.70  2013/06/13 16:34:59  moeller
  * Bivio::Biz::Model::CSVImportForm
    moved validate_record() out of columns loop
    improved error detail formatting
  * Bivio::IO::Config
    allow Root-only.bconf if BCONF is Root::.*->
  * Bivio::UI::Text::Widget::CSV
    fpc

  Revision 12.69  2013/06/10 17:39:38  moeller
  * Bivio::Biz::Model::UserRegisterForm
    internal_create_models: use Type_Email()->get_local_part instead of regex
  * Bivio::Biz::PropertyModel
    add generate_unique_for_field
  * Bivio::Delegate::SimpleWidgetFactory
    pass attrs to time zone combo
  * Bivio::Type::DateTime
    allow parsing from dd_mm_yyyy_hh_mm_ss format
  * Bivio::UI::Text::Widget::CSV
    iterate with request query
  * Bivio::UI::View::UserAuth
    indent the user settings forum list
  * Bivio::UI::XHTML::ViewShortcuts
    added indent_list option to vs_list_form()
    position label-less fields under input fields
  * Bivio::Util::Release
    added download_file (untested)

  Revision 12.68  2013/06/05 23:25:13  moeller
  * Bivio::Die
    put stack trace guards back
  * Bivio::Util::HTTPConf
    added foreach_ping(), foreach_command()

  Revision 12.67  2013/06/04 16:05:16  moeller
  * Bivio::Biz::Model::RealmMailBounce
    strip file suffix from bounce email to shorten
  * Bivio::SQL::ListQuery
    die if column in order by, but missing from model def
  * Bivio::Test::MockReturn
    NEW
  * Bivio::Test::Unit::t::Unit::T1
    test mock_methods
  * Bivio::Test::Unit::Unit
    added builtin_mock_methods

  Revision 12.66  2013/05/26 20:43:49  nagler
  * Bivio::BConf
    don't insert DBI config if db eq non
  * Bivio::Biz::Action::Error
    head_in(referrer) can return () so need to force to be scalar
  * Bivio::Biz::FormModel
    RCS file: /home/cvs/perl/Bivio/Biz/FormModel.pm,v
    Working file: Bivio/Biz/FormModel.pm
    head: 2.104
    branch:
    locks: strict
    access list:
    symbolic names:
    keyword substitution: kv
    total revisions: 199;	selected revisions: 0
    description:
  * Bivio::Biz::Model::CalendarEvent
    fixed inherited autoload
  * Bivio::ShellUtil
    handle_call_autoload: return $proto if class is ShellUtil
  * Bivio::Test::Unit::Unit
    moved AUTOLOAD to call_autoload so can call from subclasses, since
    AUTOLOAD can't be inherited

  Revision 12.65  2013/05/26 01:58:36  nagler
  * Bivio::Biz::FormModel
    add internal_process_args
  * Bivio::Biz::ListFormModel
    add get_fields_for_primary_keys to values if process called internally
  * Bivio::Biz::Model::RealmBase
    add REALM_ID_FIELD_TYPE
  * Bivio::Search::Xapian
    Was getting "use of uninitialized value in subroutine entry" in call
    to set_cuff where weight_cutoff and percent_cutoff were 0.  This was a
    guess.  The "use of..." call happens in the XS code somewhere when
    these are 0.
  * Bivio::UI::Widget::ControlBase
    take out widget substitute for now
  * Bivio::UNIVERSAL
    added method_that_does_nothing()
    unsafe_request didn't work if class wasn't a super class of
    Agent.Request.  Also now always return undef (sometimes was returning 0)
  * Bivio::Util::Backup
    _do_backticks: Call unsafe_get_request to see if there's a request so
    we can execute statically
  * Bivio::Util::LinuxConfig
    upgraded serial_console for RH6.2 with serial redirect from BIOS (Dell
    supports this)
    removed sendmail cruft

  Revision 12.64  2013/05/23 19:34:02  nagler
  * Bivio-bOP.spec
    points files/petshop/plain/b to /usr/share/Bivio-bOP-javascript

  Revision 12.63  2013/05/22 22:22:28  nagler
  * Bivio::Util::Release
    hostname for install_host_stream must be Sys::Hostname::hostname

  Revision 12.62  2013/05/22 22:12:40  nagler
  * Bivio::Mail::Outgoing
    remove_headers was not working
    Added X-Mailer on set_headers_for_list_send
    use remove_headers in set_headers_for_list_send

  Revision 12.61  2013/05/22 16:23:26  nagler
  * Bivio::Biz::FormModel
    Factored internal_get_form from _get_form, because needed to cache the
    result with modified json values.  ExpandableListFormModel depends on
    the value being cached.
    Support json form input
  * Bivio::Util::Backup
    _zfs_file_system needs to convert mount points to zfs dataset names

  Revision 12.60  2013/05/22 00:25:53  nagler
  * Bivio::Agent::HTTP::Form
    added _b_form_model_content_type to form values so we can detect what
    type the form is in FormModel
    Added application/json parsing
    Refactored to be cleaned dispatch
  * Bivio::Agent::RequestId
    use Bivio.BConf->bconf_host_name
  * Bivio::BConf
    added bconf_host_name, which should be used in place of
    Sys::Hostname::hostname(). $ENV{BIVIO_HOST_NAME} should be set for
    dev environments
  * Bivio::Biz::Action::AssertClient
    use Bivio.BConf->bconf_host_name
  * Bivio::Biz::Action::EasyForm
    delete FormModel->CONTENT_TYPE_FIELD from get_form so doesn't show up
    in csv
  * Bivio::Biz::Action::RealmMail
    local variable issue with perl 5.16
  * Bivio::Biz::ExpandableListFormModel
    call internal_get_form, which caches the result (see FormModel)
  * Bivio::Biz::Model::JobLock
    use Bivio.BConf->bconf_host_name
  * Bivio::Ext::LWPUserAgent
    max_redirect(1) even when want_redirects is false because getting:
    Client-Warning: Redirect loop detected (max_redirect = 0)
    in the headers from LWP even when requests_redirectable() is empty.
  * Bivio::IO::Config
    fix case when DefaultBConf->merge is used. The pattern match was
    expecting ::BConf, when should have been BConf.
  * Bivio::IO::File
    use Bivio.BConf->bconf_host_name
  * Bivio::PetShop::Facade::Other
    added case for HTTPStats where site_reports_realm_name is undef
  * Bivio::ShellUtil
    use Bivio.BConf->bconf_host_name
  * Bivio::SQL::FormSupport
    modularized _form_name() and added json_form_name
  * Bivio::SQL::Support
    FormModel->get_model_properties error:
    Attributes.pm:205 Use of uninitialized value $_ in exists
    caused by FormModel->get_model_properties() referencing
    constraining_field which is not an alias nor really referenced
  * Bivio::SQL::t::Support::T1Form
    FormModel->get_model_properties error:
    Attributes.pm:205 Use of uninitialized value $_ in exists
    caused by FormModel->get_model_properties() referencing
    constraining_field which is not an alias nor really referenced
  * Bivio::Test::Language::HTTP
    use Bivio.BConf->bconf_host_name
  * Bivio::Test::Unit::FormModel
    added form_is_json option for testing
  * Bivio::Test::Util
    remove cruft
  * Bivio::Type::Email
    use Bivio.BConf->bconf_host_name
  * Bivio::Type::Regexp
    Handle new charset modifiers in perl 5.14: ?^ means ?d-imsx
    The ?^ was causing PERMISSION_DENIED.
    added is_stringified_regexp
  * Bivio::Type::String
    move wrap_newlines to TextArea
  * Bivio::Type::TextArea
    String->wrap_lines became TextArea::_wrap_lines, because wasn't used
    anywhere.
    _wrap_lines calls canonicalize_charset
    from_literal only appends newline if there isn't already a newline
  * Bivio::UI::Widget::Director
    added is_stringified_regexp
    fpc: from_literal_or_die on the Regexp, since it should convert
    correctly if is_stringified_regexp
  * Bivio::Util::Backup
    leading slash wasn't getting removed on _zfs_file_system parse
  * Bivio::Util::HTTPD
    use Bivio.BConf->bconf_host_name
    PassEnv BIVIO_HTTPD_PORT
  * Bivio::Util::HTTPLog
    use Bivio.BConf->bconf_host_name
    PassEnv BIVIO_HTTPD_PORT
  * Bivio::Util::HTTPStats
    site_reports_realm_name may be undef, then _domain_forum_map_one was
    return undef, not empty array so map had undef, and this caused
    _sort_default_facade_first to dereference undef
  * Bivio::Util::NamedConf
    category cname and response-checks aren't defined in RH6.2 (bind 9.8)
    so don't add them
    fmt
  * Bivio::Util::Release
    use Bivio.BConf->bconf_host_name
  * Bivio::Util::SQL
    ddl_dir must initialize_fully

  Revision 12.59  2013/05/13 23:23:34  nagler
  * Bivio::Util::Disk
    df needs to be a hardwired executable for _data to work right
  * Bivio::Util::SQL
    allow ddl_dir to be called from other utils

  Revision 12.58  2013/05/13 02:53:05  nagler
  * Bivio::Ext::LWPUserAgent
    Set bivio_ssl_no_check_certificate if is_test, because
    remote-copy.btest was failing, since remote system didn't have valid cert
  * Bivio::PetShop::Util::TestCRM
    use req->format_email for EmailAlias (not Test)
  * Bivio::Util::Backup
    restructured zfs_* routines
  * Bivio::Util::Disk
    added zpool status check
    removed rd (old controller)
    refactored to be cleaner

  Revision 12.57  2013/05/12 20:42:42  nagler
  * Moved javascript to Bivio-bOP-javascript.rpm
  * Bivio::Biz::Action::ECCreditCardProcessor
    b_use
  * Bivio::Ext::LWPUserAgent
    added bivio_ssl_no_check_certificate and bivio_redirect_automatically
    new: want_redirects param is deprecated.  Default is still redirects
    off.
    Added POST to valid redirects, because you probably redirect after a
    form POST.
    LWP 6.x switched to ssl cert checking by default so need to set
    bivio_ssl_no_check_certificate explicitly in a few cases
  * Bivio::IO::ClassLoaderAUTOLOAD
    use replace_subroutine
  * Bivio::IO::ClassLoader
    IO::Dir calls File:stat which tests some state in an eval(), which
    causes Bivio::Die to die (can't seem to detect this case) so need to
    protect with require_external_module_quietly
  * Bivio::IO::Config
    defined(@array) is deprecated so just check for arguments (not defined)
  * Bivio::IO::File
    IO::Dir calls File:stat which tests some state in an eval(), which
    causes Bivio::Die to die (can't seem to detect this case) so need to
    protect with require_external_module_quietly
  * Bivio::PetShop::View::CSS
    b_use; fix ViewLanguageAUTOLOAD
  * Bivio::PetShop::View::Example
    b_use; fix ViewLanguageAUTOLOAD
  * Bivio::PetShop::View::PetShop
    don't put commas "Dogs:111,6,..." in a qw(), because Perl will complain
  * Bivio::PetShop::View::SiteRoot
    b_use; fix ViewLanguageAUTOLOAD
  * Bivio::PetShop::View::Source
    b_use; fix ViewLanguageAUTOLOAD
  * Bivio::PetShop::View::UserAuth
    b_use; fix ViewLanguageAUTOLOAD
  * Bivio::Test::Language::HTTP
    Use bivio_ssl_no_check_certificate
  * Bivio::Test::Util
    Use bivio_ssl_no_check_certificate and bivio_redirect_automatically
  * Bivio::Type::Enum
    unsafe_from_any might be passed undef
  * Bivio::UI::ViewLanguageAUTOLOAD
    added handle_class_loader_require (import() calls this)
    use replace_subroutine
  * Bivio::UNIVERSAL
    added global_variable_ref which is used by package_version
  * Bivio::Util::CPAN
    added more uri_lookaside_map
  * Bivio::Util::HTTPPing
    set bivio_redirect_automatically
  * Bivio::Util::NamedConf
    use LWPUserAgent->bivio_http_get
  * Bivio::Util::Release
    allow multiple Provides: lines (gets merged onto a single line)
    set PERL_LWP_SSL_VERIFY_HOSTNAME to 0, because we use self-signed
    certs mostly.  LWP 6.0 requires this.
    Use bivio_ssl_no_check_certificate and bivio_redirect_automatically

  Revision 12.56  2013/05/09 22:48:24  nagler
  * Bivio::UI::Widget::ControlBase
    WidgetSubstitute is slowing things down

  Revision 12.55  2013/05/08 19:22:19  moeller
  * Bivio::Biz::FormModel
    encapsulate format_enum_set_field
  * Bivio::Delegate::SimpleWidgetFactory
    pass attrs to CheckboxGrid
  * Bivio::Type::Enum
    fix sub order
  * Bivio::UI::FacadeComponent::WidgetSubstitute
    if there is no facade then get_widget_substitute_value returns undef (no op)
    Some older apps initialize widgets during Task initialization when the
    facade is yet initialized.
  * Bivio::UI::FacadeComponent
    added get_from_facade
  * Bivio::UI::HTML::Widget::CheckboxGrid
    use Biz_FormModel->format_enum_set_field

  Revision 12.54  2013/05/07 23:36:23  moeller
  * Bivio::Parameters
    fpc - allow Delegate type

  Revision 12.53  2013/05/07 22:29:44  moeller
  * Bivio::Agent::Task
  * Bivio::Biz::Action::ECSecureSourceProcessor
  * Bivio::Biz::Action::SiteRoot
  * Bivio::Biz::Action::WikiView
  * Bivio::Biz::Model::CRMActionList
  * Bivio::Ext::NetFTP
  * Bivio::UI::HTML::Format::Link
  * Bivio::UI::HTML::Widget::Grid
  * Bivio::UI::HTML::Widget::ImageFormButton
  * Bivio::UI::HTML::Widget::Image
  * Bivio::UI::HTML::Widget::LineCell
  * Bivio::UI::HTML::Widget::Page
  * Bivio::UI::HTML::Widget::Select
  * Bivio::UI::HTML::Widget::String
  * Bivio::UI::HTML::Widget::Style
  * Bivio::UI::HTML::Widget::TableBase
  * Bivio::UI::HTML::Widget::Table
  * Bivio::UI::HTML::Widget::TextArea
  * Bivio::UI::View::CRM
  * Bivio::UI::XHTML::ViewShortcuts
    b_use(FacadeComponent.*)
  * Bivio::BConf
    Moved TestUnit map classes to Bivio::Test::Unit
    added Bivio::UI::CSS::Widget to CSSWidget map
  * Bivio::Biz::FormModel
    change enum_set_fields_decl to take qualified field
    move enum_set_from_fields to internal_put_enum_set_from_fields
    add internal_put_fields_from_enum_set
    do_non_zero_list -> map_non_zero_list
    b_use(FacadeComponent.*)
  * Bivio::Biz::Model::FormModeBaseForm
    make delegatable
  * Bivio::Die
    print other attributes named "stack" as stack traces
  * Bivio::Test::Case
    added get_test
  * Bivio::Test
    added test ($self) attr onto case
  * Bivio::Type::Enum
    do_list -> map_list, do_non_zero_list -> map_non_zero_list
  * Bivio::UI::CSS::ViewShortcuts
    added vs_css_color()
  * Bivio::UI::FacadeBase
    added WidgetSubstitute (empty)
    added FacadeComponent.ViewSupport
    added default colors for fancy_input
  * Bivio::UI::FacadeComponent::Text
    join_tag optimization was broken: had "." instead of \.
    added split_tag
  * Bivio::UI::FacadeComponent::ViewSupport
    NEW
  * Bivio::UI::FacadeComponent::WidgetSubstitute
    NEW
  * Bivio::UI::HTML::Widget::FormField
    added fancy_input config value, shows error in left bubble
  * Bivio::UI::HTML::Widget::SourceCode
    added method anchor for Views
  * Bivio::UI::HTML::Widget::Tag
    use WidgetOutput instead of appending to buffer directly
  * Bivio::UI::HTML::Widget::TaskInfo
    refactored
    added method anchors for Views
  * Bivio::UI::View::CSS
    added fancy_input config
  * Bivio::UI::View
    move the cache to FacadeComponent.ViewSupport so facades are doing the
    caching which will allow different view_class_map (etc.) per facade.
  * Bivio::UI::Widget::ControlBase
    use WidgetSubstitute as override for widget
  * Bivio::UI::Widget::Simple
    subclass ControlBase.  This doesn't always make subclasses of this
    class work right, because they call render, not control_on_render
  * Bivio::UI::WidgetOutput
    NEW
  * Bivio::UI::Widget
    added widget_render_args which calls WidgetOutput
  * Bivio::UI::XHTML::Widget::FormFieldLabel
    added error bubble for fancy_input
    set class label on error_bubble
  * Bivio::UI::XHTML::Widget::StandardSubmit
    added b_ok_button class to ok button

  Revision 12.52  2013/05/02 17:13:14  moeller
  * Bivio::Agent::Request
    Push format_email code mostly to Type.Email
  * Bivio::Base
    calling context needs to exclude the current pacakge
  * Bivio::BConf
    document why Bivio::UI not in UICSS map (CSS doesn't use ordinary widgets)
    ignore error message for mail to default realm
    rename trace filter perf to perf_time
  * Bivio::Biz::Action::MailForward
    pass req to set_headers_for_forward
  * Bivio::Biz::Action::RealmMail
    pass req to set_headers_for_list_send
  * Bivio::Biz::FormModel
    add enum_set_fields_decl, enum_set_from_fields
  * Bivio::Delegate::SimpleWidgetFactory
    create CheckboxGrid from EnumSet
    use SQL_Support()->extract_column_name for CheckboxGrid field
  * Bivio::Die
    added _print_stack_other() to print widget/view_stack in a more
    readable format
  * Bivio::IO::Alert
    calling_context takes skip_packages which may be array_ref. Was only
    treating as scalar before, but IO.CallingContext accepted array
  * Bivio::IO::CallingContext
    changed as_string to make it useful for printing context in alerts (see Die::
  _print_stack_other)
    new_from_file_line sets sub & package, too, just to make it easier to manage
  * Bivio::Mail::Common
    export config
    added rewrite_from_domains
  * Bivio::Mail::Outgoing
    set_headers_for_list_send now puts in List-ID and Precedence: List
    From: email addresses are rewritten if rewrite_from_domains matches address
  * Bivio::MIME::Calendar
    Allow language to be specified on 'description'.
  * Bivio::Parameters
    allow parameters to be any object.  Verifies is_blesser_of
  * Bivio::PetShop::BConf
    removed unused Action map
    added class map for PetShopWidget
  * Bivio::PetShop::UICSS::ViewShortcuts
    fancy form and list css
  * Bivio::PetShop::View::Base
    moved xhtml_dock_left_standard to facade config
    no longer uses petshop view shortcuts
  * Bivio::PetShop::View::PetShop
    chrome/safari need named MAP
    use PetShopWidget class map and PetShop.ViewShortcuts
    rearranged user account page
  * Bivio::Test::HTMLParser::Forms
    handle form labels within <label> with no ":"
  * Bivio::Test::Widget
    added widget_post_new
  * Bivio::Type::Email
    format_email takes over work for req->format_email
  * Bivio::Type::Enum
    add do_list, do_non_zero_list
  * Bivio::UI::CSS::ViewShortcuts
    view_autoload interface changed to pass in simple_method and suffix as
    well as method.
  * Bivio::UI::FacadeComponent::Email
    Push format_email code mostly to Type.Email
  * Bivio::UI::FacadeComponent
    downcase 'names' value used in group() to initialize the group the
    first time.
  * Bivio::UI::Facade
    Search for FacadeComponent in UI first (deprecated usage) and then FacadeComp
  onent
  * Bivio::UI::HTML::Widget::CheckboxGrid
    NEW
  * Bivio::UI::HTML::Widget::FormField
    added internal_get_label_widget() for subclasses
  * Bivio::UI::HTML::Widget::Grid
    subclasses ControlBase now
  * Bivio::UI::HTML::Widget::MultipleChoiceGridBase
    NEW
  * Bivio::UI::HTML::Widget::RadioGrid
    push common logic down to MultipleChoiceGridBase
  * Bivio::UI::HTML::Widget::SourceCode
    added anchors at method definitions
  * Bivio::UI::HTML::Widget::TableBase
    subclasses ControlBase now
  * Bivio::UI::HTML::Widget::Table
    subclasses ControlBase
  * Bivio::UI::View::ThreePartPage
    label ThreePartPage Grid widgets
  * Bivio::UI::ViewLanguageAUTOLOAD
    added call_autoload so can be called from UI.ViewShortcuts to save
    calling context.
    renamed unsafe_calling_context to unsafe_calling_context_for_wiki_text
    because it is an odd routine, and only was used by WikiText
    Added unsafe_calling_context which just returns $_CALLING_CONTEXT
    Added widget_new_calling_context to strip out all the irrelevant packages
  * Bivio::UI::ViewLanguage
    added labelling of widgets (b_widget_label).  This will be used to
    control rendering and will improve debugging.  Also save calling
    context of where widget new() is called
  * Bivio::UI::View
    unsafe_get_current is being used for more than debuggin
    push the views on the view_stack as instances, not strings so
    Die::_print_other_stack will do the right thing
    unsafe_get_current will not return -1, which is when the view is being
    evaled but hasn't gotten to the instance stage.
  * Bivio::UI::ViewShortcuts
    save calling context
    don't need to pass calling_context in vs_call, because
    ViewLanguageAUTOLOAD can figure out the calling context by stripping
    packages using IO.CallingContext features
  * Bivio::UI::Widget::ControlBase
    call SUPER::initialize
  * Bivio::UI::Widget
    added b_widget_label which returns the label or allows you to label
    the widget and set calling context.  This gets done automatically in
    new() based on state saved by UI.ViewLanguage
    add as_string_for_stack_trace so stack trace does the right thing
    internal_as_string includes the label
    use widget_new_calling_context in new() (don't call calling_context directly)
  * Bivio::UI::XHTML::ViewShortcuts
    view_autoload interface changed to pass in simple_method and suffix as
    well as method so parsing is done in ViewLanguage, not here
    changed $no_submit arg for vs_simple_form() to $attrs,
    map old boolean value to no_submit key
  * Bivio::UI::XHTML::Widget::WikiText
    renamed unsafe_calling_context to unsafe_calling_context_for_wiki_text
    because it is an odd routine, and only was used by WikiText
  * Bivio::UNIVERSAL
    call_and_do_after gets result and wantarray so can modify result
    b_can needs to check $other is an object

  Revision 12.51  2013/04/27 23:17:34  moeller
  * Bivio::PetShop::*
    converted PetShop bview to View::PetShop
    added XHTMLWidget and UICSS maps
    refactor models
  * Bivio::Type::Enum
    get strings from facade if possible
  * Bivio::Type::WikiName
    added configuration param for Default/StartPage
  * Bivio::UI::FacadeBase
    add EmailVerifyForm.prose.prologue
    password_query_mail.to, create_mail.to
  * Bivio::UI::FacadeComponent::Enum
    NEW
  * Bivio::UI::Facade
    don't try to pre-load UI.Enum
  * Bivio::UI::View::Blog
    ' ... ' is redundant
  * Bivio::UI::View::UserAuth
    move email_verify prose to facade
    move internal_mail 'to' field to facade
  * Bivio::UNIVERSAL
    add unsafe_get_request

  Revision 12.50  2013/04/23 00:46:26  moeller
  * Bivio::Base
    added b_print()
  * Bivio::Biz::Action::Error
    fixed internal_render_content to do the right thing when
    ActionError_want_wiki_view is false
  * Bivio::Biz::Model::RealmOwnerBase
    added internal_initialize_by_realm_type
  * Bivio::Biz::Model::UnitTestForm
    NEW
  * Bivio::Biz::Model::UserCreateForm
    use format_ignore_random
  * Bivio::Biz::PropertyModel
    default internal_initialize
  * Bivio::IO::Ref
    added print_string
  * Bivio::PetShop::BConf
    Added Util map name
  * Bivio::Search::Xapian
    Allow 'elite_set' search
    Allow 'weight' and 'percent' cutoff to be specified.
  * Bivio::SQL::Support
    constraining_field was not being initialized
  * Bivio::Type::Email
    added format_ignore_random
  * Bivio::UI::FacadeBase
    added support for mobile apps.
    Changed default uri to /bp (no apps are using /hm/index)

  Revision 12.49  2013/04/19 21:28:58  moeller
  * Bivio::Biz::QueryType
    Descriptions can't be duplicates so explicitly code method and uri_attr
  * Bivio::Delegate::RowTagKey
    Don't rely on get_short_desc being anything other than a
    (non-duplicate) string.
    added internal_get_type to get the type
  * Bivio::Delegate::SimpleWidgetFactory
    use NO_QUERY for missing query type
  * Bivio::Type::Enum
    Restructured to use hash instead of array for info as first step
    towards dynamic values from facade
  * Bivio::Type::EnumSet
    removed comment
  * Bivio::Type::MailSendAccess
    use config for default
  * Bivio::Type::RowTagKey
    use internal_get_type to get the type
  * Bivio::UI::Align
    description now must be unique, map no_css text separately
  * Bivio::UNIVERSAL
    if_then_else now passes $proto to code_refs

  Revision 12.48  2013/04/18 22:47:18  moeller
  * Bivio::Type::LoginName
    fixed get_width() to use integer comparison
  * Bivio::Type::Regexp
    added add_regexp_modifiers to allow you to structure regexps better.
    Parsing from the regexp itself didn't work right, because the nested
    regexp didn't see the modifies

  Revision 12.47  2013/04/12 23:53:43  schellj
  qx changes

  Revision 12.46  2013/04/12 23:19:44  schellj
  * Bivio::Type::LoginName
    add get_width
  * Bivio::Util::TestUser
    added default_password config value

  Revision 12.45  2013/04/11 15:25:46  moeller
  * Bivio::Biz::ExpandableListFormModel
  * Bivio::Biz::Model::BlogEntryList
  * Bivio::Biz::Model::EmailAliasEditDAVList
  * Bivio::Biz::Model::ForumTreeListForm
  * Bivio::Biz::Model::ForumUserDeleteForm
  * Bivio::Biz::Model::LocationBase
  * Bivio::Biz::Model::OTP
  * Bivio::Biz::Model::TupleDefSelectList
  * Bivio::Biz::Model::TupleHistoryList
  * Bivio::Biz::Model::TupleList
  * Bivio::Biz::Model::TupleSlotTypeListForm
    use Bivio::Base
  * Bivio::Biz::FormModel
    get_literal() returns '' for ref types
  * Bivio::Biz::ListFormModel
    get_field_name_for_html() now calls superclass
    refactored $_SEP parsing into one method
    added internal_in_list_name()
  * Bivio::Biz::Model::BlogForm
    replaced call to private superclass method _authorized_name()
  * Bivio::Biz::Model::WikiForm
    renamed _authorized_name() to internal_authorized_name() for subclasses

  Revision 12.44  2013/04/09 23:55:14  moeller
  * Bivio::Biz::Model::UserSettingsListForm
    execute methods using auth_user_id as auth_id to support subclasses
    which operate in a different realm
  * Bivio::MIME::JSON
    Optimize parsing of strings which do not contain backslash escaping
    (such as base64 encoded data). This reduced the cpu consumption for a
    2.4MB string from 16 secs to 30mS.

  Revision 12.43  2013/04/02 16:48:10  schellj
  * Bivio::Biz::Model::AdmSubstituteUserForm
    use LoginName type
  * Bivio::Biz::Model::UserLoginBaseForm
    use LoginName type
  * Bivio::Biz::Model::UserLoginForm
    call super from execute_ok
  * Bivio::Type::LoginName
    NEW
  * Bivio::UI::FacadeBase
    add FormError.login.SYNTAX_ERROR

    qx changes

  Revision 12.42  2013/03/22 00:37:48  schellj
  qx changes

  Revision 12.41  2013/03/21 00:45:40  schellj
  * Bivio::Type::DomainNameArray
    allow comma or space separator

    qx changes

  Revision 12.40  2013/03/19 16:52:23  schellj
  * Bivio::Biz::Model::AcceptanceTestList
    Whitespace
  * Bivio::HTML::Scraper
    remove leading/trailing quotes from misquoted cookie values
  * Bivio::Search::Parser::RealmFile::MSOfficeBase
    add error pattern
  * Bivio::Test::Util
    selenium now runs as a service and gets restarted nightly

    qx changes

  Revision 12.39  2013/03/06 22:46:16  schellj
  qx changes - tablet support

  Revision 12.38  2013/03/06 02:49:28  schellj
  * Bivio::Biz::Model::AcceptanceTestTransactionList
    Display current URI anchor for each  interaction to make results
    easier to read.

  Revision 12.37  2013/03/03 21:52:47  schellj
  qx changes

  Revision 12.36  2013/02/27 21:08:46  schellj
  * Bivio::Util::Forum
    make cascade_delete_forum public
    move delete_unattached_users to Util.RealmUser
  * Bivio::Util::RealmUser
    delete_unattached_users moved from Util.Forum

    qx_changes

  Revision 12.35  2013/02/23 01:22:34  moeller
  * Bivio::Agent::HTTP::Reply
    moved send_fd() eval around $r->print() to catch and ignore client drops
  * Bivio::Agent::Request
    need to use b_can for delegated types
  * Bivio::BConf
    added more errors to ignore
  * Bivio::UI::HTML::Widget::Checkbox
    use dynamic checkbox id on for ListFormModel fields with in_list set
  * Bivio::UI::HTML::Widget::MultiCheckHandler
    fixed multi-check for non sequential list fields

  Revision 12.34  2013/02/14 01:04:56  moeller
  * Bivio::Biz::Model::FilterQueryForm
    remove leading * from search words
  * Bivio::Biz::Model::SummaryList
    added get_list_model()
  * Bivio::Search::Xapian
    Make date ranges such as 2010/01/31..2012/12/31 and ..12/31/2012 work.
  * Bivio::UI::HTML::Widget::Checkbox
    generate html ID using list model cursor for ListFormModels
  * Bivio::UI::HTML::Widget::MultiCheckHandler
    fixed case where form field name contained an underscore

  Revision 12.33  2013/02/05 19:08:32  schellj
  qx changes

  Revision 12.32  2013/02/04 22:09:39  schellj
  qx changes

  Revision 12.31  2013/02/01 01:34:31  schellj
  * Bivio::Biz::Model::Email
    add email_for_auth_user
  * Bivio::UI::HTML::Widget::LineCell
    fixed unreplaced PAGE_BG, refactored
  * Bivio::UI::XHTML::Widget::MailBodyPlain
    modularize text formatting

  Revision 12.30  2013/01/28 04:01:01  schellj
  qx changes

  Revision 12.29  2013/01/28 02:59:10  schellj
  * Bivio::Biz::Model::AcceptanceTestTransactionList
    Allow selenium test results to be viewed.
  * Bivio::Biz::Model::RealmFeatureForm
    call super from execute_ok
  * Bivio::UI::View::AcceptanceTestResultViewer
    Allow selenium test results to be viewed.
  * Bivio::UI::View::UserAuth
    _mail -> internal_mail

  Revision 12.28  2013/01/21 01:46:59  schellj
  * Bivio::Delegate::Cookie
    'domain must begin with dot (.)' doesn't work always.  Using a foo.org
    as a cookie domain requires it go back to foo.org (.foo.org will not
    be returned to foo.org)
  * Bivio::IO::ClassLoader
    _map_args() was too strict on checks for package style name.  Just
    need to check for ::
  * Bivio::SQL::Connection::Postgres
    perl 5.10 has problems with recursive regular expressions (no longer
    recursive).  See http://www.perlmonks.org/?node_id=810857
    Need to change parsing of FROM in _fixup_outer_join
  * Bivio::SQL::Connection
    move $_MAX_BLOB to where it is used so subclasses can override.
    Calling MAX_BLOB() without an object is cruft
  * Bivio::Type::Secret
    After Crypt::CBC 2.17, header_mode must be set to randomiv to be
    backwards compatible with old encryptions.  There is a bug with non
    8-byte ciphers when randomiv is used, but this only effects obscure
    ciphers.
  * Bivio::Util::HTTPConf
    eval_or_die doesn't report errors nicely if the code is not in a sub
    {}.  On RH 6.2 it says
    Attempt to reload Scalar/Util.pm aborted.
    Compilation failed in require at /usr/share/perl5/overload.pm line 94.
    fpc: that didn't fix it.  The problem was a map({}, ()), where the
    extra comma was causing the Scalar::Util message.
  * Bivio::Util::LinuxConfig
    bug in 2.47; --encoding=SQL_ASCII handled in system pkgs

  Revision 12.27  2013/01/18 00:46:18  schellj
  qx changes

  Revision 12.26  2013/01/16 04:29:01  schellj
  * Bivio::IO::Config
    bconf_dir_hashes deals with bconf_file not being a file and there
    being no bconf.d.
    when no $BCONF or /etc/bivio.bconf, use Bivio::DefaultBConf->merge
    even if $BIVIO_HTTPD_PORT is not set.  This allows bootstrap on
    systems without bOP installed
    bconf_dir_hashes was broken: wasn't checking bconf_file correctly
  * Bivio::Util::Class
    added u_find_all to identify duplicates
    added u_find_all_duplicates
  * Bivio::Util::HTTPD
    use $ENV{BCONF} literally.  We don't modify it so just use it literally
  * Bivio::Util::LinuxConfig
    use .rpmsave, not .bak, because new cron says:
    (root.bak) ORPHAN (no passwd entry)

  Revision 12.25  2013/01/11 22:00:04  schellj
  * Bivio::Biz::Action::UserPasswordQuery
    changed call to req->server_redirect(), use task item return value instead
  * Bivio::MIME::Calendar
    _seconds_from_hhmmss may get undef values for $minutes and $seconds so
    need to protect from undef in addition (perl 5.10/centos 6.2)

  Revision 12.24  2013/01/10 17:13:45  schellj
  * Bivio::BConf
    dev_overrides() params changed to ($home, $host, $user, $http_port, $files_root, $perl_lib)
    Do not rely on $pwd.
    Removed dev_root()
    Default more in dev() to make it so you don't need a custom *.bconf
    for most development purposes
  * Bivio::Biz::Model::ImageUploadForm
    make use of Image::Magick dynamic. CentOS 6.2 has a problem with
    multiple clients of libuuid.  Importing Search::Xapian and
    Image::Magick into the same program causes a SEGV.
    fmt
  * Bivio::IO::Config
    If $ENV{BIVIO_HTTPD_PORT} is set, module is in "dev" mode, which
    allows $ENV{BCONF} to be a *::BConf, e.g. Bivio::PetShop::BConf (or
    Bivio::PetShop).  ->dev is automatically appended, or another method
    can be specfied.  ~/bconf.d (or ~/bconf/bconf.d) is the bconf_dir
    Added bootstrap_package_dir for Bivio::BConf
    $_BCONF_DIR must always be set to something, because bconf_dir_hashes
    relies on it being defined
  * Bivio::PetShop::BConf
    removed dev_overrides (SourceCode override is now in Bivio::BConf)
  * Bivio::ShellUtil
    handle_call_autoload: if there's no request, just return the clas()
  * Bivio::Test::Unit
    added builtin_assert_file (used by Dev.bunit)
  * Bivio::Test::Util
    remote_trace didn't set "want_redirects" to be true for LWPUserAgent
  * Bivio::Util::Dev
    removed project_aliases (unused)
    Added setup* to create dev env
    Added bashrc_b_env_aliases to create aliases for development
  * Bivio::Util::HTTPD
    passes BIVIO_HTTPD_PORT
    don't need to write a custom bconf.  New IO.Config causes problems
    with that.
    file_cache and mem_cache aren't part of CentOS 6.2, and we aren't
    using them right now so don't include
  * Bivio::Util::LinuxConfig
    be explicit about "m" or "s" on compiled regexps (qr{}), because there
    was a subtle change in the way substitutions with compiled regexps
    overrides "m" and "s". if you have $re = qr{^a\n}; s{$re}{}m, the "m"
    doesn't override the implicit "s".  This is on CentOS 6.2 (perl
    5.10.1).
  * Bivio::Util::Release
    added map_projects for Util.Dev

  Revision 12.23  2013/01/08 17:31:26  schellj
  * Bivio::Agent::Request
    extra $_HTML
  * Bivio::BConf
    spc
    copy
  * Bivio::Biz::Action::AssertClient
    added hostname to default list of hosts
  * Bivio::Biz::Model::DBAccessModelForm
    remove b_debug
  * Bivio::Biz::Model::RealmMailBounce
    remove b_info
  * Bivio::Biz::Model::TaskRateLimit
    added tracing (probably too much)
    bunit working
  * Bivio::SQL::DDL
    Add index on calendar evetn uid
  * Bivio::SuperAUTOLOAD
    removed
  * Bivio::Type::Email
    format_email had pattern match on $_
  * Bivio::Type::EnumDelegator
    duplicate $delegator
  * Bivio::Type::String
    added more transliterations
  * Bivio::UI::Color
    missing "\" before "d"
  * Bivio::UI::Constant
    extra $_HTML
  * Bivio::UI::CSS
    missing "\" before "d"
  * Bivio::UI::Email
    missing '\' before d
  * Bivio::UI::Font
    missing '\' before d
  * Bivio::UI::FormError
    missing "\" before "d"
  * Bivio::UI::HTML::Widget::SourceCode
    avoid calling unsafe_map_require() on AUTOLOAD modules
  * Bivio::UI::HTML
    missing "\" before "d"
  * Bivio::UI::Icon
    missing '\' before d
  * Bivio::UI::Task
    missing "\" before "d"
  * Bivio::UI::Text
    missing '\' before d
  * Bivio::Util::HTTPD
    removed PerlTransHandler
  * Bivio::Util::HTTPStats
    extra $_FP
  * Bivio::Util::LinuxConfig
    ensure --encoding=SQL_ASCII for initdb, because later versions of
    Postgres/CentOS default to UTF8
  * Bivio::Util::SQL
    Add index on calendar evetn uid

  Revision 12.22  2012/12/31 18:08:16  nagler
  * Bivio::Agent::Job::Request
    removed some of the put_durable calls, because they could be
    overridden, and they are already durable in super

  Revision 12.21  2012/12/31 18:01:10  nagler
  * Bivio::Agent::Dispatcher
    renamed process_cleanup => call_process_cleanupC
  * Bivio::Agent::RequestId
    don't truncate the md5, because needs to be globally unique, and
    better for it to be longer (using for TaskRateLimit user id when there
    is no cookie)
  * Bivio::Agent::Request
    renamed process_cleanup => call_process_cleanup (to standardize name
    and also to detect uses)
    call_process_cleanup commits or rollbacks after every call.  This way
    one process cleanup error doesn't screw up other tasks.  TaskRateLimit
    and TaskLog want to always do somet cleanup.
    call_process_cleanup uses Biz.Registrar
  * Bivio::Biz::Action::WikiValidator
    cruft
  * Bivio::Biz::Model::CalendarEventDAVList
    Take 'uid' from CalendarEvent.
  * Bivio::Biz::Model::CalendarEventForm
    Generate uid according to spec instead of using prefixed realm id.
    uid now stored in CalendarEvent.
  * Bivio::Biz::Model::CalendarEventList
    Take 'uid' from CalendarEvent instead of RealmOwner
  * Bivio::Biz::Model::CalendarEvent
    Add explicit 'uid' field to replace use of realm owner name.
    This allows multiple calendar events to have the same 'uid'
    which is needed for series.
  * Bivio::Biz::Model::CalendarEventSeriesList
    NEW
  * Bivio::Biz::Model::JobLock
    process_cleanup now gets object as first argument
  * Bivio::Biz::Model::TaskLog
    make sure DateTime registers with Agent.Task before this module so
    that it can use the date_time on entry, not exit
  * Bivio::Biz::Model::TaskRateLimitObsoleteList
    NEW
  * Bivio::Biz::Model::TaskRateLimit
    NEW
  * Bivio::Biz::Registrar
    factor out _call and _call_args to be cleaner code
    allow $object to be CODE
  * Bivio::Ext::ApacheConstants
    added HTTP_TOO_MANY_REQUESTS for TaskRateLimt
  * Bivio::Ext::LWPUserAgent
    added convience routine bivio_http_get
  * Bivio::IO::File
    tmp_path deprecates temp_file (naming consistency, and it doesn't
    actually create the file)
    use push_process_cleanup (new in Request), and rm_rf $path
    make tmp_dir configurable
  * Bivio::Mail::Outgoing
    Added 'generate_addr_spec' that returns a message_id without the enclosing
    '<...>'. This is the recommended format for icalendar UIDs.
  * Bivio::ShellUtil
    added if_option_execute()
  * Bivio::SQL::Connection
    Added execute_one_row_hashref()
  * Bivio::SQL::DDL
    Add explicit 'uid' column to calendar_event_t to replace use of
    realm_owner_t.name. This allows multiple calendar events to have the
    same 'uid' which is needed when series are to be modified or deleted.
    added task_rate_limit
    factored out so easier to use in a upgrade_db
  * Bivio::Test::Language::HTTP
    renamed process_cleanup => call_process_cleanup
  * Bivio::Type::DateTime
    added register_with_agent_task so other registrants can force
    registration. This allows modules to use now() and get test_now if
    need be
  * Bivio::UI::FacadeBase
    http_too_many_requests
  * Bivio::Util::CPAN
    NEW
  * Bivio::Util::HTTPD
    need to kill QUIT old process
  * Bivio::Util::PropertyModel
    NEW
  * Bivio::Util::Release
    removed install/build_tar and the associated "facades" stuff (hasn't
    been used since we stopped supporting solaris)
    upgraded to be more portable and safer across perl and rpm versions
    perl_make/build now uses vendor layout for installs, because CentOS
    6.2 doesn't seem to support 'site' correctly
    added %{safe_rm} macro to rpm spec which doesn't allow removal of any
    directory which is less than three deep
    Fixed up BuildRoot code, because that isn't right for rpm 4.8*
  * Bivio::Util::SQL
    internal_upgrade_db_calendar_event_uid adds the 'uid' column to calendar_event_t
    removed old upgrades
    Added task_rate_limit lock
    Added calendar_event_uid sentinel

  Revision 12.20  2012/12/21 23:14:00  schellj
  * Bivio::Agent::Embed::Request
    add internal_need_to_toggle_secure_agent_execution
  * Bivio::Agent::Job::Request
    need_to_toggle_secure_agent_execution ->
    internal_need_to_toggle_secure_agent_execution
  * Bivio::Agent::Request
    need_to_toggle_secure_agent_execution uses
    internal_need_to_toggle_secure_agent_execution

  Revision 12.19  2012/12/20 21:42:19  schellj
  * Bivio::Agent::Job::Request
    return 0 from need_to_toggle_secure_agent_execution; don't need to
    toggle jobs
  * Bivio::Agent::Request
    need to calculate abolute uri when redirecting with want_insecure
  * Bivio::PetShop::Test::PetShop
    fpc, didn't work with some of the control logic links

  Revision 12.18  2012/12/19 16:46:27  schellj
  * Bivio::Biz::Model::CalendarEventForm
    Allow end time and start time to be equal to imply zero or irrelevant
    duration
  * Bivio::Biz::Model::CRMThreadRootList
    added missing join on RealmMail.realm_id to CRMThread.realm_id
  * Bivio::Biz::Model
    refactoring *_iterate to be clearer
    _map_iterate_handler was returning hash instead of sub in undef
    handler case
  * Bivio::UNIVERSAL
    b_can allows $object (defaults $proto)
    allows invalid method (undef or ref) to be tested

  Revision 12.17  2012/12/14 19:05:01  schellj
  * Bivio::Agent::Request
    replace need_to_secure_agent_execution with need_to_toggle_secure_agent_execution
    tweak naming
  * Bivio::Agent::TaskEvent
    replace need_to_secure_agent_execution with need_to_toggle_secure_agent_execution
  * Bivio::Agent::Task
    replace need_to_secure_agent_execution with
    need_to_toggle_secure_agent_execution
  * Bivio::Biz::Model::RealmMail
    make mail original only visible to logged in users with access to GROUP_USER_LIST
  * Bivio::Delegate::TaskId
    make mail original only visible to logged in users with access to GROUP_USER_LIST
  * Bivio::MIME::RRule
    fpc
  * Bivio::PetShop::Test::PetShop
    fix do_logout to work on pages that don't have logout links (e.g.,
    mail message original)
  * Bivio::UI::View::Mail
    make mail original only visible to logged in users with access to GROUP_USER_LIST

  Revision 12.16  2012/12/12 03:25:16  schellj
  * Bivio::BConf
    DELEGATE_ROOT_PREFIX must return scalar, because used in context which
    is an list
  * Bivio::Biz::Model::MailReceiveDispatchForm
    add mailer-daemon filtering
  * Bivio::Biz::Model::RealmMailBounce
    need to escape plus tags, too
  * Bivio::Delegate::RowTagKey
    add FILTER_MAILER_DAEMON
  * Bivio::MIME::RRule
    share code in parsing routines so errors come out from one place and
    parse loop is cleaner
    use DateTime->english_day_of_week instead of redefining here
  * Bivio::PetShop::Facade::PetShop
    CLIENT_REDIRECT_PERMANENT_MAP had been removed by mistake.
  * Bivio::PetShop::Util::SQL
    add fourem-mail-filtering forum
  * Bivio::SQL::ListSupport
    style: rename $_where and $_params, because $_<word> variables are
    supposed to be globals
  * Bivio::Type::DateTime
    refactored "english" month & week to share code for lookup and generation
  * Bivio::Util::Project
    use PERLLIB for $src so that can have multiple trees
  * Bivio::Util::ResultViewer
    removed

  Revision 12.15  2012/12/05 14:15:14  nagler
  * Bivio::Agent::Request
    unsafe_get(want_insecure), because not always there

  Revision 12.14  2012/12/04 21:29:05  nagler
  * Bivio::Agent::Request
    todo
    Added ability to want_secure on a task.  This is necessary for mail
    tasks (see Agent.TaskId)
  * Bivio::Agent::Task
    tod
  * Bivio::Biz::Action::RealmMailBase
    normalize format_recipient to include domain
  * Bivio::Biz::Model::ECCreditCardRefundForm
    ensure ECPayment.description doesn't exceed field size
    fpc
  * Bivio::Biz::Model::EmailAlias
    Push format_domain into EmailAliasOutgoing
  * Bivio::Biz::Model::MailReceiveDispatchForm
    moved email parsing to Type.Email
    refactored field_decl
    took parse_recipient private
  * Bivio::Biz::Model::RealmMailBounce
    format_recipient params normalized
  * Bivio::Delegate::TaskId
    added want_insecure=1 to mail tasks.  If the facade is set to
    require_secure=1 (e.g. PetShop::Facade::RequireSecure) then mail tasks
    will fail with a redirect to https when b-sendmail-agent POSTs an
    email to a mail task.
  * Bivio::PetShop::Delegate::TaskId
    test tasks for require_secure and want_insecure
  * Bivio::PetShop::Facade::PetShop
    test tasks for require_secure and want_insecure
  * Bivio::SQL::PropertySupport
    _prepare_select_param was assuming you could just call from_literal on
    any type.  from_literal has specific semantics, which could return
    failure.  Replaced with from_literal_for_model_value, which provides
    override in type, names the concept, can be used in ListSupport (not
    done yet), and protects against invalid values
  * Bivio::Test::Language::HTTP
    change LOCAL_EMAIL_DOMAIN_RE to LOCAL_EMAIL_RE so that entire address
    can be parsed in Type.Email
  * Bivio::Type::EmailAliasOutgoing
    added format_domain
  * Bivio::Type::Email
    moved parsing of emails from MailReceiveDispatchForm to split_parts
    Normalized parameterse of format_email to align with split_parts
    moved LOCAL_EMAIL_RE parsing to split_parts
  * Bivio::Type
    added from_literal_for_model_value
  * Bivio::Util::Forum
    cascade_delete_forum_and_users: must initialize_fully

  Revision 12.13  2012/11/26 21:15:14  schellj
  * Bivio::Biz::Model::CalendarEvent
    'from_ics' renamed 'vevents_from_ics'
  * Bivio::Biz::Registrar
    Eliminate Heisenbug when calling handle_mail_post_create
  * Bivio::MIME::Type
    added docm and related macroEnabled MIME types
  * b_agent

  Revision 12.12  2012/11/19 23:21:32  schellj
  * Bivio::MIME::Calendar
    Move NormForge MIME::Calendar extensions to bOP
  * Bivio::Test::Util
    b_use
  * Bivio::Type::DomainName
    add to_http_uri
  * Bivio::Util::Forum
    Always set the parent realm in create_forum.
    Rob
  * Bivio::Util::RealmAdmin
    doc

  Revision 12.11  2012/11/13 00:09:15  nagler
  * Bivio::Agent::Request
    added clear_cache_for_auth_realm
  * Bivio::Biz::Model::RealmOwnerBase
    factored out cascade_delete_model_list so that subclasses could augment
  * Bivio::Test::Unit
    added builtin_realm_id_exists
  * Bivio::Type::DomainNameArray
    NEW
  * Bivio::Type::ForumName
    added join_top_unless_exists
  * Bivio::UI::Facade
    handle_call_autoload allows uri passed in
  * Bivio::Util::Forum
    assert test for cascade_delete_forum_and_users
  * Bivio::Util::HTTPConf
    need to added rewrite_engine if there's a proxy to a backend
    ssl_crt was being overwritten when it shouldn't have been
  * Bivio::Util::RealmAdmin
    added unsafe_to_id

  Revision 12.10  2012/11/05 17:34:40  schellj
  * Bivio::Auth::Realm
    added assert_type
  * Bivio::Biz::Model::ForumForm
    allow admin_user_id to be set
  * Bivio::Biz::Model::MailReceiveDispatchForm
    couple X-Bivio-Forwarded explicitly with Mail.Incoming->is_forwarding_loop
  * Bivio::Biz::Model::RealmUser
    added is_user_attached_to_other_realms so you can determine if the
    user can be deleted.
  * Bivio::IO::Config
    include file in die() when do() in bconf_dir_hashes fails
  * Bivio::Mail::Common
    export FORWARDING_HDR/_RE so can have explicit coupling
  * Bivio::Mail::Incoming
    added is_forwarding_loop for explicit coupling with MailReceiveDispatchForm
  * Bivio::Mail::Outgoing
    $_KEEP_HEADERS_LIST_SEND_RE replaces $_REMOVE_FOR_LIST_RESEND.  There
    are too many headers to track, which shouldn't be passed, e.g. DKIM*.
    MIME reserves all Content-* headers, and those are all kept.
    Use FORWARDING_HDR instead of hardcoded X-Bivio-Forwarded
  * Bivio::ShellUtil
    handle_call_autoload protects against passing arguments so that we can
    eventually add the case which executes like main but without the
    commit and returning the result.  A bit too complicated to do right now.
  * Bivio::Test::Unit
    builtin_create_user was using incorrect method for deleting user
    fmt
  * Bivio::UI::FacadeComponent
    added handle_call_autoload which returns instead of component from request
  * Bivio::Util::Forum
    Added cascade_delete_forum_and_users
    delete_forum corrected and added an are_you_sure
  * Bivio::Util::HTTPConf
    need mod_reqtimeout
  * Bivio::Util::RealmAdmin
    delete_auth_user wasn't working right if the user was a member of realms

  Revision 12.9  2012/10/30 17:56:34  schellj
  * Bivio::Type::IPAddress
    missing Socket
  * b_agent

  Revision 12.8  2012/10/29 18:05:56  schellj
  * Bivio::Agent::Request
    default to apache_version 2
  * Bivio::IO::ClassLoaderAUTOLOAD
    NEW
  * Bivio::PetShop::Facade::RequireSecure
    is_production needs to be true
  * Bivio::Test::ShellUtilConf
    when a case would fail, pwd was messed up.  Also, delete the
    target directory, because it can get cluttered with old junk
  * Bivio::Util::HTTPConf
    broke apart _app_vars so could implement ssl_wildcard
    ssl_mdc is now a crt, not a boolean, but backwards compatible for now
    ssl_chain and others can be set globally
    can_secure is computed from ssl_*
    ssl_wildcard supports wildcard certificates (technically identical to ssl_mdc)
    cleaned up some formatting
    remove ssl_wildcard/mdc and now just ssl_multi_crt
    ssl_multi_crt can be set globally, and overridden locally or
    overridden with a specific ssl_crt

  Revision 12.7  2012/10/26 16:26:00  schellj
  * Bivio::UI::View::CRM
    use display_name for owner
  * b_agent

  Revision 12.6  2012/10/24 10:54:04  andrews
  * Bivio::Util::SQL
    display_name and text_size upgrades need "!" sentinels
  * b_agent
    calendar enhancements and readOnly atribute
    improve server error handling

  Revision 12.5  2012/10/21 20:10:16  nagler
  * Bivio::Agent::Embed::Request
    removed need_to_secure_task override (obsolete) and replaced with
    agent_execution_is_secure, which is always true since the task is
    executing within the server only
  * Bivio::Agent::Job::Request
    Added agent_execution_is_secure set to true since the task is
    executing within the server only
  * Bivio::Agent::Request
    Changed how "can_secure" works.  There are two paths:
    need_to_secure_agent_execution, which happens when a task is executing
    or a redirect is about to happen.  format_uri behaves differently,
    because if you are executing in a non-http environment, you still want
    to generate https:// uris for tasks that require them.
    Added can_secure to facades so that an entire facade can be secured
    Cleaned up format_uri so that require_absolute is observed for both
    task_id and uri cases. Refactored the code so the paths are clearer
  * Bivio::Agent::t::Mock::Facade::Mock
    test require_secure
  * Bivio::Agent::TaskEvent
    call need_to_secure_agent_execution instead of need_to_secure_task
  * Bivio::Agent::Task
    call need_to_secure_agent_execution instead of need_to_secure_task
  * Bivio::Base
    remove cruft
  * Bivio::Biz::Action::DAV
    format_http_prefix is obsolete;
    code now does "the right thing" with secure links
  * Bivio::Biz::Model::RealmOwner
    format_http_prefix is obsolete; call format_uri appropriately
  * Bivio::Biz::Util::RealmRole
    added clear_unused_permissions() and permission_count()
  * Bivio::IO::Alert
    fmt
  * Bivio::IO::ClassLoader
    fmt
  * Bivio::PetShop::Facade::BeforeOther
    is_production true
  * Bivio::PetShop::Facade::Other
    is_production true
  * Bivio::PetShop::Facade::PetShop
    removed want_secure (cruft)
    is_production true
  * Bivio::PetShop::Facade::RequireSecure
    NEW
  * Bivio::ShellUtil
    add get_request_or_new
    get_request_or_new -> shell_util_request_instance, use Test.Request,
    not Agent.Request
  * Bivio::Test::Language
    make sure there's a request before running tests
    ShellUtil->get_request_or_new -> shell_util_request_instance
  * Bivio::Test::Request
    Added agent_execution_is_secure set to true since the task is
    executing in a shell, which is secure
  * Bivio::Test::Unit
    go_dir takes an op, and if present, calls do_in_dir
    added builtin_config_can_secure
  * Bivio::UI::FacadeBase
    added require_secure
    want_secure removed, because was unused
  * Bivio::UI::FacadeComponent::Task
    removed "help" feature, not used
  * Bivio::UNIVERSAL
    fmt
    die(): now passes calling_context
  * Bivio::Util::HTTPStats
    removed v3(), no longer any apps at this level
    fixed daily_report and import_history to deal with date argument properly
    Cleaned up facade iteration, forum lookup, etc.
    facades can share the site_reports_realm_name forum. We want the
    default facade in this case to generate the report.  Otherwise, the
    last facade overwrites all the other facade reports.  Only generate
    reports for the first seen (alphabetically with default first) forum.
  * Bivio::Util::SQL
    added internal_upgrade_db_http_stats_biz_file

  Revision 12.4  2012/10/19 02:13:23  nagler
  * Bivio::BConf
    FacadeComponent is no its own directory
    UIXHTML and UIHTML need to include UI in path
  * Bivio::Biz::File
    fmt
  * Bivio::Biz::Model::RealmOwner
    added unauth_load_by_name_and_type_or_die
  * Bivio::Biz::Model::WikiForm
    don't execute_other() if form is in_error()
  * Bivio::Cache::SEOPrefix
    if no site_realm_id, return SUPER's internal_realm_id
  * Bivio::ShellUtil
    added handle_call_autoload which returns instance, instead of class
    name.  This allows attributes calls (get('-force')) which is necessary
    on some calls
  * Bivio::Test::Unit
    fmt
  * Bivio::UI::Color
    moved to Bivio/FacadeComponent
  * Bivio::UI::Constant
    moved to Bivio/FacadeComponent
  * Bivio::UI::CSS
    moved to Bivio/FacadeComponent
  * Bivio::UI::Email
    moved to Bivio/FacadeComponent
  * Bivio::UI::FacadeBase
    added Icon and Email, because they need to be initialized.  They used
    to be initialized because they were hardwired static components
  * Bivio/UI/FacadeComponent
    NEW
  * Bivio::UI::FacadeComponent
    removed static components so that can prepare for dynamic facades
    changed registration mechanism to be simpler in components
  * Bivio::UI::Facade
    no longer have static components to prepare for fully dynamic facades
    use as_classloader_map_name in put_on_req
  * Bivio::UI::Font
    moved to Bivio/FacadeComponent
  * Bivio::UI::FormError
    moved to Bivio/FacadeComponent
  * Bivio::UI::HTML::ViewShortcuts
    use class path (UIHTML)
  * Bivio::UI::HTML::Widget::Image
    incorrect map name on Align
  * Bivio::UI::HTML
    moved to Bivio/FacadeComponent
  * Bivio::UI::Icon
    moved to Bivio/FacadeComponent
  * Bivio::UI::Task
    moved to Bivio/FacadeComponent
  * Bivio::UI::Text
    moved to Bivio/FacadeComponent
  * Bivio::UI::View
    fmt

  Revision 12.3  2012/10/18 17:25:59  schellj
  * Bivio::Auth::Realm
    added GENERAL_NAME
  * Bivio::Biz::Action::EasyForm
    pass req to FacadeComponent.Constant->get_value
  * Bivio::Biz::Action::EmptyReply
    print a warning if the incoming status is not known
  * Bivio::Biz::Action::Error
    internal_render_content can change $status
    deal with DEFAULT_ERROR_REDIRECT_*
  * Bivio/Biz/Action/t
    NEW
  * Bivio::Biz::Model::CRMActionList
    format displaay names as "name <email>", not "name (email)"
  * Bivio::Biz::Model::CRMForm
    - change from_display_name to be user, not realm.
    - send message to board or realm with current status and updated
    fields if any changed.
  * Bivio::Biz::Model::MailForm
    move header setting logic to internal_set_headers
  * Bivio::Biz::Model::MailThreadList
    sort by RealmMail.realm_file_id for messages that arrived withing the
    same second
  * Bivio::Biz::Model::Tuple
    fix _parse_slots to always return an array ref, because map_by_two
    requires an array ref always (even if empty)
  * Bivio::ClassWrapper::TupleTag
    - fix bug with tuple_tag_label not getting set in _field_info
    - add hook to _update_properties for classes to use old/new field values
  * Bivio::HOWTO::CodingStyle
    Added Statelfulness section
    discussed with_* approach
    cleaned up some old paradigms.
  * Bivio::PetShop::Util::TestCRM
    CRM->setup_realm sets priority and prefix so needed to change uses to
    match was there before
  * Bivio::Search::Xapian
    wrap calls to open read/write xapian db so always atomic.  There are
    times (e.g. during create_test_db) where there are reads overlapping
    with writes during a transaction.
  * Bivio::UI::FacadeBase
    labels for CRMForm field update mail
  * Bivio::UI::Facade
    remove deprecated warning in get_value, because covered by get_from_request_or_self
    get_instance accepts a uri, domain, or class.  class must begin with
    upper case letter.  find_by_uri_or_domain can now only accept lower
    case uri or domain (deprecated for now)
    added map_iterate_with_setup_request and with_setup_request
  * Bivio::UI::FormError
    fixed deprecated warning on UI.Text->get_widget_value()
    fpc
    fmt
    b_use
  * Bivio::UI::HTML::Widget::Script
    combobox: if one item matches search and tab is pressed, complete with that item
  * Bivio::UI::View::CRM
    add field_updates_imail
  * Bivio::UI::XHTML::Widget::ComboBox
    make wider
  * Bivio::Util::CRM
    removed setup_realm_with_priority
    setup_realm takes a priority and CRM_SUBJECT_PREFIX but defaults to priority 1-3.
  * Bivio::Util::Forum
    can pass parent_realm as 3rd arg, and will be used with_realm
  * Bivio::Util::HTTPConf
    added global_params
  * Bivio::Util::HTTPD
    got a read request timeout so bump header=2
  * Bivio::Util::RealmMail
    wrong class map for Facade.pm
  * Bivio::Util::SiteForum
    use IO.Config->is_test not req->is_test
  * Bivio::Util::SQL
    clear the realm set by initialize_db (probably the last default realm
    created, e.g. forum)

  Revision 12.2  2012/10/08 15:15:58  nagler
  * Bivio::Biz::Action::Error
    revert 1.7
  * Bivio::PetShop::Util::TestData
    fixed incorrect get_value call
  * Bivio::Util::SiteForum
    fixed incorrect get_value call

  Revision 12.1  2012/10/07 21:49:49  andrews
  * b_agent changes to prevent duplicate popups and improve handling of
    error on first request.

  Revision 12.0  2012/10/07 18:23:08  nagler
  * Bivio::Biz::Action::EmptyReply
    uc(status) since the code depends on this
  * Bivio::Biz::Action::Error
    factored out internal_render_content so that subclasses can override
    if they want to just return the forbidden error
  * Bivio::Biz::Model::Bulletin
    rm pod, refactor
    added $req to get_local_file_name() call
  * Bivio::Biz::Model::Forum
    modularize ROOT_FORUM_PARENT_ID
  * Bivio::Biz::Model::UserPasswordQueryForm
    b_use
  * Bivio::Type::Email
    added equals_domain
    downcase result of split_parts
    simplified is_test to use Config
    removed hardwired calls to package's methods in init (doesn't allow override)
    b_use
  * Bivio::Type::ForumName
    downcase output of split and join
  * Bivio::UI::Facade
    added handle_call_autoload so can get instance in tests

  Revision 11.92  2012/10/05 20:11:45  andrews
  Release notes:
  * b_agent fixes for beta 1
  * Bivio::Agent::Job::Dispatcher
    fixed formatting on JOB_END
  * Bivio::Agent::Request
    Task->has_uri requires $reqw
  * Bivio::Biz::Model::FilterQueryForm
    avoid deprecated value warning with UI.Text->get_value
  * Bivio::Type::FilePath
    get_suffix wasn't allowing foo..bar (double dot)
  * Bivio::Util::RealmAdmin
    skip task_log_t when scanning realm_ids, too much data there

  Revision 11.91  2012/10/02 19:07:32  nagler
  * Bivio::Agent::HTTP::Reply
    wrap $r->send_fd() in Die->eval() to catch APR connection errors
  * Bivio::Agent::HTTP::Request
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Agent::Job::Dispatcher
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Agent::Request
    added is_http_content_type and refactored is_http_method
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Agent::Task
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Auth::Permission
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Auth::Realm
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Biz::Action::ClientRedirect
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Biz::Action::DAV
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Biz::Action::RealmlessRedirect
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Biz::FormContext
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Biz::Model::ForumTreeList
    b_use
  * Bivio::Biz::Model::RealmDAVList
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Biz::Model::RealmFileDeletePermanentlyForm
    save realm_file in other field so can be used atomically after file is
    deleted
  * Bivio::Biz::Model::SearchList
    removed b_info
  * Bivio::ClassWrapper::TupleTag
    used equals_class_name
  * Bivio::Delegate::TaskId
    b_use so that Agent.Task can be overridden by an application
  * Bivio::HOWTO::CodingStyle
    b_use so that Agent.Task can be overridden by an application
  * Bivio::PetShop::Test::Request
    rmpod
    b_use so that Agent.Task can be overridden by an application
  * Bivio::SQL::Connection
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Test::Request
    added content_type call for is_http_content_type testing
  * Bivio::Test
    b_use so that Agent.Task can be overridden by an application
  * Bivio::Type::DateTime
    b_use so that Agent.Task can be overridden by an application
  * Bivio::UI::Email
    deprecate passing req_or_facade as undef and not an instance (does Request->get_current)
  * Bivio::UI::Facade
    deprecate passing req_or_facade as undef and not an instance (does Request->get_current)
  * Bivio::UI::HTML::Widget::StyleSheet
    b_use so that Agent.Task can be overridden by an application
  * Bivio::UI::XHTML::Widget::BasicPage
    removed
  * Bivio::UI::XHTML::Widget::MobileDetector
    use equals_class_name instead of == on the facade instances
  * Bivio::UNIVERSAL
    added equals_class_name for class/package comparisons with proto/self
    so, e.g. MobileDetector can do simpler compares
  * Bivio::Util::HTTPConf
    ssl_only needs to generate redirect for http://http_host to https
  * Bivio::Util::RealmAdmin
    added scan_realm_id() to search for a realm_id across all tables
  * Bivio::Util::SiteForum
    change Web Site to Site Management

  Revision 11.90  2012/09/20 10:43:09  andrews
  Release notes:
  * b_agent various changes to improce 'enter' key handling
  * Bivio::UI::HTML::Widget::DateField
    need to initialize _date_picker to set up pa
  * Bivio::UI::HTML::Widget::Script
    use unique id for datepicker elements
    use form name to lookup fields
  * Bivio::UI::XHTML::Widget::DatePicker
    use control_on_render instead of initialize
    use generated unique ids instead of field name (previous
    commit).
    use form_name to lookup fields.

  Revision 11.89  2012/09/14 17:42:32  moeller
  * Bivio::Biz::Model::CSVImportForm
    show error long description for record errors
    changed invalid enum error from NOT_FOUND to SYNTAX_ERROR

  Revision 11.88  2012/09/12 21:56:45  schellj
  * Bivio::Agent::Request
    b_use
  * Bivio::Agent::t::Mock::TaskId
    added ability to have arbitrary attributes (attr_*) on tasks
    refactored _put_attr to be cleaner (unnecessarily complexity for
    die_actions chaining
  * Bivio/Agent/t/TaskId
    NEW
  * Bivio::Agent::TaskId
    validate 'int' attribute supplied
    Took business logic from Delegate.TaskId and moved here.  This was
    allowed by having Delegate.TaskId subclass Type.EnumDelegate so that
    methods could be called from the enum directly.
    merge_task_info was computing $_INCLUDED_COMPONENT (was $_INCLUDED),
    but this was wrong since merge_task_info is simply stateless business
    logic.  Rather have _compile() set that.  In order to make that work,
    needed to create dummy config _TASK_COMPONENT_<name> which gets set by
    merge_task_info when components are referenced.  These are then
    stripped by _compile()
  * Bivio::Agent::Task
    added ability to have arbitrary attributes (attr_*) on tasks
    refactored _put_attr to be cleaner (unnecessarily complexity for
    die_actions chaining
    die_actions parsing wasn't working.  The TaskEvent wasn't being passed
    to _put_attr (the original value was [just the task name])
    validate that the attributes (name, int, etc.) are defined in the
    values passed to new()
  * Bivio::Auth::Role
    call compile after all inititialization is complete
  * Bivio::BConf
    default Bivio::Search to Bivio::Search::None, since this is the
    default case
    deprecated NoECService: using ECService
  * Bivio::Biz::FormModel
    added CANCEL_BUTTON_NAME; used to declare in internal_initialize and overridable
    don't need '.x' stripping on field names in _parse_cols; it's a no-op
  * Bivio::Biz::Model::CSVImportForm
    added validate_record() call for subclasses
  * Bivio::Biz::Model::MailForm
    added CALL_SUPER_ATTR_HACK so that execute_cancel and execute_ok call
    SUPER and return if there's a result.  This is need for an app which
    overrides Biz.FormModel, temporarily
    renamed CALL_SUPER_ATTR_HACK, and define as constant method (doesn't
    need to be on request)
  * Bivio::Delegate::ECService
    NEW
  * Bivio::Delegate::FailoverWorkQueueOperation
    subclass Type.EnumDelegate
  * Bivio::Delegate::NoDbAuthSupport
    subclass Type.EnumDelegate
  * Bivio::Delegate::NoECService
    rmpod
    subclass Type.EnumDelegate
    deprecated: use ECService
  * Bivio::Delegate::RealmDAG
    subclass Type.EnumDelegate
  * Bivio::Delegate::RealmType
    subclass Type.EnumDelegate
  * Bivio::Delegate::Role
    subclass Type.EnumDelegate
  * Bivio::Delegate::RowTagKey
    subclass Type.EnumDelegate
  * Bivio::Delegate::SimpleLocation
    subclass Type.EnumDelegate
  * Bivio::Delegate::SimpleMotionStatus
    subclass Type.EnumDelegate
  * Bivio::Delegate::SimpleMotionType
    subclass Type.EnumDelegate
  * Bivio::Delegate::SimpleMotionVote
    subclass Type.EnumDelegate
  * Bivio::Delegate::SimplePermission
    subclass Type.EnumDelegate
  * Bivio::Delegate::SimpleTypeError
    subclass Type.EnumDelegate
  * Bivio::Delegate::TaskId
    fmt
    Refactored canonicalize_task_info from _merge_modifiers so that
    applications could normalize the task list into hashes thus easier to
    manipulate task lists.  Moved validation into Agent.Task, since that's
    where it belongs.  Don't allow a single "info" structure to have
    duplicate names (they should be merged already).
    Moved all info_* methods out of this module into
    Agent.TaskComponents.  This file has the business logic, and the other
    now just describes the components.
    move the business logic into Agent.TaskId so that testing is cleaner.
    Delegates shouldn't have a lot of logic
    Take the definitions back from TaskComponents (obsolete)
  * Bivio::Delegator
    Use global variable name $_PREV_AUTOLOAD instead of $last for
    recursion sentinnel
  * Bivio::IO::ClassLoader
    removed delegate_require_info, because only used by EnumDelegator
    added delegate_get_map_entry and delegate_replace_map_entry to support
    Bivio.Search->delegate_search_xapian.
    Some refactoring and cleanup
  * Bivio::Search
    Added delegate_search_xapian so that TaskId could replace the map
    entry to Bivio::Search::Xapian if info_xapian component is included.
  * Bivio::SQL::FormSupport
    use field names as $col->{form_name} during development to make
    debugging easier
  * Bivio::Test::Util
    make sure selenium server is running for apps that need it
  * Bivio::Type::EnumDelegate
    NEW
  * Bivio::Type::EnumDelegator
    Delegates can now call back into Delegator via AUTOLOAD or directly
    internal_delegate_package calls Type.EnumDelegate->internal_set_delegator_package
    Put in check for infinite delegation loop, just like Bivio.Delegator
  * Bivio::Type::t::EnumDelegator::I1
    must subclass EnumDelegate
  * Bivio::Type::UserAgent
    There are too many robots, but they seem to have http:// or an email
    in the string so map those to robot_other
  * Bivio::TypeError
    delegate_require_info is gone, because not directly related to
    ClassLoader.  Just call get_delegate_info directly, since only used in
    EnumDelegator case.
  * Bivio::UI::XHTML::Widget::WikiText
    cleaned up "tag postfix" code.  id regexp expanded to include ":" and
    ".".  Classes need to appear before "#id", but no way to check for
    that, just in documentation
  * Bivio::UNIVERSAL
    added as_classloader_mapped_package

  Revision 11.87  2012/09/06 01:26:29  schellj
  * Bivio::Biz::Model::MailForm
    revert previous change, altered behavior

  Revision 11.86  2012/09/05 19:41:43  schellj
  * Bivio::Biz::Model::AuthUserRealmList
    added assertion in internal_post_load_row to check that
    load_all_for_task was called.  Without that assertion, you'd never
    know that calling load_all is doing the wrong thing.  This explicitly
    couples the two routines.
  * Bivio::HOWTO::CodingStyle
    added section on implicit coupling
  * Bivio::PetShop::BConf
    can't use Bivio::Biz::Model in ClassLoader_Bunit test map, because
    Bivio.Universal->CLASSLOADER_MAP_NAME tries to extract the class name
    out of the maps, and picks up the wrong map (not Model)
  * Bivio::UI::XHTML::Widget::WikiText
    added ability to say @tag#id

  Revision 11.85  2012/09/05 00:50:42  nagler
  * Bivio::IO::ClassLoader
    call_autoload wasn't handling maps with underscores and had dead part
    of regex /^(?:^|::)...
    call_autoload handles maps with numbers in them (CAL54)
  * Bivio::PetShop::BConf
    added classloader bunit support
  * Bivio::Type::DocletFileName
    use is_site_realm_name
  * Bivio::UI::FacadeBase
    normalized the names of site_* queries
    added special_realm_name_equals

  Revision 11.84  2012/08/29 17:02:15  andrews
  * "burrito"is the default realm in Application.js doer now so that
     demo does not get 404. Needs to be configurable and passed
     to client code.

  Revision 11.83  2012/08/28 16:43:54  nagler
  * Bivio::Biz::Model::RealmFile
    added FailoverWorkQueue support
  * Bivio::IO::Alert
    fmt
  * Bivio::Util::Backup
    added -F to zfs receive
  * Bivio::Util::FailoverWorkQueue
    copy
  * Bivio::Util::HTTPConf
    generate restricted SSL ciphers to protect against beast attack:
    https://community.qualys.com/blogs/securitylabs/2011/10/17/mitigating-the-beast-attack-on-tls
  * Bivio::Util::LinuxConfig
    removed sendmail and network support, not used
    fpc: serial_console was messed up
  * Bivio::Util::PGStandby
    not sure the status, but want to checkin.  Not in use yet
  * Bivio::Util::Task
    NEW

  Revision 11.82  2012/08/27 17:28:54  andrews
  * Add FileDropInstructionLabel.js
    A label that is invisible unless
    the browser supports file drag and
    drop for uploads

  Revision 11.81  2012/08/27 12:27:11  andrews
  *   Add code to base qooxdoo to check that table is still available in
      "_getAvailableWidth". Very occasionally it is null which result in a
      console error. _getAvailableWidth is called from a timer so it is
      diffuclt to see what the cause is. Seems to occur when tables are
      destroyed and redisplayed.

  *   Shorter URIs esp. in registration mails

  *   Maintain list position when flipping between table and list views

  *   Use 'legacy' upload for IE 9 which does not support the HTML 5 file
      API. FileDropComposite is also a form and UploadButton becomes a
      regular file button.

  *   Load spinning wheel for upload button in legacy mode

  *   Fix file drag and drop for Chrome.

  *   Only display the "drag file here" instructions on browsers that
      support drag and drop.

  *   Add 'readOnly' attribute similar to textField's to DateField and
      SelectBox

  *   Double clicking row executes first permitted action from context menu

  *   Allow tables to have selection disabled. Value is focused row

  *   Popup from previous form would sometimes appear due to left-over context in URI

  *   Move to Qooxdoo 2.0.1

  *   Indicate empty list with 'No items to display' or similar
      specifiable string

  *   Parse error when day of month had a single digit

  Revision 11.80  2012/08/24 15:23:10  nagler
  * Bivio::ShellUtil
    do_backticks: don't try quoting command or calling sh -c
    usage_error: set message on "DIE" as the error so when -live code
    executes, you get something reasonable in the output (e.g. if
    processing an email)

  Revision 11.79  2012/08/20 16:33:29  schellj
  Release notes:
  * Bivio::Test::Unit
    add builtin_random_integer
    fpc

  Revision 11.78  2012/08/06 09:06:45  andrews
  * Bivio::Biz::Model::RealmMailDeleteForm
    Call execute_ok from super class

  Revision 11.77  2012/08/04 00:14:51  schellj
  * Bivio::UI::HTML::Widget::Script
    include text for inactive days (presumably visually differentiated
    with CSS)
  * Bivio::UI::View::CSS
    adjust DatePicker colors

  Revision 11.76  2012/08/03 23:05:24  schellj
  * Bivio::UI::View::CSS
    specify width for days in month

  Revision 11.75  2012/08/03 18:15:31  nagler
  * Bivio::Biz::ListModel
    refactor _format_uri_args into internal_format_uri_args so can be
    overriden by subclass.
    Added internal_format_uri_get_path_info for RealmFileVersionsList,
    because it is a list which requires path_info
    fmt
  * Bivio::Biz::Model::RealmFileVersionsList
    Added internal_format_uri_get_path_info to add the path_info for
    next_detail, etc.
    Must have a path_info on request
  * Bivio::Biz::QueryType
    added can_take_path_info for RealmFileVersionsList
  * Bivio::ShellUtil
    removed do_sh, do_backticks does more
    do_backticks now tries to quote the string and pass it to sh -c
    don't need $' for _sh_quote().
  * Bivio::UI::XHTML::ViewShortcuts
    add option to vs_list_form to place the list before other form fields
  * Bivio::Util::SSL
    use do_backticks instead do_sh (obsolete)

  Revision 11.74  2012/07/27 21:17:08  moeller
  * Bivio::Biz::Model::Motion
    added "other" ref to TupleDef.tuple_def_id
  * Bivio::Biz::Model::TupleSlotChoiceList
    changed order_by to other, sorting not implemented
  * Bivio::Biz::Model::TupleSlotChoiceSelectList
    changed order_by to other, sorting not implemented
  * Bivio::UI::View::CSS
    adjust placement of DatePicker
  * Bivio::UI::View::Motion
    removed internal_motion_initiator() and internal_motion_type()
  * Bivio::UI::View::Tuple
    added dummy ID to list form checkbox
  * Bivio::UI::XHTML::Widget::DatePicker
    don't need id on month

  Revision 11.73  2012/07/25 19:04:25  andrews
  Release notes:
  * Bivio::Biz::Model::MailForm
    Respect the super class's return value in execute_ok and execute_cancel
  * Bivio::Biz::Model::RealmOwnerBase
    more manual model clean up during cascade_delete()
  * Bivio::Biz::Model::TupleDefListForm
    don't clear label error, can cause row to get deleted
    if an invalid label is edited
  * Bivio::Type::Integer
    remove trailing 0 decimals before validating
  * Bivio::UI::HTML::Widget::DateField
    add optional DatePicker
    DatePicker start_date, end_date now optional
  * Bivio::UI::HTML::Widget::Script
    add DatePicker functions
    moved much of the DatePicker logic here to allow for acceptable
    rendering times and less rendered html with multiple pickers
    zero pad DatePicker dates
    manipulate dates in local timezone
  * Bivio::UI::View::CSS
    add styles for DatePicker
    add b_dp_inactive_day
    adjust colors
    specify z-index for DatePicker
    adjust colors, add b_dp_selected state
    adjust DatePicker icon placement
  * Bivio::UI::View::Tuple
    fixed tuple editor for Boolean types
  * Bivio::UI::XHTML::Widget::DatePicker
    NEW
  * Bivio::UI::XHTML::Widget::DropDown
    add 'no_arrow' option
    allow for link_onclick attr
  * Bivio::Util::Backup
    do_backticks (not back_ticks)

  Revision 11.72  2012/07/15 15:54:03  nagler
  * Bivio::ShellUtil
    do_backticks takes ignore_exit_code parameter
  * Bivio::UI::FacadeBase
    added Motion list_action labels
  * Bivio::UI::View::Motion
    use Motion list_action facade values
  * Bivio::UI::XHTML::Widget::MailBodyHTML
    Was not rendering HTML (from Word) with embedded meta and link tags.
    Added these and other empty elements.  Was incrementing
    $state->{ignore} when empty tag, and that means everything that
    follows, say, meta, would be ignored.  The parser needs to deal with
    incorrect html better.
  * Bivio::Util::Backup
    removed "archive/" directory concept in trim_directories and
    archive_mirror_link. Only keep weeklies online.
    remove remote_archive() unused
    added support for zfs backups
    doc
    _do_back_ticks needs ignore_exit_code
  * Bivio::Util::Project
    create ~/src/perl/Bivio/files and run make in javascript directory

  Revision 11.71  2012/07/09 17:59:17  moeller
  * Bivio::Biz::Model::FormModeBaseForm
    stub out dispatched methods
  * Bivio::Util::Class
    u_info() allows unknown classes, per bunit

  Revision 11.70  2012/07/05 20:02:47  schellj
  Release notes:
  * Bivio::Biz::Action::UserPasswordQuery
    Bivio::Base
  * Bivio::Biz::Model::ConfirmationForm
    Bivio::Base
  * Bivio::Biz::Model::ForumDeleteForm
    Bivio::Base
  * Bivio::Biz::Model::ImageUploadForm
    Bivio::Base
  * Bivio::Biz::Model::MailReceiveBaseForm
    Bivio::Base
  * Bivio::Biz::Model::MotionForm
    Call 'execute_ ... ' methods in super class
  * Bivio::Biz::Model::MotionVoteForm
    Call 'execute_ ... ' methods in super class
  * Bivio::Biz::Model::RealmLogoList
    Bivio::Base
  * Bivio::Biz::Model::RealmMailBounceList
    Bivio::Base
  * Bivio::Biz::Model::RealmUserDeleteForm
    Bivio::Base
  * Bivio::Biz::Model::SearchForm
    Bivio::Base
  * Bivio::Biz::Model::SearchList
    Bivio::Base
  * Bivio::Biz::Model::TestWidgetForm
    Bivio::Base
  * Bivio::Biz::Model::TupleSlotTypeClassList
    Bivio::Base
  * Bivio::Biz::Model::TupleUseList
    Bivio::Base
  * Bivio::Biz::Model::UserPasswordForm
    Bivio::Base
    call super
  * Bivio::Biz::t::ListModel::T4List
    Bivio::Base
  * Bivio::ShellUtil
    _method_ok returns the method found
  * Bivio::Test::HTMLParser::Forms
    support is_not_bivio_html
  * Bivio::Test::HTMLParser::Tables
    support is_not_bivio_html
  * Bivio::Test::HTMLParser
    support is_not_bivio_html
  * Bivio::Test::Language::HTTP
    support is_not_bivio_html
  * Bivio::Test::ShellUtilConf
    added setup_case
  * Bivio::UNIVERSAL
    bug: grep_methods and grep_subroutines weren't handling hierarchy right
  * Bivio::Util::Class
    renamed methods u_* so wouldn't collide with methods in
    Bivio::UNIVERSAL.  ShellUtil will check for u_* methods first
  * Bivio::Util::CSV
    fix for sort_csv
  * Bivio::Util::Release
    add optional command to yum_update

  Revision 11.69  2012/06/14 16:27:41  nagler
  * Fix qooxdoo build to only include necessary files

  Revision 11.68  2012/06/13 22:56:25  nagler
  * Added files/qooxdoo
  * Bivio::BConf
    set default database and connection
  * Bivio::Search::Xapian
    Allow queries of the form 'a OR NOT b'

  Revision 11.67  2012/06/07 00:33:20  moeller
  * Bivio::Biz::Model::MotionCommentForm
    now derives from FormModeBaseForm
  * Bivio::Biz::Model::MotionCommentList
    added MotionCommentList.creation_date_time
  * Bivio::Biz::Model::MotionList
    added execute_load_this_for_parent()
  * Bivio::Biz::Model::Motion
    added is_open()
  * Bivio::Biz::Model::RealmOwnerBase
    added model defs back to cascade_delete()
  * Bivio::Delegate::TaskId
    for motion comments, load this from parent id
  * Bivio::Type::String
    transliterate unicode thin space
  * Bivio::UI::View::Motion
    comment form now takes THIS_AS_PARENT

  Revision 11.66  2012/05/31 20:49:36  moeller
  * Bivio::Biz::Model::MotionList
    enumerate vote types for count field
  * Bivio::UI::HTML::Widget::Checkbox
    allow overriding ID value
  * Bivio::UI::JavaScript::Widget::WidgetInjector
    rework to allow cross-domain injection
    allow for the injection of javascript with the widget
  * Bivio::Util::TestMail
    add $percent_replies to create_messages

  Revision 11.65  2012/05/22 16:30:08  moeller
  * Bivio::BConf
    added Model.AcceptanceTestList root config value
  * Bivio::Biz::Model::AcceptanceTestList
    added root config value, allows use with Bivio/PetShop
  * Bivio::Biz::Model::Lock
    added execute_auth_user()
  * Bivio::Biz::Model::MotionList
    fixed boolean return value
  * Bivio::Delegate::TaskId
    move EMAIL_ALIAS_LIST_FORM to adm
  * Bivio::UI::FacadeBase
    move EMAIL_ALIAS_LIST_FORM to adm
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    add EMAIL_ALIAS_LIST_FORM

  Revision 11.64  2012/05/16 17:38:00  moeller
  * Bivio::Biz::Model::EmailAliasListForm
    NEW
  * Bivio::Delegate::TaskId
    add EMAIL_ALIAS_LIST_FORM
  * Bivio::Type::TimeZone
    now uses static time zone list, compatible with DateTime::TimeZone
    versions 0.48 and 1.39
  * Bivio::Type::UserAgent
    added ultraseek to list of robots
  * Bivio::UI::FacadeBase
    add EMAIL_ALIAS_LIST_FORM
  * Bivio::UI::View::SiteAdmin
    add email_alias_list_form
  * Bivio::Util::Disk
    added tw_cli test

  Revision 11.63  2012/04/25 18:27:21  moeller
  * Bivio::Type::DateTime
    add is_weekday and is_weekend
  * Bivio::UI::HTML::Widget::Image
    added tooltip
  * Bivio::UI::HTML::Widget::ListActions
    use Cache.RealmOwner when looking up realm
  * Bivio::Util::HTTPConf
    removed php
  * Bivio::Util::HTTPD
    Chrome BrowserMatch with reqtimeout header=1

  Revision 11.62  2012/04/09 15:58:59  schellj
  * Bivio::Biz::Action::MySite
    pass query along for user tasks
  * Bivio::Biz::Action::TunnelBase
    call HTTP::Request->add_content explicitly instead of passing a sub
    can't pass scalar ref to HTTP::Request->content
    change to Apache2::RequestReq API for headers_in.  Returns a
    APR::Table
  * Bivio::Biz::ListFormModel
    remove b_debug
  * Bivio::Biz::Model::RealmOwnerBase
    delete realm CRMThread, RealmMail, RealmRole, RealmFile on cascade_delete
    remove MotionVotes, nullify MotionVote.affiliated_realm_id as
    necessary, remove Motions on cascade_delete
    fpc
  * Bivio::Search::Xapian
    MAX_WORD at 240 is too long for a UTF8 string.  80 seems to work.
  * Bivio::ShellUtil
    no $_ in _other
  * Bivio::UI::View::File
    fixed unlock javascript - now there are two cancel buttons
  * Bivio::Util::HTTPConf
    added php
  * Bivio::Util::HTTPD
    added all modules including php for v2
    remove mod_dir from apache V2 (see TODO)
    remove mod_php5:libphp5:libphp5.c from V2 modules
  * Bivio::Util::NamedConf
    fmt

  Revision 11.61  2012/03/19 20:37:50  moeller
  * Bivio::IO::ClassLoader
    added is_valid_map_class_name
  * Bivio::UI::FacadeBase
    added b_list_action font
  * Bivio::UI::HTML::Widget::Link
    added tooltip attribute
  * Bivio::UI::HTML::Widget::ListAction
    NEW
  * Bivio::UI::HTML::Widget::YesNo
    Allow event_handler to be specified
  * Bivio::UI::View::CSS
    added a.list_action
  * Bivio::UI::Widget::URI
    added query_type param, if present calls format_uri() on source
  * Bivio::UI::XHTML::ViewShortcuts
    Add 'vs_descriptive_field_no_description' to
    'vs_descriptive_field'. Suppresses the description below the input
    field (analogous to 'vs_descriptive_field_no_label').
  * Bivio::Util::RealmMail
    added clear_junk_messages()

  Revision 11.60  2012/03/09 23:41:37  moeller
  * Bivio::Biz::Action::ECCreditCardProcessor
    die unless currency is USD
  * Bivio::Biz::Action::ECPaymentProcessAll
    removed processor config
    let the ECCreditCardPayment model determine the processor used
  * Bivio::Biz::Action::ECPayPalProcessor
    use ACK as processor_response if L_LONGMESSAGE0 is not present
  * Bivio/Util/t/Release
    NEW
  * Bivio::Util::User
    add detach_user

  Revision 11.59  2012/03/08 23:11:26  moeller
  * Bivio::Util::Release
    build: __perl_provides and __perl_requires are set to nil.  The
    rpmbuild perl parser is a regexp and really flakey so it wasn't
    completing the build
    yum_update checks yum_update_conflicts and only reinstalls pkgs that
    were installed before

  Revision 11.58  2012/03/08 20:38:43  moeller
  * Bivio::Biz::Action::ECPayPalProcessor
    NEW
  * Bivio::Biz::Model::ECCreditCardPaymentForm
    now uses ECCreditCardPayment->process_payment()
  * Bivio::Biz::Model::ECCreditCardPayment
    rm pod
    refactored
    added process_payment()
  * Bivio::Biz::Model::ECCreditCardRefundForm
    now calls process_payment() directly
  * Bivio::Biz::Model::ECPayment
    added currency_name field
  * Bivio::SQL::DDL
    added ec_payment_t.currency_name
  * Bivio::Type::CurrencyName
    added is_valid_paypal()
  * Bivio::Type::ECPaymentStatus
    added get_paypal_type()
  * Bivio::Util::Release
    yum_update: fpc (was passing array_ref to system)
    yum_update: -force/-nodeps => force/nodeps
  * Bivio::Util::SQL
    added payment_currency db upgrade

  Revision 11.57  2012/03/08 01:38:48  nagler
  * Bivio::UI::View::AcceptanceTestResultViewer
    Adapt to 't*' in URI by creating URI in perl instead of in JavaScript
    Adapt to 't*' in URI by creating URI in perl instead of in JavaScript
    Adapt to 't*' in URI by creating URI in perl instead of in JavaScript
  * Bivio::UI::View::Base
    Adapt to 't*' in URI by creating URI in perl instead of in JavaScript
    Backout previous check-in
    allow xml views to set content_encoding.  Default to ISO-8859-1
  * Bivio::UI::XML::Widget::Page
    allow xml views to set content_encoding.  Default to ISO-8859-1

  Revision 11.56  2012/03/02 02:43:04  nagler
  * Bivio::BConf
    Bivio::UI::Facade.http_suffix is deprecated
  * Bivio::Biz::Model::RealmFileList
    defer initialization of global vars ($_RF, $_FP, $_ARF) to avoid
    circular initialization in Bivio::Biz::Model::_load_all_property_models
  * Bivio::Biz::PropertyModel
    _assert_realm_id_field() was not iterating properly
  * Bivio::DefaultBConf
    Bivio::UI::Facade.http_suffix is deprecated
  * Bivio::IO::Config
    doc
  * Bivio::IO::File
    added symlink
  * Bivio::PetShop::BConf
    Bivio::UI::Facade.http_suffix is deprecated
  * Bivio::Test::Request
    $req => $self in get_instance
  * Bivio::UI::Facade
    Bivio::UI::Facade.http_suffix is deprecated
  * Bivio::Util::HTTPConf
    http_suffix is deprecated
  * Bivio::Util::Project
    link default_prefix to '.' if not there and local_file_root has a
    "ddl" folder
  * Bivio::Util::Search
    cleaner output

  Revision 11.55  2012/02/24 20:36:21  moeller
  * Bivio::Biz::Model::JobLock
    job_lock_t.message is now Text64K
  * Bivio::Biz::Model::Lock
    changed realm_id type back to PrimaryId to avoid cascade_delete()
    clearing the current lock
  * Bivio::Biz::Model::MotionVote
    motion_vote_t.comment is now Text64K
  * Bivio::PetShop::Test::PetShop
    moved fixup_files_uri to TestLanguage.HTTP->visit_realm_file_change_mode
  * Bivio::Search::Xapian
    added unsafe_get_values_for_primary_id
    added local() to $ENV
  * Bivio::SQL::DDL
    change VARCHAR(500) fields to TEXT64K
  * Bivio::Test::Language::HTTP
    added submit_realm_file_plain_text, random_alpha_string,
    visit_realm_file_change_mode (was fixup_files_uri in
    TestLanguage.PetShop)
    fixed case in visit_realm_folder to allow undef $folder meaning root
  * Bivio::Type::DisplayName
    use Text64K width
  * Bivio::Type::TupleSlot
    use Text64K width
  * Bivio::Util::Search
    added audit_db/realm
  * Bivio::Util::SQL
    added display_name and text_size bundle upgrades, changes size to Text64K

  Revision 11.54  2012/02/23 18:32:35  nagler
  * Bivio::Agent::HTTP::Query
    is_blesser_of deprecates is_blessed
  * Bivio::Agent::HTTP::Reply
    is_blesser_of deprecates is_blessed
  * Bivio::Agent::Job::Dispatcher
    is_blesser_of deprecates is_blessed
  * Bivio::Agent::Request
    as_string was not printing all in one line (format_args was putting in
    newline before "]")
    is_blesser_of deprecates is_blessed
  * Bivio::Agent::TaskEvent
    is_blesser_of deprecates is_blessed
  * Bivio::Auth::Realm
    is_blesser_of deprecates is_blessed
  * Bivio::Biz::Action::DAV
    is_blesser_of deprecates is_blessed
  * Bivio::Biz::Action::FileManagerAjax
    fmt
  * Bivio::Biz::Action::RealmMailBase
    is_blesser_of deprecates is_blessed
  * Bivio::Biz::Action::RemoteCopy
    do_iterate handler must return 1
  * Bivio::Biz::Action::WikiValidator
    do_iterate handler must return 1
  * Bivio::Biz::Action
    is_blesser_of deprecates is_blessed
  * Bivio::Biz::FormModel
    is_blesser_of deprecates is_blessed
  * Bivio::Biz::ListModel
    is_blesser_of deprecates is_blessed
  * Bivio::Biz::Model::AscendingAuthBaseList
    NEW
  * Bivio::Biz::Model::AscendingAuthList
    removed
  * Bivio::Biz::Model::DBAccessModelForm
    refactored to be in a cleaner style
    removed dup var
  * Bivio::Biz::Model::DBAccessModelList
    refactored to be in a cleaner style
  * Bivio::Biz::Model::Lock
    is_blesser_of deprecates is_blessed
    copy
    fpc: chain RealmOwner.realm_id
  * Bivio::Biz::Model::RealmOwnerBase
    b_use
  * Bivio::Biz::Model::RealmRole
    is_blesser_of deprecates is_blessed
  * Bivio::Biz::Model::RowTag
    is_blesser_of deprecates is_blessed
  * Bivio/Biz/Model/t/AscendingAuthBaseList
    NEW
  * Bivio::Biz::Model::TupleDefList
    AscendingAuthBaseList replaces AscendingAuthList
  * Bivio::Biz::Model::TupleSlotChoiceList
    is_blesser_of deprecates is_blessed
  * Bivio::Biz::Model::TupleSlotTypeList
    b_use
  * Bivio::Biz::Model::UserLoginBaseForm
    push up get_basic_authorization_realm, internal_validate_login_value,
    and validate_login from UserLoginForm so can be used by other apps
  * Bivio::Biz::Model::UserLoginForm
    push up get_basic_authorization_realm, internal_validate_login_value,
    and validate_login to UserLoginBaseForm so can be used by other apps
  * Bivio::Biz::Model
    moved internal_verify_do_iterate_result to Bivio.UNIVERSAL
    Added do_iterate_model_subclasses
    _load_all_property_models uses do_iterate_model_subclasses
    better encapsulation of symtab manipulations
  * Bivio::Biz::PropertyModel
    added unauth_delete_by_realm_id
    register_child_model does the work of registration, not PropertySupport
  * Bivio::Cache::RealmFileBase
    put warning if missing realm_id in handle_property_model_modification
  * Bivio::Delegate::SimpleWidgetFactory
    is_blesser_of deprecates is_blessed
  * Bivio::Delegate::TaskId
    fmt
    _merge_modifiers needs to allow for the case where the hash holds an
    entire task entry, and there is no "parent" to modify
  * Bivio::IO::Alert
    is_blesser_of deprecates is_blessed
  * Bivio::IO::CallingContext
    is_blesser_of deprecates is_blessed
  * Bivio::IO::Ref
    is_blesser_of deprecates is_blessed
  * Bivio::Mail::Incoming
    is_blesser_of deprecates is_blessed
  * Bivio::MIME::JSON
    Allow values for the 'literals' (true, false, null) to be specified on 'fromText'. This allows disambiguation of e.g. null from a string containing the word 'null'.
  * Bivio::PetShop::BConf
    enable use_file_manager
  * Bivio::PetShop::Util::SQL
    needs to be https://petshop.bivio.biz
  * Bivio::Search::Parseable
    is_blesser_of deprecates is_blessed
  * Bivio::Search::Parser
    is_blesser_of deprecates is_blessed
  * Bivio::ShellUtil
    is_blessed => is_blesser_of
  * Bivio::SQL::ListQuery
    is_blesser_of deprecates is_blessed
  * Bivio::SQL::PropertySupport
    register_child_model moved to PropertyModel
    Multiple files sharing the same model work with cascade_delete (the
    "parent_model $field" thing didn't work right
  * Bivio::SQL::Support
    is_blesser_of deprecates is_blessed
  * Bivio::t::Parameters::T1
    is_blesser_of deprecates is_blessed
  * Bivio::Test::Language::HTTP
    rework verify_zip() to use IO.Zip
    added visit_realm_file/folder so tests can be independent of FileManager
    configuration.
    Changed test uris to be /t*<command>
  * Bivio::Test::LanguageWrapper
    is_blesser_of deprecates is_blessed
  * Bivio::Test::Reload
    fpt
  * Bivio::Test::Unit
    is_blesser_of deprecates is_blessed
  * Bivio::Test::Util
    b_use
  * Bivio::Test::Widget
    is_blesser_of deprecates is_blessed
  * Bivio::Test
    is_blessed => is_blesser_of
  * Bivio::Type::ArrayBase
    do_iterate checks result with internal_verify_do_iterate_result
    is_blesser_of deprecates is_blessed
  * Bivio::Type::DateTime
    do_iterate checks result with internal_verify_do_iterate_result
  * Bivio::Type::Enum
    is_blesser_of deprecates is_blessed
  * Bivio::Type
    is_blessed => is_blesser_of
  * Bivio::UI::FacadeBase
    normalize all test/dev tasks to use /t*<command> namespace to avoid
    conflicts with other uris
  * Bivio::UI::FacadeComponent
    is_super_of deprecates is_subclass
  * Bivio::UI::Facade
    is_blesser_of deprecates is_blessed
    is_super_of deprecates is_subclass
  * Bivio::UI::Font
    is_blesser_of deprecates is_blessed
  * Bivio::UI::FormError
    is_blesser_of deprecates is_blessed
  * Bivio::UI::HTML::Format
    is_super_of deprecates is_subclass
  * Bivio::UI::HTML::Widget::Checkbox
    is_blesser_of deprecates is_blessed
  * Bivio::UI::HTML::Widget::CKEditor
    refactored to be in a cleaner style
  * Bivio::UI::HTML::Widget::Form
    is_blesser_of deprecates is_blessed
  * Bivio::UI::HTML::Widget::Link
    is_blesser_of deprecates is_blessed
  * Bivio::UI::HTML::Widget::Page
    is_blesser_of deprecates is_blessed
  * Bivio::UI::HTML::Widget::RadioGrid
    is_blesser_of deprecates is_blessed
  * Bivio::UI::HTML::Widget::SourceCode
    is_blesser_of deprecates is_blessed
  * Bivio::UI::HTML::Widget::String
    is_blesser_of deprecates is_blessed
  * Bivio::UI::HTML
    is_blesser_of deprecates is_blessed
  * Bivio::UI::Task
    cruft
  * Bivio::UI::Text::Widget::Link
    is_blesser_of deprecates is_blessed
  * Bivio::UI::View::AcceptanceTestResultViewer
    test uri changed
  * Bivio::UI::View::DBAccess
    refactored to be in a cleaner style
  * Bivio::UI::ViewLanguage
    is_blesser_of deprecates is_blessed
  * Bivio::UI::View
    is_blesser_of deprecates is_blessed
  * Bivio::UI::ViewShortcuts
    is_blesser_of deprecates is_blessed
  * Bivio::UI::Widget::ControlBase
    is_blesser_of deprecates is_blessed
  * Bivio::UI::Widget
    is_blesser_of deprecates is_blessed
  * Bivio::UI::XHTML::ViewShortcuts
    is_blesser_of deprecates is_blessed
  * Bivio::UI::XHTML::Widget::TaskMenu
    is_blesser_of deprecates is_blessed
  * Bivio::UI::XHTML::Widget::WikiText
    is_blesser_of deprecates is_blessed
  * Bivio::UNIVERSAL
    moved internal_verify_do_iterate_result from Biz.Model, and added caller=
    is_super_of deprecates is_subclass
    is_blesser_of deprecates is_blessed

  Revision 11.53  2012/02/03 22:33:58  moeller
  * Bivio::Biz::ListModel
    now calls internal_verify_do_iterate_result()
  * Bivio::Biz::Model::AuthUserRealmList
    explicit 0|1 return from do_rows() call
  * Bivio::Biz::Model::DBAccessModelForm
    do_iterate() now expects a 0|1 value
  * Bivio::Biz::Model
    added internal_verify_do_iterate_result() to ensure
    do_iterate() and do_rows() handler returns a valid boolean
  * Bivio::Test::Language::HTTP
    verify_zip: allow specification of text that must be absent from zip member c
  ontent.
    dynamically include IO::Uncompress::Unzip
  * Bivio::UI::XHTML::Widget::MobileToggler
    don't render link unless control is set

  Revision 11.52  2012/02/02 21:10:06  schellj
  * Bivio::Test::Language::HTTP
    'verify_zip' recursively unzips the current response and compares against
    the expected zip file contents passed as an array ref in I<expected>.
    The array contains pairs of expected member names and expected
    member content.
    The member name is a string or a regexp.
    The expected content is one of:
    o A string that must be exectly equal to the entire zip member content
    o A regexp that must match the zip member content
    o An array reference specifying the content of an embedded zip file
    o undefined, meaning that the member content can be anything.
    'expected' example:
    [
        'myfile.bin' => undef,
        'hello.txt' => 'Hello World',
        'goodbye.txt' => qr/bye/,
        qr/file-\d\d\d.pdf/ => qr/^%PDF/,
        'a.zip' => [
            'a.txt' => undef,
            'b.zip' => [
                'b1.txt' => undef,
            ],
            'c.txt' => undef,
         ],
    ];
  * Bivio::Type::DateTime
    add to_mm_dd_yyyy
  * Bivio::Util::HTTPConf
    ServerTokens ProductOnly (avoids PCI scan issues)
    is_production only set for IO.Config

  Revision 11.51  2012/01/30 02:37:49  nagler
  * Bivio::Biz::Model::RobotRealmFileList
    ignore count in query as well so can test small page sizes
  * Bivio::UI::View::File
    robot_list: added pager

  Revision 11.50  2012/01/30 02:03:51  nagler
  * Bivio::Agent::HTTP::Form
    Allow one or more files to be dragged onto the file manager for upload
    Add support for the 'multiple' attribute on 'file' input
    fields that allows more than one file to be
    selected. Browser each file in a 'part' but all parts have
    the same name. Create an array containing the parts with the
    same name.
  * Bivio::Agent::Request
    internal_copy_implicit: don't clear the query if there's a uri in named
    Don't use $a, rather $attr
  * Bivio::BConf
    ignore AssertNotRobot and connection aborts errors
  * Bivio::Biz::Action::AssertNotRobot
    server_redirect if there's a robot_task
  * Bivio::Biz::Action::FileManagerAjax
    Allow one or more files to be dragged onto the file manager for upload
    Support 'multiple' on file input control'
    o Added timeouts and error handling to all Ajax calls
    o Can pass 'root' folder in URL path
      http://bop2.local:8042/site/file-manager/Public
    o To use file manager instead of the file tree list,
      configure
      'Bivio::UI::XHTML::Widget::FeatureTaskMenu' => {
          use_file_manager => 1,
       }
    o Drag item out of file manager onto desktop or folder to
      download it.
      (Chrome only)
    o Image preview and file name are links to the content
      with the correct content type so items can easily be
      downloaded with 'Save link as ..' or opened in a
      new tab.
    o Can select multiple files in dialg box for for upload
      (Chrome and Firefox)
    o Content that looks like 'wiki' markup will rendered in the
      preview pane.
      (Preview cannot be resized in IE)
    o Deletion of 'archived' files is permanent
    o icon for 'Archive' is an upright trash can (kicked
      over trash can when expanded).
  * Bivio::Biz::Model::ConfirmableForm
    don't redirect in execute_unwind() if the form is in error
  * Bivio::Biz::Model::RealmFileTreeList
    o Added timeouts and error handling to all Ajax calls
    o Can pass 'root' folder in URL path
      http://bop2.local:8042/site/file-manager/Public
    o To use file manager instead of the file tree list,
      configure
      'Bivio::UI::XHTML::Widget::FeatureTaskMenu' => {
          use_file_manager => 1,
       }
    o Drag item out of file manager onto desktop or folder to
      download it.
      (Chrome only)
    o Image preview and file name are links to the content
      with the correct content type so items can easily be
      downloaded with 'Save link as ..' or opened in a
      new tab.
    o Can select multiple files in dialg box for for upload
      (Chrome and Firefox)
    o Content that looks like 'wiki' markup will rendered in the
      preview pane.
      (Preview cannot be resized in IE)
    o Deletion of 'archived' files is permanent
    o icon for 'Archive' is an upright trash can (kicked
      over trash can when expanded).
  * Bivio::Biz::Model::RobotRealmFileList
    NEW
  * Bivio::Delegate::TaskId
    o Added timeouts and error handling to all Ajax calls
    o Can pass 'root' folder in URL path
      http://bop2.local:8042/site/file-manager/Public
    o To use file manager instead of the file tree list,
      configure
      'Bivio::UI::XHTML::Widget::FeatureTaskMenu' => {
          use_file_manager => 1,
       }
    o Drag item out of file manager onto desktop or folder to
      download it.
      (Chrome only)
    o Image preview and file name are links to the content
      with the correct content type so items can easily be
      downloaded with 'Save link as ..' or opened in a
      new tab.
    o Can select multiple files in dialg box for for upload
      (Chrome and Firefox)
    o Content that looks like 'wiki' markup will rendered in the
      preview pane.
      (Preview cannot be resized in IE)
    o Deletion of 'archived' files is permanent
    o icon for 'Archive' is an upright trash can (kicked
      over trash can when expanded).
    FORUM_FILE_TREE_LIST/MANAGER redirect to ROBOT_FILE_LIST if UserAgent
    is a Robot.  This displays public files only.
  * Bivio::IO::File
    copy
  * Bivio::ShellUtil
    added print_line
  * Bivio::SQL::Connection
    there was a missing "v"
  * Bivio::Type::VersionsFileName
    NEW
  * Bivio::UI::FacadeBase
    o Added timeouts and error handling to all Ajax calls
    o Can pass 'root' folder in URL path
      http://bop2.local:8042/site/file-manager/Public
    o To use file manager instead of the file tree list,
      configure
      'Bivio::UI::XHTML::Widget::FeatureTaskMenu' => {
          use_file_manager => 1,
       }
    o Drag item out of file manager onto desktop or folder to
      download it.
      (Chrome only)
    o Image preview and file name are links to the content
      with the correct content type so items can easily be
      downloaded with 'Save link as ..' or opened in a
      new tab.
    o Can select multiple files in dialg box for for upload
      (Chrome and Firefox)
    o Content that looks like 'wiki' markup will rendered in the
      preview pane.
      (Preview cannot be resized in IE)
    o Deletion of 'archived' files is permanent
    o icon for 'Archive' is an upright trash can (kicked
      over trash can when expanded).
    ROBOT_FILE_LIST
  * Bivio::UI::HTML::Widget::MonthYear
    Allow year range to be explicitly specified
    Allow year range to be explicitly specified
    Remove b_debug
  * Bivio::UI::View::FileManager
    Allow one or more files to be dragged onto the file manager for upload
    Eliminate some hard coded paths
    o Added timeouts and error handling to all Ajax calls
    o Can pass 'root' folder in URL path
      http://bop2.local:8042/site/file-manager/Public
    o To use file manager instead of the file tree list,
      configure
      'Bivio::UI::XHTML::Widget::FeatureTaskMenu' => {
          use_file_manager => 1,
       }
    o Drag item out of file manager onto desktop or folder to
      download it.
      (Chrome only)
    o Image preview and file name are links to the content
      with the correct content type so items can easily be
      downloaded with 'Save link as ..' or opened in a
      new tab.
    o Can select multiple files in dialg box for for upload
      (Chrome and Firefox)
    o Content that looks like 'wiki' markup will rendered in the
      preview pane.
      (Preview cannot be resized in IE)
    o Deletion of 'archived' files is permanent
    o icon for 'Archive' is an upright trash can (kicked
      over trash can when expanded).
  * Bivio::UI::View::File
    added robot_list (ROBOT_FILE_LIST)
  * Bivio::UI::XHTML::Widget::FeatureTaskMenu
    o Added timeouts and error handling to all Ajax calls
    o Can pass 'root' folder in URL path
      http://bop2.local:8042/site/file-manager/Public
    o To use file manager instead of the file tree list,
      configure
      'Bivio::UI::XHTML::Widget::FeatureTaskMenu' => {
          use_file_manager => 1,
       }
    o Drag item out of file manager onto desktop or folder to
      download it.
      (Chrome only)
    o Image preview and file name are links to the content
      with the correct content type so items can easily be
      downloaded with 'Save link as ..' or opened in a
      new tab.
    o Can select multiple files in dialg box for for upload
      (Chrome and Firefox)
    o Content that looks like 'wiki' markup will rendered in the
      preview pane.
      (Preview cannot be resized in IE)
    o Deletion of 'archived' files is permanent
    o icon for 'Archive' is an upright trash can (kicked
      over trash can when expanded).
  * Bivio::Util::Release
    adde

  Revision 11.49  2012/01/17 00:14:53  nagler
  * Bivio::BConf
    fmt
  * Bivio::Biz::Action::AssertClient
    added execute_is_test
  * Bivio::Biz::Action::FileManagerAjax
    NEW
  * Bivio::Biz::Model::DBAccessModelForm
    Remove debug
  * Bivio::Biz::Model::FileChangeForm
    Refactor image upload in wysiwig editor, make image upload locations configurable, make 'upload image' tab optional
  * Bivio::Biz::Model::RealmUserAddForm
    fmt
  * Bivio::Biz::Model::TestWidgetForm
    added another test field
  * Bivio::Delegate::TaskId
    Support for Simon Georget's File Manager (https://github.com/simogeo/Filemanager)
    info_dev => info_test
    gather all test tasks in info_test
    Added AssertClient->execute_is_test to all test tasks
  * Bivio::IO::File
    comment
  * Bivio::Test::Language::HTTP
    added local_mail_host()
    home_page_uri($facade) calls http_facade() if $facade is passed,
    because http_facade wasn't sticky otherwise
    generate_local/remote_email accept email addresses as first args and
    will replace with facade domain if specified
  * Bivio::UI::FacadeBase
    Support for Simon Georget's File Manager (https://github.com/simogeo/Filemanager)
    encapsulate "/b" from CKEditor in get_local_file_plain_common_uri()
    _cfg_dev => _cfg_test
  * Bivio::UI::Facade
    added get_local_file_plain_common_uri which encapsulates "/b" from CKEditor
    fmt
  * Bivio::UI::HTML::ViewShortcuts
    cruft
  * Bivio::UI::HTML::Widget::CKEditor
    Refactor image upload in wysiwig editor, make image upload locations configurable, make 'upload image' tab optional
  * Bivio::UI::HTML::Widget::MultipleChoice
    fixed enum sorting to work if enum_sort is as_int (not just defaulted)
    cleaned up formatting
  * Bivio::UI::View::Blog
    Refactor image upload in wysiwig editor, make image upload locations configurable, make 'upload image' tab optional
  * Bivio::UI::View::FileManager
    NEW
  * Bivio::UI::View::Wiki
    Refactor image upload in wysiwig editor, make image upload locations configurable, make 'upload image' tab optional
  * Bivio::UI::View::WysiwygFile
    Refactor image upload in wysiwig editor, make image upload locations configurable, make 'upload image' tab optional
  * Bivio::Util::Project
    creates "/b" link in files/<default>/plain for CKEditor if it doesn't
    exist -- assumes files structure is $ENV{HOME}/src/perl/Bivio
    Symlinks of directories stay symlinks (not directories, because "/b"
    wasn't working)
  * Bivio::Util::SQL
    delete log files in destroy_db

  Revision 11.48  2012/01/10 16:17:15  moeller
  * Bivio::Biz::Model::TupleSlotType
    validate_slot() returns choice value which matched
  * Bivio::Delegate::TaskId
    load paged list for FORUM_MOTION_STATUS
    fpc
  * Bivio::UI::View::Motion
    added pager to status page
  * Bivio::Util::Project
    if the directory is a link, don't mkdir, rather link to it

  Revision 11.47  2012/01/06 00:42:23  nagler
  * Bivio::Biz::Action::AssertNotRobot
    return NOT_FOUND so search engines do not get to login page
  * Bivio::Biz::Model::DBAccessModelForm
    NEW
  * Bivio::Biz::Model::DBAccessModelList
    NEW
  * Bivio::Biz::Model::DBAccessRowList
    NEW
  * Bivio::Biz::Model::ForumUserDeleteForm
    need to return 1 from Forum->do_iterate
  * Bivio::Delegate::TaskId
    DBAccess utility'
  * Bivio::UI::FacadeBase
    DBAccess utility'
  * Bivio::UI::View::DBAccess
    NEW

  Revision 11.46  2011/12/23 17:36:53  moeller
  * Bivio::UI::XHTML::ViewShortcuts
    vs_descriptive_field() - don't show label if wf_type is Boolean
  * Bivio::Util::Search
    fixed dup declaration
  * Bivio::Util::SQL
    added upgrade_db tuple_boolean_type

  Revision 11.45  2011/12/21 23:58:42  nagler
  * Bivio::Biz::Model::CRMThread
    Added cascade_delete to remove TupleTags
  * Bivio::Biz::Model::RealmMail
    delete_message: fix updating of non-root messages, CRMThreads aren't
    always associated with a given message
    todos
  * Bivio::Die
    added catch_quietly_unless_test
  * Bivio::PetShop::Util::TestData
    added clear_crm_threads
  * Bivio::Type::GeomPoint
    b_use
  * Bivio::UI::FacadeBase
    msg_summary is 50em
  * Bivio::UI::View::CSS
    added CSS for msg_summary
  * Bivio::UI::XHTML::Widget::WikiText::Widget
    call catch_quietly_unless_test so get errors to logs in dev/test
  * Bivio::UI::XHTML::Widget::WikiText
    clean up _task_id() so returns SITE_WIKI_VIEW if in that context
    wasn't cascading $task_id in all places
    call catch_quietly_unless_test so get errors to logs in dev/test
  * Bivio::Util::RealmMail
    added toggle_is_public_for_all
    added USAGE

  Revision 11.44  2011/12/20 01:38:21  nagler
  * Bivio::Biz::Model::RealmMail
    Deleting root RealmMail of ticket did not work
  * Bivio::Type::DecimalDegree
    compute to 8 decimal places
  * Bivio::UI::FacadeBase
    added xhtml_copyright_qualifier which can be overwritten
  * Bivio::UI::View::Motion
    use TrimmedText widget for comment and text columns
  * Bivio::UI::ViewShortcuts
    added vs_now_as_year
  * Bivio::UI::XHTML::ViewShortcuts
    added vs_trimmed_text_column()
  * Bivio::UI::XHTML::Widget::XLink
    factored out XLinkURI
  * Bivio::UI::XHTML::Widget::XLinkURI
    NEW
  * Bivio/UI-xml
    NEW
  * Bivio::Util::SiteForum
    init_bulletin: moved set_user_to_any_online_admin inside with_realm so
    would get a user in general realm.
    fixed formatting
  * Bivio::Util::TestMail
    num_msgs is now fixed (not random)

  Revision 11.43  2011/12/06 03:06:59  nagler
  * Bivio::Agent::Request
    removed is_production config param
  * Bivio::Biz::Action::RealmMail
    Don't queue a job if the user agent is_mail_agent so that we lock up
    an apache process
  * Bivio::Biz::Model::MailRealmsThreadRootList
    removed
  * Bivio::Delegate::TaskId
    reflectors need MailReceiveStatus
  * Bivio::PetShop::Test::PetShop
    b_use
  * Bivio::ShellUtil
    added do_backticks
  * Bivio::Test::ShellUtilConf
    call do_backticks
  * Bivio::Type::String
    canonicalize_and_excerpt is now re-entrant
  * Bivio::Type::UserAgent
    added is_mail_agent
  * Bivio::UI::HTML::Widget::SourceCode
    use do_backticks
  * Bivio::UI::View::ThreePartPage
    indirect the xhtml_head_title in xhtml_head_tags
  * Bivio::UI::XHTML::Widget::WikiText::Macro
    allow for @{param} in text so can be inline with other \w chars
  * Bivio/UI-xml
    NEW
  * Bivio::Util::TestMail
    NEW
  * Bivio::XML::DocBook
    use do_backticks

  Revision 11.42  2011/12/05 20:16:59  moeller
  * ckeditor.js
    render underlined text correctly

  Revision 11.41  2011/12/05 19:42:16  moeller
  * Bivio::BConf
    Synchronize newly created/deleted realm files with failover host
  * Bivio::Biz::FailoverWorkQueue
    NEW
  * Bivio::Biz::Model::RealmFile
    Synchronize newly created/deleted realm files with failover host
  * Bivio::Delegate::FailoverWorkQueueOperation
    NEW
  * Bivio::Search::Xapian
    Xapian DB replication to failover host using xapian-replicate(-server) and rs
  ync
  * Bivio::SQL::DDL
    Synchronize newly created/deleted realm files with failover host
  * Bivio::Type::FailoverWorkQueueOperation
    NEW
  * Bivio::Type::TimeZone
    UTC now included in DateTime::TimeZone->all_names
  * Bivio::Util::FailoverWorkQueue
    NEW
  * Bivio::Util::Search
    Xapian DB replication to failover host using xapian-replicate(-server) and rs
  ync
  * Bivio::Util::SQL
    Synchronize newly created/deleted realm files with failover host

  Revision 11.40  2011/11/22 20:49:31  schellj
  * Bivio::Biz::Model::MailRealmsThreadRootList
    move execute_load_recent here from subclasses
  * Bivio::UI::HTML::Format::DateTime
    don't add 'GMT' when using rfc822 mode (already included)
  * Bivio::UI::HTML::Widget::DateTime
    add previously unsupported date modes
  * Bivio::UI::HTML::Widget::Table
    allow use of table_max_rows without explicit source_name

  Revision 11.39  2011/11/17 17:26:26  moeller
  * Bivio::Biz::Action::AssertNotRobot
    NEW
  * Bivio::Biz::Model::CSVImportForm
    work-around for slow unicode value parsing, write and then read back
    the csv file before parsing
  * Bivio::Biz::Model::MailRealmsThreadRootList
    only allow public messages
  * Bivio::Delegate::TaskId
    added Action.AssertNotRobot to FORUM_FILE_TREE_LIST
  * Bivio::MIME::Calendar
    handle empty VCALENDAR case
  * Bivio::SQL::Connection::Postgres
    Allow connection host and port to be specified. Method to get
    postgres settings
  * Bivio::Util::PGStandby
    NEW

  Revision 11.38  2011/11/09 22:59:28  schellj
  * Bivio::Biz::Model::MailFromRealmsList
    removed
  * Bivio::Biz::Model::MailRealmsThreadRootList
    NEW
  * Bivio::Type::Gender
    match "M" and "F" literals
    use "M" and "F" as MALE and FEMALE string names, respectively
  * Bivio::UI::View::Mail
    sytax error in internal_thread_root_list
  * Bivio::UI::XHTML::Widget::MobileDetector
    added robot_redirect_for_desktop
  * Bivio::Util::HTTPD
    don't require port
  * Bivio/Util/t/Release
    NEW

  Revision 11.37  2011/11/06 16:29:36  nagler
  * Bivio::Agent::HTTP::Query
    die if a value is a reference when formatting (and not a command line)
  * Bivio::Agent::Request
    added set_task_and_uri used by Test.Request to correctly set the task
  * Bivio::Biz::Action::WikiValidator
    _uri_root() must be dynamically computed, because initial_uri will
    change for each path.
    Use set_task_and_uri() to set the task
  * Bivio::Biz::FormModel
    set empty_properties properly
  * Bivio::Biz::Model::MailFromRealmsList
    get message sender display_name from file, not message
    from_display_name, which isn't a required field
  * Bivio::Delegate::Cookie
    removed b_debug()
  * Bivio::Delegate::NoCookie
    stubbed out put_escaped() and unsafe_get_escaped()
  * Bivio::Ext::HTTPCookies
    fixed clone to really delete temp files.  HTTP::Coookies will save to
    the file always if there's a $self->{file}
  * Bivio::IO::Ref
    nested_differences documents the differences in keys of a hash, even
    if the number of keys is different
  * Bivio::Mail::Common
    need to set test-recipient
  * Bivio::SQL::ListQuery
    THIS_REGEX not needed
  * Bivio::Test::HTMLParser::Forms
    don't label a field if no class is being parsed
  * Bivio::Test::Language::HTTP
    added save_cookies_in_history() -- don't save cookies in the history
    by default, because too many tests depend on go_back() to stay logged in
  * Bivio::Test::Request
    use set_task_and_uri() to set the task
  * Bivio::Type::DateTime
    added common_log_format (Apache/NCSA) parsing
  * Bivio::Type::Enum
    added as_query
  * Bivio::Type::HTTPStatus
    added as_string
  * Bivio::Type::IPAddress
    added to_inet & unsafe_to_domain
  * Bivio::Type::UserAgent
    added is_robot_search_verified() to verify ip addresses of (popular)
    robots
  * Bivio/UI-xml
    NEW
  * Bivio::Util::Wiki
    b_use

  Revision 11.36  2011/11/02 22:45:10  schellj
  Release notes:
  * Bivio::Agent::Request
    use clone_return_is_self() interface rather than explictly returning singleton
  * Bivio::Biz::Action::AssertClient
    *** empty log message ***
  * Bivio::Biz::Action::WikiValidator
    fixed uri_root
  * Bivio::Biz::Model::MailFromRealmsList
    NEW
  * Bivio::Biz::Model
    use clone_return_is_self() interface rather than explictly returning singleton
  * Bivio::Delegate::Cookie
    Provide methods to get/put cookie values that may contain the RS (036) character
  * Bivio::Ext::HTTPCookies
    NEW
  * Bivio::IO::Ref
    nested_copy wasn't actually cloning the object
    nested_copy wasn't calling clone.  The test for an instance was
    incorrect.  nested_copy was also not copying the referential structure
    properly, that is, if a reference was copied around a structure
    (e.g. via a Collection.Attribute "parent"), then the reference was
    duplicated.  Now nested_copy manages references properly.  To
    accomplish this, had to add nested_copy_notify_clone API which is
    called by UNIVERSAL->clone to manage recursive references
  * Bivio::SQL::ListQuery
    added THIS_REGEX
  * Bivio::SQL::Support
    use clone_return_is_self() interface rather than explictly returning singleton
  * Bivio::t::UNIVERSAL::Clonee2
    NEW
  * Bivio::Test::Language::HTTP
    added reset_user_agent to set to undef
    fixed set_user_agent_to_robot_other to set to an actual browser string.
    save_excursion() saves cookies (uses new Bivio::Ext::HTTPCookies)
    fixed tmp_file() call
  * Bivio::Type::Enum
    use clone_return_is_self() interface rather than explictly returning singleton
  * Bivio::UNIVERSAL
    IO.Ref->nested_copy was not calling clone (even though it was supposed
    to) so clone wasn't really being tested.  Need to make sure that when
    cloning, you get a new instance unless clone_return_is_self() is true
    in which case you are returning self (which usually means the instance
    is a singleton)
  * Bivio/Util/t/Release
    NEW

  Revision 11.35  2011/10/24 03:24:51  nagler
  * Bivio::Test::Language::HTTP
    added set_user_agent_to_actual_browser/etc.
  * Bivio::Type::UserAgent
    added BROWSER_ROBOT_SEARCH
    renamed BROWSER_ROBOT => BROWSER_ROBOT_OTHER
    added is_robot*() routines.  Don't rely on the UA being an exact
    value.

  Revision 11.34  2011/10/23 23:28:41  nagler
  * Bivio::Biz::Model::RealmFile
    rewrote delete_empty_folders to not delete '/' and to not rely on
    pattern matching or multiple questions (is_empty) on every row.
  * Bivio::Type::UserAgent
    added is_robot
    added is_real_user (is_browser & is_robot)
  * Bivio::UNIVERSAL
    added self_from_req
    Changed unsafe_self_from_req to work if no request is passed, similar
    to Facade->get_from_request_or_self

  Revision 11.33  2011/10/23 02:20:18  nagler
  * Bivio::Util::Release
    Save the values of _b_release_define() so they can not only be used in
    other sections but also in _b_release_file.  See Release.bunit as an
    example.
    need to allow semicolons in arguments to _b_release_*()
    _b_release_files: handle multi-line macro expansions
  * Bivio/Util/t/Release
    removed

  Revision 11.32  2011/10/21 23:16:20  schellj
  * Bivio::Biz::Action::WikiValidator
    added the uri root to uris missing a leading /
  * Bivio::Biz::Model::RealmFile
    add delete_empty_folders
    set auth_id to loaded realm_id on RealmFileList query in is_empty
  * Bivio::Util::HTTPD
    fixed "tail -f ..." message
    added ExtendedStatus On and /z server-status location

  Revision 11.31  2011/10/19 04:11:02  nagler
  * Bivio::Die
    format the incoming SIG{DIE} msg, because it may be an improperly
    overloaded object (APR::Error doesn't implement "eq", for example)
  * Bivio::IO::Alert
    format the incoming SIG{WARN} msg, because it may be an improperly
    overloaded object (APR::Error doesn't implement "eq", for example)
    format_args() stringifies incoming objects.
  * Bivio::Search::Xapian
    acquire_lock everywhere
  * Bivio::Util::HTTPConf
    no trans_handler
  * Bivio::Util::Search
    acquire_lock at start of rebuild_realm

  Revision 11.30  2011/10/16 23:05:16  nagler
  * Bivio::Agent::HTTP::Dispatcher
    added a trans_handler, because apache 2.0 reports:
    Module bug?  Request filename is missing for URI /
    You need to set filename to something so that Apache's trans_handler
    code doesn't produce this message
  * Bivio::Util::HTTPConf
    Changed trans_handler to 'Bivio::Agent::HTTP::Dispatcher::trans_handler' to fix
    Module bug?  Request filename is missing for URI /
  * Bivio::Util::HTTPD
    set PerlTransHandler for 2.0 (good for testing so matches what
    Util.HTTPConf does

  Revision 11.29  2011/10/16 04:01:07  nagler
  * Bivio::Util::HTTPConf
    Load mod_authz_user and mod_authn_default
    load mod_authz_default module (with this, you'll get weird errors)

  Revision 11.28  2011/10/15 23:26:49  nagler
  * Bivio::Type::CIDRNotation
    use IPAddress REGEX
    Added get_net_mask and assert_host_address
  * Bivio::Type::IPAddress
    NEW
  * Bivio::Util::HTTPConf
    turn on basic auth
  * Bivio::Util::NetConf
    NEW
  * Bivio::Util::Release
    added _b_release_define so can have formatted %define's in spec files

  Revision 11.27  2011/10/13 21:19:08  schellj
  * Bivio::Util::CSV
    cols containing \r need to be quoted
  * Bivio::Util::SQL
    changed column_exists() sql for pg

  Revision 11.26  2011/10/11 16:40:04  schellj
  * Bivio::Test::Util
    save unit test output to unit_log_dir
  * Bivio::UI::FacadeBase
    change text for ok_no_validate_button, ok_button for sub/super users
  * Bivio::UI::View::Wiki
    switch order of ok_button, ok_no_validate_button
  * Bivio::Util::SQL
    added drop_constraints()

  Revision 11.25  2011/10/07 23:43:07  nagler
  * Bivio::Biz::IIF
    NEW
  * Bivio::Test::Util
    make sure we can delete test directories
  * Bivio::Util::Forum
    Added create_realm
  * Bivio::Util::IIF
    Moved to Biz.IIF
  * Bivio::Util::LinuxConfig
    loosen IP regexp

  Revision 11.24  2011/10/05 00:26:24  moeller
  * Bivio::Biz::Model::CRMThread
    now calls Email->unsafe_user_id_from_email()
  * Bivio::Biz::Model::Email
    added unsafe_user_id_from_email()
  * Bivio::Mail::Incoming
    share get_from_user_id() in Model.Email->unsafe_user_id_from_email()
  * Bivio::Util::LinuxConfig
    need to generate networks with Type.CIDRNotation.map_host_addresses
    b/c was only handling 24 bit subnets or smaller

  Revision 11.23  2011/10/04 00:15:42  schellj
  * Bivio::Test::Util
    unit test bconf suffix now "-bunit"
    remove unnecessary var
  * Bivio::UI::View::WysiwygFile
    Improve private/public image upload

  Revision 11.22  2011/10/03 04:00:16  nagler
  * Bivio::Agent::Reply
    need to default set_cache_max_age
  * Bivio::Biz::Model::DAVList
    b_use
  * Bivio::Biz::Model::MailReceiveDispatchForm
    use Mail.Common->TEST_RECIPIENT_HDR (was incorrectly using X-Bivio-Mail-Test)
  * Bivio::Biz::Model::RealmDAVList
    need to list specific order_by, because UserRealmDAVList.bunit was
    failing on with Postgres 8.4.  Sort order was varying without it
    being set explicitly
  * Bivio::UI::View::Blog
    create*() needs to reference BlogCreateForm, not BlogEditForm.
    _edit() needs to accept $form param

  Revision 11.21  2011/10/02 03:18:43  nagler
  * Bivio::Agent::HTTP::Reply
    send: don't set_cache_private if already set Cache-Control and is
    scalar, because some other module either set_cache_private or wanted
    non-private caching
    added set_cache_max_age
  * Bivio::Biz::Action::LocalFilePlain
    set_cacheable_output: Moved Cache-Control/Expires to set_cache_max_age

  Revision 11.20  2011/10/02 00:08:40  nagler
  * Bivio::Agent::HTTP::Reply
    b_use
    return $self from a few more routines
  * Bivio::Agent::Reply
    added unsafe_get_header (better than explicitly touching attribute "headers")
  * Bivio::Biz::Action::LocalFilePlain
    added set_cacheable_output and if Facade.want_local_file_cache is
    true, cache for 3600 seconds (setting Cache-Control and Expires) headers
  * Bivio::Biz::Model::MailPartList
    use LocalFilePlain.set_cacheable_output for parts
  * Bivio::Biz::Model::TupleDefListForm
    need to proccess the row if it was not empty previously
    update existing label/moniker
    only clear label errors if the field is blank
  * Bivio::IO::t::Config::T2
    NEW
  * Bivio::Type::UserAgent
    facebookexternalhit is a robot
  * Bivio::UI::HTML::ViewShortcuts
    allow html_attrs which contain underscores and dashes.
    vs_html_attrs_render_one won't strip the last part if the attr is all
    upper case.  This preserves behavior for Grid, Table, etc., but allows
    attributes with underscores (e.g. Facebook's show_face)
  * Bivio::UI::HTML::Widget::ControlBase
    allow attributes with underscores and dashes
  * Bivio::UI::HTML::Widget::Grid
    fmt
  * Bivio::UI::HTML::Widget::Page
    doc
  * Bivio::UI::HTML::Widget::Tag
    allow tags with ':' so can support xml namespaces (e.g. FBXML)
  * Bivio::UI::Icon
    added get_uri

  Revision 11.19  2011/09/28 20:07:19  moeller
  * Bivio::Biz::Model::BlogList
    Fix images with ^href sources in blogs
  * Bivio::UI::View::Blog
    Fix images with ^href sources in blogs
    Fix images with ^href sources in blogs
  * Bivio::UI::View::File
    add buttons to top of file-change edit contents form
  * Bivio::UI::XHTML::Widget::TaskMenu
    Allow 'link_target' to be specified on TaskMenu items

  Revision 11.18  2011/09/26 16:08:43  schellj
  * Bivio::Type::String
    more transliteration
  * Bivio::UI::HTML::Widget::Table
    add column_summary_value
  * Bivio::UI::View::Blog
    Creating a blog entry was always non-wysiwyg even if wysiwyg mode enabled

  Revision 11.17  2011/09/23 12:25:23  nagler
  * Bivio::IO::Config
    added ignore_errors config param for certain cases (link_facade_files)
  * Bivio::UI::HTML::Widget::Script
    trim_text guard against null element
  * Bivio::UI::XHTML::Widget::TrimmedText
    don't render javascript unless rendered length greater than cutoff

  Revision 11.16  2011/09/21 20:59:53  moeller
  * Bivio::Agent::Request
    warn if an unresolvable facade name is passed to format_http_prefix()
  * Bivio::Biz::Model::FileChangeForm
    Allow new images to be uploaded and existing images to be browsed
    from wysiwyg editor
  * Bivio::Delegate::TaskId
    Allow new images to be uploaded and existing images to be browsed
    from  wysiwyg editor
  * Bivio::HTML::Scraper
    instruct HTMLParser to ignore script, object, style and xml tags when
    parsing text
  * Bivio::Test::Util
    fix for nightly_output_to_wiki reporting directories with /t/ in the middle
  * Bivio::Type::String
    transliterate "zero width space"
  * Bivio::UI::FacadeBase
    Allow new images to be uploaded and existing images to be browsed
    from wysiwyg editor
  * Bivio::UI::HTML::Widget::CKEditor
    Allow new images to be uploaded and existing images to be browsed
    from wysiwyg editor
  * Bivio::UI::HTML::Widget::Script
    added trim_text script
  * Bivio::UI::View::Wiki
    Allow new images to be uploaded and existing images to be browsed
    from wysiwyg editor
  * Bivio::UI::View::WysiwygFile
    NEW
  * Bivio::UI::XHTML::Widget::TrimmedText
    NEW
  * Bivio::Util::User
    during merge_users(), copy user's RealmFile records rather than update
    to avoid dependencies with nested folders

  Revision 11.15  2011/09/13 20:32:15  schellj
  * Bivio::Biz::ListFormModel
    add get_non_empty_result_set_size
  * Bivio::Biz::ListModel
    add get_non_empty_result_set_size
  * Bivio::MIME::JSON
    added to_text()
  * Bivio::Test::Util
    fix for test paths that have a /t/ in the middle
  * Bivio::UI::HTML::Widget::Table
    add summary_only attr
  * Bivio::Util::CSV
    added sort_csv() utility
  * Bivio::Util::LinuxConfig
    while (--$i) gets into an infinite loop if the mask is 32

  Revision 11.14  2011/08/29 20:37:12  nagler
  * Bivio::Test::Util
    don't change directory to create link
    use unit test specific bconf
  * Bivio::Type::CIDRNotation
    added address_to_host_num
  * Bivio::Util::LinuxConfig
    _bits2netmask supports all net sizes
  * Bivio::Util::NamedConf
    handle larger address spaces than just class C
  * Bivio::Util::Release
    added run_sh
    fpc
    fpc

  Revision 11.13  2011/08/25 17:15:11  schellj
  * Bivio::Test::Util
    _make_nightly_dir: symlink will fail if the link already exists
  * Bivio::UI::HTML::Widget::ListActions
    Allow 'path_info' to be specified on ListActions

  Revision 11.12  2011/08/24 20:56:24  schellj
  * Bivio::MIME::Calendar
    ignore contact
    apply tzid to dtstart, dtend if present
    removed TODO
  * Bivio::Test::Util
    create symlink 'latest' to latest nightly cvs dir
  * Bivio::Util::HTTPConf
    interim checking for apache2 so have original /etc/rc.d/init.d/httpd
    from apache2
    $_INIT_RC_V2 should work for apache2
    fpc
    PerlFreshRestart is not an apache2 command, need Apache2::compat
    fpc
    no SSLLog in v2
    no SSLLogLevel
    need mod_authz_host
    trans_handler by default is Apache::Constants::OK
    trans_handler uses Ext.ApacheConstants, because v1 & v2 are so
    different (and screwed up)
  * Bivio::Util::LinuxConfig
    postgres_base: need to have sameuser as optional
  * Bivio::Util::SQL
    fmt
  * Bivio::Util::SSL
    need to set_serial

  Revision 11.11  2011/08/22 18:50:24  nagler
  * Bivio::Util::HTTPConf
    support apache v2
  * Bivio::Util::HTTPD
    better support v2

  Revision 11.10  2011/08/22 16:28:57  schellj
  * Bivio::Biz::Model::Motion
    Change motion question to Text64K
  * Bivio::SQL::DDL
    Change motion question to Text64K
  * Bivio::SQL::ListQuery
    changed CORRUPT_QUERY die to a warn when unknown order by column is
    used. clears the order_by and continues instead.
  * Bivio::Test::ShellUtilConf
    use builtin_bunit_base_name not simple_package_name
  * Bivio::Test::Unit
    added builtin_bunit_base_name
  * Bivio::TypeValue
    fixed as_string() for values with multiple items
  * Bivio::UI::HTML::Widget::Page
    added html_tag_attrs
  * Bivio::UI::View::Wiki
    added blank label to version_list() radios
  * Bivio::UI::XHTML::Widget::Page3
    use qualified class, not package
  * Bivio::Util::SQL
    Change motion question to Text64K
    add motion_question_64k to bundle

  Revision 11.9  2011/08/12 16:04:02  moeller
  * Bivio::UI::HTML::Widget::Checkbox
    refactored to allow Radio widget to subclass
    added label tag around label text
  * Bivio::UI::HTML::Widget::RadioGrid
    Radio.value --> Radio.on_value
  * Bivio::UI::HTML::Widget::Radio
    refactored, now a subclass of Checkbox
  * Bivio::UI::HTML::Widget::YesNo
    refactored, now uses Radio widgets
  * Bivio::UI::View::CSS
    cleanup checkbox css
  * Bivio::UI::View::Wiki
    Radio.value --> Radio.on_value

  Revision 11.8  2011/08/11 00:03:39  schellj
  * Bivio::PetShop::Facade::PetShop
    add GROUP_MAIL_RECEIVE_WEEKLY_BUILD_OUTPUT
  * Bivio::Test::Util
    run all unit tests for bOP, not just Bivio/PetShop
  * Bivio::UI::FacadeBase
    add GROUP_MAIL_RECEIVE_WEEKLY_BUILD_OUTPUT

  Revision 11.7  2011/08/08 23:59:32  schellj
  * Bivio::Biz::Action::WeeklyBuildOutput
    NEW
  * Bivio::Delegate::TaskId
    add GROUP_MAIL_RECEIVE_WEEKLY_BUILD_OUTPUT
  * Bivio::Test::Util
    add weekly_build_output_to_wiki
    weekly_build_output_to_wiki - toss content older than one day

  Revision 11.6  2011/08/08 20:15:19  schellj
  * Bivio::Agent::Embed::Request
    override need_to_secure_task(),
    embeded tasks don't need to switch to secure mode
  * Bivio::BConf
    also include commit_or_rollback in the sql filter
  * Bivio::Biz::Model::ForumUserDeleteForm
    fix for not finding RealmUser records in sub forums where none exist
    in the parent forum
  * Bivio::Biz::Util::RealmRole
    set_user to reset cached values after un/make_super_user
  * Bivio::IO::Log
    require 'directory'
  * Bivio::Test::Util
    allow unit tests to run if acceptance tests failed
  * Bivio::UI::FacadeBase
    RCS file: /home/cvs/perl/Bivio/UI/FacadeBase.pm,v
    Working file: Bivio/UI/FacadeBase.pm
    head: 1.326
    branch:
    locks: strict
    access list:
    symbolic names:
    keyword substitution: kv
    total revisions: 326;	selected revisions: 0
    description:
  * Bivio::Util::SiteForum
    improved init_admin_user
    added admin_user()
    don't set auth_user_id if the default in init_admin_user
  * Bivio::Util::SQL
    need to rollback on create_db, because facade init does queries which
    are in error, and PG complains about that
    clearer prompt on destroy_db

  Revision 11.5  2011/07/29 17:28:19  moeller
  * Bivio::UI::View::Wiki
    fixed baked in $req for wiki buttons, added wiki buttons to wysiwyg edit

  Revision 11.4  2011/07/28 20:08:24  moeller
  * Bivio::Biz::Model::MotionForm
    archive old same-named files when creating motion document
  * Bivio::Biz::Model::MotionList
    use versionless tail for file name
  * Bivio::Biz::Model::WikiForm
    add ok_no_validate_button
  * Bivio::DefaultBConf
    need to set NoDbAuthSupport explicitly
  * Bivio::Ext::DBI
    connect: die if db is not set
  * Bivio::IO::Zip
    minor refactoring
  * Bivio::MIME::Calendar
    allow continued line to start with a tab
    allow empty values
    canonicalize_charset for result from HTML->unescape()
  * Bivio::UI::FacadeBase
    add ok_no_validate_button to WikiForm
  * Bivio::UI::View::Motion
    use versionless tail when displaying motion file name
  * Bivio::UI::View::Wiki
    add ok_no_validate_button for sub/superusers

  Revision 11.3  2011/07/14 19:13:08  moeller
  * Bivio::UI::View::Wiki
    add buttons to top of wiki edit form
  * Bivio::Util::User
    when merging RealmFile records, override_is_read_only for updates

  Revision 11.2  2011/07/04 16:47:25  nagler
  * Bivio::DefaultBConf
    added facade and taskid
  * Bivio::Delegate::DefaultTaskId
    NEW
  * Bivio/UI/Facade
    NEW

  Revision 11.1  2011/07/04 16:17:12  nagler
  * Bivio::BConf
    added dev_root and DELEGATE_ROOT_PREFIX
    added CURRENT_VERSION
  * Bivio::DefaultBConf
    NEW

  Revision 11.0  2011/07/04 16:02:53  nagler
  * Bivio::BConf
    added dev_root and DELEGATE_ROOT_PREFIX
  * Bivio::Biz::Model::RealmOwner
    added unauth_load_and_get_id
  * Bivio::Collection::Attributes
    added put_req, and expose REQ_KEY
  * Bivio::Delegate::SimpleTypeError
    added INTERNAL_SYSTEM_ERROR for cases outside of normal syntax
  * Bivio::ShellUtil
    new() takes a $req so can initialize with directly linked request
    removed get_project_root
  * Bivio::Test::Unit
    display comments with /* */ on cases
  * Bivio::Test::Util
    print for unit tests
  * Bivio::UI::FacadeBase
    expose internal_site_name
  * Bivio::Util::HTTPD
    use get_local_file_root
  * Bivio::Util::RealmAdmin
    added is_realm_user
  * Bivio::Util::SQL
    added ddl_dir() use that instead of hack to find files

  Revision 10.91  2011/07/01 23:28:02  schellj
  * Bivio::Biz::Model::AcceptanceTestList
    NEW
  * Bivio::Biz::Model::AcceptanceTestTransactionList
    NEW
  * Bivio::Biz::Model::UserSettingsListForm
    don't require verification if substitute user changes email
  * Bivio::Delegate::Cookie
    ignore prior tag values if current tag exists
    clear prior tags with hostname domain
  * Bivio::Delegate::TaskId
    Acceptance Test Result Viewer - generate view on the fly
  * Bivio::Test::Util
    also run unit tests in nightly
  * Bivio::Type::UserAgent
    _is_robot: added other robots, added (?:) to avoid setgin $n variables
    added libcurl
  * Bivio::UI::FacadeBase
    Acceptance Test Result Viewer - generate view on the fly
  * Bivio::UI::HTML::Widget::File
    fixed missing size attribute render
  * Bivio::UI::View::AcceptanceTestResultViewer
    NEW

  Revision 10.90  2011/06/27 23:40:08  schellj
  * Bivio::Biz::Model::EmailVerifyForceForm
    NEW
  * Bivio::Delegate::TaskId
    add USER_EMAIL_VERIFY_FORCE_FORM
  * Bivio::UI::FacadeBase
    add force verify email
  * Bivio::UI::View::UserAuth
    add force verify email
  * Bivio::Util::LinuxConfig
    turn on NETWORKING_IPV6=yes

  Revision 10.89  2011/06/22 18:04:47  schellj
  * Bivio::Type::String
    fixed AE transliteration, added C cedilla
  * Bivio::Util::Forum
    add forum_activity, cascade_forum_activity

  Revision 10.88  2011/06/21 17:25:29  moeller
  * Bivio::Biz::Action::EasyForm
    fpc: separate $form into $form and $form_param, and only return goto
    if not $form_param
  * Bivio::Delegate::Cookie
    delete the prior_tag cookies for both IP and $domain (if exists)
  * Bivio::Delegate::SimpleTypeError
    updated FILE_NAME error message
  * Bivio::Test::Language::HTTP
    Add test script file name and line number to request log file for
    test result viewer
  * Bivio::Type::FileName
    don't allow % in a file name
  * Bivio::Type::UserAgent
    added BROWSER_ROBOT
  * Bivio::UI::FacadeBase
    column string for email_verified_date_time
  * Bivio::Util::HTTPD
    added search paths for apache on CentOS 5.6
  * Bivio::Util::ResultViewer
    NEW

  Revision 10.87  2011/06/08 21:40:14  moeller
  * Bivio::Biz::Model::RoleBaseList
    added internal_cache_key() for subclasses to override if they change
    roles_by_category()

  Revision 10.86  2011/06/06 20:49:22  moeller
  * Bivio::UI::HTML::Widget::Radio
    render enum as html before comparing values

  Revision 10.85  2011/06/03 20:02:38  schellj
  * Bivio::UI::HTML::Widget::RadioGrid
    double escaping the enum value

  Revision 10.84  2011/06/03 15:49:38  nagler
  * Bivio::UI::HTML::Widget::RadioGrid
    put spans around elements
    only put the span around the label if it is not a blessed widget
  * Bivio::UI::XHTML::Widget::RealmCSS
    fmt

  Revision 10.83  2011/06/02 02:44:20  schellj
  * Bivio::BConf
    added "all" trace
  * Bivio::Biz::Action::EasyForm
    Added $no_update_mail param for subclasses
    fpc
    added ability to pass in form directly
  * Bivio::Biz::Action::RealmFile
    fix error output
  * Bivio::Test::Language::HTTP
    update uri with internal_append_query
  * Bivio::UI::View::Motion
    For entity ePOlls, add affiliation to summary screen, summary csv, comment list/csv and votes list/csv

  Revision 10.82  2011/05/24 23:47:38  moeller
  * Bivio::Agent::TaskEvent
    use facade_uri with redirects
  * Bivio::Biz::Model::AdmUserList
    b_use
  * Bivio::Delegate::TaskId
    load Model.Model in FORUM_MOTION_VOTE_LIST_CSV

  Revision 10.81  2011/05/23 20:23:41  moeller
  * Bivio::Biz::Model::MotionList
    refactored vote count columns
  * Bivio::UI::View::Motion
    Allow subclasses to override motion type column and vote list fields

  Revision 10.80  2011/05/20 19:01:25  nagler
  * Bivio::BConf
    Bivio::IO::Log.directory is $uri based
  * Bivio::IO::Log
    log directory can't be required, because default_merge_overrides()
    isn't always called in Bivio::BConf
    directory is required, and now in Bivio::BConf to use the main uri,
    not the specific facade uri

  Revision 10.79  2011/05/18 02:15:30  schellj
  * Bivio::Util::RealmAdmin
    add force_email_verify

  Revision 10.78  2011/05/16 22:12:46  nagler
  * Bivio::BConf
    dev(): added is_dev => 1
  * Bivio::Biz::Action::Error
    Facade configurable view (ActionError_default_value)
  * Bivio::Delegate::Cookie
    added prior_tags which are read and deleted if found
  * Bivio::IO::Config
    added is_dev
  * Bivio::Test::Language::HTTP
    login_as accepts facade
  * Bivio::UI::FacadeBase
    export internal_merge and internal_base_tasks allowing filtering by sublcasses
  * Bivio::UI::View::Error
    export body
  * Bivio::UI::XHTML::Widget::RealmCSS
    added view_name so can specify which view to render

  Revision 10.77  2011/05/12 20:57:48  moeller
  * Bivio::UI::View::Motion
    Added internal_display_comment_field() for subclasses

  Revision 10.76  2011/05/12 00:46:22  schellj
  * Bivio::Biz::Model::EmailVerify
    don't need internal_get_realm_id anymore
    added force_update to use when people first register

  Revision 10.75  2011/05/11 21:49:26  schellj
  * Bivio::Biz::Model::EmailVerifyForm
    add internal_get_mail
    will be logged in, load email from auth_user
  * Bivio::Delegate::TaskId
    moved email verify views to UserAuth
    redirect to USER_SETTINGS_FORM on USER_EMAIL_VERIFY cancel
  * Bivio::Test::Unit
    allow more than 9 test files for a module
  * Bivio::UI::FacadeBase
    email verify text change
    verify email text adjustment
  * Bivio::UI::View::Mail
    moved email verify views to UserAuth
  * Bivio::UI::View::UserAuth
    moved email verify views from Mail

  Revision 10.74  2011/05/10 23:39:15  moeller
  * Bivio::Biz::Model::MotionVote
    removed items already defined in superclass
  * Bivio::UI::HTML::Widget::MultipleChoice
    NEW
  * Bivio::UI::HTML::Widget::RadioGrid
    now derived from MultipleChoice widget
  * Bivio::UI::HTML::Widget::Radio
    rm pod, refactored
    convert selected value using get_field_type()->to_html()
    added event_handler
  * Bivio::UI::HTML::Widget::Select
    moved logic to superclass for sharing with RadioGrid

  Revision 10.73  2011/05/10 16:33:01  nagler
  * Bivio::Biz::Model::TaskLog
    added set_user_id()
  * Bivio::UI::FacadeBase
    moved USER_EMAIL_VERIFY tasks to _cfg_user_auth()

  Revision 10.72  2011/05/10 03:01:59  schellj
  * Bivio::Util::SQL
    added upgrade_db email_verify

  Revision 10.71  2011/05/10 01:18:20  schellj
  * Bivio::Biz::Model::EmailVerifyForm
    NEW
  * Bivio::Biz::Model::EmailVerify
    NEW
  * Bivio::Biz::Model::UserSettingsListForm
    redirect to USER_EMAIL_VERIFY if email changed
  * Bivio::Delegate::SimpleTypeError
    add EMAIL_VERIFY_KEY
  * Bivio::Delegate::TaskId
    add USER_EMAIL_VERIFY, USER_EMAIL_VERIFY_SENT
  * Bivio::Search::Parser
    set modified_date_time to model
  * Bivio::SQL::DDL
    add email_verify_t
  * Bivio::Type::EmailVerifyKey
    NEW
  * Bivio::UI::FacadeBase
    changes for USER_EMAIL_VERIFY
  * Bivio::UI::HTML::Widget::JavaScript
    made newlines in-place
  * Bivio::UI::View::Mail
    added email_verify_mail, email_verify_sent
  * Bivio::UI::View::UserAuth
    remove row control on email
  * Bivio::UI::XHTML::Widget::MobileDetector
    removed unused handle_cookie_in()

  Revision 10.70  2011/05/09 17:30:45  nagler
  * Bivio::BConf
    added ability to set "uri" so can have different value from Root
    added backup_root; added "uri" so can be different from Root
  * Bivio::Biz::File
    addec backup_root
  * Bivio::UI::View::Motion
    Add badge number to vote result CSV (refactor)
    Fix comment list on status screen

  Revision 10.69  2011/05/03 19:15:08  moeller
  * Bivio::Biz::Action::RealmMailBase
    fixed arg order to format_recipient()
  * Bivio::Biz::Model::MotionVoteList
    Add display name to mail link in vote list
  * Bivio::UI::View::Motion
    Add display name to mail link in vote list
  * Bivio::Util::Project
    ignore .cvsignore

  Revision 10.68  2011/05/02 18:23:54  nagler
  * Bivio::Biz::Action::EasyForm
    ensure the existing csv file content has a trailing "\n"
    so heading substitution works
  * Bivio::Biz::Action::SCMViewerTunnel
    removed
  * Bivio::Biz::Action::SFEETunnel
    removed
  * Bivio::Biz::Model::MotionCommentList
    Truncate long comments and provide link to comment detail
  * Bivio::Delegate::TaskId
    Truncate long comments and provide link to comment detail
    removed MotionAux from FORUM_MOTION_COMMENT_DETAIL
    changed items loaded for FORUM_MOTION_COMMENT_DETAIL
  * Bivio::PetShop::BConf
    turn on use_wysiwyg
  * Bivio::UI::FacadeBase
    Yes/No -> Approve/Disapprove and other labels
    Display only own vote for non-officers. Refactor open/closed ePoll lists
    Truncate long comments and provide link to comment detail
  * Bivio::UI::View::Motion
    Show the initiator's name and email on the ePoll status page.
    Yes/No -> Approve/Disapprove and other labels
    Truncate long comments and provide link to comment detail
    added items to comment_detail()
    Include motion ID in both "parent" and "this" in URL to vote form.
    Make "comment" list action optional
  * Bivio::Util::Project
    was including the default facade directory as one of the dirs to link

  Revision 10.67  2011/04/26 17:14:06  moeller
  * Bivio::Biz::Action::RealmMailBase
    use format_recipient to format the email address
  * Bivio::Biz::Model::MailReceiveDispatchForm
    removed '.' and '-' support.  Now use '*' to separate the op
  * Bivio::Biz::Model::RealmMailBounce
    use format_recipient to format the email address
  * Bivio::Type::String
    convert U+2BC to single-quote
  * Bivio::Util::RealmAdmin
    added initialize_ui() to create_user()

  Revision 10.66  2011/04/21 22:29:40  moeller
  * Bivio::UI::FacadeBase
    removed ref to UserInfo
  * Bivio::UI::View::Motion
    added internal_comment_csv_fields() for subclasses

  Revision 10.65  2011/04/21 21:04:05  nagler
  * Bivio::Util::HTTPConf
    added cookie_domain support

  Revision 10.64  2011/04/21 18:12:09  nagler
  * Bivio::UI::ViewShortcuts
    vs_is_current_facade uses simple_class, not uri, because uri may change

  Revision 10.63  2011/04/20 21:42:33  moeller
  * Bivio::Biz::Model::CSVImportForm
    allow columns with constraint NONE to be missing
  * Bivio::Biz::Model::MotionComment
    Change motion comment to Text64K
  * Bivio::Biz::Model::MotionForm
    update Motion with motion_file_id
  * Bivio::SQL::DDL
    Change motion comment to Text64K
  * Bivio::UI::Text::Widget::CSV
    strip trailing newlines from values
  * Bivio::Util::SQL
    Change motion comment to Text64K

  Revision 10.62  2011/04/20 04:46:09  schellj
  * Bivio::Biz::Model::MotionCommentList
    Add badge number to comment csv. Remove comment in vote list and csv
    removed UserInfo ref
  * Bivio::Biz::Model::MotionForm
    When creating a new ePoll, if a document was supplied and the ePoll name already existed then an internal error resulted instead of "already exists"..
  * Bivio::UI::FacadeBase
    Add badge number to comment csv. Remove comment in vote list and csv
  * Bivio::UI::View::File
    show "(locked)" on non-simple file trees
  * Bivio::UI::View::Motion
    Add badge number to comment csv. Remove comment in vote list and csv
  * Bivio::Util::RealmFile
    made audit_folders() public

  Revision 10.61  2011/04/18 21:42:40  nagler
  * Bivio::Search::Xapian
    store the actual modified_date_time not yyyy_mm_dd.  It's not used by
    Xapian so is ok to do this
  * Bivio::UI::View::Motion
    Make comment in vote list optional.

  Revision 10.60  2011/04/18 01:39:03  nagler
  * Bivio::Biz::Model::RealmSettingList
    Added get_file_path, which can rely on FILE_PATH_BASE.  Makes easier
    for subclasses to specify file path in multiple places
  * Bivio::Collection::Attributes
    added get_request.  WidgetValueSource already had get_request and this
    makes it more coupled by asking if "req" is on self first
  * Bivio::Search::Parser
    added xapian_posting_synonyms (defaults [])
    fmt
    Add req to attributes
  * Bivio::Search::Xapian
    Added get_stemmer (needed for parsers which want to create synonyms)
    Bind synonyms (only stemmed versions)
  * Bivio::UI::Facade
    revert find_by_uri_or_domain to use $_URI_SEARCH_LIST.  Needed to
    allow "dotted" facade uris
  * Bivio::UI::Widget::URI
    subclass as ControlBase so MobileToggler won't render tasks without uri's
  * Bivio::UI::XHTML::Widget::MobileDetector
    uri_args_for returns a hash with a control that won't render the URI
    if there's no uri for the current task
    uri_args_for: control can't use vs_task_has_uri, because doesn't work
    when not in a view

  Revision 10.59  2011/04/12 23:07:50  moeller
  * Bivio::UI::Facade
    revert find_by_uri_or_domain() to search domain parts in order
  * Bivio::UI::XHTML::Widget::RealmCSS
    backed out last change, caused bad css in NO-MATCH case

  Revision 10.58  2011/04/11 22:54:52  schellj
  * Bivio::Biz::Model::CalendarEventMonthList
    time zone fix q586
  * Bivio::Biz::Model::CalendarEventWeekList
    time zone fix q586
  * Bivio::Biz::Model::TupleDef
    removed unused arg from create_from_hash()
  * Bivio::Biz::Model::TupleSlotDef
    minor refactoring
  * Bivio::Delegate::TaskId
    fixed load_all on TupleUseList

  Revision 10.57  2011/04/08 00:51:53  schellj
  * Bivio::Biz::Model::Motion
    avoid uninitialized value in update()
    fixed status compare in update()
  * Bivio::Biz::Model::RealmFileDeletePermanentlyForm
    NEW
  * Bivio::Biz::Model::RealmFile
    added restore, restore_path, create_or_update_with_file
  * Bivio::Biz::Model::RealmFileRestoreForm
    NEW
  * Bivio::Biz::Model::RealmFileTreeList
    fix for is_archive, old $_VERSIONS_FOLDER_RE didn't work
  * Bivio::Delegate::TaskId
    added FORUM_FILE_RESTORE_FORM, FORUM_FILE_DELETE_PERMANENTLY_FORM
  * Bivio::SQL::ListQuery
    format_uri_for_this() doesn't include order_by from current list
  * Bivio::UI::FacadeBase
    added support for FORUM_FILE_RESTORE_FORM, FORUM_FILE_DELETE_PERMANENTLY_FORM
  * Bivio::UI::HTML::Widget::Tag
    die unless tag has a value
  * Bivio::UI::View::File
    added "Restore", "Delete Permanently" links for archived files
  * Bivio::UI::View::Motion
    removed Results and View Comments, now shown on Status page
    added internal_list_actions() for subclasses
  * Bivio::UI::XHTML::ViewShortcuts
    don't create Tag() for names which start with '_'

  Revision 10.56  2011/04/04 21:25:26  moeller
  * Bivio::Biz::Model::ContactForm
    minor refactoring
  * Bivio::UI::View::UserAuth
    general_contact_mail() now gets subject from ContactForm

  Revision 10.55  2011/04/04 16:23:20  moeller
  * Bivio::Util::RealmAdmin
    added leave_role()
  * Bivio::Util::SQL
    added sentinels for bundle upgrades motion2 and motion3

  Revision 10.54  2011/04/01 00:03:42  moeller
  * Bivio::Biz::Model::Motion
    set start_date_time and end_date_time from status changes
    for apps without start/end date_time
  * Bivio::Biz::Model::MotionVoteForm
    removed Motion fields
  * Bivio::Biz::Model::MotionVote
    default user_id and realm_id in create()
  * Bivio::Delegate::TaskId
    removed unneeded MotionList->execute_load_all_with_query
  * Bivio::UI::View::Motion
    made internal_topic_from_list() and internal_topic_from_motion() public
    use internal_date_time_attr() for status dates

  Revision 10.53  2011/03/30 21:27:25  nagler
  * Bivio::BConf
    use localhost.localdomain
  * Bivio::Biz::Model::RealmMail
    delete RealmMailBounce during delete_message()
  * Bivio::Delegate::TaskId
    Moniker combobox for additional comment fields.
    Use of wysiwyg editor is confurable
  * Bivio::UI::View::Motion
    removed b_debug()
    Make start/end date/time formats configurable in motion list.
    Add poll 'status' screen with summary votes list and comment list
  * Bivio::UI::Widget::IfMobile
    added is_mobile
  * Bivio::UI::XHTML::Widget::MobileDetector
    don'tneed to register for cookie

  Revision 10.52  2011/03/28 21:06:14  moeller
  * Bivio::Agent::Request
    don't modify txn_resources in place during delete_txn_resource(),
    something be iterating over it
  * Bivio::Agent::TaskEvent
    Need require_absolute for Mobile task events
  * Bivio::Biz::Action::Acknowledgement
    convert task label to int during handle_client_redirect()
  * Bivio::Biz::Model::MotionForm
    end date processing
    Schema had to be used by a table or else validation failed.
    changed TupelDef back to Tuple Use
    moved new features to app
  * Bivio::Biz::Model::MotionList
    'can_vote/can_comment' based on end time
    Queries for vote counts
    added question to sorting
  * Bivio::Biz::Model::Motion
    vote counts
  * Bivio::Delegate::TaskId
    motions additional 'status' page and comment list CSV
    changed motion task's execute_load_all_with_query() to execute_load_page()
  * Bivio::HTML::Scraper
    increase redirect limit to 10
  * Bivio::PetShop::Facade::Mobile
    NEW
  * Bivio::PetShop::Facade::PetShop
    Added mobile facade support
  * Bivio::PetShop::View::Base
    Mobile support
  * Bivio::Search::Parser::RealmFile::CommandBase
    don't pipe error into output
  * Bivio::Search::Xapian
    get message from die during get_values_for_primary_id() rather than
    warning with die message to avoid errors from HTTPLog
  * Bivio::SQL::DDL
    removed motion_t.moniker NOT NULL
  * Bivio::UI::FacadeBase
    MobileToggler support
  * Bivio::UI::Facade
    allow URIs to match dotted values
    Convert globals to refs
  * Bivio::UI::View::CSS
    MobileToggler support
    loosen div.want_sep qualifier so can be used in TaskMenu with differen class
    added _site_motion() CSS values
  * Bivio::UI::View::Motion
    added page topic to tasks
    comment results csv now includes tuple fields
    moved some motion form fields to app
  * Bivio::UI::Widget::IfMobile
    NEW
  * Bivio::UI::Widget::IfUserAgent
    NEW
  * Bivio::UI::XHTML::Widget::MailBodyHTML
    ignore utf warnings during parse()
  * Bivio::UI::XHTML::Widget::MobileDetector
    NEW
  * Bivio::UI::XHTML::Widget::MobileToggler
    NEW
  * Bivio::UI::XHTML::Widget::RealmCSS
    compress better
  * Bivio::Util::Project
    NEW

  Revision 10.51  2011/03/23 19:50:33  moeller
  * Bivio::Biz::Model::RealmFileTreeList
    added MAX_FILES_PER_FOLDER, limit folder files and use a "more" link
    if limit is reached
  * Bivio::Biz::Model::RealmFolderFileList
    NEW
  * Bivio::Delegate::TaskId
    added FORUM_FOLDER_FILE_LIST
  * Bivio::HTML::Scraper
    ignore UTF warnings during parse_html()
  * Bivio::UI::FacadeBase
    added FORUM_FOLDER_FILE_LIST
    backed out ePoll name change
  * Bivio::UI::HTML::Widget::CKEditor
    Cosmetic change for unit test
  * Bivio::UI::View::File
    added folder_file_list(), reuse tree_list() for implementation
  * Bivio::Util::Search
    don't allow running commands as root

  Revision 10.50  2011/03/19 22:44:05  nagler
  * Bivio::Agent::Request
    added delete_txn_resource for Lock
  * Bivio::Agent::Task
    the loop in _call_txn_resources was wrong.  Need two phase commit.
    handle_prepare_commit is called before handle_commit.
    Xapian may execute in handle_prepare_commit phase, including grabbing
    a lock
  * Bivio::Biz::Action::ClientRedirect
    die with NOT_FOUND if uri not in execute_permanent_map()
  * Bivio::Biz::Action::RealmFile
    if loading a folder, set path_info to folder path from file lookup
  * Bivio::Biz::Model::Lock
    Now can have multiple locks on the request.  This is necessary,
    because Xapian may need a lock, and the task needs a lock, too, during
    ShellUtil execution.
  * Bivio::Biz::Model::MotionList
    Display vote count and allow votes to be changed.
  * Bivio::Biz::Model::MotionVoteForm
    Display vote count and allow votes to be changed.
  * Bivio::Biz::Model::RealmMailDeleteForm
    removed require_context, might be deleting last message in thread
  * Bivio::Mail::Common
    minor text change
  * Bivio::Search::Parser::RealmFile::PDF
    fix error regex
  * Bivio::Search::Parser::RealmFile::Unknown
    turn unknown text file parsing back on
  * Bivio::Search::Xapian
    Because execute does a bunch of db stuff, it can't be called in
    handle_commit.  Changed Agent.Task to have handle_prepare_commit, and
    that's what's called to prepare the commit
  * Bivio::Test::FormModel
    Locks changed so now have to call release_all
  * Bivio::UI::FacadeBase
    Cosmetic "poll" -> "ePoll" for IEEE
  * Bivio::UI::View::Motion
    Display vote count and allow votes to be changed.
  * Bivio::Util::RealmFile
    added clear_files_and_mail()
  * Bivio::Util::Search
    remove debug stmt

  Revision 10.49  2011/03/17 21:03:23  nagler
  * Bivio::Biz::Model::TupleTag
    tuple_def_id refers to TupleUse.tuple_def_id so cascade_delete() order
    is correct for the realm
  * Bivio::Search::Parseable
    get_os_path checks for "content" iwc it writes that to a temporary
    file instead of use $rf->get_os_path
  * Bivio::Search::Parser::RealmFile::CommandBase
    do the call to get_os_path and replace that in the command
  * Bivio::Search::Parser::RealmFile::MSExcel
    use internal_run_parser
  * Bivio::Search::Parser::RealmFile::MSOfficeBase
    use internal_run_parser
  * Bivio::Search::Parser::RealmFile::MSPowerPoint
    use internal_run_parser
  * Bivio::Search::Parser::RealmFile::MSWord
    use internal_run_parser
  * Bivio::Search::Parser::RealmFile::OpenXMLDoc
    use internal_run_parser
  * Bivio::Search::Parser::RealmFile::PDF
    use internal_run_parser
  * Bivio::Search::Parser::RealmFile::Unknown
    don't parse files without content types
  * Bivio::Search::Parser::RealmFile::Wiki
    use internal_run_parser
  * Bivio::Search::Xapian
    call super class if get_values_for_primary_id() query returns no result
  * Bivio::SQL::DDL
    added motion_comment_t.creation_date_time
    added motion_comment_t.realm_id
  * Bivio::UI::Font
    support NNNpx
  * Bivio::Util::Search
    cleaned up the logging output

  Revision 10.48  2011/03/17 18:10:49  moeller
  * Bivio::Search::Xapian
    catch errors when querying Xapian and warn, then call super for
    default processing

  Revision 10.47  2011/03/17 16:30:12  moeller
  * Bivio::Biz::Model::MotionCommentForm
    NEW
  * Bivio::Biz::Model::MotionCommentList
    NEW
  * Bivio::Biz::Model::MotionComment
    NEW
  * Bivio::Biz::Model::MotionForm
    added Motion.moniker with validator
  * Bivio::Biz::Model::MotionList
    added can_comment() and Motion.moniker
  * Bivio::Biz::Model::Motion
    now derived from Model.RealmBase
    added moniker field
  * Bivio::Biz::Model::MotionVoteForm
    don't allow votes if motion is closed
  * Bivio::Biz::Model::MotionVoteList
    can_iterate => 1
  * Bivio::Biz::Model::MotionVote
    now derived from Model.RealmBase
  * Bivio::ClassWrapper::TupleTag
    don't include missing labels as undef items
    call get_tuple_use_moniker() when loading TupleUse
  * Bivio::Delegate::TaskId
    added FORUM_MOTION_COMMENT and FORUM_MOTION_COMMENT_LIST
  * Bivio::Search::Parser
    use type 'unparsed' for unparsed files
  * Bivio::SQL::DDL
    added motion_comment_s and motion_comment_t
  * Bivio::SQL::Statement
    changed TRUE and FALSE to (1 = 1) and (1 = 0) to be compatible with oracle
  * Bivio::UI::FacadeBase
    added FORUM_MOTION_COMMENT and FORUM_MOTION_COMMENT_LIST
  * Bivio::UI::View::Motion
    added comment_form() and comment_result()
  * Bivio::Util::SQL
    added bundle upgrade motion_comment

  Revision 10.46  2011/03/15 01:46:45  nagler
  * Bivio::Agent::Request
    added call handlers for handle_format_uri_named
  * Bivio::UI::FacadeBase
    added support for ABTest
  * Bivio::UI::View::CSS
    added support for ABTest
  * Bivio::UI::Widget::ABTest
    NEW

  Revision 10.45  2011/03/14 23:21:07  moeller
  * Bivio::Biz::Model::FileChangeForm
    changed _add_file_name() to public validate_file_name()
  * Bivio::Biz::Model::Forum
    removed ref to name_lc
  * Bivio::Biz::Model::MotionForm
    now derived from FormModeBaseForm
    added motion file
    refactored
  * Bivio::Biz::Model::MotionList
    removed execute_load_parent()
    added can_vote()
    added motion file fields
  * Bivio::Biz::Model::Motion
    added start_date_time, end_date_time and motion_file_id
  * Bivio::Delegate::TaskId
  * Bivio::UI::FacadeBase
    combined FORUM_MOTION_ADD and FORUM_MOTION_EDIT into FORUM_MOTION_FORM
  * Bivio::SQL::DDL
    added motion_t start_date_time, end_date_time, motion_file_id
  * Bivio::UI::View::Motion
    added motion start/end dates and motion file
  * Bivio::Util::SQL
    added motion2 upgrade - adds motion_t start_date_time, end_date_time,
    and motion_file_id

  Revision 10.44  2011/03/14 19:19:40  nagler
  * Bivio::Util::RealmMail
    added audit_threads and audit_threads_all_realms

  Revision 10.43  2011/03/11 20:37:38  nagler
  * Bivio::BConf
    don't send pages for search parser utility failures
  * Bivio::Biz::Model::MailThreadList
    added message_id
  * Bivio::Biz::Model::Motion
    minor refactor
  * Bivio::Biz::Model::MotionVote
    minor refactoring
  * Bivio::Biz::Model::RealmMail
    cascade_delete was not the right thing to do
    added audit_threads
  * Bivio::Biz::Model::RealmMailReferenceList
    get modified_date_time
  * Bivio::PetShop::Util::SQL
    consolidate into TestData->init
  * Bivio::PetShop::Util::TestData
    added init & init_mail_references
  * Bivio::Search::Parser
    warn if parser failed
  * Bivio::SQL::ListQuery
    allow order_by of [qw(Model.field asc)],
  * Bivio::Type::DateTime
    english_month
  * Bivio::UI::View::Mail
    prevent delete link from showing up on CRM threads
  * Bivio::UI::Widget::Director
    fmt
  * Bivio::Util::RealmFile
    need to import mail in mtime order
    set modified_date_time from the value of the Date: field in mail msgs
    Run audit_threads
  * Bivio::Util::RealmMail
    added audit_threads
    added audit_threads_all_realms

  Revision 10.42  2011/03/09 00:18:27  schellj
  * Bivio::Biz::Model::ForumUserAddForm
    fix for possible multiple main roles
  * Bivio::MIME::Calendar
    canonicalize_charset before calling unescape()
  * Bivio::Test::ForumUserUnit
    allow for multiple main roles testing
  * Bivio::Type::String
    added more transliterations: nbsp, -, fi and fl ligatures
  * Bivio::UI::Widget::Director
    b_use

  Revision 10.41  2011/03/07 18:42:13  moeller
  * Bivio::Biz::ListModel
    changed b_warn to req->warn()
  * Bivio::Biz::Model::RealmFile
    add update_with_file
  * Bivio::Biz::Model::RealmFileRevertForm
    NEW
  * Bivio::Biz::Model::RealmMailDeleteForm
    save message instead of putting on request
  * Bivio::Delegate::RowTagKey
    changed TEXTAREA_WRAP_LINES to BooleanFalseDefault
  * Bivio::Delegate::TaskId
    add 'Revert to Version' action to file history list
  * Bivio::Mail::Address
    allow undisclosed-recipients value for address list
  * Bivio::Mail::Outgoing
    warn/strip trailing newlines from set_header() value
  * Bivio::UI::FacadeBase
    add 'Revert to Version' action to file history list
    fix RealmMailDeleteForm strings
  * Bivio::UI::View::File
    add 'Revert to Version' action to file history list
  * Bivio::UI::View::Mail
    simplify delete form
  * Bivio::UI::View::Wiki
    add 'Revert to Version' action to file history list
  * Bivio::UI::XHTML::ViewShortcuts
    add vs_file_versions_actions_column

  Revision 10.40  2011/03/03 18:22:01  nagler
  * Bivio::Biz::ListModel
    RowTag->row_tage_get_for_auth_user replaces Auth.Support->unsafe_get_user_pref
  * Bivio::Biz::Model::RowTag
    added row_tag_get/replace_for_auth_user and
  * Bivio::Delegate::NoDbAuthSupport
    RowTag->row_tage_get_for_auth_user replaces Auth.Support->unsafe_get_user_pref
  * Bivio::Delegate::RowTagKey
    removed REALM_FILE_LOCKING and FACADE_CHILD_TYPE
  * Bivio::Delegate::SimpleAuthSupport
    RowTag->row_tage_get_for_auth_user replaces Auth.Support->unsafe_get_user_pref
  * Bivio::MIME::JSON
    ignore \r
  * Bivio::Type::TextArea
    RowTag->row_tage_get_for_auth_user replaces Auth.Support->unsafe_get_user_pref
  * Bivio::Type
    all types have get_default
  * Bivio::UI::HTML::Widget::Table
    RowTag->row_tage_get_for_auth_user replaces Auth.Support->unsafe_get_user_pref
  * Bivio::Util::RowTag
    b_use

  Revision 10.39  2011/03/02 19:43:27  nagler
  * Bivio::Search::Parser
    don't die if document can't be parsed
  * Bivio::Search::Xapian
    add date range capability
  * Bivio::Type::DateTime
    added to_yyyy_mm_dd
  * Bivio::Type::MailSendAccess
    change sort order
  * Bivio::Type::String
    translate n~
  * Bivio::Util::RealmFile
    improved error message for rfc822 parse failure

  Revision 10.38  2011/02/26 22:05:58  moeller
  * Bivio::MIME::Calendar
    allow double escaped quotes
    allow value=date-time
    allow value=uri

  Revision 10.37  2011/02/24 02:55:02  nagler
  * Bivio::Biz::Model::MailPartList
    from_name is get_local_part(from_email) if name not available (not
    whole email address, because would expose too much in public mailing lists)
  * Bivio::Biz::Model::MailThreadList
    added RealmMail.from_display_name, removed RealmOwner.display_name,
    because not the rigth thing
  * Bivio::Biz::Model::MailThreadRootList
    added RealmMail.from_display_name, removed RealmOwner.display_name,
    because not the right thing
  * Bivio::Biz::Model::RealmMailDeleteForm
    removed unused global
  * Bivio::Biz::Model::RealmMail
    added from_display_name, compute from get_from or get_local_part of email
    sort list of b_use's
  * Bivio::Biz::Model::RowTag
    added row_tag_get and row_tag_replace, which use RowTagKey->get_type
    to convert the values
  * Bivio::Biz::Model::WikiValidatorSettingList
    $realm needs to be gotten outside the with_realm
  * Bivio::Delegate::RowTagKey
    added types (as short_desc) to keys
  * Bivio::SQL::DDL
    added realm_mail_t.from_display_name
  * Bivio::SQL::Support
    check result of match in parse_column_name, and print a error msg if
    regexp doesn't match
  * Bivio::Type::BooleanFalseDefault
    NEW
  * Bivio::Type::BooleanTrueDefault
    NEW
  * Bivio::Type::RowTagKey
    added get_type (calls get_short_desc)
  * Bivio::UI::FacadeBase
    don't use is_default_id to check if a realm_id was initialized
  * Bivio::UI::View::Blog
    fixed method name typo
  * Bivio::UI::View::Mail
    show from_display_name if it is non-null or extract local part from from_email
  * Bivio::UI::View::Wiki
    fixed method name typo
  * Bivio::Util::RealmFile
    always set import_tree() modified_date_time to file date_time
    catch errors when creating mail from rfc822
  * Bivio::Util::SQL
    internal_upgrade_db_mail_from_display_name

  Revision 10.36  2011/02/23 00:09:35  schellj
  * Bivio::Biz::PropertyModel
    RCS file: /home/cvs/perl/Bivio/Biz/PropertyModel.pm,v
    Working file: Bivio/Biz/PropertyModel.pm
    head: 2.49
    branch:
    locks: strict
    access list:
    symbolic names:
    keyword substitution: kv
    total revisions: 123;	selected revisions: 0
    description:
  * Bivio::Delegate::TaskId
    don't call create/edit_wysiwyg directly, let Blog/Wiki make decision
    about use_wysiwg
  * Bivio::UI::HTML::Widget::CKEditor
    NEW
  * Bivio::UI::View::Blog
    added use_wysiwyg config parameter so can deploy without having
    wysiwyg code released
  * Bivio::UI::View::Wiki
    added use_wysiwyg config parameter so can deploy without having
    wysiwyg code released

  Revision 10.35  2011/02/22 00:39:27  nagler
  * Bivio::Agent::Task
    Support for "extra_auth" attribute on tasks, which allows arbitrary
    control logic on tasks
  * Bivio::Auth::Realm
    Added "extra_auth" call on can_user_execute_task if it exists in Auth.Support
  * Bivio::BConf
    Delegate mapping in merge_class_loader needed better regexp for
    PetShop (two levels)
    remove map() on ClassLoader config so Widget maps are listed explicitly
  * Bivio::Biz::Action::AdminRealmMail
    Added want_realm_mail_created and want_reply_to
  * Bivio::Biz::Action::BoardRealmMail
    Added want_reply_to
  * Bivio::Biz::Action::RealmMailBase
    default want_realm_mail_created and want_reply_to
  * Bivio::Biz::Action::RealmMail
    renamed WANT_REALM_MAIL_CREATED and ALLOW_REPLY_TO to
    want_realm_mail_created and want_reply_to which take $req so can be
    dynamic values
  * Bivio::Biz::Model::BlogEditForm
    carry_path_info in execute_cancel()
  * Bivio::Biz::Model::MailForm
    don't init $_V, rather just b_use('UI.View') -- avoid initialization loops
  * Bivio::Biz::Model::RealmMailPublicForm
    If RealmFile.is_public on the msg, then allow the user in private
    realms to turn it off
  * Bivio::Biz::Model::SearchForm
    explicity set ok_button form_name to avoid javascript problems
  * Bivio::Biz::Model::UserLoginBaseForm
    NEW
  * Bivio::Biz::Model::UserLoginForm
    push up code into UserLoginBaseForm so subclasses can override without
    grabbing whole module
  * Bivio::Biz::Model::WikiValidatorSettingList
    don't get setting if no site_reports_realm_id
  * Bivio::Biz::PropertyModel
    cruft
  * Bivio::Delegate::TaskId
    Use WYSIWYG (CKEditor) for blogs and wikis
    Rename the 'wysiwyg' methods edit_wysiwyg and create_wysiwyg
  * Bivio::Delegator
    Added b_can so can answer question about AUTOLOADED methods
  * Bivio::PetShop::BConf
    use simple form of delegates
    Added Auth.Support delegate (for extra_auth testing)
  * Bivio::PetShop::Delegate::Support
    NEW
  * Bivio::PetShop::Delegate::TaskId
    added extra_auth case on USER_ACCOUNT_EDIT
  * Bivio::ShellUtil
    new_other() works with a mapped class
  * Bivio::t::Delegator::D1
    test b_can
  * Bivio::Type::MailSendAccess
    added ALL_GUESTS
  * Bivio::UI::FacadeBase
    Use WYSIWYG (CKEditor) for blogs and wikis
    Editor is in "files/plain/b" which can be a link to Bivio/files
  * Bivio::UI::Mail::Widget::Message
    Subclass Widget.ControlBase so messages can render as empty (not executing)
  * Bivio::UI::View::Base
    added control to mail and imail
  * Bivio::UI::View::Blog
    Use WYSIWYG (CKEditor) for blogs and wikis
    CKEditor - missed "create"
    Rename the 'wysiwyg' methods edit_wysiwyg and create_wysiwyg
  * Bivio::UI::View::Mail
    if the msg is public (even in a private group) display the GROUP_MAIL_TOGGLE_PUBLIC
  * Bivio::UI::View::Wiki
    Use WYSIWYG (CKEditor) for blogs and wikis
    Rename the 'wysiwyg' methods edit_wysiwyg and create_wysiwyg
  * Bivio::UI::Widget::ControlBase
    if control is not defined, don't initialize
  * Bivio::UNIVERSAL
    Added b_can so can answer question about AUTOLOADED methods
  * Bivio::Util::RealmFile
    restore path after creating RealmMail from rfc822 during import_tree()

  Revision 10.34  2011/02/17 00:15:02  moeller
  * Bivio::Biz::Model::RealmMailDeleteForm
    NEW
  * Bivio::Biz::Model::RealmMail
    added delete_message for individual message complete deletion (no archiving)
    fix for deleting only message in a thread
  * Bivio::Delegate::TaskId
    added GROUP_MAIL_DELETE_FORM
  * Bivio::Type::RowTagValue
    can't be subclass of type Type.Text64K, because it adds a newline
  * Bivio::UI::FacadeBase
    added facade components for delete message functionality
  * Bivio::UI::View::Mail
    added delete message link
  * Bivio::UI::XHTML::Widget::WikiText
    Backout previous change for #611 (add <strike>).
    "strike" is deprecated in XHTML - will fix in ckeditor

  Revision 10.33  2011/02/15 19:51:26  nagler
  * Bivio::Biz::Action::RealmFile
    $realm_id not req(auth_id) needs to be used for error msg in die
  * Bivio::Biz::Action::WikiView
    changed the way default_start_page is loaded.  Use
    default_start_page_realm, otherwise use the facade's site_realm_id.
    DEFAULT_START_PAGE_PATH replaces DEFAULT_START_PAGE so apps can
    override full path (public or private, for example)
  * Bivio::Type::WikiName
    DEFAULT_START_PAGE_PATH replaces DEFAULT_START_PAGE so apps can
    override full path (public or private, for example)
  * Bivio::UI::XHTML::Widget::TaskMenu
    doc
  * Bivio::UI::XHTML::Widget::WikiText
    #611 add <strike>

  Revision 10.32  2011/02/13 14:11:58  nagler
  * Bivio::Biz::Model::RowTag
    don't insert the value if it is undefined OR zero length
  * Bivio::Util::SQL
    fixed row_tag_value_64k upgrade to drop index for oracle version

  Revision 10.31  2011/02/12 23:31:52  nagler
  * Bivio::Biz::Model::MailUnsubscribeForm
    die if no bulletin_realm_id facade value
  * Bivio::Biz::Util::ListModel
    removed Action.PublicRealm hack
  * Bivio::UI::FacadeBase
    label feature_wiki

  Revision 10.30  2011/02/10 19:22:43  moeller
  * Bivio::Biz::Action::RealmFile
    allow viewing public folders
  * Bivio::Biz::Model::RealmFeatureForm
    added allow_<feature> fields so can control which fields are
    rendered.  Subclasses override internal_allow_field_value
  * Bivio::Biz::Model::RealmFileTreeList
    don't render public mail
  * Bivio::Delegate::SimplePermission
    MAIL_WRITE => MAIL_ADMIN
  * Bivio::Delegate::TaskId
    MAIL_WRITE => MAIL_ADMIN
    removed DATA_BROWSE permission from FORUM_FILE_TREE_LIST
  * Bivio::IO::File
    added set_modified_date_time()
  * Bivio::SQL::DDL
    row_tag_t.value is now 65535
  * Bivio::Type::RowTagValue
    Length is now 65535
  * Bivio::Type::String
    accept undef/empty strings in canonicalize*
  * Bivio::UI::View::File
    added list_action css class to File tree actions column
  * Bivio::UI::View::GroupAdmin
    allow RealmFeatureForm to control which fields are rendered
  * Bivio::Util::RealmFile
    export_tree() now sets the file's modified date_time,
    import_tree() updates folder's modified_date_time to the max content date_tim
  e
  * Bivio::Util::SiteForum
    init_bulletin: do want mail_want_reply_to for staging (should be set
    up the same as the bulletin realm)
  * Bivio::Util::SQL
    internal_upgrade_db_row_tag_value_64k: RowTag.value is now 65535
    internal_upgrade_db_mail_admin: add MAIL_ADMIN to anybody with ADMIN_WRITE

  Revision 10.29  2011/02/07 18:32:20  nagler
  * Bivio::Biz::Model::MailUnsubscribeForm
    added is_subscribed_to_bulletin_realm
    Allow realm_id to be passed into all bulletin realm calls
  * Bivio::Util::SiteForum
    init_bulletin needs to default a user and name

  Revision 10.28  2011/02/07 16:01:50  nagler
  * Bivio::Agent::Job::Request
    set path_info to undef
  * Bivio::Biz::Action::RealmMail
    call Outgoing->edit_body on BULLETIN_MAIL_MODE forum msgs
    added BULLETIN_BODY_TEMPLATE so can use BULLETIN_MAIL_MODE without templating
  * Bivio::Biz::Model::MailPartList
    added set_attachment_visited() and was_attachment_visited()
    to control whether to render extra attachments to a file
  * Bivio::Biz::Model::MailThreadList
    added get_message_anchor so explicitly coupled between View.Mail and SearchList
  * Bivio::Biz::Model::MailUnsubscribeForm
    NEW
  * Bivio::Biz::Model::RealmEmailList
    added RealmOwner.name
  * Bivio::Biz::Model::RealmFile
    toggle_is_public() doesn't changed modified_date_time
  * Bivio::Biz::Model::RealmMailBounce
    If BulletinMailMode set for realm, remove user from realm
    use MailUnsubscribeForm
  * Bivio::Biz::Model::RealmMailList
    use MailThreadList->get_message_anchor
  * Bivio::Biz::Model::RealmOwner
    added unauth_load_by_email_id_or_name_or_die
  * Bivio::Biz::Model::SearchList
    use MailThreadList->get_message_anchor
  * Bivio::Delegate::RowTagKey
    added BULLETIN_BODY_TEMPLATE
  * Bivio::Delegate::TaskId
    added USER_MAIL_UNSUBSCRIBE_FORM
  * Bivio::IO::Template
    b_use
  * Bivio::Mail::Outgoing
    added edit_body
    b_use
  * Bivio::Search::Parser
    Need to canonicalize_charset on all values going into xapian
  * Bivio::ShellUtil
    unauth_realm_id works on emails or names
    lock_action needs to protect against an unreadable/non-existent lock_pid file
  * Bivio::Type::BulletinBodyTemplate
    NEW
  * Bivio::Type::BulletinMailMode
    NEW
  * Bivio::Type::FilePath
    added is_public
  * Bivio::Type::String
    test AE ligature
  * Bivio::Type
    row_tag_get now handles model_or_id correctly
  * Bivio::UI::FacadeBase
    added 'p' font def
    added USER_MAIL_UNSUBSCRIBE_FORM
    added BULLETIN_REALM_NAME and bulletin_realm_id
    _unsafe_realm_id returns 0 when not found, because 1 is legitimate
    realm_id, which isn't a good idea as values are getting bound to the
    general realm
  * Bivio::UI::View::CSS
    added Font 'p'
  * Bivio::UI::View::File
    make tree list actions column rightmost
  * Bivio::UI::View::Mail
    removed internal_part_list() id,
    only render attachments if they haven't already been rendered inline
    added unsubscribe_form
    use MailThreadList->get_message_anchor
  * Bivio::UI::XHTML::Widget::MailBodyHTML
    render img src
    mark mime_cids as rendered when accessed inline
    render a anchors
  * Bivio::Util::RealmFile
    make mail files public if public path
    fpc
  * Bivio::Util::SiteForum
    set BULLETIN_MAIL_MODE and MAIL_SUBJECT_PREFIX on bulletin_staging
    added BULLETIN_BODY_TEMPLATE so can use BULLETIN_MAIL_MODE without templating
  * Bivio::Util::TestUser
    leave_and_delete takes a pattern
    create uses parameters()

  Revision 10.27  2011/02/02 16:46:46  nagler
  * Bivio::Agent::HTTP::Reply
    added http_status_code support
    downcased builtin responses
  * Bivio::Agent::HTTP::Request
    passed $named to reply->client_redirect
  * Bivio::Agent::Request
    added http_status_code to EXTRA_URI_PARAM_LIST
  * Bivio::Agent::TaskEvent
    added http_status_code to params
  * Bivio::Biz::Action::ClientRedirect
    added execute_permanent_map
  * Bivio::Biz::Action::Error
    fpc
  * Bivio::Biz::Action::PermanentRedirect
    removed
  * Bivio::Biz::Action::RealmFile
    removed unused assert_access
  * Bivio::Biz::Model::MailPartList
    added access_is_public_only feature
  * Bivio::Biz::Model::MailThreadList
    added access_is_public_only feature
    added is_public
  * Bivio::Biz::Model::RealmFeatureForm
    added mail_visibility
  * Bivio::Biz::Model::RealmFile
    added toggle_is_public
    make lists ephemeral
  * Bivio::Biz::Model::RealmMailList
    added is_public
  * Bivio::Biz::Model::RealmMail
    added access_is_public_only and assert_mail_visibility
    support for visibility control
  * Bivio::Biz::Model::RealmMailPublicForm
    NEW
  * Bivio::Biz::Model::Tuple
    make TupleUseList ephemeral
  * Bivio::Biz::Model::TupleSlotListForm
    fmt
  * Bivio::Biz::Model::TupleUseForm
    Bivio::Base
  * Bivio::Delegate::RowTagKey
    MAIL_VISIBILITY
  * Bivio::Delegate::TaskId
    Mail permissions now controlled through assert_mail_visibility
    replaced PERMANENT_REDIRECT with CLIENT_REDIRECT_PERMANENT_MAP
    added GROUP_MAIL_TOGGLE_PUBLIC
  * Bivio::HTML::Scraper
    catch and ignore errors/warnings when extracting cookies
  * Bivio::MIME::RRule
    allow interval 1
    allow wkst if byday isn't multiple
  * Bivio::PetShop::BConf
    test data for CLIENT_REDIRECT_PERMANENT_MAP
  * Bivio::PetShop::Facade::PetShop
    MY_SITE defaults to SITE_ROOT
    test data for CLIENT_REDIRECT_PERMANENT_MAP
  * Bivio::PetShop::Util::SQL
    added mail_forum_public and mail_forum_allow_public
  * Bivio::Search::Parser::RealmFile::MessageRFC822
    b_use
  * Bivio::Test::Language::HTTP
    exported user_agent_instance
  * Bivio::Type::FilePath
    from_public doesn't die if no /public prefix
  * Bivio::Type::MailVisibility
    NEW
  * Bivio::Type::String
    \xb4 --> '
  * Bivio::UI::FacadeBase
    mail_visibility_mode
    fpc
    replace wrench with 'Modify' link
    added GROUP_MAIL_TOGGLE_PUBLIC & CLIENT_REDIRECT_PERMANENT_MAP
  * Bivio::UI::Task
    fix HELP link
  * Bivio::UI::View::File
    replace wrench with 'Modify' link
  * Bivio::UI::View::Mail
    added GROUP_MAIL_TOGGLE_PUBLIC
  * Bivio::Util::SQL
    upgrade to add mail_write

  Revision 10.26  2011/01/28 00:30:32  schellj
  * Bivio::UI::XHTML::ViewShortcuts
    if field has column_widget, then just put in list

  Revision 10.25  2011/01/27 23:23:20  moeller
  * Bivio::Biz::Action::Error
    when rendering wiki, set task to FORUM_WIKI_VIEW so unwinds work correctly
  * Bivio::Biz::Model::GroupUserForm
    added can_add_user()
    don't update RealmUser.role if not editable
  * Bivio::Biz::Model::GroupUserList
    added can_add_user()
  * Bivio::HTML::Scraper
    ignore utf8 warnings when writing files
  * Bivio::Search::Parser::RealmFile::MessageRFC822
    guard against unsplittable text
  * Bivio::UI::View::GroupAdmin
    don't show GROUP_USER_ADD_FORM link unless ->can_add_user()
    don't show permission field unless editable
  * Bivio::Util::SQL
    bug in the way !site_admin_forum_users2 was being initialized

  Revision 10.24  2011/01/19 20:10:48  nagler
  * Bivio::Delegate::SimpleWidgetFactory
    value needs to be in brackets for Year
  * Bivio::Util::SQL
    fpc

  Revision 10.23  2011/01/18 21:52:25  moeller
  * Bivio::Biz::Model::CalendarEvent
    when importing vevent, trim long strings after canonicalizing the charset
  * Bivio::Type::DateTime
    fixed Task registration on test systems
  * Bivio::Util::Release
    added rollback instructions to install
  * Bivio::Util::SQL
    added upgrade db to remove forum feature_motion and feature_tuple

  Revision 10.22  2011/01/14 17:59:09  nagler
  * Bivio::UI::FacadeBase
    removed help_index
    removed text-indent: 2em
  * Bivio::UI::View::CSS
    removed help_index

  Revision 10.21  2011/01/14 16:04:29  nagler
  * Bivio::Agent::Job::Dispatcher
    can_enqueue_job had is_blessed arguments wrong

  Revision 10.20  2011/01/13 06:17:54  nagler
  * Bivio::Delegate::SimpleWidgetFactory
    support source_is_list_model
  * Bivio::MIME::JSON
    no longer derived from Attributes, now uses fields, 3x faster
  * Bivio::UI::HTML::Widget::Table
    allow headings to be applied outside the creation of the widget so
    incoming widgets can get a heading, too.
  * Bivio::UI::XHTML::ViewShortcuts
    vs_descriptive_field accepts hash
    vs_list_form wraps get_list_model on fields if they are not available
    from ListFormModel and are available by ListModel

  Revision 10.19  2011/01/12 18:11:19  nagler
  * Bivio::Agent::Job::Dispatcher
    added can_enqueue_job
  * Bivio::Biz::Model::CalendarEvent
    initialize $_RO dynamically to avoid circular import
  * Bivio::Biz::Model
    added field_decl_from_property_model
  * Bivio::MIME::JSON
    NEW
  * Bivio::Search::Parseable
    added get_excerpt
  * Bivio::Search::Parser::RealmFile
    added realms_for_rebuild_db and do_iterate_realm_models
  * Bivio::Search::Parser
    added handle_new_text
    added simple_class to field_term
  * Bivio::Search::Xapian
    can qualify by simple_class
    don't return model from query() if no_model is set
  * Bivio::Type::DateTime
    use IO.Config for is_test (no longer need req() on set_test_now)
  * Bivio::UI::FacadeBase
    dtstart/end need names
  * Bivio::Util::Search
    remove RealmFile dependency, instead just iterate classes

  Revision 10.18  2011/01/08 14:59:58  nagler
  * Bivio::Auth::Role
    added calculate_expression and is_admin
  * Bivio::BConf
    guests can read motions and tuples
  * Bivio::Biz::Util::RealmRole
    use Auth.Role->calculate_expression
  * Bivio::Delegate::Role
    moved is_admin to Auth.Role
  * Bivio::MIME::Calendar
    unescape \\
    call HTML->unescape() on values
  * Bivio::MIME::RRule
    NEW
  * Bivio::Type::String
    convert common latin chars to ascii
  * Bivio::UI::XHTML::Widget::ECMAScriptFile
    removed
  * Bivio::UI::XHTML::Widget::ECMAScriptNamed
    removed
  * Bivio::UI::XHTML::Widget::ECMAScript
    removed

  Revision 10.17  2011/01/05 02:30:45  schellj
  * Bivio::MIME::Calendar
    sort event rows by dtstart and rrule,
    added recurrence-id and sequence to data
    parse out exdate list, and status
    for date times with timezones, convert times to utc
    parse out and ignore valarm subentries within an entry
    ignore categories and organizer
  * Bivio::Search::Parser::RealmFile::CommandBase
    NEW
  * Bivio::Search::Parser::RealmFile::MSExcel
    NEW
  * Bivio::Search::Parser::RealmFile::MSOfficeBase
    NEW
  * Bivio::Search::Parser::RealmFile::MSPowerPoint
    NEW
  * Bivio::Search::Parser::RealmFile::MSWord
    NEW
  * Bivio::Search::Parser::RealmFile::OpenXMLDoc
    NEW
  * Bivio::Search::Parser::RealmFile::PDF
    refactored to use CommandBase
  * Bivio::UI::View::CSS
    added table.b_search_results div.uri
  * Bivio::UI::View::Search
    added file uri

  Revision 10.16  2010/12/27 20:51:46  nagler
  * Bivio::UI::View::Wiki
    removed WikiHelpList

  Revision 10.15  2010/12/27 14:52:02  nagler
  * Bivio::Biz::Model::CalendarEvent
    couple realm_id
  * Bivio::IO::Log
    need to import UI.Facade dynamically

  Revision 10.14  2010/12/27 14:43:28  nagler
  * Bivio::HTML::Scraper
    fmt
    file_name returns undef if no directory attr and accepts absolute path
    without directory
    if no directory, don't return a file_name
  * Bivio::HTML::t::Scraper::T1
    fmt
  * Bivio::IO::Config
    added is_test
  * Bivio::IO::Log
    b_use
    mkdir_parent_only
  * Bivio::Test::Unit
    builtin_tmp_dir was calling rm_rf instead of builtin_rm_rf
  * Bivio::Type::DateTime
    refactor month to num code
    added full month names

  Revision 10.13  2010/12/26 03:59:30  nagler
  * Bivio::BConf
    merge_class_loader accepts an array_ref for overrides->{delegates} and
    maps to a hash
  * Bivio::Biz::Model::CalendarEventForm
    if no time_zone is set, assume UTC
  * Bivio::Biz::Model::CalendarEventList
    fmt
  * Bivio::Biz::Model::CalendarEvent
    set time_zone from ics file
  * Bivio::Biz::Model::FormModeBaseForm
    NEW
  * Bivio::Delegate::RealmType
    doc
    doc
  * Bivio::Delegate::SimpleLocation
    doc
  * Bivio::MIME::Calendar
    use Bivio::Base
    parse out start/end date timezone attr
    allow calscale, sequence, rrule, and transp values
    parse out and ignore vtimezone entries
    unescape newline, comma and semicolon
    save time_zone in event data
    _timezone() saves the default time zone and applies to records without timezones
    exclude a few more unhandled keys
    store rrule, even though Model.CalendarEvent can't handle (yet)
  * Bivio::Search::Parser
    moved excerpting to Type.String->canonicalize_and_excerpt
    canonicalize_and_excerpt returns a ref now
  * Bivio::ShellUtil
    added assert_test()
  * Bivio::Type::Location
    EnumDelegator
  * Bivio::Type::String
    added canonicalize_and_excerpt
    canonicalize_and_excerpt returns a ref now
  * Bivio::Type::UserAgent
    added is_msie_6_or_before
  * Bivio::Type::USState
    Lookup state in table or NOT_FOUND
  * Bivio::UI::DateTimeMode
    added HOUR_MINUTE_AM_PM_LC and FULL_MONTH_DAY_AND_YEAR
    simplified compile() statement
  * Bivio::UI::FacadeBase
    added CSS for td_header_left, logo_su_logo, table_main
    b_* in front of td_footer_center, table_main, etc.
  * Bivio::UI::HTML::Format::DateTime
    added HOUR_MINUTE_AM_PM_LC and FULL_MONTH_DAY_AND_YEAR
    refactored to be clearer what's going on
    don't need DateTimeWithTimeZone
    HOUR_MINUTE_AM_PM_LC: no leading 0 on hours
  * Bivio::UI::View::CSS
    added CSS for td_header_left, logo_su_logo, table_main
    b_* in front of td_footer_center, table_main, etc.
  * Bivio::UI::XHTML::Widget::TaskMenu
    *** empty log message ***
    if passing in xlink (lower case) then need to set label, too
  * Bivio::UI::XHTML::Widget::XLinkLabel
    added qualify_label

  Revision 10.12  2010/12/24 16:25:11  nagler
  * Bivio::Agent::Request
    add clear_cache_for_auth_user
  * Bivio::Agent::Task
    permissions => permission_set
  * Bivio::Biz::Action
    added new
  * Bivio::Biz::Model::CSVImportForm
    removed call_super_before
  * Bivio::Biz::Model::FileChangeForm
    removed call_super*
  * Bivio::Biz::PropertyModel
    added unauth_create_unless_exists
  * Bivio::Biz::Util::RealmRole
    list_roles replaces category_role_group
    fixed methods to use "role calculation" (role|group)
  * Bivio::ClassWrapper
    moved code_ref_for_* to ClassWrapper from UNIVERSAL as private
    routine(s) ; there's a bug in the symbol table gets trashed so
    call_super, etc. which relied on code_ref_for_* can't be used
  * Bivio::Delegate::Role
    is_admin => in_category_role_group(all_admins)
  * Bivio::Delegate::TaskId
    permissions => permission_set
  * Bivio::Delegation
    remove call_delegator_super
  * Bivio::PetShop::Util::SQL
    turn on feature_task_log explicitly
  * Bivio::ShellUtil
    assert_have_user checks auth_user not -user flag so methods can be
    called directly
  * Bivio::t::UNIVERSAL::DelegateSuper
    moved code_ref_for_* to ClassWrapper from UNIVERSAL as private
    routine(s) ; there's a bug in the symbol table gets trashed so
    call_super, etc. which relied on code_ref_for_* can't be used
  * Bivio::t::UNIVERSAL::Super3
    removed
  * Bivio::Type::PositiveInteger
    NEW
  * Bivio::UI::FacadeBase
    b_wiki_width is blank by default
  * Bivio::UI::View::CSS
    allow wiki index on right or left
  * Bivio::UI::View::Wiki
    move index to left
  * Bivio::UNIVERSAL
    moved code_ref_for_* to ClassWrapper from UNIVERSAL as private
    routine(s) ; there's a bug in the symbol table gets trashed so
    call_super, etc. which relied on code_ref_for_* can't be used
  * Bivio::Util::CRM
    added setup_realm_with_priority
  * Bivio::Util::Forum
    use assert_have_user
  * Bivio::Util::SiteForum
    used facade's realm names, not hardwired
    initialize task_log explicitly
    create placeholder start page for all realms
  * Bivio::Util::SQL
    removed initialize_motion/tuple/task_log_permissions
    added init_task_log_for_forums

  Revision 10.11  2010/12/22 19:43:03  schellj
  * Bivio::Biz::Model::ForumUserAddForm
    remove existing main roles when adding admin
  * Bivio::Biz::Model::RealmUserAddForm
    removed unnecessary code
  * Bivio::Biz::Model::RealmUser
    added delete_main_roles
  * Bivio::ShellUtil
    assert_have_user() checks for 'user' arg
  * Bivio::Util::Forum
    added make_admin_of_forum

  Revision 10.10  2010/12/16 22:09:50  moeller
  * Bivio::BConf
    removed Forms.error_color override
  * Bivio::Test::HTMLParser::Forms
    use default error_color which was coming from Bivio::BConf
  * Bivio::UI::HTML::Widget::RealmFilePage
    don't catch die during render_value()
  * Bivio::UI::View::CRM
    fixed missing tuple fields in CRM query form
  * Bivio::Util::HTTPStats
    SiteForum not referenced

  Revision 10.9  2010/12/12 23:29:46  nagler
  * Bivio::Biz::Model::RealmEmailList
    ensure is unique list of emails/realm_ids (role is deleted from query)
  * Bivio::Biz::Model::RealmUserAddForm
    if no internal_user_id, just return
  * Bivio::Biz::Model
    added field_decl_exclude
  * Bivio::Biz::Util::RealmRole
    added roles_for_permissions
  * Bivio::Test::HTMLParser::Forms
    fmt
  * Bivio::Test::ListModel
    added make_expect_rows

  Revision 10.8  2010/12/11 18:43:39  nagler
  * Bivio::UI::View::File
    remove invalid text in code
    DateTime() only accepts a widget value
  * Bivio::UI::XHTML::Widget::HelpWiki
    remove debug

  Revision 10.7  2010/12/10 23:47:48  nagler
  * Bivio::Biz::Model::FileChangeForm
    locking is configured
  * Bivio::Biz::Model::RealmFileLock
    locking is configured
  * Bivio::Biz::Model::RealmFileTreeList
    locking is configured
  * Bivio::Biz::Model::RealmFileVersionsList
    locking is configured
  * Bivio::Biz::Model::SearchList
    _b_realm_only wasn't computing public_realm_ids properly
  * Bivio::Biz::Model::UserCreateForm
    call if_then_else
  * Bivio::SQL::DDL
    need constraint on folder_t
  * Bivio::UI::FacadeBase
    support for help_wiki
  * Bivio::UI::FacadeComponent
    initialize the value once per name in a group
  * Bivio::UI::Font
    fmt
  * Bivio::UI::View::CSS
    support for help wiki
  * Bivio::UI::View::File
    locking is configured
  * Bivio::UI::View::ThreePartPage
    added vs_xhtml_title()
  * Bivio::UI::View::Wiki
    locking is configured
    move help index to the left
  * Bivio::UI::XHTML::ViewShortcuts
    added vs_xhtml_title()
  * Bivio::UI::XHTML::Widget::HelpWiki
    added want_popup attribute so can just be a link (want_popup = 0)

  Revision 10.6  2010/12/09 18:40:56  nagler
  * Bivio::Util::NamedConf
    PTR generated if only one A record
    PTR checking, must be exactly one
    '@' is back as a PTR identifier

  Revision 10.5  2010/12/09 16:18:06  nagler
  * Bivio::Biz::Model::RealmOwnerBase
    cascade_delete deletes RowTag, RealmDAG and any RealmUser records
  * Bivio::Test::Unit
    builtin_random_realm_name
  * Bivio::UI::HTML::Widget::Script
    added b_all_elements_by_class
  * Bivio::UI::XHTML::Widget::DropDown
    fix for cmd-click not opening new tabs in ff, fix to close dd upon
    clicking link a second time
  * Bivio::Util::NamedConf
    handle ptr cases
  * Bivio::Util::RealmAdmin
    delete_auth_realm_and_users calls delete_auth_user and delete_auth_realm
    delete_auth_user calls delete_auth_realm
    delete_auth_realm no longer needs to delete RealmUser records RealmOwnerBase handles this
  * Bivio::Util::Search
    don't commit first time.

  Revision 10.4  2010/12/07 20:07:57  nagler
  * Bivio::Biz::Model::BlogList
    push up access check in prepare_statement_for_access_mode
  * Bivio::Biz::Model::RealmFileList
    added prepare_statement_for_access_mode
  * Bivio::Biz::Model::WikiHelpList
    NEW
  * Bivio::Biz::Model::WikiList
    call prepare_statement_for_access_mode
  * Bivio::PetShop::Util::SQL
    change the default color for help pages; purple too annoying
  * Bivio::Type::BlogFileName
    to_absolute uses SQL_LIKE_BASE check
  * Bivio::Type::CIDRNotation
    map_host_addresses must use fixed decimals, because the addresses are
    greater than the max signed int
  * Bivio::Type::DocletFileName
    added SQL_LIKE_BASE
    and to_sql_like_path uses it
  * Bivio::Type::SettingsName
    added SQL_LIKE_BASE
  * Bivio::Type::WikiDataName
    added SQL_LIKE_BASE
  * Bivio::Type::WikiName
    strip _Help from the title
  * Bivio::UI::FacadeBase
    support for help_list
  * Bivio::UI::HTML::Widget::DateField
    if form is in error render form literal not form value
  * Bivio::UI::View::CSS
    support for help_list
    fpc
  * Bivio::UI::View::Wiki
    added WikiHelpList for help realm in view
  * Bivio::UI::XHTML::Widget::WikiText::HTML
    NEW
  * Bivio::UI::XHTML::Widget::WikiText::Macro
    use parse_lines_till_end_tag
  * Bivio::UI::XHTML::Widget::WikiText
    _parse_my_tag pushes tag if parse_tag_start returns true
  * Bivio::UI::XHTML::Widget::WikiTextTag
    added parse_lines_till_end_tag
  * Bivio::Util::Search
    cleaned up messageing
  * Bivio::Util::SQL
    internal_db_upgrade_bulletin => internal_upgrade_db_bulletin
    site_help_title upgrade

  Revision 10.3  2010/12/02 20:22:09  nagler
  * Bivio::Type::String
    _clean_whitespace was cleaning multiple newlines

  Revision 10.2  2010/12/01 06:47:35  schellj
  * Bivio::Type::ECService
    rmpod
    copy
  * Bivio::UI::HTML::Widget::Script
    fix for combobox drop down conflicting with menu drop down
  * Bivio::UI::XHTML::Widget::DropDown
    fix for conflict with combobox drop down

  Revision 10.1  2010/11/30 07:53:40  schellj
  * Bivio::Biz::Model::CRMActionList
    now using CRMUserList (GroupUserList did more work than needed here)
  * Bivio::Biz::Model::CRMUserList
    NEW

  Revision 10.0  2010/11/23 14:24:27  nagler
  Switch to 10.0

  Revision 9.94  2010/11/23 14:22:02  nagler
  * Bivio::IO::File
    Trim [\r\n] at end of line in do_lines

  Revision 9.93  2010/11/17 22:43:35  schellj
  * Bivio::Biz::Model::CRMActionList
    more efficient id_to_name/name_to_id behavior, don't need validate_id
  * Bivio::Biz::Model::CRMForm
    id will be defined iff it is valid
  * Bivio::Biz::Model::CRMThreadRootList
    fix for changed CRMActionList->name_to_id behavior
  * Bivio::UI::FacadeBase
    add label for CRM status NEW
  * Bivio::UI::HTML::Widget::Script
    fix for dropdown positioning

  Revision 9.92  2010/11/17 02:31:49  nagler
  * Bivio::Type::Line
    from_literal calls canonicalize_charset
  * Bivio::Type::String
    added canonicalize_charset to remove Windows-1252 and UTF-8 characters
    on TextArea
  * Bivio::Type::TextArea
    canonicalize_newlines moved to Type.String
    from_literal calls canonicalize_charset
  * Bivio::Type::Text
    fmt

  Revision 9.91  2010/11/16 20:44:36  nagler
  * Bivio::Delegate::TaskId
    get_delegate_info calls merge_task_info, not info_base

  Revision 9.90  2010/11/16 08:24:33  schellj
  * Bivio::Agent::Request
    used UNIVERSAL->if_then_else
  * Bivio::Agent::t::Mock::TaskId
    don't inlude all components.  Unnecessary and creates conflicts
  * Bivio::Agent::TaskId
    tasks are now configured as hashes
  * Bivio::Agent::Task
    allow tasks to be configured as a hash with converted values (references)
  * Bivio::BConf
    TaskLog configured as task component
    SimpleTaskId gone
  * Bivio::Biz::Model::CRMActionList
    fix for validation of status actions
  * Bivio::Biz::Model::TaskLog
    TaskLog configured as task component
    SimpleTaskId gone
  * Bivio::Delegate::SimpleTaskId
    removed
  * Bivio::Delegate::TaskId
    task_log configures as a component
    merged with SimpleTaskId.pm
  * Bivio::Test::ShellUtilConf
    NEW
  * Bivio::Type::CIDRNotation
    NEW
  * Bivio::Type::SyntacticString
    internal_post_from_literal can return an error
  * Bivio::UI::FacadeBase
    task_log is a component
  * Bivio::UI::HTML::Widget::Script
    changes for removed anchor on combobox button
  * Bivio::UI::Task
    tasks now configure as a hash
  * Bivio::UI::Text::Widget::File
    removed
  * Bivio::UI::View::CSS
    changes for removed anchor on combobox button, disable button text
    selection (Mozilla, Webkit)
  * Bivio::UI::Widget::MIMEBodyWithAttachment
    removed
  * Bivio::UI::XHTML::Widget::ComboBox
    remove anchor on combobox button, disable button text selection (IE)
  * Bivio::UI::XHTML::Widget::FeatureTaskMenu
    don't include tasks if they don't exists
  * Bivio::UI::XHTML::Widget::TaskMenu
    reorder render_tag_value "control" checking.  Wasn't able to have a
    tasks which don't exists
  * Bivio::UNIVERSAL
    added if_then_else
  * Bivio::Util::HTTPConf
    allow passing in or read_input
  * Bivio::Util::NamedConf
    NEW
  * Bivio::Util::SQL
    added general_accountant upgrade: accounting has admin_read privs in
    general realm

  Revision 9.89  2010/11/12 09:40:46  schellj
  * Bivio::Biz::Model::CRMActionList
    support for use of combobox
  * Bivio::Biz::Model::CRMForm
    support use of combobox
  * Bivio::Biz::Model::CRMQueryForm
    support for use of combobox
  * Bivio::Biz::Model::CRMThreadRootList
    support for use of combobox
  * Bivio::UI::FacadeBase
    added combo_box_arrow
  * Bivio::UI::HTML::Widget::Image
    fixed src_name if src_is_uri and xhtml
  * Bivio::UI::HTML::Widget::Script
    add arrow button to make a true combobox
  * Bivio::UI::View::CRM
    change owner select to combobox
  * Bivio::UI::View::CSS
    styles for combobox arrow
  * Bivio::UI::XHTML::Widget::ComboBox
    add arrow button

  Revision 9.88  2010/11/08 22:19:49  nagler
  * Bivio::Agent::Request
    refactored assert_test to call IO.Config->assert_test
  * Bivio::BConf
    added bunit_case Trace config
  * Bivio::Ext::BerkeleyDB
    NEW
  * Bivio::IO::Config
    added assert_test()
  * Bivio::Test
    added want_void option (like want_scalar)
    move trace statement for bunit_case Trace config
  * Bivio::Type::ExistingFolderArg
    NEW
  * Bivio::Type::FolderArg
    NEW
  * Bivio::UNIVERSAL
    added map_by_slice and boolean
    refactored map_by_two to use map_by_slice
    added call_and_do_after

  Revision 9.87  2010/11/03 22:09:19  schellj
  * Bivio::Agent::TaskEvent
    removed TODO
  * Bivio::Util::SQL
    always initialize_fully in bundle db upgrades, move
    initialize_fully up in motion_vote_aff_drop_not_null

  Revision 9.86  2010/11/03 04:17:30  schellj
  * Bivio::Biz::Model::MotionVote
    allow affiliated_realm_id to be null, users don't need to be
    affiliated with themselves if they aren't in an organization
  * Bivio::SQL::DDL
    remove NOT_NULL constraint from motion_vote_t.affiliated_realm_id
  * Bivio::Util::SQL
    drop motion_vote_t.affiliated_realm_id not null, remove motion
    vote affiliated_realm_ids that were set to user_id

  Revision 9.85  2010/11/02 21:22:06  moeller
  * Bivio::Agent::Task
    undid previous change
  * Bivio::BConf
    removed Delegate.FormErrors
  * Bivio::Biz::FormModel
    get_form() rather than unsafe_get('form') when getting context from
    request,
    don't call internal_get_file_field_names() on non instance
  * Bivio::Delegate::SimpleFormErrors
    removed
  * Bivio::PetShop::BConf
    removed Delegate.FormErrors
  * Bivio::PetShop::Delegate::FormErrors
    removed
  * Bivio::UI::HTML::FormErrors
    removed
  * Bivio::UI::HTML::Widget::FormFieldError
    removed UIHTML.FormErrors

  Revision 9.84  2010/11/02 14:54:58  moeller
  * Bivio::Agent::Task
    parse the request's form before throwing a forbidden error, allows the
    form to retain values in case of a login time-out

  Revision 9.83  2010/10/29 17:41:35  nagler
  * Bivio::Auth::Permission
    rmpod
    now an EnumDelegator
  * Bivio::Base
    added b_catch
  * Bivio::Delegate::TaskId
    added is_production predicate to info_dev()
  * Bivio::Util::Class
    removed tasks_for_label and tasks_for_view: not in use, and too
    tightly coupled implementation with TaskId which is changing
  * Bivio::Util::RealmFile
    added backup_realms

  Revision 9.82  2010/10/28 16:39:48  nagler
  * Bivio::Biz::Model::RealmFileList
    use STRPOS and SUBSTR
  * Bivio::Biz::Model::RealmFile
    use STRPOS and SUBSTR
  * Bivio::SQL::Connection::Oracle
    translate STRPOS( to INSTR(
  * Bivio::Util::RealmMail
    use STRPOS and SUBSTR
  * Bivio::Util::SQL
    oracle does not have a ddl directory, necessarily

  Revision 9.81  2010/10/27 21:55:09  nagler
  * Bivio::Util::SQL
    column_exists for oracle
    dropped unnecessary "drop column" in init_site_forum upgrade

  Revision 9.80  2010/10/27 18:42:07  schellj
  * Bivio::UI::View::Tuple
    added NewEmptyRowHandler() to schema and table editor
  * Bivio::Util::SQL
    added drop_member_if_administrator2

  Revision 9.79  2010/10/26 20:47:10  schellj
  * Bivio::Biz::Model::ForumUserAddForm
    check for any roles in parent forum before adding user
  * Bivio::Biz::Model::RealmUserAddForm
    get existing_roles more efficiently, remove warning

  Revision 9.78  2010/10/26 15:20:03  moeller
  * Bivio::Biz::Model::GroupUserList
    replaced EXISTS statement in internal_pre_load with
    internal_role_exists_statement
  * Bivio::UI::HTML::Widget::NewEmptyRowHandler
    use c.childNodes not c.children
  * Bivio::UI::HTML::Widget::Script
    ComboBox search for drop_down rather than lookup by name,
    allows cloned value to work properly
  * Bivio::UI::XHTML::Widget::ComboBox
    removed dd_name and _drop_down_id()
  * Bivio::Util::HTTPD
    added run_db

  Revision 9.77  2010/10/22 22:53:29  moeller
  * Bivio::Biz::Model::SelectSearchForm
    removed
  * Bivio::Delegate::TaskId
    FORUM_FILE_VERSIONS_LIST & FORUM_WIKI_VERSIONS_LIST are paged lists
  * Bivio::SQL::PropertySupport
    improved error messages when missing "table_name" or "columns"
  * Bivio::UI::HTML::Widget::CopyListValueHandler
    NEW
  * Bivio::UI::HTML::Widget::JoinHandler
    rm pod, refactored
  * Bivio::UI::HTML::Widget::NewEmptyRowHandler
    NEW
  * Bivio::UI::HTML::Widget::SelectSearch
    removed
  * Bivio::UI::HTML::Widget::SourceCode
    wrap unsafe_map_require() in catch_quietly() in case the map is invalid
  * Bivio::UI::View::Wiki
    page history is now paged

  Revision 9.76  2010/10/18 01:57:11  nagler
  * Bivio::Biz::ListFormModel
    iterate_* methods were added incorrectly.  They now die.
  * Bivio::Biz::Model::CSVImportForm
    internal_source_error takes @args
    look up some of the text (detail_prefix) in Facade
    internal_put_error_and_detail call_super_before
    If enum is empty, return NULL, not not found, only if constraint is NOT_NULL
    previous checkin: fields can now refer to forms directly,
    e.g. UserLoginForm.RealmOwner.password
  * Bivio::Biz::Model::t::CSVImportForm::T1Form
    added fields
  * Bivio::Biz::Model
    assert_is_instance/singleton called throw_die incorrectly
  * Bivio::Delegate::SimpleFormErrors
    dies if called
  * Bivio::PetShop::Model::FieldTestForm
    added Enum
  * Bivio::Test::FieldWidget
    set source to be the form
  * Bivio::Test::Language::HTTP
    _append_query => internal_append_query
  * Bivio::Test::Unit
    b_use
    removed cruft comments
  * Bivio::Test::Widget
    allow bunit to set $source
  * Bivio::Type::FileField
    added from_any
  * Bivio::UI::FacadeBase
    added FormError.prose.detail_prefix
  * Bivio::UI::FormError
    detail can be a widget (FormModel doesn't care)
    FormError returns a widget
    to_html => to_widget_value
  * Bivio::UI::HTML::ViewShortcuts
    vs_string passes $attrs only if exists
  * Bivio::UI::HTML::Widget::AmountCell
    NEW_ARGS
  * Bivio::UI::HTML::Widget::Enum
    rmpod
    simplified, dynamic, and NEW_ARGS
    fpc
    field may be a reference
  * Bivio::UI::HTML::Widget::FormFieldError
    FormError implements to_widget_value
  * Bivio::UI::HTML::Widget::String
    b_use
    NEW_ARGS
  * Bivio::UI::XHTML::Widget::FormFieldError
    FormError implements to_widget_value
    Removed reference to UIHTML.FormErrors

  Revision 9.75  2010/10/15 20:55:37  moeller
  * Bivio::Biz::Model::ContextWritebackForm
    NEW
  * Bivio::Delegate::SimpleWidgetFactory
    DollarCell subclasses AmountCell
  * Bivio::UI::HTML::Widget::AmountCell
    Added html_format attribute
    simplified config
  * Bivio::UI::HTML::Widget::DollarCell
    subclass AmountCell

  Revision 9.74  2010/10/13 19:44:39  nagler
  * Bivio::Biz::Model::ECCreditCardPaymentForm
    return 0 from process_payment() if in_error()
    minor refactoring
  * Bivio::Biz::Model::User
    _compute_sorting_names needs to delete the sorting name if the
    non-sort name exists, that is, if first_name_sort is passed in, but
    not first_name, first_name_sort should not be updated.
  * Bivio::Biz::Model::UserSettingsListForm
    added validate_user_names
  * Bivio::Biz::Model
    added assert_is_instance for clearer error msgs when a class is the object
  * Bivio::Test::Language::HTTP
    _append_query should delete duplicate query key values
  * Bivio::Type::Date
    added TO_STRING_REGEX
  * Bivio::Type::DateTime
    now() must register __PACKAGE__ with Agent.Task, not $proto, which my
    Date or Time, not necessarily DateTime
  * Bivio::UI::FacadeBase
    paragraph_text gets underline
  * Bivio::UI::View::CSS
    paragraph_text gets special font
  * Bivio::Util::SQL
    search facades ddl firs
    create_test_db checks to see if there are any *.sql, not just that the
    ddl path is a directory

  Revision 9.73  2010/10/05 18:37:24  schellj
  * Bivio::BConf
    sort delegates
  * Bivio::Biz::ListFormModel
    added execute_ok_row_dispatch similar to EditDAVList
  * Bivio::Biz::Model::SiteAdminSubstituteUserForm
    rename var to be more clear
  * Bivio::Biz::Model::TupleExpandableListForm
    bivio::Base
  * Bivio::UI::FacadeBase
    move page_size to top level
    added Font embedded_prose_link
    Text for add_rows button
  * Bivio::UI::HTML::Widget::ListActions
    fmt
  * Bivio::UI::View::CSS
    added Font('embedded_prose_link'); to text like div.empty_list a, form
    .desc a, etc
  * Bivio::UI::XHTML::ViewShortcuts
    add_rows shows up by default for ExpandableListFormModel

  Revision 9.72  2010/09/29 17:19:14  moeller
  * Bivio::Delegate::TaskId, Bivio::UI::FacadeBase
    added FORUM_CRM_THREAD_ROOT_LIST_CSV
  * Bivio::UI::View::CRM
    added thread_root_list_csv()

  Revision 9.71  2010/09/23 19:14:32  moeller
  * Bivio::Type::DateTime
    removed get_next_year and added add_years
    removed get_previous_*
  * Bivio::Util::Release
    removed --skipdeps arg to Makefile.PL, causes problems in old modules

  Revision 9.70  2010/09/16 17:56:03  moeller
  * Bivio::Test::Request
    only call require_no_cookie() if the request supports it
  * Bivio::UI::View::Tuple
    don't show list action if expecting a realm and operating in general realm

  Revision 9.69  2010/09/16 16:59:22  moeller
  * Bivio::UI::View::CSS
    undid previous change
  * Bivio::UI::XHTML::Widget::DropDown
    undid previous change

  Revision 9.68  2010/09/13 17:04:37  moeller
  * Bivio::UI::HTML::Widget::Script
    use new RegExp() instead of // to avoid HTML Tidy warnings
  * Bivio::UI::View::CSS
    removed position relative from .task_menu_wrapper for better MSIE layout
  * Bivio::UI::View::Tuple
    remove eq_forum row control from _list_actions as tuples can now
    belong to any realm_type
  * Bivio::UI::XHTML::Widget::DropDown
    set dropdown left to parentNode's left, avoid MSIE missing scrollbar bug
  * Bivio::Util::Backup
    fixed to work on server properly

  Revision 9.67  2010/09/09 03:32:44  nagler
  * Bivio::BConf
    added Bivio::UI::HTML to UIXHTML path
  * Bivio::UI::HTML::ViewShortcuts
    can't use Bivio::Base UI.ViewShortcuts; Probably with an older app
    which keeps shorcuts in odd place
  * Bivio::UI::HTML::Widget::Grid
    rmpod
    b_use
  * Bivio::UI::HTML::Widget::TableBase
    rmpod
    b_use
  * Bivio::UI::XHTML::ViewShortcuts
    b_use

  Revision 9.66  2010/09/08 22:08:53  nagler
  * Bivio::Agent::HTTP::Cookie
    rmpod
    fmt
  * Bivio::Agent::HTTP::Form
    b_use
  * Bivio::Agent::Job::Request
    b_use
  * Bivio::Agent::Request
    is_production now comes from config.  Still in Request config.  One
    must be true for is_production
    added REQUIRE_ABSOLUTE_GLOBAL
    Fixed numerous b_use calls
  * Bivio::Agent::Task
    display the error if the commit fails
    cache has_realm_type
  * Bivio::Auth::Realm
    remove comments
  * Bivio::Base
    Added b_use cache.  Can't do in IO.ClassLoader, because has particular
       semantics on post_require
  * Bivio::Biz::Action::EmptyReply
    b_use
  * Bivio::Biz::Action
    use eq, not ==
  * Bivio::Biz::Model::AuthUserRealmList
    fixed load_all_for_task to move out invariants
    removed internal_clear_model_cache, because was clearing cache every
    internal_post_load_row.
    cache the state of is_defined_for_facade
  * Bivio::Biz::Model::JobLock
    rmpod
    b_use
  * Bivio::Biz::Model::MailReceiveDispatchForm
    if_version changed (not sure how); fix use
  * Bivio::Biz::Model::QuerySearchBaseForm
    b_use
  * Bivio::Biz::Model::RealmAdminEmailList
    use get_category_role_group all_admins
  * Bivio::Biz::Model::RealmOwner
    b_use
  * Bivio::Biz::Model::RoleBaseList
    cache _roles()
  * Bivio::Biz::Model::TaskLog
    b_use
  * Bivio::Biz::Model::TreeList
    compare of PrimaryId was very slow so customized is_equal, and called here
  * Bivio::Biz::Model::TupleSlotType
    b_use
  * Bivio::Biz::Model::UserLoginForm
    b_use
  * Bivio::Biz::Model
    todo & fmt
  * Bivio::Biz::Util::ListModel
    b_use
  * Bivio::Cache::RealmRole
    restructure so internal_compute_no_cache returns a hash, not the permission_set
    moved DEFAULT_PERMISSIONS cache to SimpleAuthSupport, because it is
    more than a simple cache.
    Need to use as_int, because values are persisted
  * Bivio::Cache
    was putting on the request for internal_compute_no_cache case
    use Bivio.ShellUtil->lock_action to manage locking.  Simplifies the
    process, because Storable had its own lock, and then we had to
    introduce ours.  Also, locking is implicitly non-blocking
    need to return $res from _read_and_thaw
  * Bivio::Collection::Attributes
    optimized get and unsafe_get for single parameter case
    added with_attributes
  * Bivio::Collection::SingletonMap
    rmpod
    b_use
    removed Carp
  * Bivio::Delegate::Cookie
    b_use
  * Bivio::Delegate::NoCookie
    rmpod
    removed comments
  * Bivio::Delegate::SimpleAuthSupport
    moved DEFAULT_PERMISSIONS cache back here, because backfills with EMPTY_PERMISSION_MAP
  * Bivio::Delegate::TaskId
    added PUBLIC_WIDGET_INJECTOR
  * Bivio::Delegator
    b_use
  * Bivio::Die
    added catch_and_rethrow
  * Bivio::IO::ClassLoader
    not COUPLING
  * Bivio::IO::Config
    added is_production
  * Bivio::IO::File
    fpt
    use catch_and_rethrow
  * Bivio::ShellUtil
    added no_warn to lock_action
    b_warn
    lock_action calls return_scalar_or_array
  * Bivio::Test::FormModel
    b_use
  * Bivio::Test::ForumUserUnit
    b_use
  * Bivio::Test::Request
    added require_no_cookie
    put_durable on certain attributes
  * Bivio::Test::Unit
    require_no_cookie explicitly, because wasn't actually working in all
    tests.  Needed for re-entrancy, too
  * Bivio::Test::Util
    b_use
    execute_task is re-entrant
  * Bivio::Type::EnumDelegator
    fmt
  * Bivio::Type::Location
    rmpod
    b_use and fmt
  * Bivio::Type::PrimaryId
    for performance reasons, is_equal coded locally
    copy
  * Bivio::Type
    added CLASSLOADER_MAP_NAME and removed put_on_request (in UNIVERSAL)
  * Bivio::UI::FacadeBase
    adjust validation string for different types of tuple lables/monikers
    added PUBLIC_WIDGET_INJECTOR
  * Bivio::UI::Facade
    b_use
  * Bivio::UI::HTML::Format
    rmpod
    b_use & fmt
  * Bivio::UI::HTML::ViewShortcuts
    simplify _use to use b_use
  * Bivio::UI::HTML::Widget::StandardSubmit
    rmpod
    ViewLanguageAUTOLOAD
  * Bivio::UI::JavaScript::Widget::QuotedValue
    factored out escape_value
  * Bivio::UI::JavaScript::Widget::WidgetInjector
    NEW
  * Bivio::UI::View::Base
    added js() and xhtml_widget() views for WidgetInjector
  * Bivio::UI::View::WidgetInjector
    NEW
  * Bivio::UI::View
    call_main and render accept view_class and view_name or just view_name
  * Bivio::UI::Widget
    b_use
  * Bivio::UI::XHTML::Widget::HelpWiki
    control_on_value must return a string, not undef
  * Bivio::UI::XHTML::Widget::Pager
    refactor _get_page_numbers
  * Bivio::UNIVERSAL
    add put_on_request so can move out of subclasses
  * Bivio::Util::Backup
    added lock_action to most calls
    b_use
  * Bivio::Util::HTTPConf
    is_production now comes from config.  Still in Request config.  One
    must be true for is_production
  * Bivio::Util::HTTPD
    get running on gentoo
    don't PassEnv vars that don't exist
  * Bivio::Util::Release
    b_use

  Revision 9.65  2010/08/29 17:49:18  nagler
  * Bivio::Test::HTMLParser::Forms
    Detect err_title class showing up
  * Bivio::Test::Language::HTTP
    go_back() supports a count
    When an err_title class shows up without input errors on the form, die

  Revision 9.64  2010/08/27 19:09:40  moeller
  * Bivio::Biz::Action::ECCreditCardProcessor
    don't warn about missing login unless on production
  * Bivio::Util::HTTPLog
    always log JOB_ERROR

  Revision 9.63  2010/08/25 20:39:20  moeller
  * Bivio::Agent::Request
    format the query before redirecting the realm during server_redirect
  * Bivio::Biz::FormModel
    always set acknowledgement to SAVE_LABEL_DEFAULT unless present
  * Bivio::Test::HTMLParser::Forms
    clear prev_cell_text at start of a form
  * Bivio::Type::Boolean
    ignore space around literals

  Revision 9.62  2010/08/23 23:27:43  moeller
  * Bivio::Agent::HTTP::Query
    added support for Action.Acknowledgement
  * Bivio::Agent::Request
    Use AgentHTTP.Query
    Fixed carry_query logic
  * Bivio::Biz::Action::Acknowledgement
    added SAVE_LABEL_DEFAULT
  * Bivio::Biz::FormModel
    move Acknowledgement support to AgentHTTP.Query
  * Bivio::Biz::ListFormModel
    added iterate_*
  * Bivio::Biz::ListModel
    Use AgentHTTP.Query
  * Bivio::Biz::Model::Address
    remove comments
  * Bivio::Biz::Model::CalendarEventForm
    acknowledgement needs to be in the query
  * Bivio::Biz::Model::TaskLog
    Use AgentHTTP.Query
  * Bivio::UI::HTML::Widget::AmountCell
    deal with undef properly
  * Bivio::UI::Text::Widget::CSV
    added want_iterate_start attribute,
    allows iterating unloaded PropertyModels or ListModels
  * Bivio::UI::View::CSS
    more menu in .tools was not aligning properly

  Revision 9.61  2010/08/09 20:54:53  moeller
  * Bivio::Biz::FormModel
    support for new concept of a 'constraining_field'
  * Bivio::Biz::Model::CRMForm
    stop processing if superclass is in_error()
  * Bivio::Biz::Model::MailForm
    put an error on from_email if from email is invalid
  * Bivio::Delegate::SimpleTypeError
    added INVALID_SENDER
  * Bivio::SQL::Support
    added 'constraining_field' concept whereby a field's validation is
    defined as dependent on the constraints of another field
  * Bivio::Test::Language::HTTP
    text_exists uses _fixup_pattern_protected
    use AgentHTTP.Query
    undid change to text_exists()
  * Bivio::UI::View::Mail
    added from_email FormFieldError

  Revision 9.60  2010/08/05 15:20:33  moeller
  * Bivio::BConf
    ignore declined CC errors
  * Bivio::Biz::Action::ECCreditCardProcessor
    added more warning info
  * Bivio::Biz::Model::CRMForm
    fpc
  * Bivio::Biz::Util::ListModel
    use AgentHTTP.Query
  * Bivio::SQL::Connection::Postgres
    fixed constraint attrname lookup
  * Bivio::Test::Util
    use AgentHTTP.Query
  * Bivio::Util::SQL
    want_reply_to and is_public_email need to have DROP NOT NULL in
    site_forum upgrade

  Revision 9.59  2010/07/28 17:23:20  nagler
  * Bivio::UI::View::Tuple
    Be compatible with vs_list_form change

  Revision 9.58  2010/07/28 00:00:39  nagler
  * Bivio::Biz::Model::ECCreditCardPaymentForm
    fpc
  * Bivio::UI::XHTML::ViewShortcuts
    fpc: vs_list_form field validation incorrect
  * Bivio::UI::XHTML::Widget::FeatureTaskMenu
    sort_labels were wrong order

  Revision 9.57  2010/07/27 17:44:29  nagler
  * Bivio::PetShop::BConf
    added realm_user_util5
  * Bivio::PetShop::Util::SQL
    added realm_user_util5
  * Bivio::Type::CurrencyName
    NEW
  * Bivio::Type::Currency
    NEW
  * Bivio::Type::Dollar
    rmpod
    *** empty log message ***
  * Bivio::Type::NonNegativeCurrency
    NEW
  * Bivio::Type::NonNegativeInteger
    NEW
  * Bivio::Type::NonNegativePercent
    NEW
  * Bivio::Type::Time
    fix minor operator error in from_literal
  * Bivio::UI::FacadeBase
    moved out Logo link in xhtml_logo to vs_header_su_link()
    renamed sort_first/second/etc. to sort_label_01/02/etc.
  * Bivio::UI::XHTML::ViewShortcuts
    moved out Logo link in xhtml_logo from FacadeBase to vs_header_su_link()
    vs_list_form was not parsing field names correctly
  * Bivio::UI::XHTML::Widget::FeatureTaskMenu
    added internal_merge_tasks
    use sort_label_nn
  * Bivio::Util::RealmUser
    allow all realms of a particular RealmType to be added in auditor

  Revision 9.56  2010/07/12 19:14:46  moeller
  * Bivio::Biz::Model::RealmUserAddForm
    changed "must have exactly one main role" to be a warn_deprecated
  * Bivio::UI::FacadeBase
    fixed xlink_all_users
  * Bivio::UI::HTML::Widget::MonthYear
    added month_choices arg
  * Bivio::UI::View::Blog
    added is_public to create()
  * Bivio::UI::View::CSS
    improve field position
  * Bivio::UI::XHTML::Widget::FeatureTaskMenu
    added exclude_tasks()
    made SiteAdminDropDown third item
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    sort the list
  * Bivio::UI::XHTML::Widget::TaskMenu
    sort_label needed to handle refs (widgets)
  * Bivio::Util::Backup
    remote_archive: check that the drive mounted correctly
    fpc

  Revision 9.55  2010/06/15 21:46:36  nagler
  * Bivio::Biz::Model::MailForm
    support for cleaning up to/cc when board_only selected
  * Bivio::Type::EmailArray
    b_use
  * Bivio::UI::FacadeBase
    added board_only support
  * Bivio::UI::View::Mail
    added board_only field to send_form
  * Bivio::UI::ViewShortcuts
    added vs_ui_members

  Revision 9.54  2010/06/15 20:27:38  moeller
  * Bivio::Biz::Model::RealmUserAddForm
    don't assume Model.RealmUser is on request
  * Bivio::Mail::Incoming
    get_reply_email_arrays will return realm with ALL as Cc, if there's
    already a To.  Cleaned up the duplicate code a bit
  * Bivio::UI::HTML::Widget::RealmFilePage
    ignore javascript links

  Revision 9.53  2010/06/14 17:24:16  nagler
  * Bivio::Biz::Action::AdminRealmMail
    pushed up format_email_for_auth_realm and changed to format_email_for_realm
  * Bivio::Biz::Action::BoardRealmMail
    Subclass RealmMailBase
  * Bivio::Biz::Action::RealmMailBase
    NEW
  * Bivio::Biz::Action::RealmMail
    Subclass RealmMailBase
  * Bivio::Biz::Model::CRMForm
    Removed internal_send_to_board_maybe
    Always send to board (broken when internal_send_to_board_maybe removed)
    to/cc switched around when new
    Grab first From: in the list of all emails so MailReplyWho->ALL does
    the right thing
  * Bivio::Biz::Model::MailForm
    added removal of board.<realm> emails
    Removed internal_send_to_board_maybe
    Added internal_send_to_board
    refactoring (use field_decl)
    Added board_always for CRMForm
    Added internal_get_reply_incoming for CRMForm
  * Bivio::Biz::Model::RealmUserAddForm
    assert that we only have one main role
  * Bivio::Mail::Incoming
    cruft
  * Bivio::Type::ArrayBase
    Added get_element
  * Bivio::UI::View::Mail
    factored out internal_send_form_email_field

  Revision 9.52  2010/06/10 17:14:07  moeller
  * Bivio::Test::Reload
    update reload time stamp after modules and/or ddl files have been
    checked and updated, if necessary.
  * Bivio::Type::USZipCodeMap
    NEW
  * Bivio::Type::USZipCode
    added zip_codes_by_proximity()
  * Bivio::UI::HTML::Widget::MonthYear
    always show month/year as a select widget
  * Bivio::UI::XHTML::Widget::DropDown
    cancelBubble is a Microsoft model property, w3c browsers use stopPropagatio()

  Revision 9.51  2010/05/31 20:17:02  nagler
  * Bivio::PetShop::View::CSS
    revert to 1.5
  * Bivio::ShellUtil
    fmt
  * Bivio::Test::WikiText
    todo
  * Bivio::UI::FacadeBase
    revert to 1.264
  * Bivio::UI::HTML::Widget::Script
    revert to 1.21
    revert to 1.19
  * Bivio::UI::View::CSS
    revert to 1.120
    reapply 1.124
  * Bivio::UI::View::ThreePartPage
    revert to 1.32
  * Bivio::UI::XHTML::Widget::DropDown
    revert to 1.5
  * Bivio::UI::XHTML::Widget::RealmDropDown
    revert to 1.13
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    revert to 1.11
  * Bivio::UI::XHTML::Widget::TaskMenu
    revert to 1.42
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    revert to 1.42

  Revision 9.50  2010/05/29 22:13:33  nagler
  * Bivio::Auth::Support
    rmpod
  * Bivio::BConf
    feature_motion is the same as open_results_motion
  * Bivio::Biz::Model::BlogList
    call Bivio.Search, not Search.Xapian so if Xapian not installed,
    doesn't pull in Xapian
  * Bivio::Biz::Model::MailThreadRootList
    call Bivio.Search, not Search.Xapian so if Xapian not installed,
    doesn't pull in Xapian
  * Bivio::Biz::Model::RealmFile
    search_class is no longer configured.  Instead Bivio.Search specifies
    delegate explicitly dependent on which search component included
  * Bivio::Biz::Model::SearchList
    call Bivio.Search, not Search.Xapian so if Xapian not installed,
    doesn't pull in Xapian
  * Bivio::Delegate::TaskId
    Bivio.Search manages the delegation of the search class based on which
    task is included
  * Bivio::Delegate
    rmpod
  * Bivio::Delegator
    rmpod
    allow subclasses to specify delegate explicitly (Bivio::Search needs this)
  * Bivio::PetShop::Util::SQL
    don't need open_results_motion now that feature_motion does the same thing
  * Bivio::Search::None
    NEW
  * Bivio::Search::Xapian
    moved code up to Search.None so excerpts work even if Xapian is not installed
  * Bivio::Search
    NEW
  * Bivio::Util::Search
    module_version not needed
  * Bivio::Util::SQL
    don't need open_results_motion now that feature_motion does the same thing

  Revision 9.49  2010/05/28 20:41:27  dobbs
  * Bivio::Biz::Model::CalendarEventForm
    $_US -> $_USLF, call SUPER::validate
  * Bivio::UI::HTML::Widget::Script
    DropDowns now toggle visibility instead of toggling display
  * Bivio::UI::View::CSS
    DropDowns now toggle visibility instead of toggling display
  * Bivio::UI::XHTML::Widget::DropDown
    DropDowns now toggle visibility instead of toggling display

  Revision 9.48  2010/05/28 16:27:04  nagler
  * Bivio::Biz::Model::CalendarEventForm
    added validation for time_zone_selector field
  * Bivio::Biz::Model::UserSettingsListForm
    added validation (delegation) method validate_time_zone_selector
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    no longer defaults the class to bmenu, use TaskMenu's b_task_menu
  * Bivio::Util::Search
    acquire lock per $_X, not directly
    don't index default realms

  Revision 9.47  2010/05/27 16:07:30  dobbs
  * Bivio::UI::View::CSS
    made .b_hide more specific so DropDowns work inside .tools

  Revision 9.46  2010/05/26 23:26:47  dobbs
  * Bivio::Biz::Model::TimeZoneList
    add unsafe_enum_for_display_name, reorg to make use of _get_enum_from_model
  * Bivio::UI::HTML::Widget::Script
    cancelBubble is a microsoft model property. For w3c compliant browsers
    we need to use stopPropagation()
  * Bivio::UI::View::CSS
    fix new TaskMenu and DropDown styles for IE6
    remove unnecessary styling on .b_dd_link
    links styles in .b_dd_menu now override links styles from table.dock
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    the class in @b-menu.someclass is now correctly handed off to TaskMenu()

  Revision 9.45  2010/05/21 21:14:48  dobbs
  * Bivio::UI::View::CSS
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    revert SiteAdminDropDown and fix CSS instead

  Revision 9.44  2010/05/21 19:40:02  nagler
  * Bivio::Biz::Model::RealmUserAddForm
    check IS_AUDIT_ENABLED
  * Bivio::Util::RealmUser
    added IS_AUDIT_ENABLED

  Revision 9.43  2010/05/20 22:45:56  dobbs
  * Bivio::Test::HTMLParser::Forms
    HTMLParser now clears previous text on a form start tag
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    changed from TaskMenu to simple OL

  Revision 9.42  2010/05/19 19:47:59  dobbs
  * Bivio::Biz::Model::RealmFile
    allow override_versioning flag in update_with_content()
  * Bivio::UI::View::CSS
    fix indention for unordered list items in slide notes sections
    merge blocks for .b_task_menu li
  * Bivio::UI::XHTML::Widget::TaskMenu
    now appends html class instead of overriding
  * Bivio::Util::HTTPStats
    import_tree without archiving old files
  * Bivio::Util::RealmFile
    added noarchive arg to import_tree(),
    added purge_archive()

  Revision 9.41  2010/05/18 22:21:49  dobbs
  * Bivio::UI::View::CSS
    fix dropdown border color
    fix .b_first margin and remove borders on tools in ?/mail-thread

  Revision 9.40  2010/05/18 21:38:18  dobbs
  * Bivio::UI::View::CSS
    reduce font-size for dock and some fixes for IE

  Revision 9.39  2010/05/17 22:28:42  dobbs
  * Bivio::Biz::Model::ECCreditCardPaymentForm
    execute_empty now only populates fields if user is logged in
  * Bivio::PetShop::View::CSS
    DropDown javascript move to <head>, prefix b_ for css and facade
  * Bivio::Test::WikiText
    added wiki_create() and refactored b-menu units
  * Bivio::UI::FacadeBase
    DropDown javascript move to <head>, prefix b_ for css and facade
  * Bivio::UI::HTML::Widget::Script
    DropDown javascript move to <head>, prefix b_ for css and facade
    call window.onload just before </body>
  * Bivio::UI::View::CSS
    first draft: TaskMenu changed to <ol><li>
    DropDown javascript move to <head>, prefix b_ for css and facade
    fix interaction between new TaskMenu and wiki bmenus
    .selected => .b_selected
  * Bivio::UI::View::ThreePartPage
    dock_right now uses TaskMenu
  * Bivio::UI::XHTML::Widget::DropDown
    DropDown javascript move to <head>, prefix b_ for css and facade
  * Bivio::UI::XHTML::Widget::RealmDropDown
    dock_right now uses TaskMenu
    DropDown javascript move to <head>, prefix b_ for css and facade
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    DropDown javascript move to <head>, prefix b_ for css and facade
  * Bivio::UI::XHTML::Widget::TaskMenu
    use <ol><li>, not <div>, and b_ class prefix
    put more dropdown inside an <li>
    DropDown javascript move to <head>, prefix b_ for css and facade
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    fix interaction between new TaskMenu and wiki bmenus
  * Bivio::UI::XHTML::Widget::WikiText
    added alt tag to implict img tags

  Revision 9.38  2010/05/13 22:29:58  nagler
  * Bivio::Agent::Job::Request
    b_use Agent::Reply
  * Bivio::Agent::Request
    added facade_uri to format_uri so can switch facades easily
  * Bivio::Auth::Realm
    fmt
  * Bivio::Biz::Model::UserLoginForm
    if disable_assert_cookie set on request, then like on the form itself
  * Bivio::Test::Reload
    always delete the request ($req was not being set before)
  * Bivio::Test::Request
    don't introduce_values
    disable_assert_cookie
    put disable_assert_cookie on self
    b_use
  * Bivio::Type::UserAgent
    Added BROWSER_IPHONE & ->is_mobile_device
    fmt
  * Bivio::UI::CSS
    NEW
  * Bivio::UI::FacadeBase
    Define new CSS FacadeComponent
    added menu_want_sep/_clear
    encapsulate CSS('b_prose')
    define xhtml_logo_normal XLink
  * Bivio::UI::Facade
    default initialization for a component is empty
  * Bivio::UI::View::CSS
    use new CSS FacadeComponent
    use CSS menu_want_sep
    encapsulate CSS('b_prose')
  * Bivio::UI::Widget::Equals
    NEW
  * Bivio::UI::XHTML::Widget::TaskMenu
    define want_more_label
    fmt
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    allow id= attribute
  * Bivio::UI::XHTML::Widget::WikiText
    Parse blank tag attributes correctly: @a href= foo
    allow "@tag attr=" that is, attr= ends the line
  * Bivio::Util::CSV
    added assertion to test if a file name is passed to parse/_records

  Revision 9.37  2010/05/10 15:34:40  moeller
  * Bivio::Biz::Action::ECCreditCardProcessor
    refactored, removed unimplemented check_transaction_batch()
  * Bivio::Biz::Action::ECPaymentProcessAll
    fixed unauth_iterate_start
    removed call to check_transaction_batch() - not implemented
  * Bivio::Biz::Action::ECSecureSourceProcessor
    rm pod, refactored - changed internal_get_additional_form_data()
    to return an array of key/value pairs
  * Bivio::Biz::Model::CalendarEventList
    seconds => minute
  * Bivio::Biz::Model::EmailForDomainList
    NEW
  * Bivio::Biz::Model::FileChangeForm
    Q#520:        Can't rename suffix of file when upper case
  * Bivio::Biz::Model::TaskLogList
    added execute_unauth_iterate_start and execute_iterate_start
  * Bivio::Delegate::TaskId
    Use execute_*_iterate_start for TASK_LOG_CSV tasks, which now exits at
    a "reasonable" number (10K)
  * Bivio::Type::Email
    added replace_domain
  * Bivio::UI::View::Blog
    removed HIDE_IS_PUBLIC
    Made cols same as WIKI
  * Bivio::UI::View::Wiki
    removed HIDE_IS_PUBLIC
  * Bivio::UI::XHTML::ViewShortcuts
    vs_user_email_list: control on wf_list_link should check is_super_user
  * Bivio::Util::Email
    NEW
  * Bivio::Util::RealmFile
    added folder_sizes

  Revision 9.36  2010/04/29 16:48:19  nagler
  * Bivio::Cache
    need to create the directory first
  * Bivio::Test::Language::HTTP
    reworked verify_no_link to use patterns
    fix vc conflict
  * Bivio::UI::XHTML::ViewShortcuts
    use ADM_SUBSTITUTE_USER for super users in vs_user_email_list

  Revision 9.35  2010/04/29 00:00:51  nagler
  * Bivio::Auth::RealmType
    is_default_id should just use unsafe_from_int, because doesn't work
    with large realm_ids to use Type.Integer
    need to restrict test of is_default_id to numbers less than $_MIN,
    because large realm_ids may get into e+ digits
  * Bivio::Biz::Model::ForbiddenForm
    don't logout if substitute user
  * Bivio::Cache::RealmRole
    put in non-blocking locking on computation.  If there's no cache, then
    internal_compute_no_cache will return undef (OK for SEOPrefix) and for
    RealmRole, it will go right to the db
  * Bivio::Cache
    put in non-blocking locking on computation.  If there's no cache, then
    internal_compute_no_cache will return undef (OK for SEOPrefix) and for
    RealmRole, it will go right to the db

  Revision 9.34  2010/04/28 02:51:56  nagler
  * Bivio::Cache::RealmRole
    Added 'enable' configuration to allow apps to turn off caching.
    Important if RealmRole table is large

  Revision 9.33  2010/04/28 01:43:13  nagler
  * Bivio::Biz::Action::BoardRealmMail
    NEW
  * Bivio::Biz::Model::CRMForm
    added internal_send_to_board_maybe
  * Bivio::Biz::Model::MailForm
    added internal_send_to_board_maybe
  * Bivio::Delegate::TaskId
    added BOARD_REALM_MAIL_RECEIVE
  * Bivio::PetShop::Util::TestData
    need a commit_or_rollback at end of reset_seo_btest to force the cache
    to be updated
  * Bivio::Test::Language::HTTP
    enable verify_local_mail to test for 0 messages
  * Bivio::UI::FacadeBase
    added BOARD_REALM_MAIL_RECEIVE

  Revision 9.32  2010/04/27 23:57:48  nagler
  * Bivio::Cache::RealmFileBase
    NEW
  * Bivio::Cache::SEOPrefix
    move code up to RealmFileBase

  Revision 9.31  2010/04/27 22:05:44  moeller
  * Bivio::Agent::Request
    can't use $_F in format_email, because may not have a facade.

  Revision 9.30  2010/04/26 03:14:13  nagler
  * Bivio::Agent::Request
    fpc
  * Bivio::Util::HTTPLog
    don't close file handle if not open

  Revision 9.29  2010/04/25 22:54:06  nagler
  * Bivio::Agent::Request
    don't load UI.Facade until have to
  * Bivio::Cache
    don't load Biz.File until have to

  Revision 9.28  2010/04/25 17:48:22  nagler
  * Bivio::Agent::t::Mock::Facade::Mock
    fpc
  * Bivio::Biz::Model::RealmSettingList
    export get_file_path
  * Bivio::Biz::Model::SEOPrefixSettingList
    removed
  * Bivio::Cache::RealmRole
    pushed up code into Cache
  * Bivio::Cache::SEOPrefix
    NEW
  * Bivio::Cache
    support subclasses better
  * Bivio::PetShop::Util::SQL
    init_seo_btest => reset_seo_btest; Made reentrant
  * Bivio::PetShop::Util::TestData
    init_seo_btest => reset_seo_btest; Made reentrant
  * Bivio::UI::Task
    moved SEOPrefixSettingList => SEOPrefix

  Revision 9.27  2010/04/24 21:40:39  nagler
  * Bivio::Agent::Embed::Request
    added unsafe_get_current_root
    b_use
  * Bivio::Agent::HTTP::Dispatcher
    get_db_time is gone
  * Bivio::Agent::HTTP::Request
    start_time is in superclass
  * Bivio::Agent::Request
    Added perf_time_op, etc. to support generalized performance timing
    Added unsafe_get_current_root (for perf_time)
    process_cleanup always goes through the loop
  * Bivio::Agent::t::Mock::Facade::Mock
    need mock  site_realm_id
  * Bivio::BConf
    added perf trace
  * Bivio::Biz::Action::LocalFilePlain
    get_db_time is gone
  * Bivio::Biz::Model::BlogList
    use get_excerpt_for_primary_id
  * Bivio::Biz::Model::MailThreadRootList
    use get_excerpt_for_primary_id
  * Bivio::Biz::PropertyModel
    fmt
  * Bivio::IO::ClassLoader
    added unsafe_required_class
  * Bivio::IO::File
    b_use
  * Bivio::Search::Xapian
    use perf_time_op
  * Bivio::SQL::Connection
    get_db_time was not recording all fetches and finishes
    Use perf_time_op
  * Bivio::SQL::ListSupport
    use perf_time_op
    b_use
  * Bivio::SQL::PropertySupport
    use perf_time_op
    b_use
  * Bivio::SQL::Support
    use perf_time_op
    b_use
  * Bivio::UI::Facade
    added unsafe_get_from_source
  * Bivio::UI::HTML::Widget::Link
    use ViewLanguageAUTOLOAD
  * Bivio::UI::HTML::Widget::Page
    show_time is replaced by req->perf_time_op
    use ViewLanguageAUTOLOAD

  Revision 9.26  2010/04/24 17:49:12  moeller
  * Bivio::Biz::Model::TaskLogList
    added execute_unauth_load_all to allow SITE_ADMIN_TASK_LOG_CSV to get
    all records instead of only the current page
  * Bivio::Delegate::TaskId
    changed *_TASK_LOG_CSV tasks to load all records instead of only the
    current page
  * Bivio::UI::HTML::Widget::MultiCheckHandler
    fixed render so it only happens once per page
  * Bivio::UI::XHTML::Widget::ComboBox
    avoid recalculating list items if already rendered

  Revision 9.25  2010/04/22 22:01:02  nagler
  * Bivio::Cache::RealmRole
    set $_FILE dynamically so don't bring in Biz.File (which has a
    required config param)
  * Bivio::Ext::DBI
    rmpod
    fpc

  Revision 9.24  2010/04/22 20:11:55  nagler
  * Bivio::Auth::Realm
    clear_model_cache is replaced by Cache.RealmOwner
  * Bivio::BConf
    added Cache map
  * Bivio::Biz::Action::JobBase
    factor out enqueue_task
  * Bivio::Biz::Model::RealmOwner
    clear_model_cache is replaced by PropertyModel->internal_data_modification
  * Bivio::Biz::Model::RealmRole
    clear_model_cache is replaced by PropertyModel->internal_data_modification
  * Bivio::Biz::PropertyModel
    added internal_data_modification and register_handler
  * Bivio/Cache
    NEW
  * Bivio::Cache
    NEW
  * Bivio::Delegate::SimpleAuthSupport
    use Cache.RealmRole
  * Bivio::SQL::PropertySupport
    $order_by  not required for iterate_start, because can be faster for
    certain cases
    Eliminate circular import
  * Bivio::Test::Unit
    inline_* need to return IGNORE_RETURN
  * Bivio::Util::User
    catch and ignore uniqueness errors when merging user data

  Revision 9.23  2010/04/22 16:52:52  moeller
  * Bivio::Biz::ListModel
    don't put "list_model" on request if ephemeral
  * Bivio::Biz::Model::RealmSettingList
    set_ephemeral when checking for RealmFile
  * Bivio::Biz::Model::SEOPrefixSettingList
    set_ephemeral

  Revision 9.22  2010/04/22 00:13:29  nagler
  * Bivio::Biz::Model::RealmSettingList
    added unauth_* methods so can load more easily (without setting realm)
  * Bivio::Biz::Model::SEOPrefixSettingList
    NEW
  * Bivio::PetShop::Util::SQL
    added seo_btest support
  * Bivio::PetShop::Util::TestData
    added seo_btest support
  * Bivio::UI::Task
    added SEOPrefixSettingList support

  Revision 9.21  2010/04/20 20:17:07  moeller
  * Bivio::Biz::Action::ECPaymentProcessAll
    rm pod,
    put payment model on request during iterate
  * Bivio::Type::CountryCode
    added montenegro and serbia

  Revision 9.20  2010/04/18 20:05:33  nagler
  * Bivio::Biz::Action::DevRestart
    NEW
  * Bivio::Biz::Model::GroupUserForm
    only delete "everybody" roles in change_main_role
  * Bivio::Biz::Model::SiteAdminSubstituteUserForm
    check for eq_administrator in all roles, not just main role
  * Bivio::Biz::Model
    cruft
    do_iterate calls put_on_request if the loop ends early
  * Bivio::Biz::PropertyModel
    iterate does not put_on_request
    b_use
  * Bivio::Delegate::SimpleAuthSupport
    set_ephemeral on do_iterate to avoid put_on_request()
    don't query on realm roles which have already been cached
  * Bivio::Delegate::SimpleTaskId
    modularized merge_task_info better
    _sort() was not returning correct value when $b was base
    b_use
  * Bivio::Delegate::TaskId
    added info_dev component, DEV_RESTART
  * Bivio::PetShop::Util::SQL
    use change_main_role in _init_site_admin
  * Bivio::SQL::PropertySupport
    delete_all supports generalized queries
    delete_all uses _prepare_where
    factor out _prepare_where from _prepare_select
    put in an assertion on the query on delete_all
  * Bivio::Test::Language::HTTP
    doc
  * Bivio::Type::ArrayBase
    sort unique needs to use to_literal, from_literal before doing keys
  * Bivio::Type::Enum
    compare works if only passed one parameter, it uses $self as the $left
  * Bivio::UI::FacadeBase
    added _cfg_dev
    b_use
  * Bivio::UNIVERSAL
    cache request keys by package name
    cache as_classloader_map_name, not _REQ_KEY_CACHE
    $self => $proto in a couple of places
  * Bivio::Util::HTTPD
    added restart function

  Revision 9.19  2010/04/14 15:27:34  moeller
  * Bivio::Biz::t::ExpandableListFormModel::T1ListForm
    added CLASSLOADER_MAP_NAME
  * Bivio::Test::HTMLParser::Cleaner
    removed 015 line
  * Bivio::UI::HTML::Widget::SourceCode
    unsafe_map_require dies on syntax error so must execute in eval
  * Bivio::UNIVERSAL
    as_classloader_map_name returns package_name if map_name is empty
  * Bivio::Util::SiteForum
    fpc

  Revision 9.18  2010/04/13 00:22:58  nagler
  * Bivio::PetShop::Util::SQL
    create ROOT user
    always init root
  * Bivio::Util::SiteForum
    moved site_admin_forum_users2 to SiteForum
    Call at initialization
  * Bivio::Util::SQL
    moved site_admin_forum_users2 to SiteForum
    Call at initialization
    don't init site_admin_forum_users2 if not v10

  Revision 9.17  2010/04/12 21:28:49  nagler
  * Bivio::Biz::Model::RealmUserAddForm
    don't delete userse before adding
  * Bivio::Type::ArrayBase
    exclude algorithm would explode memory

  Revision 9.16  2010/04/12 02:46:06  nagler
  * Bivio::Biz::Model::RealmUserAddForm
    normalize some code
  * Bivio::Biz::Model
    Let UNIVERSAL create CLASSLOADER_MAP_NAME
  * Bivio::Biz::PropertyModel
    added rows_exists
  * Bivio::PetShop::View::CSS
    leave logo for /src
  * Bivio::UI::XHTML::ViewShortcuts
    need to specify realm on vs_user_email_list wf_list_link
  * Bivio::Util::SQL
    files/*/ddl is now checked for existence in create_test_db
    upgrades site_admin_forum_users2 added, site_admin_forum_users deleted
    fpc

  Revision 9.15  2010/04/10 00:38:44  nagler
  * Bivio::IO::ClassLoader
    added all_map_names & unsafe_map_for_package
  * Bivio::PetShop::Delegate::TaskId
    SOURCE is now a method view
  * Bivio::PetShop::Facade::PetShop
    SOURCE takes path_info
  * Bivio::PetShop::View::Base
    added TaskInfo to footer_left
  * Bivio::PetShop::View::CSS
    support for SOURCE
  * Bivio::PetShop::View::Source
    NEW
  * Bivio::UI::FacadeComponent
    fmt
  * Bivio::UI::HTML::Widget::SourceCode
    do a better job of mapping classes
    fpc
  * Bivio::UI::HTML::Widget::TaskInfo
    escape html
  * Bivio::UNIVERSAL
    load IO.ClassLoader with Bivio::IO::ClassLoader to allow app overrides
    added CLASSLOADER_MAP_NAME which uses unsafe_map_for_package

  Revision 9.14  2010/04/09 23:07:00  moeller
  * Bivio::Biz::Model::MailReceiveDispatchForm
    modernize config registration
  * Bivio::Biz::Model::RealmFeatureForm
    internal_use_general_realm_for_site_admin only use general on is_create
  * Bivio::Delegate::Cookie
    call b_die
  * Bivio::Test::HTMLParser::Cleaner
    &quot; should not be escaped at $html level
    need to decouple unescape_text from text (full clean)
  * Bivio::Test::HTMLParser::Forms
    unescape_text explicitly
  * Bivio::Test::HTMLParser::Tables
    unescape_text explicitly
  * Bivio::Test::HTMLParser
    rmpod
    added unescape_text (really should be in cleaner, but in a hurry)
    fpc

  Revision 9.13  2010/04/08 21:42:15  moeller
  * Bivio::Util::Release
    call Makefile.PL with --skipdeps so it doesn't go out to CPAN

  Revision 9.12  2010/04/08 20:56:23  moeller
  * Bivio::Biz::Action::UserLogout
    rmpod
    oc
    clean
  * Bivio::Biz::Model::SiteAdminUserList
    removed
  * Bivio::Biz::Model::UserCreateForm
    join_site_admin_realm not necessary, use v10
  * Bivio::Delegate::TaskId
    v10: SITE_ADMIN_SUBSTITUTE_USER_DONE returns to GROUP_USER_LIST
  * Bivio::PetShop::BConf
    join_site_admin_realm not necessary, use v10
  * Bivio::UI::FacadeBase
    SiteAdminUserList gone
    v10: xlink_all_users goest to GROUP_USER_LIST and SITE_ADMIN_REALM_NAME
  * Bivio::UI::View::SiteAdmin
    use AdmUserList not SiteAdminUserList
  * Bivio::Util::Release
    allow building modules without a Makefile.PL, but with Build.PL instead
  * Bivio::Util::SQL
    use AdmUserList not SiteAdminUserList

  Revision 9.11  2010/04/07 21:55:43  nagler
  * Bivio::Biz::Model::GroupUserList
    v10: use SiteAdminSubstituteUserForm for can_substitute_user
  * Bivio::Biz::Model::RealmUserAddForm
    delete prior user records if any
  * Bivio::Biz::Model::SiteAdminSubstituteUserForm
    can su from any realm, just make sure user is an admin of that realm
  * Bivio::Biz::Model::TimeZoneList
    need to pass req to get_value
  * Bivio::Biz::Model::UserRegisterForm
    create_unapproved_applicant already deletes user records so don't need
    to do it here

  Revision 9.10  2010/04/07 20:32:40  nagler
  * Bivio::Biz::Model::AdmSuperUserList
    NEW
  * Bivio::Biz::Model::RealmDropDownList
    provide REQUIRED_ROLE_GROUP to qualify role to all_guests
  * Bivio::Biz::Model::SiteAdminSubstituteUserForm
    don't allow users not in the site-admin realm to be su'd to
  * Bivio::Biz::Model::SiteAdminSuperUserList
    removed
  * Bivio::Biz::Model::UserBaseDAVList
    fmt
  * Bivio::Biz::Model::UserForumDAVList
    include site-admin
  * Bivio::Biz::Model::UserForumList
    provide REQUIRED_ROLE_GROUP to qualify role to all_guests
  * Bivio::Delegate::Role
    added all_guests
  * Bivio::Delegate::TaskId
    require_secure for GROUP_USER_LIST
  * Bivio::PetShop::BConf
    v10
  * Bivio::UI::FacadeBase
    v10: xl_linkall_users uses GROUP_USER_LIST, not SITE_ADMIN_USER_LIST
  * Bivio::UI::Widget::SiteAdminControl
    v10: use GROUP_USER_LIST, not SITE_ADMIN_USER_LIST
  * Bivio::UI::XHTML::ViewShortcuts
    v10: use SITE_ADMIN_SUBSTITUTE_USER (was formerly v5, but never really
    worked at that level) instead of ADM_SUBSTITUTE_USER
  * Bivio::UI::XHTML::Widget::RealmDropDown
    use REQUIRED_ROLE_GROUP in UserFormList to qualify at all_guests

  Revision 9.9  2010/04/07 17:48:46  moeller
  * Bivio::Biz::Model::Email
    moved execute_load_home() to super class
  * Bivio::Biz::Model::LocationBase
    added execute_load_home()
  * Bivio::Biz::Model::UserRegisterForm
    need to iterate over roles to delete them.
    make auth iterate, not unauth_iterate_start
  * Bivio::UI::FacadeBase
    added label for SiteAdminUserList.RealmOwner.diplay_name
  * Bivio::Util::User
    added merge_users()

  Revision 9.8  2010/04/06 00:35:50  nagler
  * Bivio::Biz::Model::AdmSubstituteUserForm
    added can_substitute_user
    substitute_user now takes a Form instance so can overrided default substitute_user
  * Bivio::Biz::Model::AdmUserList
    added can_substitute_user
  * Bivio::Biz::Model::GroupUserList
    added can_substitute_user
  * Bivio::Biz::Model::SiteAdminSubstituteUserForm
    can_substitute_user now effective
  * Bivio::Biz::Model::SiteAdminSuperUserList
    NEW
  * Bivio::Biz::Model::SiteAdminUserList
    added SUBSTITUTE_USER_FORM
  * Bivio::Biz::Model::UserCreateForm
    added join_site_admin_realm configuration param
    call join_site_admin_realm if join_site_admin_realm is true
    join_site_admin_realm: don't add the user if can't load the realm (for
    db init)
  * Bivio::Biz::Model::UserLoginForm
    call can_substitute_user on the form passed in
  * Bivio::Biz::Model::UserRegisterForm
    delete RealmUser record if_unapproved_applicant_mode before
    GroupUserForm add
  * Bivio::Delegate::TaskId
    SITE_ADMIN_SUBSTITUTE_USER works for anybody with ADMIN_WRITE
    privileges, but can_substitute_user limits to ADMINISTRATOR
  * Bivio::PetShop::BConf
    added join_site_admin_realm
  * Bivio::PetShop::Util::SQL
    added SITE_ACCOUNTANT
    Create site_adm with account
  * Bivio::Type::ArrayBase
    sort_unique uses compare()
  * Bivio::Type::PrimaryIdArray
    NEW
  * Bivio::UI::XHTML::ViewShortcuts
    added can_substitute_user for list
  * Bivio::Util::RealmMail
    added anonymize_emails
    limit length of email

  Revision 9.7  2010/04/04 21:25:08  nagler
  * Bivio::Biz::Action::RealmFile
    access_is_public_only accepts realm_file, not realm, and creates realm
    instead of doing with_realm
  * Bivio::Biz::ListModel
    set_cursor for calls to internal_post_load_row
  * Bivio::Biz::Model::RealmOwner
    call clear_model_cache on any update
  * Bivio::Biz::Model::RealmRole
    call clear_model_cache on changes
  * Bivio::Delegate::NoDbAuthSupport
    rmpod
    added clear_model_cache
  * Bivio::Delegate::SimpleAuthSupport
    added clear_model_cache
  * Bivio::Search::Xapian
    don't call add_value with undef
  * Bivio::UI::XHTML::Widget::SearchForm
    default show_b_realm_only to is_group

  Revision 9.6  2010/04/03 17:26:35  nagler
  * Bivio::Auth::Realm
    caceh RealmOwner
    added clear_model_cache
  * Bivio::Biz::Model::RealmOwner
    added clear_model_cache
  * Bivio::Type::BlogFileName
    from_sql_column needs to check from_absolute
  * Bivio::Type::DocletFileName
    don't subclass FileName, because Doclets can have slashes in them
  * Bivio::Type::WikiName
    allow slashes in the names
  * Bivio::UI::XHTML::Widget::WikiText
    names can have slashes and from_absolute can't always be called on
    paths, because may be blogs

  Revision 9.5  2010/03/31 23:15:01  nagler
  * Bivio::UI::View::Mail
    added extra_tools to internal_standard_tools

  Revision 9.4  2010/03/31 16:53:47  nagler
  * Bivio::BConf
    test of http_port being odd
  * Bivio::Biz::Model::SearchList
    added display of RealmOwner.display name with a link
    (result_realm_uri) and show_byline
  * Bivio::Test::HTMLParser::Forms
    fixed comment to match code
  * Bivio::UI::View::CSS
    more margin in search results byline
  * Bivio::UI::View::Search
    added display of RealmOwner.display name with a link
    (result_realm_uri) and show_byline
  * Bivio::UI::XHTML::Widget::ClearOnFocus
    cannot use SCRIPT.  Use Tag({tag=>'script'...}) instead
  * Bivio::UI::XHTML::Widget::SearchForm
    control broken

  Revision 9.3  2010/03/17 22:33:49  nagler
  * Bivio::Biz::Action::AdminRealmMail
    misspelt EMAIL_LIST
  * Bivio::Biz::Model::SearchForm
    CLEAR_ON_FOCUS_HINT management is handled by ClearOnFocus widget in JavaScript
  * Bivio::Biz::Model::SearchList
    SearchForm is now subclass of ListQueryForm so could rip out
    parse_query_from_request.
    Added b_realm_only which allows you to constrain search to current realm
  * Bivio::Delegate::TaskId
    added GROUP_SEARCH_LIST to support b_realm_only
  * Bivio::Test::Language::HTTP
    verify that get exactly the number of messages
    verify_local_mail won't keep trying if $expect_count not supplied
  * Bivio::UI::FacadeBase
    added GROUP_SEARCH_LIST to support b_realm_only
  * Bivio::UI::View::CSS
    support b_realm_only checkbox
  * Bivio::UI::XHTML::Widget::ClearOnFocus
    Initialize the hint in the javascript
  * Bivio::UI::XHTML::Widget::SearchForm
    added b_realm_only checkbox

  Revision 9.2  2010/03/16 17:32:00  nagler
  * Bivio::Biz::Model::CRMThread
    revert to 1.20.  Can't put link in "pre_create_file", because may be
    going out to user.

  Revision 9.1  2010/03/15 17:26:46  moeller
  * Bivio::Biz::FormModel
    don't put errors on file fields if stay_on_page

  Revision 9.0  2010/03/15 03:29:54  nagler
  Switch to 9.0

  Revision 8.95  2010/03/15 03:29:14  nagler
  * Bivio::Biz::FormModel
    form_errors were not being printed unless there was a form_error_task

  Revision 8.94  2010/03/12 04:19:39  nagler
  * Bivio::Agent::Request
    added seo_uri_prefix to FORMAT_URI_PARAMETERS
  * Bivio::Agent::Task
    added unauth_execute
  * Bivio::Biz::Action::AdminRealmMail
    added format_email_for_auth_realm
  * Bivio::Biz::ListModel
    find_row_by accepts a hash for (field, value) tuples to match
  * Bivio::Biz::Model::RealmUserList
    order by RealmOwner.dispaly_name first
  * Bivio::Biz::Model::SearchList
    factored out format_uri_params_with_row
  * Bivio::PetShop::Util::SQL
    top_level_forum was not setting admin correctly
  * Bivio::UI::Task
    added seo_uri_prefix
    removed comments in parse_uri, because too complicated to be cluttered
    by comments
  * Bivio::Util::SiteForum
    added internal_post_site_create()
    create site-reports before site-admin
  * Bivio::Util::TaskLog
    b_use FacadeComponent.Task

  Revision 8.93  2010/03/10 22:57:16  moeller
  * Bivio::Util::SiteForum
    get SITE_REALM from the default facade SITE_REALM_NAME

  Revision 8.92  2010/03/10 01:43:16  moeller
  * Bivio::Util::Forum
    added delete_forum

  Revision 8.91  2010/03/08 22:52:41  moeller
  * Bivio::Auth::Role
    cache get_category_role_group
  * Bivio::Biz::Action::AdminRealmMail
    NEW
  * Bivio::Biz::Action::RealmMail
    refactoring to support AdminRealmMail
  * Bivio::Biz::Model::RoleBaseList
    don't warn on too many/no roles
  * Bivio::Delegate::TaskId
    added ADMIN_REALM_MAIL tasks
  * Bivio::UI::FacadeBase
    fix sort_third and added through ninth
    fpc
    added ADMIN_REALM_MAIL tasks
  * Bivio::Util::RealmFile
    use is_version

  Revision 8.90  2010/03/05 21:16:29  moeller
  * Bivio::Auth::Role
    added in_category_role_group
  * Bivio::Biz::Model::CRMActionList
    use GroupUserList, not RealmEmailList
  * Bivio::Biz::Model::CRMThread
    include link to CRM ticket at top of all tickets
  * Bivio::Biz::Model::ForumTreeList
    use all_members for where
  * Bivio::Biz::Model::ForumUserEditDAVList
    use GroupUserForm
  * Bivio::Biz::Model::GroupUserForm
    member and administrator roles are mutually exclusive
    security handled with role groups (can't upgrade a user to all_admins
    role if not a member of all_admins)
  * Bivio::Biz::Model::RealmMemberList
    use category_role_group
  * Bivio::Biz::Model::RealmUserAddForm
    member and administrator roles are mutually exclusive
  * Bivio::Biz::Model::RoleBaseList
    used category role groups for determining main role
  * Bivio::Biz::Model::UserSubscriptionList
    use category_role_group
  * Bivio::Biz::PropertyModel
    added unauth_rows_exist
  * Bivio::Delegate::Role
    all_users includes USER role
  * Bivio::PetShop::BConf
    member and administrator roles are mutually exclusive
  * Bivio::Test::Case
    added error_note
  * Bivio::Test::FormModel
    actual_return on Request went away
    Call error_note with get_errors on form
  * Bivio::Type::ArrayBase
    NEW
  * Bivio::Type::Array
    deprecated
  * Bivio::Type::Date
    from_unix calls SUPER::from_unix and then from_datetime
  * Bivio::Type::DateTime
    now() needs to call __PACKAGE__->from_unix, not $proto->from_unix
  * Bivio::Type::StringArray
    moved up code to ArrayBase
  * Bivio::Type::Time
    from_unix calls SUPER::from_unix and then from_datetime
  * Bivio::UI::Facade
    remove unknown facade uri error
  * Bivio::Util::Forum
    added tree_paths
  * Bivio::Util::RealmFile
    added noarchive flag
  * Bivio::Util::RealmUser
    assert too many main roles
    _assert_map must return $map
  * Bivio::Util::SiteForum
    init_files only if test
    don't call ADM directly in init_files use set_user_to_any_online_admin
  * Bivio::Util::SQL
    db_upgrade drop_member_if_administrator

  Revision 8.89  2010/02/24 14:50:18  nagler
  * Bivio::Agent::TaskEvent
    catch case of carry_path_info/query and path_info/query being set in
    return result
  * Bivio::Biz::FormModel
    carry_query not being checked in return of {carry_query => 1}; delete
    carry_query once carried.  TaskEvent now assserts
  * Bivio::Util::SQL
    added xapian_exec_realm2 upgrade to switch realm type to user from club

  Revision 8.88  2010/02/23 23:30:03  moeller
  * Bivio::Biz::FormModel
    fixed carry_query nesting

  Revision 8.87  2010/02/23 21:29:20  moeller
  * Bivio::Biz::FormModel
    Fixed ack being carried from execute_ok with a non-empty and non-hash
    return

  Revision 8.86  2010/02/23 00:21:30  nagler
  * Bivio::UI::FacadeBase
    calendar support
  * Bivio::UI::View::Calendar
    dynamically calculate height of create link in month view
  * Bivio::UI::View::CSS
    calendar has to be fixed with so renders on IE*
  * Bivio::Util::SiteForum
    don't create site-help if exists already (some apps use 'site' as help realm)

  Revision 8.85  2010/02/22 04:31:41  nagler
  * Bivio::Biz::Model::Lock
    allow passing in realm_id into acquire
  * Bivio::Biz::Model::RealmMail
    b_use
  * Bivio::Biz::Model::RealmUserAddForm
    audit user after adding
  * Bivio::Delegate::TaskId
    JOB_XAPIAN_COMMIT is now ANY_OWNER since adding xapian_exec
  * Bivio::Search::Xapian
    Q#461: lock is in own realm so we don't get
    terminate called after throwing an instance of 'Xapian::DatabaseModifiedError'
  * Bivio::Test::WikiText
    die_on_validate_error by default
  * Bivio::UI::FacadeBase
    added ThreePartPage_want_dock_left_standard
    fix up mail css
  * Bivio::UI::View::CSS
    search_results => b_search_results
    fix up mail css
  * Bivio::UI::View::Mail
    date can't be in a SPAN
  * Bivio::UI::View::ThreePartPage
    added ThreePartPage_want_dock_left_standard
  * Bivio::UI::XHTML::Widget::RealmDropDown
    cache realm_types and choices
  * Bivio::UI::XHTML::Widget::WikiText::Email
    NEW
  * Bivio::Util::RealmFile
    import_tree: if file is a mail file, use RealmMail to create
  * Bivio::Util::RealmMail
    b_use
  * Bivio::Util::SQL
    initialize_xapian_exec_realm and upgrade

  Revision 8.84  2010/02/21 17:38:48  nagler
  * Bivio::Biz::Model::AuthUserRealmList
    split can_user_execute_task to can_user_execute_task_in_any_realm and
    can_user_execute_task_in_this_realm.  Was not handling arguments
    properly before
  * Bivio::Biz::Model::CalendarEventForm
    dco
  * Bivio::Biz::Model::CalendarEventList
    added show_create_on_month_view
    can_user_* tasks were flakey
  * Bivio::Biz::Model::CalendarEventWeekList
    add is_today_*
  * Bivio::PetShop::Util::TestData
    added calendar_btest_read_only
  * Bivio::UI::FacadeBase
    calendar highlight today
  * Bivio::UI::View::Calendar
    allow create for users
    highlight today
    today highlight is at cell level to allow alternative styling
  * Bivio::UI::View::CSS
    highlight today

  Revision 8.83  2010/02/21 02:27:38  nagler
  * README
    Added BOOKKEEPING section
  * MANIFEST.html
    NEW

  Revision 8.82  2010/02/20 22:48:18  nagler
  * Bivio::Biz::Model::CalendarEventForm
    added create_date in query
  * Bivio::Biz::Model::CalendarEventWeekList
    added create_date
  * Bivio::Biz::Model::FileChangeForm
    don't set is_text_content_type if length greater than TextArea can hold
  * Bivio::Biz::Model::FilterQueryForm
    added default_date_filter & ability to default field
  * Bivio::Biz::Model::RoleBaseList
    Allow larger lists
  * Bivio::Biz::Model::TaskLogList
    Added TaskLog.client_address
    TaskLog.client_address takes precence
    set default_date_filter to WEEK
  * Bivio::Biz::Model::TaskLog
    Added TaskLog.client_address
  * Bivio::Biz::Model::UnauthCalendarEventList
    is_copy => b_is_copy
  * Bivio::PetShop::Facade::Other
    test initialize Other
  * Bivio::SQL::DDL
    Added TaskLog.client_address
    added indexes for uri and client_address to task_log
  * Bivio::Type::DateInterval
    rmpod
    rmpod
  * Bivio::Type::Date
    accept European date format
    Use $proto and internal_join/split
    support d.m.yyyy format
  * Bivio::Type::DateTime
    _join() & _split() => internal_join/split
    Put in $proto-><CONSTANT> most places
  * Bivio::UI::FacadeBase
    support for Add Event on month view of calendar
    Added TaskLog.client_address
    added desc to start/end_date
  * Bivio::UI::FacadeComponent
    added handle_init_from_prior_group to allow group aliases
    dynamically initialized values are initialized twice
  * Bivio::UI::Facade
    added init_from_prior_group to allow group aliases
  * Bivio::UI::HTML::Widget::DateYearHandler
    rmpod
    Handle '.' as a separator
    New formats: 0202 => 02/02/<year>; 020205 => 02/02/2005; 6/7/8 => 6/7/2008
    Handle century transitions properly
  * Bivio::UI::HTML::Widget::JavaScript
    cruft
  * Bivio::UI::Text
    don't do the initialization here
  * Bivio::UI::View::Calendar
    added link to create an event on a particular day in the month view
  * Bivio::UI::View::CSS
    support for Add Event on month view of calendar
    need :link to ensure b_day_of_month_create visible
    typo
  * Bivio::UI::View::TaskLog
    Added TaskLog.client_address
  * Bivio::UI::XHTML::ViewShortcuts
    vs_filter_query_form uses vs_selector_form
    modularize vs_field_description and put in a DIV, not BR()
    fpc
  * Bivio::Util::SQL
    Added TaskLog.client_address
    added indexes to task_log_client_address upgraded

  Revision 8.81  2010/02/18 00:41:05  nagler
  * Bivio::Delegate::SimpleAuthSupport
    fix caching once again
  * Bivio::Util::TaskLog
    trim $uri

  Revision 8.80  2010/02/17 23:49:03  nagler
  * Bivio::Agent::Request
    if the query is put with a string, parse it

  Revision 8.79  2010/02/17 18:41:16  nagler
  * Bivio::Delegate::SimpleAuthSupport
    all realms for user in a single query

  Revision 8.78  2010/02/17 01:59:49  nagler
  * Bivio::Agent::HTTP::Request
    call internal_call_handlers in server_redirect
  * Bivio::Agent::Request
    added internal_call_handlers to handle_server_redirect
  * Bivio::Agent::TaskEvent
    don't carry_* if there's nothing to carry
  * Bivio::Biz::Action::Acknowledgement
    Register for handle_server/client_redirect so ack carried properly
  * Bivio::Biz::ExpandableListFormModel
    don't rely on buttons passed to internal_pre_execute
  * Bivio::Biz::FormContext
    carry query properly in the event of context
  * Bivio::Biz::FormModel
    refactored execute_ok handling (both direct calls and http processing)
    internal_post_execute is called in all cases now
    deal with carrying query on Acknowledgements
  * Bivio::Biz::ListModel
    b_use and fmt
  * Bivio::Biz::Model::CalendarEventForm
    used 'acknowledgement' attribute on return to FormModel
  * Bivio::PetShop::View::Base
    dynamic dock
  * Bivio::UI::FacadeBase
    ack for USER_SETTINGS_FORM
  * Bivio::UI::HTML::ViewShortcuts
    removed vs_acknowledgement
  * Bivio::UI::View::ThreePartPage
    factor out vs_rss_task_in_head()
  * Bivio::UI::XHTML::ViewShortcuts
    added vs_rss_task_in_head to share with Page3
  * Bivio::UI::XHTML::Widget::Acknowledgement
    use extract_and_delete_label
    Fix up calling structure for Widgets
  * Bivio::UI::XHTML::Widget::Pager
    fmt

  Revision 8.77  2010/02/15 22:37:05  moeller
  * Bivio::UI::HTML::Widget::Radio
    made XHTML conformant
  * Bivio::UI::HTML::Widget::ScriptOnly
    escape < and / per w3 validator
  * Bivio::UI::View::Wiki
    fixed script type
    set head title for help() for xhtml validator
    use vs_text_as_prose() for WikiValidator labels
  * Bivio::UI::XHTML::Widget::HelpWiki
    no spaces in javascript: href
  * Bivio::UI::XHTML::Widget::MainErrors::WikiValidator
    use vs_text_as_prose() for WikiValidator labels

  Revision 8.76  2010/02/08 01:17:20  nagler
  * Bivio::UI::FacadeBase
    old_password, new_password, confirm_new_password at outerlevel
    fpc

  Revision 8.75  2010/02/07 23:57:37  nagler
  * Bivio::Agent::Task
    accept an array for permissions_spec
    accept a hash for attributes
  * Bivio::Agent::t::Mock::TaskId
    accept an array for permissions_spec
    accept a hash for attributes
  * Bivio::Biz::Model::GroupUserForm
    roles_by_category could be undef so don't assume set
  * Bivio::Delegate::SimpleTaskId
    added _merge_modifiers which allows applications to modify an existing
    task's config instead of having to copy it.
  * Bivio::Delegate::TaskId
    fix permissions on BLOG (only need FEATURE_BLOG not alos ANYBODY(implied)
  * Bivio::PetShop::Delegate::TaskId
    use task modifiers
  * Bivio::UI::FacadeBase
    support for UserAuth
  * Bivio::UI::View::Base
    turn on first_focus using page3_body_first
  * Bivio::UI::View::CSS
    pass $source to internal_site_css
  * Bivio::UI::View::UserAuth
    move all text except unapproved_applicant_mail to Facade
  * Bivio::UI::ViewShortcuts
    vs_ui_wiki();
  * Bivio::UI::XHTML::Widget::Page3
    added page3_body_first

  Revision 8.74  2010/02/07 19:12:28  nagler
  * Bivio::Biz::Model::CalendarEventMonthList
    b_month is now correctly initialzied CalendarEventForm
  * Bivio::Biz::Model::RealmFileTreeList
    cleaned up permissions
    some formatting
  * Bivio::Delegate::TaskId
    added write_task to FORUM_FILE_TREE_LIST

  Revision 8.73  2010/02/07 00:56:53  nagler
  * Bivio::Biz::Model::CalendarEventDayList
    detail_uri not needed
  * Bivio::Biz::Model::CalendarEventForm
    return to the calendar page which has the date fo the first event
  * Bivio::Biz::Model::CalendarEventMonthForm
    encapsulate beginning_of_month in CalendarEventMonthDate
  * Bivio::Biz::Model::MonthList
    encapsulate beginning_of_month in CalendarEventMonthDate
  * Bivio::PetShop::Util::SQL
    init_calendar_btest
    removed "Created $user"
  * Bivio::PetShop::Util::TestData
    added init_calendar_btest and reset_calendar_btest
  * Bivio::Test::HTMLParser::Links
    don't record link if there's an onclick and href=#
  * Bivio::Test::Language::HTTP
    added date_time_now(), follow_menu_link() (name may change), and case_tag()
  * Bivio::Type::CalendarEventMonthDate
    NEW
  * Bivio::Type::DateTime
    TEST_NOW_QUERY_KEY added
    set_date_time now returns the now it sets
  * Bivio::UI::FacadeBase
    minor calendar support
  * Bivio::UI::HTML::Widget::JavaScript
    unique_html_id
  * Bivio::UI::View::Calendar
    When editing or in detail, go to the forum, not user realm
  * Bivio::UI::XHTML::ViewShortcuts
    id's are generated dynamically by JavaScript
  * Bivio::UI::XHTML::Widget::ComboBox
    id's are generated dynamically by JavaScript
  * Bivio::UI::XHTML::Widget::DropDown
    id's are generated dynamically by JavaScript
  * Bivio::UI::XHTML::Widget::RealmDropDown
    id's are generated dynamically by JavaScript
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    id's are generated dynamically by JavaScript
  * Bivio::UI::XHTML::Widget::TaskMenu
    id's are generated dynamically by JavaScript
  * Bivio::Util::HTTPStats
    backticks to piped_exec
  * Bivio::Util::Release
    remove reference to customer
  * Bivio::Util::SQL
    init_realm_role_with_config accepts a string also

  Revision 8.72  2010/02/03 23:24:57  nagler
  * Bivio::UI::View::CSS
    changed dd_menu top to 3ex for MSIE

  Revision 8.71  2010/02/03 17:44:24  nagler
  * Bivio::UI::Font
    use ->req, not  in FacadeComponent.Font->format_html
  * Bivio::UI::HTML::Widget::FormButton
    use ->req, not  in FacadeComponent.Font->format_html
  * Bivio::Util::SiteForum
    init_forum

  Revision 8.70  2010/01/29 18:35:12  nagler
  * Bivio::Biz::Model::RealmRole
    always initialize default permission map
  * Bivio::Biz::Util::RealmRole
    initialize_permissions called always on edit()
    category_role_group
  * Bivio::Util::HTTPLog
    only check for 0 length error file on production

  Revision 8.69  2010/01/28 22:15:30  nagler
  * Bivio::Biz::ListModel
    _load_this() will continue if first_only and no this
  * Bivio::PetShop::Test::PetShop
    delete realms created in test (user delete not work yet)
  * Bivio::Test::Language::HTTP
    login is either Email or User
  * Bivio::Test::Language
    pass $die to handle_cleanup
  * Bivio::Util::RealmAdmin
    delete_auth_realm
    deprecate delete_user (delete_auth_user) & delete_with_users (delete_auth_realm_and_users)

  Revision 8.68  2010/01/28 17:47:44  nagler
  * Bivio::Biz::Model::ForumForm
    internal_post_realm_create
  * Bivio::Delegate::TaskId
    event_list_ics works for ANY_OWNER
  * Bivio::Type::TimeZone
    default is configured
  * Bivio::Util::SQL
    print run_date_time of upgrade_db which already ran

  Revision 8.67  2010/01/27 20:04:35  nagler
  * Bivio::PetShop::Facade::PetShop
    fixed subtle bug in FacadeComponent.Text
  * Bivio::UI::FacadeBase
    fixed subtle bug in FacadeComponent.Text
  * Bivio::UI::Text
    fixed subtle bug in FacadeComponent.Text

  Revision 8.66  2010/01/27 06:21:19  nagler
  * Bivio::Biz::FormModel
    minor error msg fmt
  * Bivio::Biz::Model::RealmFeatureForm
    feature_file is implicit
  * Bivio::Parameters
    added ability for defaulting repeating parameter with an array
  * Bivio::PetShop::Util::SQL
    fourem-sub2 is now mail_want_reply_to => 0
  * Bivio::UI::FacadeBase
    task_menu sorting support
    Calendar.want_b_time_zone
  * Bivio::UI::HTML::Widget::DateTime
    b_use
    UI not FacadeComponent
  * Bivio::UI::View::Calendar
    don't display b_time_zone if want_b_time_zone is false
  * Bivio::UI::XHTML::Widget::FeatureTaskMenu
    test want_sorting
  * Bivio::UI::XHTML::Widget::TaskMenu
    added want_sorting and show_current_task
  * Bivio::Util::HTTPLog
    die if error_file is an empty file
  * Bivio::Util::RowTag
    list: return a hash instead of formatting
  * Bivio::Util::SiteForum
    init_realms, init_files, and realm_names deprecated.  Use forum_config and init_forums
    fpc
    fpc
    fpc
    fpc
    revert init_forums, init_realms, init_files and forum_config
  * Bivio::t::Parameters::T1
    added ability for defaulting repeating parameter with an array

  Revision 8.65  2010/01/25 03:28:41  nagler
  * Bivio::Agent::Request
    removed incorrect internal_get_realm_for_task optimization
    realm_cache => cache_for_auth_realm
    Added cache_for_auth_user
    fixed internal_get_realm_for_task for odd case
  * Bivio::Biz::ListFormModel
    internal_put_field handles multiple values
  * Bivio::Biz::Model::AuthUserGroupList
    UserSubscriptionList now subclasses AuthUserGroupList; subscribed? now means can user execute FORUM_MAIL_THREAD_ROOT_LIST?
  * Bivio::Biz::Model::AuthUserGroupSelectList
    need to eval the select as prose
  * Bivio::Biz::Model::AuthUserRealmList
    added can_user_execute_task
  * Bivio::Biz::Model::CalendarEventDayList
    NEW
  * Bivio::Biz::Model::CalendarEventDeleteForm
    loaded RealmOwner.display_name as well
  * Bivio::Biz::Model::CalendarEventForm
    load_all_for_task defaults date
    moved time_zone_selector code to TimeZoneList
  * Bivio::Biz::Model::CalendarEventList
    added can_user_edit_any_realm
    cleaner time_zone support
  * Bivio::Biz::Model::CalendarEventMonthForm
    NEW
  * Bivio::Biz::Model::CalendarEventMonthList
    Categorizes into weeks
    Brackets dates around weeks
    Added is_list_view, this_month
    put b_month on the query
    time_zone support
  * Bivio::Biz::Model::CalendarEventWeekList
    NEW
  * Bivio::Biz::Model::Forum
    rm#
  * Bivio::Biz::Model::ForumForm
    allow internal_admin_user_id to be passed and overridden
  * Bivio::Biz::Model::ListQueryForm
    allow overrides in internal_query_fields
    print error when no order_by_names
  * Bivio::Biz::Model::MonthList
    look up names in facade
    allow caller to set date
    added this_month as first item
  * Bivio::Biz::Model::QuerySearchBaseForm
    removed internal_pre_execute
    Added defaulting of values in execute_ok
  * Bivio::Biz::Model::RealmFeatureForm
    Use Type.row_tag_replace/get and check ROW_TAG_KEY
  * Bivio::Biz::Model::RealmUserAddForm
    $admin_user_id could be an array_ref (allows [] for none)
  * Bivio::Biz::Model::RowTag
    Default primary_id if undef
  * Bivio::Biz::Model::SearchList
    cruft
  * Bivio::Biz::Model::SelectMonthForm
    removed
  * Bivio::Biz::Model::TimeZoneList
    added enum_for_display_name & display_name_for_enum
  * Bivio::Biz::Model::UserSettingsListForm
    added time_zone
  * Bivio::Biz::Model::UserSubscriptionList
    UserSubscriptionList now subclasses AuthUserGroupList; subscribed? now means can user execute FORUM_MAIL_THREAD_ROOT_LIST?
    load_all was getting in deep recursion b/c looped back
  * Bivio::Biz::Model
    allow passing in overrides in field_decl
  * Bivio::ClassWrapper::TupleTag
    realm_cache => cache_for_auth_realm
  * Bivio::Collection::Attributes
    added get_and_delete
  * Bivio::Delegate::SimpleWidgetFactory
    added DateTimeWithTimeZone
    added support for TimeZoneSelector
  * Bivio::Delegate::TaskId
    reorganized calendar tasks. list/month views the same
  * Bivio::IO::Alert
    show both datetime and to_string versions in formatting
  * Bivio::Parameters
    do not return [undef] for optional repeatable parametres
  * Bivio::ShellUtil
    don't set the facade in initialize_ui if already set
  * Bivio::Type::Date
    b_use
  * Bivio::Type::DateTime
    refactored so _split() and _join() are used to split/join date/time parts
    added set_beginning/end_of_day
    added set_beginning/end_of_week & do_iterate
    bug in error message
  * Bivio::Type::DateTimeWithTimeZone
    NEW
  * Bivio::Type::MailWantReplyTo
    removed row_tag_get/replace_value.  Use Type->row_tag_*
  * Bivio::Type::RealmArg
    check email, too
  * Bivio::Type::TimeZone
    added ROW_TAG_KEY
  * Bivio::Type::TimeZoneSelector
    NEW
  * Bivio::Type
    cleaned up row_tag_* interface
  * Bivio::UI::FacadeBase
    dock left is now FeatureTaskMenu()
    reorganized calendar tasks
    added colors and fonts for calendar so can be overriden within facade
    fixed up Forum uses
    Added hooks in facade for calendar formatting
    time zone support in calendar
  * Bivio::UI::HTML::Widget::DateYearHandler
    onBlur => onblur
  * Bivio::UI::HTML::Widget::Script
    set autocomplete set on combobox
  * Bivio::UI::HTML::Widget::Select
    better error when no primary_keys
  * Bivio::UI::View::CSS
    added colors and fonts for calendar so can be overriden within facade
    support for vs_selector_form
    Added hooks in facade for calendar formatting
  * Bivio::UI::View::Calendar
    month and list views merged into one with a switch off CalendarEventMonthList
    Removed business logic for rendering in the views
    don't select anything in tools on month & list view
    added time zone support
  * Bivio::UI::View::UserAuth
    added time_zone
  * Bivio::UI::ViewLanguage
    added missing OUR($_TRACE);
  * Bivio::UI::XHTML::ViewShortcuts
    added vs_selector_form
    vs_selector_form is a POST, not GET
    vs_selector: wrap in b_item DIVs and class b_selector
  * Bivio::UI::XHTML::Widget::ComboBox
    AUTOCOMPLETE is not a valid attribute
  * Bivio::UI::XHTML::Widget::FeatureTaskMenu
    NEW
  * Bivio::UI::XHTML::Widget::RealmDropDown
    added internal_control_value for subclasses
  * Bivio::UI::XHTML::Widget::TaskMenu
    fmt
  * Bivio::Util::RealmAdmin
    added diff_users
  * Bivio::Util::RealmDAG
    NEW
  * Bivio::Util::SQL
    added mail_want_reply_to_default
  * Bivio::t::Parameters::T1
    do not return [undef] for optional repeatable parametres

  Revision 8.64  2010/01/21 21:05:04  moeller
  * Bivio::Agent::Request
    can_user_execute_task accepts a Task as sell now
  * Bivio::Agent::t::Mock::Facade::Mock
    define Constant and Color
  * Bivio::Biz::FormModel
    Added get_default_value() which computes the value dynamically if a CODE
    internal_put_error/_and_detail accepts undef, which causes internal_clear_error
  * Bivio::Biz::ListModel
    unsafe_load_this does not die if no "this" on query
  * Bivio::Biz::Model::BlogList
    add get_rss_title
  * Bivio::Biz::Model::CalendarEventDAVList
    better modularization
    Introduced DateTime->ical
  * Bivio::Biz::Model::CalendarEventDeleteForm
    load the CalendarEvent from the request
  * Bivio::Biz::Model::CalendarEventForm
    Handles user vs group execution so that user sees aggregate of groups
    Added recurring events and copying
    Standards time_zone handling
    Added acknowledgements
  * Bivio::Biz::Model::CalendarEventList
    limit the query to AuthUserGroupList
  * Bivio::Biz::Model::CalendarEventMonthList
    date pushed up into CalendarEventList
  * Bivio::Biz::Model::CalendarEvent
    default values in create() properly
    moved update_from_ics from CalendarEventList
  * Bivio::Biz::Model::ForumTreeList
    removed internal_extend_where since internal_prepare_statement is sufficient
  * Bivio::Biz::Model::QuerySearchBaseForm
    call get_default_value b/c default_value could be dynamically computed
  * Bivio::Biz::Model::RealmDAG
    use maps to get packages indirectly
  * Bivio::Biz::Model::RealmUserAddForm
    require context
  * Bivio::Biz::Model::SelectMonthForm
    default_value dynamically computed
  * Bivio::Biz::PropertyModel
    Added assert_properties, load_from_properties, and get_qualified_field_name_list
  * Bivio::Collection::Attributes
    added unsafe_get_and_delete
  * Bivio::Delegate::SimpleAuthSupport
    cache permissions for realms and load permissions for entire realm at once
    added missing our($_TRACE)
  * Bivio::Delegate::SimpleTypeError
    removed INVALID_END_DATETIME
  * Bivio::Delegate::SimpleWidgetFactory
    added display support for HTTPURI (Link(String()))
    added internal_default_want_parens()
  * Bivio::Delegate::TaskId
    added FORUM_CALENDAR_EVENT_LIST and FORUM_CALENDAR_EVENT_LIST_ICS
  * Bivio::Parameters
    allow declarations with qualified type names (Auth.Role and Bivio::Auth::Role)
  * Bivio::PetShop::Facade::PetShop
    my_site_redirect_map needs to return array_ref from code_ref
  * Bivio::PetShop::Util::SQL
    no need for demo_calendar
  * Bivio::SQL::Support
    added extract_column_name
  * Bivio::Test::Case
    added tags
  * Bivio::Test::Unit
    added case_tag
    builtin_self returns $_SELF, not $_TYPE, because $_TYPE is not
    necessarily a subclass of Test.Unit (Test.Request only case at this time)
  * Bivio::Test
    added case_tag
  * Bivio::Type::DateTime
    added set_beginning_of_month
    b_use
    to_string accepts timezone name (probably should accept TimeZone object)
  * Bivio::Type::TimeZone
    added as_display_name
  * Bivio::Type
    added is_greater_than, is_greater_than_or_equals, is_less_than, is_less_than_or_equals
  * Bivio::UI::Constant
    subclass Text
  * Bivio::UI::FacadeBase
    reset_pre line-height: 100% (used to be 60%)
    cleaned up AtomFeed support
    Added more CalendarEvent support
  * Bivio::UI::Text
    Can be subclassed by other components which don't always bind to text
  * Bivio::UI::View::Calendar
    major revamp to support recurring events
    cleaned up formatting of event_detail
    link generation better
  * Bivio::UI::View::CSS
    added b_literal
    support for labels/fields on .simple layouts, not just "form"
  * Bivio::UI::View::GroupAdmin
    user_list() now accepts a list model name so applications can reuse this view with subclasses of GroupUserList
  * Bivio::UI::View::Mail
    always show links for attachments even if has CID
  * Bivio::UI::XHTML::ViewShortcuts
    downcase tag in view_autoload
    added vs_label_cell
  * Bivio::UI::XHTML::Widget::TaskMenu
    grep out task_id, don't assume it is first element in FORMAT_URI_PARAMETERS
  * Bivio::UI::XML::Widget::AtomFeed
    cleaned up structure to better support calendaring
  * Bivio::UI::XML::Widget::DateTime
    allow alternative renderings (to_ical)
  * Bivio::UI::XML::Widget::String
    allow undef values like HTMLWidget.String
  * Bivio::Util::SQL
    added user_feature_calendar bundle

  Revision 8.63  2009/12/30 22:39:19  moeller
  * Bivio::Biz::Model::GroupUserForm
    fixed old/new comparison
  * Bivio::Biz::Model::GroupUserQueryForm
    added internal_roles() for subclasses

  Revision 8.62  2009/12/29 23:46:45  moeller
  * Bivio::Biz::Model::GroupUserList
    can_show_row in user_list can't work
  * Bivio::Biz::Model::UserLoginForm
    print a warning if pass RealmOwner.password and not validated
  * Bivio::Delegate::SimpleWidgetFactory
    change order of overrides in wf_list_link
  * Bivio::Type::MailWantReplyTo
    not NullBoolean
  * Bivio::Type::RealmFeature
    not NullBoolean
  * Bivio::UI::View::GroupAdmin
    can_show_row in user_list can't work
  * Bivio::UI::XHTML::Widget::ComboBox
    default auto_submit => 0
  * Bivio::UI::XHTML::Widget::ForumDropDown
    RealmDropDown now expects a list of realm_types in DEFAULT_REALM_TYPES
    DEFAULT_REALM_TYPE renamed to DEFAULT_REALM_TYPES
  * Bivio::UI::XHTML::Widget::RealmDropDown
    RealmDropDown now expects a list of realm_types in DEFAULT_REALM_TYPES
    DEFAULT_REALM_TYPE renamed to DEFAULT_REALM_TYPES

  Revision 8.61  2009/12/29 02:29:20  nagler
  * Bivio::Agent::Request
    added set_realm_unless_same
  * Bivio::Agent::Task
    sorted methods
    added get_attr_as_task
  * Bivio::Auth::Realm
    added equals_by_name_or_id
  * Bivio::Biz::Model::AdmRealmRoleList
    NEW
  * Bivio::Biz::Model::ForumForm
    moved internal_use_general_realm_for_site_admin up to RealmFeatureForm
  * Bivio::Biz::Model::GroupUserList
    added can_show_row and can_change_privileges
    default privs to get_short_desc
  * Bivio::Biz::Model::RealmFeatureForm
    added IMPLICIT_FEATURE_TYPE_MAP and force_default_values
    added ALL_FEATURES_WHICH_ARE_CATEGORIES
  * Bivio::Biz::Model::RealmFile
    make init_realm safe against reinit
  * Bivio::Biz::Util::RealmRole
    added is_category
  * Bivio::Delegate::Role
    cache MAP
    uncache map, becuse subclasses may modify
  * Bivio::Delegate::SimpleWidgetFactory
    added control to wf_list_link
  * Bivio::Die
    use fixup_perl_error to produce better error messages
  * Bivio::IO::Alert
    added fixup_perl_error to produce better syntax error messages
  * Bivio::PetShop::Model::AdmSubstituteUserForm
    NEW
  * Bivio::PetShop::View::UserAuth
    added adm_substitute_user to test ComboBox
  * Bivio::SQL::DDL
    added indexes on RowTag.value and TaskLog.date/super_user_id
  * Bivio::Test
    allow IGNORE_RETURN to work for compute_params so
    Unit.builtin_inline_case works
  * Bivio::Type::Array
    added to_hash
  * Bivio::UI::Facade
    added matches_uri_or_domain & find_by_uri_or_domain
    added matches_class_name
  * Bivio::UI::FacadeBase
    added is_special_realm_name
  * Bivio::UI::HTML::Widget::Script
    added escape_html & use in combobox
  * Bivio::UI::JavaScript::Widget::QuotedValue
    do the work in render
  * Bivio::UI::Mail::Widget::Mailbox
    added NEW_ARGS
  * Bivio::UI::View::GroupAdmin
    share better with _feature_form
    parameterize forum_form
  * Bivio::UI::ViewLanguage
    use ClassLoader->call_method so can have Map_Class() form
  * Bivio::UI::ViewShortcuts
    added vs_is_current_facade
  * Bivio::UI::Widget
    added is_initialized
  * Bivio::UI::XHTML::Widget::ComboBox
    refactored and allow list_display_field to be any value, not just a field
  * Bivio::UI::XHTML::Widget::RealmDropDown
    make _one_choice() support all realms with owners
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    export the TASK_MENU_LIST to allow overrides
  * Bivio::UI::XHTML::Widget::TaskMenu
    fmt
  * Bivio::UI::XHTML::Widget::XLink
    fmt
  * Bivio::Util::SQL
    added index_20091227
    use RealmFeatureForm.force_default_values to setup of club & forum

  Revision 8.60  2009/12/27 02:03:39  nagler
  * Bivio::Auth::Role
    introduced realm role categories
  * Bivio::BConf
    introduced realm role categories
  * Bivio::Biz::Action::RealmMail
    MailWantReplyTo change
  * Bivio::Biz::Action::WikiView
    added config option to create default start page
  * Bivio::Biz::FormModel
    added internal_post_parse_columns
  * Bivio::Biz::Model::EditDAVList
    added view_shortcuts to dav_reply_get
  * Bivio::Biz::Model::Forum
    removed is_public_email (Categories) and want_reply_to (now RowTag)
  * Bivio::Biz::Model::ForumEditDAVList
    removed is_public_email (Categories) and want_reply_to (now RowTag)
  * Bivio::Biz::Model::ForumForm
    UI now creates forums via RealmFeatureForm, feature_wiki is always on, feature_crm is always off
    share better with RealmFeatureForm
    fixed top_forum name change error return
  * Bivio::Biz::Model::ForumList
    removed is_public_email (Categories) and want_reply_to (now RowTag)
  * Bivio::Biz::Model::MailForm
    mail_want_reply_to
  * Bivio::Biz::Model::RealmFeatureForm
    UI now creates forums via RealmFeatureForm, feature_wiki is always on, feature_crm is always off
    generalized interface so can be subclassed easily
    execute_empty and execute_ok behave properly in all cases
    introduced row_tag_replace_value & row_tag_get_value APIs
    introduced as_realm_role_category
  * Bivio::Biz::Util::RealmRole
    Added category role groups and set arithmetic (*everybody-all_admins)_
  * Bivio::Delegate::Role
    added role groups
  * Bivio::Delegate::RowTagKey
    added MAIL_WANT_REPLY_TO
  * Bivio::Delegate::SimpleRealmName
    unsafe_from_uri must test SPECIAL_PLACEHOLDER first b/c may be shorter
    than get_min_width
  * Bivio::Delegate::TaskId
    added FORUM_EDIT_FORM
    fixed REALM_FEATURE_FORM
  * Bivio::PetShop::Delegate::Role
    rmpod
    b_use
  * Bivio::PetShop::Test::PetShop
    create_crm/_forum implementation changed due to MAIL_WANT_REPLY_TO changes
  * Bivio::PetShop::Util::SQL
    mail_want_reply_to
    wiki_bunit => bunit_wiki
  * Bivio::SQL::DDL
    removed is_public_email (Categories) and want_reply_to (now RowTag)
  * Bivio::Test::WikiText
    bunit_wiki name change
  * Bivio::Type::Array
    added sort_unique and map_sort_map
  * Bivio::Type::ForumEmailMode
    removed
  * Bivio::Type::ForumName
    set get_min_width
  * Bivio::Type::MailSendAccess
    NEW
  * Bivio::Type::MailWantReplyTo
    NEW
  * Bivio::Type::RealmFeature
    NEW
  * Bivio::Type::String
    check get_min_width if non-zero
  * Bivio::Type::SyntacticString
    need to not call SUPER, because of get_min_width check
  * Bivio::Type::WantReplyTo
    removed
  * Bivio::Type::WikiName
    added DEFAULT_START_PAGE
  * Bivio::UI::FacadeBase
    UI now creates forums via RealmFeatureForm, feature_wiki is always on, feature_crm is always off
    fpc
    removed is_public_email (Categories) and want_reply_to (now RowTag)
    Added vs_ui_forum(); so all uses of Forum can be switched
  * Bivio::UI::HTML::Widget::Checkbox
    bumped Prose() on label down to v5
  * Bivio::UI::View::GroupAdmin
    NEW
  * Bivio::UI::View::GroupUser
    removed
  * Bivio::UI::ViewShortcuts
    Added vs_ui_forum(); so all uses of Forum can be switched
  * Bivio::UI::XHTML::ViewShortcuts
    added vs_descriptive_field_no_label
  * Bivio::UI::XHTML::Widget::RealmDropDown
    drop down label is Prose()
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    moved create_forum and configure_features out
  * Bivio::UI::XHTML::Widget::TaskMenu
    label is Prose
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    is_inline_text
  * Bivio::UI::XML::Widget::Page
    text/xml
  * Bivio::Util::CRM
    mail_want_reply_to change
  * Bivio::Util::SQL
    mail_want_reply_to upgrade (drops Forum.is_public_email/want_reply_to)
  * Bivio::Util::SiteForum
    mail_want_reply_to change

  Revision 8.59  2009/12/23 17:12:59  moeller
  * Bivio::BConf
    expand to include more text on httplog
  * Bivio::Biz::Random
    validate length is an integer
  * Bivio::IO::ClassLoader
    call_autoload: improve error message
  * Bivio::Test::Language
    ignore wide-print warnings
  * Bivio::Test::Unit
    added builtin_clear_local_mail and builtin_verify_local_mail
  * Bivio::UI::FacadeBase
    simplify labels for realm features
  * Bivio::UI::View::CSS
    added .bold, .underline, .italic/s
    set position:relative for .selector
    added separate css for combobox dropdown menu
  * Bivio::UI::Widget
    improve error message
  * Bivio::UI::XHTML::Widget::ComboBox
    use cb_menu class instead of dd_menu
  * Bivio::UI::XHTML::Widget::WikiText
    added ability to chain classes, e.g. div.c1.c2 produces <div class="c1 c2">
  * Bivio::Util::HTTPLog
    trim pager emails and include more info
    substr right before sending the email

  Revision 8.58  2009/12/18 22:39:48  dobbs
  * Bivio::Biz::Model::RealmFeatureForm
    require context
  * Bivio::UI::FacadeBase
    change to Verdana as default font
    enable specialization of SiteAdminDropDown within standard dock_left
  * Bivio::UI::XHTML::Widget::TaskMenu
    renamed want_more_count to want_more_threshold for clarity

  Revision 8.57  2009/12/17 15:30:54  moeller
  * Bivio::UI::HTML::Widget::Table
    fixed even and odd rows so renders classes properly
  * Bivio::UI::View::CSS
    b_even/odd_row rename
  * Bivio::UI::View::Search
    search_results => b_search_results
  * Bivio::UI::XHTML::ViewShortcuts
    vs_table_attrs() shouldn't default even/odd classes, Table() does that
  * Bivio::UI::XHTML::Widget::TaskMenu
    want_more/_count should be dynamic
    refactored code into _want_more() to make more readable
  * Bivio::UI::XHTML::Widget::WikiText
    need to pass ViewShortcuts to render_html

  Revision 8.56  2009/12/16 18:46:12  dobbs
  * Bivio::UI::FacadeBase
    added control to configure_features xlink
  * Bivio::Util::HTTPLog
    added apache2 log location

  Revision 8.55  2009/12/15 23:20:03  dobbs
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    renamed edit_features to configure_features
  * Bivio::UI::FacadeBase
    renamed edit_features to configure_features
    add email_mode to RealmFeatureForm
  * Bivio::Biz::Model::RealmFeatureForm
  * Bivio::UI::View::GroupUser
    add email_mode to RealmFeatureForm

  Revision 8.54  2009/12/14 18:23:03  dobbs
  * Bivio::Delegate::TaskId
  * Bivio::UI::FacadeBase
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    added Create Forum and Edit Features to SiteAdminDropdown
  * Bivio::Mail::Outgoing
    allow missing To:

  Revision 8.53  2009/12/14 03:29:36  nagler
  * Bivio::IO::ClassLoader
    reduce tracing.  showing cached values made tracing useless
  * Bivio::PetShop::View::Example
    added ProgressBar test
  * Bivio::UI::FacadeBase
    support progress bar and sorting
  * Bivio::UI::HTML::Widget::ClearDot
    xhtml
  * Bivio::UI::HTML::Widget::ControlBase
    ViewShortcuts
  * Bivio::UI::HTML::Widget::ProgressBar
    rmpod
    xhtml
  * Bivio::UI::HTML::Widget::Table
    added b_sort_arrow class
  * Bivio::UI::View::CSS
    support progress bar and sorting
  * Bivio::UI::ViewLanguage
    msg
  * Bivio::UI::ViewShortcutsBase
    rmpod
    fmt

  Revision 8.52  2009/12/13 19:24:05  nagler
  * Bivio::BConf
    No more facade children
  * Bivio::Delegate::SimpleFacadeChildType
    removed
  * Bivio::IO::Config
    No more facade children
  * Bivio::UI::Facade
    No more facade children
  * Bivio::UI::FacadeChildType
    removed
  * Bivio::UI::HTML::Widget::Table
    intialize all rows with classes
  * Bivio::UI::TableRowClass
    rmpod
    fmt

  Revision 8.51  2009/12/13 00:53:30  nagler
  * Bivio::IO::ClassLoader
    cruft
  * Bivio::ShellUtil
    don't check for Model.RealmFile unless imported already
  * Bivio::UI::FacadeComponent
    don't import Facade

  Revision 8.50  2009/12/12 21:55:56  nagler
  * Bivio::Agent::HTTP::Dispatcher
    call set_handlers, not push_handlers (doesn't work on Apache2)
  * Bivio::Biz::Model::RealmFeatureForm
    enable xhtml_dock_left_standard for non-fourm realms
  * Bivio::PetShop::Facade::BeforeOther
    NEW
  * Bivio::PetShop::Facade::Other
    test make_groups() and data sharing across calls
  * Bivio::PetShop::Facade::PetShop
    test make_groups() and data sharing across calls
  * Bivio::UI::Constant
    b_use
  * Bivio::UI::Facade
    make_groups was clobbering data
    b_use
  * Bivio::UI::FacadeBase
    enable xhtml_dock_left_standard for non-fourm realms
  * Bivio::UI::FacadeComponent
    copy config and clone data to avoid clobbering passed in values
    b_use
  * Bivio::UI::Font
    fmt
  * Bivio::UI::HTML
    b_use
  * Bivio::UI::Text
    b_use
  * Bivio::UI::XHTML::Widget::TaskMenu
    Added want_more and want_more_count.  Menu items over the want_more_count (default=5) are rendered in the 'more' DropDown menu
  * Bivio::UNIVERSAL
    added is_subclass
  * Bivio::Util::HTTPLog
    rmpod
    include first part of hostname in Subject:

  Revision 8.49  2009/12/10 00:28:46  nagler
  * Bivio::Biz::Model
    added new_other_with_query & handle_call_autoload
  * Bivio::IO::ClassLoader
    IO.ClassLoader->call_autoload API change: allow $no_match to be a list
    of maps to search
  * Bivio::ShellUtil
    unauth_/model use IO.ClassLoader->call_autoload
  * Bivio::Test::Language
    moved AUTOLOAD to Test.LanguageWrapper
  * Bivio::Test::LanguageWrapper
    NEW
  * Bivio::Test::Unit
    unauth_/model use Biz.Model->new_other_with_query
  * Bivio::Type
    IO.ClassLoader->call_autoload API change
  * Bivio::Util::t::Shell::T1
    IO.ClassLoader->call_autoload API change

  Revision 8.48  2009/12/08 21:22:09  aviggio
  * Bivio::Biz::Model::ForumForm
    revert $_MODELS to sub REALM_MODELS

  Revision 8.47  2009/12/08 18:18:29  nagler
  * Bivio::Agent::Task
    any_group => any_owner
  * Bivio::Auth::RealmType
    USER is part of ANY_GROUP
    b_use
    any_group => any_owner
  * Bivio::BConf
    added feature_file & feature_group_admin
  * Bivio::Biz::Model::ForumForm
    added task to edit realm features
  * Bivio::Biz::Model::RealmFeatureForm
    NEW
  * Bivio::Biz::Util::RealmRole
    added do_super_users()
  * Bivio::Delegate::RealmType
    any_group => any_owner
  * Bivio::Delegate::SimplePermission
    added FEATURE_GROUP_ADMIN
  * Bivio::Delegate::TaskId
    required FEATURE_GROUP_ADMIN for all group_admin tasks
    required FEATURE_SITE_ADMIN for SITE_ADMIN_SUBSTITUTE_USER_DONE
    added task to edit realm features
    any_group => any_owner
  * Bivio::PetShop::Test::PetShop
    test 100+ byte message ids
  * Bivio::PetShop::Util::SQL
    demo gets feature_file
  * Bivio::SQL::DDL
    message_id is 255
  * Bivio::Type::MACAddress
    NEW
  * Bivio::Type::MessageId
    message_id is 255
  * Bivio::UI::FacadeBase
    added task to edit realm features
  * Bivio::UI::Task
    any_group => any_owner
  * Bivio::UI::View::GroupUser
    added task to edit realm features
  * Bivio::Util::SQL
    internal_upgrade_db_feature_group_admin
    add_permissions_to_realm_type
    message_id_255 upgrade

  Revision 8.46  2009/12/07 04:08:06  nagler
  * Bivio::UI::FacadeBase
    added task_menu_selected
  * Bivio::UI::HTML::Widget::Script
    added b_element_by_class and b_has_class
  * Bivio::UI::View::CSS
    added dd_visible & dd_hidden
  * Bivio::UI::View::ThreePartPage
    copy body_class to xhtml_body_class
  * Bivio::UI::XHTML::Widget::DropDown
    use b_element_by_class() in javascript to find classes and toggle
  * Bivio::UI::XHTML::Widget::RealmDropDown
    added DIV_task_menu_wrapper temporarily so CSS.pm does the right thing

  Revision 8.45  2009/12/05 05:38:32  nagler
  * Bivio::Biz::FormModel
    make copy of form values
  * Bivio::Biz::Model::EditDAVList
    b_use and format
  * Bivio::Biz::Model::ForumEditDAVList
    b_use and format
  * Bivio::Biz::Model::ForumForm
    renamed features to categories to be consistent (they aren't just features)
    normalized the categories for email
    create: default values to parent realm's values or if general, standard defaults
    update: default values to prior settings
  * Bivio::Biz::Model::ForumList
    include all categories
  * Bivio::SQL::DDL
    name of constraint incorrect
  * Bivio::Type::ForumEmailMode
    fmt
  * Bivio::Type::NullBoolean
    NEW
  * Bivio::UI::View::CSS
    fixed the positioning for dropdown menus
  * Bivio::UI::View::GroupUser
    create_form: pull the values from ForumForm CATEGORY_LIST
  * Bivio::Util::SQL
    added drop_object

  Revision 8.44  2009/12/04 17:36:09  dobbs
  * Bivio::Biz::Action::TestBackdoor
    rollback put results in the HTTP reply 'cos it introduced security risks

  Revision 8.43  2009/12/04 00:46:37  nagler
  * Bivio::Biz::Action::TestBackdoor
    return output from ShellUtils in the HTTP reply
  * Bivio::Biz::Model::ForumForm
    add feature controls
  * Bivio::SQL::DDL
    user_id is primary key so already indexed
  * Bivio::UI::FacadeBase
    added ForumForm labels
  * Bivio::UI::HTML::Widget::Link
    don't escape javascript: links
  * Bivio::UI::View::File
    document.file_form => document.forms['file_form']
  * Bivio::UI::View::GroupUser
    add feature controls
  * Bivio::Util::Wiki
    reorder _update_b_tags expressions
    _update_b_tags expressions ignore case

  Revision 8.42  2009/12/02 13:20:59  nagler
  * Bivio::PetShop::Widget::Search
    switch input to the left
  * Bivio::UI::Align
    added css_mode for backwards compatibiilty with non-CSS sites
  * Bivio::UI::FacadeBase
    don't show more if can't show CALENDAR
  * Bivio::UI::HTML::ViewShortcuts
    restore vs_center
    removed vs_center, put in specific app
  * Bivio::UI::HTML::Widget::JavaScript
    modularize the concept of a global variable name (window.bivio)
  * Bivio::UI::XHTML::Widget::DropDown
    multiple DropDowns now work
  * Bivio::Util::SQL
    factor out parts of init_realm_role so can be overriden
    Added UNAPPROVED_APPLICANT to default init values
    Removed update of roles once initialized in init_realm_role_copy_anonymous_permissions

  Revision 8.41  2009/11/29 01:47:53  nagler
  * Bivio::Biz::Action::WikiValidator
    die_on_validate_error was broken
  * Bivio::Biz::Model::BlogList
    Search parser requires model passed to excerpt
  * Bivio::Biz::Model::MailThreadRootList
    added AUTH_USER_ID_FIELD
  * Bivio::Biz::Model::SearchList
    Xapian does more of the parsing and now caches excerpts
  * Bivio::Biz::Model
    added get_auth_user_id/_name with refactoring of _well_known_name/value
  * Bivio::Ext::LWPUserAgent
    rmpod
    copy & fmt
  * Bivio::PetShop::Util::SQL
    factored out TestData->init_search
  * Bivio::PetShop::Util::TestData
    NEW
  * Bivio::PetShop::Widget::Search
    fpc
  * Bivio::Search::Parser::RealmFile::MessageRFC822
    reuse 'text' if available in handle_realm_file_new_text
    parser requires a model
  * Bivio::Search::Parser
    put excerpt if doesn't exist in _do
    Xapian caches exerpt, author_user_id, etc.
    Fill in default values for these
    xapian_terms_and_postings changed interface
  * Bivio::Search::Xapian
    Xapian caches exerpt, author_user_id, etc.
    xapian_terms_and_postings changed interface
    author/_email is looked up dynamically if not set (MessageRFC822
    caches this value since it comes from the document)
  * Bivio::Test::Language::HTTP
    added user_agent_timeout
  * Bivio::UI::FacadeBase
    show Home in xhtml_dock_left_standard when not in forum
  * Bivio::UI::View::CSS
    .search_results .date must be a DIV, because <noscript> can't be in
    inline tags
  * Bivio::UI::View::Search
    .search_results .date must be a DIV, because <noscript> can't be in
    inline tags
  * Bivio::Util::Search
    call rebuild_realm properly

  Revision 8.40  2009/11/28 03:14:57  nagler
  * Bivio::BConf
    updated ignore_list
  * Bivio::HTML
    doc
  * Bivio::PetShop::BConf
    ThreePartPage.center_replaces_middle => 1
  * Bivio::PetShop::View::Base
    center_replaces_middle
    Use standard dock_left
  * Bivio::PetShop::View::CSS
    turn off image borders
  * Bivio::PetShop::Widget::Search
    rmpod
    xhtml
  * Bivio::UI::Align
    only generate css
  * Bivio::UI::FacadeBase
    All CSS reset and base styling can be overriden.  See View.CSS
  * Bivio::UI::HTML::FormErrors
    rmpod
    escape_attr_value
  * Bivio::UI::HTML::ViewShortcuts
    removed vs_center
  * Bivio::UI::HTML::Widget::Checkbox
    b_use
  * Bivio::UI::HTML::Widget::ClearDot
    rmpod
    xhtml
  * Bivio::UI::HTML::Widget::File
    rmpod
    xhtml by subclassing InputBase
  * Bivio::UI::HTML::Widget::Form
    name= is not valid xhtml
    attributes must be escaped
  * Bivio::UI::HTML::Widget::Grid
    fix empty_row deletion (<tr></tr> is not valid xhtml)
  * Bivio::UI::HTML::Widget::Image
    attributes must be escaped in xhtml
  * Bivio::UI::HTML::Widget::ImageFormButton
    border is not a valid xhtml attribute
  * Bivio::UI::HTML::Widget::Link
    attributes must be escaped in xhtml
  * Bivio::UI::HTML::Widget::ListActions
    attributes must be escaped in xhtml
  * Bivio::UI::HTML::Widget::MailTo
    attributes must be escaped in xhtml
  * Bivio::UI::HTML::Widget::RealmFilePage
    attributes must be escaped in xhtml
  * Bivio::UI::HTML::Widget::Select
    </option> is required
  * Bivio::UI::HTML::Widget::SourceCode
    xhtml
  * Bivio::UI::HTML::Widget::StyleSheet
    attributes must be escaped in xhtml
  * Bivio::UI::HTML::Widget::Table
    nowrap="nowrap"
    '' (blank) cells map to &nbsp; always
  * Bivio::UI::HTML::Widget::TaskInfo
    xhtml
  * Bivio::UI::HTML::Widget::TextArea
    wrap=virtual is not valid xhtml
  * Bivio::UI::Icon
    escape_attr_value
  * Bivio::UI::View::CSS
    reset and base styling is structured with Facade values so can be
    overridden by apps.
    Added b_align support
  * Bivio::UI::View::ThreePartPage
    Added center_replaces_middle config, because xhtml_*_middle should be
    xhtml_*_center, since they are horizontal.
  * Bivio::UI::XHTML::ViewShortcuts
    removed vs_grid3
  * Bivio::UI::XHTML::Widget::TaskMenu
    lower case xlinks are looked up as xlinks.  Upper case xlinks are TaskIds

  Revision 8.39  2009/11/23 17:22:32  dobbs
  * Bivio::BConf
    copy
  * Bivio::Biz::Action::WikiValidator
    don't b_warn if not validating
  * Bivio::Biz::FormModel
    added IS_SPECIFIED constraint
  * Bivio::Biz::Model::CSVImportForm
    check_value takes type
  * Bivio::Biz::Model::ForumForm
    added web UI for creating forums
  * Bivio::Biz::Model::MailForm
    use IS_SPECIFIED
    added validate to always has To:
  * Bivio::Delegate::SimpleTypeError
    fix grammar in TOP_FORUM_NAME
  * Bivio::Delegate::SimpleWidgetFactory
    made easier to subclass
  * Bivio::Delegate::TaskId
    added web UI for creating forums
  * Bivio::PetShop::Util::SQL
    use internal_realm_role_config_data
  * Bivio::SQL::Constraint
    check_value takes type
    added IS_SPECIFIED
  * Bivio::Test::HTMLParser::Links
    output xpath-like value on errors
  * Bivio::Type::Enum
    equals_by_name takes "any"
  * Bivio::Type::StringArray
    is_specified checks undef
  * Bivio::Type::TupleSlotType
    use is_specified
  * Bivio::UI::FacadeBase
    Added css_reset, MAIL_RECEIVE_URI_PREFIX, changed a couple of TaskMenu sorts
    added web UI for creating forums
  * Bivio::UI::Font
    bigger and smaller are not valid, use 120% & 80%
  * Bivio::UI::HTML::Widget::Checkbox
    xhtml: checked="checked"
  * Bivio::UI::HTML::Widget::InputBase
    xhtml: disabled="disabled="
  * Bivio::UI::HTML::Widget::Radio
    xhtml: checked="checked"
  * Bivio::UI::HTML::Widget::Select
    xhtml: selected="selected"
  * Bivio::UI::HTML::Widget::String
    b_use
  * Bivio::UI::HTML::Widget::TextArea
    xhtml: readonly="readonly"
  * Bivio::UI::HTML::Widget::YesNo
    xhtml: checked="checked"
  * Bivio::UI::Task
    added a HELP constant so can be overriden
  * Bivio::UI::View::Base
    protect USER_PASSWORD with user_auth component check
  * Bivio::UI::View::CSS
    don't reset the fonts so much
  * Bivio::UI::View::Calendar
    don't output URL if no URL
  * Bivio::UI::View::GroupUser
    added web UI for creating forums
  * Bivio::UI::View::LocalFile
    b_use
  * Bivio::UI::View::Method
    b_use
  * Bivio::UI::View::ThreePartPage
    protect USER_PASSWORD with user_auth component check
  * Bivio::UI::View
    b_use
  * Bivio::UI::ViewLanguage
    changed _view_in_eval to always ask UI.View for the view
  * Bivio::UI::Widget::MIMEEntityView
    b_use
  * Bivio::UI::XHTML::Widget::ForumDropDown
    use DEFAULT_REALM_TYPE
  * Bivio::UI::XHTML::Widget::RealmCSS
    b_use
  * Bivio::UI::XHTML::Widget::RealmDropDown
    allow subclass to pass hash for values to override display_name,
    task_id, and name
  * Bivio::UI::XHTML::Widget::TaskMenu
    check if xlink is a String, iwc surround in SPAN.  Other constraint
    was too loose.
    needed to wrap in a DIV if not HTMLWidget.ControlBase
  * Bivio::Util::SQL
    added internal_realm_role_config_data
    fixed oracle's group_concat

  Revision 8.38  2009/11/18 22:03:47  nagler
  * Bivio::Biz::Action::EasyForm
    was not managing references correctly
  * Bivio::Test::HTMLParser::Links
    rmpod
  * Bivio::Type::TextArea
    don't rely on canonicalize_newlines to return same ref
  * Bivio::UI::View::File
    try a different work-around for firefox layout bug

  Revision 8.37  2009/11/17 14:55:16  nagler
  * Bivio::BConf
    ignore JOB_START/END changed
  * Bivio::Biz::Action::EasyForm
    always append trailing newline
    call canonicalize_newlines
  * Bivio::Biz::Model::FileChangeForm
    Append a trailing newline if content is submitted from a form
    append_new_line unnecessary b/c comes in via TextArea
  * Bivio::Biz::Model::MailReceiveDispatchForm
    remove a debug
  * Bivio::Type::Text64K
    subclass of TextArea
  * Bivio::Type::TextArea
    added append_trailing_newline
    changed size to match max browser size
    fixed a bug in from_literal which smashes together multiple lines
    renamed append_new_line to canonicalize_newlines
    from_literal uses it
    \n\r is no longer parsed; This format is no longer relevant
    parse whitespace on blank lines explicitly (\s includes newlines even
    if //mg)
    Don't strip multiple blank lines or leading newlines
  * Bivio::UI::HTML::Format::Link
    rmpod
  * Bivio::Util::CSV
    call canonicalize_newlines which takes a ref
  * Bivio::Util::Wiki
    correct random-image reference and call are_you_sure

  Revision 8.36  2009/11/10 18:41:20  nagler
  * Bivio::PetShop::Util::SQL
    add forum for RealmFileVersionsList.bunit
  * Bivio::UI::XHTML::Widget::WikiText
    added paragraphing config

  Revision 8.35  2009/11/04 21:28:24  aviggio
  * Bivio::Biz::Model::RealmFileVersionsList
    factor file suffix into versions query

  Revision 8.34  2009/10/25 18:10:27  nagler
  * Bivio::Biz::Model::RoleBaseList
    added is_oracle feature
  * Bivio::Util::SQL
    added group_concat for oracle

  Revision 8.33  2009/10/25 13:36:46  nagler
  * Bivio::Agent::HTTP::Dispatcher
    better tracing
  * Bivio::Biz::Action::LocalFilePlain
    backout previous change
    added robots_txt_allow_all so can turn off for a facade
  * Bivio::Biz::Model::UserLoginForm
    added register_with_cookie config to allow apps to turn off cookie
    processing by this module
  * Bivio::PetShop::Facade::Other
    for testing robots_txt_allow_all
  * Bivio::UI::FacadeBase
    added robots_txt_allow_all
  * Bivio::Util::LinuxConfig
    add_crontab_line needs to first look for /var/spool/cron/tabs as an
    alternative location

  Revision 8.32  2009/10/23 12:34:16  nagler
  * Bivio::Biz::Action::LocalFilePlain
    allow Bivio::Util::Spider in robots.txt for test servers
  * Bivio::Biz::File
    added delete & unsafe_read
    absolute_path is now idem potent
  * Bivio::UI::HTML::Widget::Table
    wrap title in DIV with title_row_class
  * Bivio::UI::XHTML::Widget::Page3
    use xhtml_title instead of page3_title, fixes Prose eval of title
  * Bivio::Util::Release
    remove all *.bs, .packlist, perllocal.pod from top level build dir,
    because /usr/lib64 is not necessarily where perl gets installed
  * Bivio::Util::Spider
    NEW
  * Bivio/Util/t/Spider
    NEW

  Revision 8.31  2009/10/12 23:46:05  nagler
  * Bivio::UI::View::CSS
    move b_prose change to wiki section

  Revision 8.30  2009/10/12 22:44:44  nagler
  * Bivio::Biz::Model::BlogList
    Set is_inline_text explicitly in render_html
  * Bivio::Mail::Outgoing
    $np => $bp
  * Bivio::Test::ListModel
    save_excursion around map_rows so cursor preserved
  * Bivio::UI::View::CSS
    don't text-indent dd|li|blockquote|td p.b_prose
  * Bivio::UI::XHTML::Widget::WikiText::Macro
    compile params definition in @b-def
  * Bivio::UI::XHTML::Widget::WikiText
    allow callers to override is_inline_text in render_html
    set is_inline_text when rendering title
    fixed $_INLINE_RE problem with paragraphing

  Revision 8.29  2009/10/12 05:30:50  nagler
  * Bivio::UI::XHTML::Widget::WikiText::Include
    Include my.bwiki during pre_parse, if it exists
  * Bivio::UI::XHTML::Widget::WikiText::Option
    NEW
  * Bivio::UI::XHTML::Widget::WikiText
    Call pre_parse in my_tags
  * Bivio::UI::XHTML::Widget::WikiTextTag
    default pre_parse

  Revision 8.28  2009/10/12 04:27:47  nagler
  * Bivio::Agent::Request
    doc
  * Bivio::Auth::RealmType
    added is_group
  * Bivio::Biz::Action::RealmMail
    new interface to set_headers_for_list_send
  * Bivio::Biz::Action::WikiValidator
    use calling_context
    when die_on_validate_error is true, make sure errors don't cascade
    through catches in WikiText
  * Bivio::Biz::Model::BlogList
    use calling_context when calling WikiText
    check error returned by BlogContent->split
  * Bivio::Biz::Model::MailReceiveDispatchForm
    made duplicate_threshold_seconds configurable
    if_test, then duplicates NOT ignored unless X-Bivio-Mail-Test is set
    in header of message
  * Bivio::Die
    ensure $attrs->{message} is always defined
  * Bivio::IO::CallingContext
    added equals
    fixed internal_as_string
    added inc_line
  * Bivio::Mail::Outgoing
    new interface to set_headers_for_list_send
  * Bivio::Parameters
    NEW
  * Bivio::PetShop::Util::SQL
    create wiki_bunit forum
    include.bwiki is created on demand
    use ROOT for wiki_bunit
  * Bivio::Test::Unit
    added comment option to assert_*
  * Bivio::Test::WikiText
    Added ability to set is_public in init args
    Added wiki_data_create & wiki_data_delete_all
    use TestUser->ADM for user
  * Bivio::TypeError
    rmpod
    fpc
  * Bivio::UI::XHTML::Widget::WikiText::Embed
    use parameters()
  * Bivio::UI::XHTML::Widget::WikiText::Include
    include_content requires IO.CallingContext so errors have correct line numbers
    use parameters()
  * Bivio::UI::XHTML::Widget::WikiText::Macro
    include_content requires IO.CallingContext so errors have correct line numbers
    use parameters()
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    use calling_context to store file/line
    include_content requires IO.CallingContext so errors have correct line numbers
    use parameters()
  * Bivio::UI::XHTML::Widget::WikiText::SWFObject
    use parameters()
  * Bivio::UI::XHTML::Widget::WikiText::Widget
    use parameters()
  * Bivio::UI::XHTML::Widget::WikiText
    use calling_context to store file/line
    include_content requires IO.CallingContext so errors have correct line numbers
    moved options to $state
    if render_html or render_plain_text return undef, use ''
  * Bivio::UI::XHTML::Widget::WikiTextTag
    added parameters() and parameters_error()
    added default render_html()
    removed parse_args
  * Bivio::UNIVERSAL
    added parameters() which calls Bivio.Parameters
  * Bivio::Util::Wiki
    share code between two upgrade paths
  * Bivio/t/Parameters
    NEW

  Revision 8.27  2009/10/10 00:30:58  nagler
  * Bivio::Biz::Action::Error
    use ActionError.wiki_name.default if status not found in facade
  * Bivio::UI::FacadeBase
    Added ActionError.wiki_name.default
  * Bivio::UI::Text
    unsafe_get_value checks wantarray
  * Bivio::UI::XHTML::Widget::RealmDropDown
    _one_choice shouldn't be true if the choice is not in the user's realm list

  Revision 8.26  2009/10/09 05:05:06  nagler
  Release notes:
  * Bivio::Agent::Request
    added if_test
  * Bivio::IO::CallingContext
    addec new_from_file_line
  * Bivio::Test::WikiText
    added check_return to trim_space
  * Bivio::UI::XHTML::Widget::WikiText::Embed
    call render_error
    parse_args may return false iwc bail immediately
  * Bivio::UI::XHTML::Widget::WikiText::Include
    call render_error
    parse_args may return false iwc bail immediately
  * Bivio::UI::XHTML::Widget::WikiText::Macro
    NEW
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    call render_error
    parse_args may return false iwc bail immediately
  * Bivio::UI::XHTML::Widget::WikiText::SWFObject
    Vista requires wmode=opaque
    cleaned up code a bit more
  * Bivio::UI::XHTML::Widget::WikiText::Widget
    call render_error
    parse_args may return false iwc bail immediately
  * Bivio::UI::XHTML::Widget::WikiText
    support for macros
  * Bivio::UI::XHTML::Widget::WikiTextTag
    better error handling

  Revision 8.25  2009/10/08 16:27:25  aviggio
  * Bivio::Biz::Action::WikiValidator
    renamed unsafe_get_self to get_current_or_new
  * Bivio::Biz::Action::WikiView
    unsafe_load_wiki_data forces the path to be in a WikiData directory
  * Bivio::Die
    Alert now uses IO.CallingContext
  * Bivio::IO::Alert
    factor out IO.CallingContext so can be used by other parsers
  * Bivio::IO::CallingContext
    NEW
  * Bivio::PetShop::Util::SQL
    remove empty line in test wiki content
    avoid hardwired paths, use Type.*Name modules
    added include.bwiki
  * Bivio::Type::FilePathArg
    NEW
  * Bivio::Type::SettingsName
    NEW
  * Bivio::UI::FacadeBase
    factored out internal_dav_text
  * Bivio::UI::XHTML::Widget::WikiText::Include
    NEW
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    unsafe_load_wiki_data now forces path to be WikiData
  * Bivio::UI::XHTML::Widget::WikiText
    support @b-include tag
    added include_content
    fixed paragraphing so does the right thing within @td and cascades
    class (as before)
  * Bivio::UI::XHTML::Widget::WikiTextTag
    EXPECT_CHILDREN => ACCEPTS_CHILDREN
  * Bivio::Util::Wiki
    modify upgrade_content and upgrade_blog_titles to operate across all realms
    handle @aa-random-image conversion

  Revision 8.24  2009/10/02 21:28:21  dobbs
  * Bivio::BConf
    fixed close_results_motion typo
  * Bivio::Biz::Action::WikiValidator
    added die_on_validate_error
  * Bivio::Biz::Model::MailReceiveDispatchForm
    fmt
  * Bivio::Biz::Model::RealmMail
    log emails which cause a die during creation
  * Bivio::Delegate::TaskId
    typo
  * Bivio::MIME::Type
    minor refactoring
  * Bivio::Mail::Incoming
    ignore bad message ids
  * Bivio::Test::Unit
    replace chomp_and_return with trim_space
  * Bivio::UI::XHTML::Widget::WikiText::Embed
    refactoring to be a real parser with AST
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    refactoring to be a real parser with AST
  * Bivio::UI::XHTML::Widget::WikiText::SWFObject
    refactoring to be a real parser with AST
    add noflash attribute to SWFObject
  * Bivio::UI::XHTML::Widget::WikiText::Widget
    refactoring to be a real parser with AST
  * Bivio::UI::XHTML::Widget::WikiText
    refactoring to be a real parser with AST
    fix spurious end tag problem
    start down path of macros
    EXPECTED_CHILDREN => EXPECT_CHILDREN
  * Bivio::UI::XHTML::Widget::WikiTextTag
    NEW
  * Bivio::Util::RealmMail
    get_date_time now returns a DateTime
  * Bivio::Util::Wiki
    upgrade @random-image tags
    use trace to reduce runtime output

  Revision 8.23  2009/09/28 03:11:38  nagler
  * Bivio::BConf
    use enhanced categories_map configuration
  * Bivio::Biz::Model::MailForm
    MailForm and CRMForm no longer show validation errors when canceled
  * Bivio::Biz::Util::RealmRole
    Added +/-<category> to category_map so category configuration can be shared.
    Allow + on roles in category map
  * Bivio::Delegate::SimpleRealmName
    clean_and_trim needs to strip all \W
    copy
  * Bivio::Die
    refactor _as_string_args
  * Bivio::MIME::Type
    update Internet media types, based on Apache conf/mime.types rev 800196
  * Bivio::PetShop::BConf
    added realm_user_util4 for ShellUtil.RealmUser testing
  * Bivio::PetShop::Util::SQL
    added realm_user_util4 for ShellUtil.RealmUser testing
    added init_motion
  * Bivio::ShellUtil
    added unauth_realm_id
  * Bivio::Test::Language::HTTP
    generate_local_email now accepts an optional domain
    change local_email_domain_re to =, not - so a bit clearer
  * Bivio::Type::Email
    added get_domain_part
    added hook to get_domain_part() for testing domain specific email behavior
    fmt
  * Bivio::Type::Phone
    from_literal implementation unnecessary
  * Bivio::Util::RealmUser
    added EXPLICIT realms which are not included $_ALL_REALMS
  * Bivio::Util::TestUser
    format_email and create accept a domain
  * Bivio::Util::Wiki
    rename convert_links to upgrade_content
    rename convert_titles to upgrade_blog_titles
    extract app-specific content upgrades
    fix _mutable_wikitext calls

  Revision 8.22  2009/09/18 21:59:46  aviggio
  * Bivio::Util::Wiki
    extract _is_mutable_wiki_file, check content type

  Revision 8.21  2009/09/17 21:39:02  aviggio
  * Bivio::Util::Wiki
    add _update_caret_ampersand

  Revision 8.20  2009/09/17 21:20:47  dobbs
  Release notes:
  * Bivio::Biz::Model::GroupUserList
  * Bivio::UI::View::GroupUser
    disabled the link to edit privileges for WITHDRAWN users
  * Bivio::Biz::Model::RoleBaseList
    handle undef in roles
  * Bivio::Type::FormMode
    use Bivio::Base
  * Bivio::Util::Backup
    added size check
    don't blow up entirely if a dd fails.  It may die due to some random
    error, not just a out of disk problem

  Revision 8.19  2009/09/10 15:31:45  moeller
  * Bivio::Biz::Model::GroupUserForm
  * Bivio::Biz::Model::GroupUserList
  * Bivio::Biz::Model::RoleSelectList
    exclude WITHDRAWN users in GroupUserList unless privilege filter is
    explicitly set to WITHDRAWN
  * Bivio::Biz::Model
    put_on_request() clears ephemeral state
  * Bivio::Biz::PropertyModel
    _unload() doesn't call delete_from_request() for ephemeral models
  * Bivio::UI::XHTML::Widget::WikiText
    export regexes
  * Bivio::Util::Wiki
    add convert_links and convert_titles
    don't insert carets for wiki tag lines
    convert_links wiki and blog path checks

  Revision 8.18  2009/09/09 15:55:05  moeller
  * Bivio::Biz::FormContext
    removed assumption that realm is the current realm in new_empty(),
    let the request determine the default realm if necessary

  Revision 8.17  2009/09/04 19:58:52  moeller
  * Bivio::Biz::Model::QuerySearchBaseForm
    factored out get_current_query_for_list
  * Bivio::Util::Backup
    Fixed quoting issues

  Revision 8.16  2009/08/31 16:04:54  moeller
  * Bivio::PetShop::Util::SQL
    create dummy "spaces in name.gif" file

  Revision 8.15  2009/08/31 00:12:47  nagler
  * Bivio::Biz::Action::WikiView
    missing $req on call to UI.Constant->get_value
    remove comment
  * Bivio::Biz::Model::Lock
    fmt
  * Bivio::Biz::Util::RealmRole
    change output format of list so useable as a Shell->batch
  * Bivio::IO::Ref
    added newline to diff between actual and expected
    Label --- EXPECT +++ ACTUAL so matches the '+' and '-'.  '***' and
    '---' was counterintuitive.
  * Bivio::MIME::Type
    added OpenOffice (oasis) types
  * Bivio::SQL::Connection
    remove _prep_params_for_io
    Produce trace statements which are directly executable
  * Bivio::SQL::PropertySupport
    fmt
  * Bivio::Test::Language::HTTP
    removed comment
  * Bivio::Type::Enum
    remove restrction on subclassing
  * Bivio::Type::YearWindow
    added ability to have offsets or absolute years
    Can be subclassed
    compile_short_desc: allow subclasses to override short_desc
  * Bivio::UI::FacadeBase
    SHELL_UTIL has a Text entry
  * Bivio::UI::Task
    improve error message when no realm for a uri, but should have one
  * Bivio::Util::Backup
    write dd 2> /dev/null
  * Bivio::Util::HTTPStats
    correct comment
  * Bivio::Util::RealmAdmin
    join_user doesn't blow up if role already exists
  * Bivio::Util::SQL
    remove parse_trace_output; unnecessary b/c SQL.Connection produces
    executable output

  Revision 8.14  2009/08/12 23:18:37  moeller
  * Bivio::Biz::Action::EmptyReply
    map UPDATE_COLLISION to SERVER_ERROR
  * Bivio::Biz::FormModel
    added has_stale_data(), set when hidden values have validation errors
  * Bivio::Biz::Model::Lock
    changed error from UPDATE_COLLISION to DB_ERROR for better detection,
    minor refactoring
  * Bivio::Delegate::TaskId
    added DEFAULT_ERROR_REDIRECT_UPDATE_COLLISION
  * Bivio::PetShop::ViewShortcuts
    rm pod, now uses XHTML.ViewShortcuts
  * Bivio::Test::HTMLParser::Tables
    guard against -1 array insert
  * Bivio::Type::TextArea
    don't call super from_literal which trims leading/trailing whitespace
  * Bivio::UI::FacadeBase
    added DEFAULT_ERROR_REDIRECT_UPDATE_COLLISION task and text
    added form_stale_data_title text
    added missing label for task log spreadsheets
  * Bivio::UI::XHTML::ViewShortcuts
    added stale form data section to vs_form_error_title()

  Revision 8.13  2009/08/06 20:12:21  nagler
  * Bivio::Agent::HTTP::Reply
    remove charset change
  * Bivio::Biz::Model::GroupUserList
    remove creation_date_time from order_by, belonged in UnapprovedApplicantList
  * Bivio::Biz::Model::UnapprovedApplicantList
    order by creation_date_time
  * Bivio::PetShop::View::Base
    added blog to dock left menu
  * Bivio::Type::Line
    rmpod
  * Bivio::Type::Text64K
    rmpod
  * Bivio::Type::Text
    rmpod
    Type.Text now subclasses Type.Line -- leading and trailing whitespace will now be trimmed
  * Bivio::UI::View::CSS
    duplicate styles removed
  * Bivio::UI::XHTML::Widget::WikiText
    IGNORED-TAG-VALUE removed now that errors are displayed by validate
  * Bivio::Util::Backup
    prevent output when no files

  Revision 8.12  2009/07/28 22:48:56  moeller
  * Bivio::Biz::Model::MailReceiveDispatchForm
    now calls Incoming->get_from_user_id()
  * Bivio::Biz::Model::RealmMail
    now calls Incoming->get_from_user_id()
  * Bivio::Mail::Incoming
    added get_from_user_id(), allows multiple users sharing the same
    email
  * Bivio::SQL::ListQuery
    fixed format_uri_for_this_as_parent() when parent_id is already on
    the query

  Revision 8.11  2009/07/26 15:56:35  nagler
  * Bivio::Agent::HTTP::Reply
    specify utf8 in content-type header so browsers send back forms in utf8
  * Bivio::IO::ClassLoader
    added call_autoload
  * Bivio::Test::Type
    renamed handle_autoload/_ok to handle_test_unit_autoload_ok
  * Bivio::Test::Unit
    renamed handle_autoload/_ok to handle_test_unit_autoload_ok
  * Bivio::Type
    added handle_autoload
  * Bivio::UI::XML::Widget::AtomFeed
    added xml declaration to top of AtomFeed
  * Bivio::UI::XML::Widget::XMLDocument
    NEW
  * Bivio::Util::Backup
    remote_archive: ignore dd output
  * Bivio::Util::Shell
    use call_autoload

  Revision 8.10  2009/07/16 19:02:28  nagler
  * Bivio::SQL::Connection::Postgres
    fixed blob type
  * Bivio::SQL::DDL
    removed task_log foreign keys
  * Bivio::Util::Backup
    remove empty messages from compress_and_trim_log_dirs
  * Bivio::Util::SQL
    add upgrade to remove task log foreign keys

  Revision 8.9  2009/07/10 00:28:08  nagler
  * Bivio::Agent::Embed::Request
    need to unescape uri before calling internal_initialize_with_uri
  * Bivio::Biz::Action::WikiValidator
    Added error_txt and send_all_mail
    unsafe_get_self takes realm_id
    added ignore regexp per realm (defined in site-reports)
  * Bivio::Biz::Model::RealmFile
    added warning if given realm_id doesn't match the auth_id on the request
  * Bivio::Biz::Model::WikiValidatorSettingList
    NEW
  * Bivio::PetShop::Util::SQL
    added WikiValidatorSettingList
  * Bivio::Type::Date
    REGEX_FILE_NAME
  * Bivio::UI::FacadeBase
    changed subject
    site_reports_realm_id
  * Bivio::UI::View::Wiki
    added validator_all_mail and validator_txt
  * Bivio::UI::XHTML::Widget::WikiText
    pass realm_id to unsafe_get_self
  * Bivio::Util::Backup
    added archive_logs
  * Bivio::Util::Wiki
    validate_realm returns errors and count; no longer sends email
    validate_all_realms sends one email
    validate_all_realms now takes a -realm, not email

  Revision 8.8  2009/07/07 21:07:34  nagler
  * Bivio::Util::Backup
    need check on num_keep

  Revision 8.7  2009/07/07 14:17:03  nagler
  * Bivio::Biz::Model::BulletinForm
    no context
  * Bivio::Biz::Model::MailForm
    require context, and don't return "next"
  * Bivio::Biz::Model::MailThreadList
    use
  * Bivio::Biz::Model::MailThreadRootList
    added update_uri
  * Bivio::Biz::Model::SearchList
    internal_private_realm_ids was returning all realms, when it should
    only have been returning the list of realms to which the user has
    DATA_READ access
  * Bivio::Delegate::TaskId
    added update_task for mailform tasks
  * Bivio::PetShop::Util::SQL
    added xapian_withdrawn to test user with no permissions in realm
  * Bivio::UI::View::CRM
    drilldown changed so that everything but subject goes right to form
  * Bivio::UI::View::Mail
    fmt
    fixed css class on RoundedBox
  * Bivio::UI::View::SiteAdmin
    put alphabetical_chooser() in user_list() 'cos it's still needed here
  * Bivio::UI::XHTML::ViewShortcuts
    removed alphabetical_chooser from vs_user_email_list()
  * Bivio::Util::Backup
    added remote_archive and compress_and_trim_log_dirs
    archive_logs not working yet
  * Bivio::Util::HTTPStats
    override NotPageList adding .rss .atom .ics
    override ValidHTTPCodes adding 201 207 302
    correct SkipFiles regex

  Revision 8.6  2009/06/22 17:46:07  moeller
  * Bivio::Auth::RoleSet
    increased width to 15, rm pod
  * Bivio::IO::Config
    doc
  * Bivio::Test::Language::HTTP
    doc
  * Bivio::Type::EnumSet
    die if ref passed to to_sql_param(),
    changed die() to b_die()

  Revision 8.5  2009/06/19 00:22:14  dobbs
  * Bivio::Biz::Action::TestBackdoor
    assert_test
  * Bivio::Biz::Model::TaskLog
    set date_time in post execute so acceptance test can set_test_now
  * Bivio::Test::Language::HTTP
    added get_uri_for_link()
  * Bivio::Type::DateTime
    fixed handle_pre_execute_task() to call set_test_now() with a request
  * Bivio::UI::View::CSS
    XHTMLWidget.RoundedBox will now accept a radius (in pixels) for the rounded corners
  * Bivio::UI::XHTML::Widget::RoundedBox
    XHTMLWidget.RoundedBox will now accept a radius (in pixels) for the rounded corners
  * Bivio::UI::XHTML::Widget::WikiText
    now accepts is_public
  * Bivio::Util::HTTPStats
    changed the no dmains found warning to a trace; can know say
    --trace=httpstats to get all errors
  * Bivio::Util::LinuxConfig
    _edit() defaults $search so that $value begins the line unless
    contains a \n iwc does what it did before (q{\Q$value}s)

  Revision 8.4  2009/06/15 20:51:52  moeller
  * Bivio::UI::XHTML::Widget::ComboBox
    the drop down element is now named using the field name, allowing
    multiple widgets per form
  * Bivio::Util::HTTPStats
    fix previous day log name

  Revision 8.3  2009/06/12 15:36:23  dobbs
  * Bivio::Util::RealmMail
    added import_bulletins

  Revision 8.2  2009/06/10 22:47:15  moeller
  * Bivio::Biz::FormModel
    better error message on 'cannot equivalence a hash'
  * Bivio::Biz::Model::UserCreateForm
    don't put qualified fields inside a field_decl
  * Bivio::Delegate::SimpleWidgetFactory
    added wf_widget
  * Bivio::Util::HTTPStats
    only create report if facade has SITE_REPORTS_REALM_NAME
    check todays date for previous log file, don't die if < v3

  Revision 8.1  2009/06/10 16:40:27  moeller
  * Bivio::Biz::Model::UserSettingsForm
    removed
  * Bivio::Biz::Model::UserSettingsListForm
    allow substitute user to edit the email
  * Bivio::Type::UserAgent
    added BROWSER_MSIE_8
  * Bivio::UI::FacadeBase
    removed UserSettingsForm
  * Bivio::UI::View::UserAuth
    added email editing for substitute user
  * Bivio::UI::XHTML::Widget::MailHeader
    render date values using DateTime widget

  Revision 8.0  2009/06/05 23:21:42  nagler
  * Bivio::Type::PrimaryId
    can_be_zero is still false, but from_literal allows 0 as value.
    is_specified will return false for 0.  However, we need a value which
    is not a PrimaryId that SQL.Statement can accept to mean "do not match
    anything" (see Model.WikiList)
  * Bivio::Util::Search
    test problem of realm without any data

  Revision 7.96  2009/06/04 20:25:53  aviggio
  * Bivio::BConf
    added JavaScript widget map
  * Bivio::UI::FacadeBase
    rename SITE_REPORTS_REALM_NAME for consistency, update use
  * Bivio::UI::HTML::Widget::Script
    added JAVASCRIPT_B_COMBO_BOX()
  * Bivio/UI/JavaScript
    NEW
  * Bivio::UI::View::CSS
    added div.cb_selected for ComboBox
  * Bivio::UI::XHTML::ViewShortcuts
    added more options to vs_filter_query_form()
  * Bivio::UI::XHTML::Widget::ComboBox
    use class for selected color,
    don't eat enter if dropdown is hidden
    add constants for keycodes,
    when typing in field, save value, restore on escape,
    move static javascript to Script,
    put list values in window.bivio.combobox.list_<list_class>,
    move quoted value to Bivio::UI::Javascript::Widget::QuotedValue,
    add auto_submit,
    added hint_name
    cleaned up list value formatting

  Revision 7.95  2009/06/03 23:23:17  aviggio
  * Bivio::Type::ForumName
    added split
  * Bivio::UI::XHTML::Widget::ComboBox
    NEW
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    unsafe_load_realm_file => unsafe_load_wiki_data
  * Bivio::UI::XHTML::Widget::WikiText
    unsafe_load_realm_file => unsafe_load_wiki_data
  * Bivio::Util::HTTPStats
    simplify reports forum search, add SkipFiles directive

  Revision 7.94  2009/06/03 03:44:39  nagler
  * Bivio::Biz::Action::WikiView
    added unsafe_load_wiki_data
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    removed dead code
  * Bivio::UI::XHTML::Widget::WikiText
    call unsafe_load_wiki_data

  Revision 7.93  2009/06/03 03:07:52  nagler
  * Bivio::Biz::Model::MailReceiveDispatchForm
    refactored to structure "ignore" checks
    added filter_spam (based on X-Spam-Flag)
    All ignored mail goes to Biz.File folder and removed RealmMailBounce coupling
  * Bivio::PetShop::BConf
    filter_spam turned on
  * Bivio::Type::MailFileName
    support older RealmFile paths

  Revision 7.92  2009/06/01 22:13:05  moeller
  * Bivio::Biz::Action::WikiValidator
    set query and path_info to undef when clearing request

  Revision 7.91  2009/06/01 15:46:13  dobbs
  * Bivio::Biz::Model::BlogList
    revert internal_realm_list()

  Revision 7.90  2009/05/30 16:02:44  nagler
  * Bivio::Biz::Action::WikiValidator
    print_stack when removing perl junk
    added req to end of warnings
  * Bivio::IO::Alert
    added print_stack()
  * Bivio::Test::WikiText
    fmt
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    remove <a> from labels, because can't have <a> with <a>, report error.
    (silently) strip leading/trailing spaces on all cells
    return '' when no links

  Revision 7.89  2009/05/29 00:15:25  dobbs
  * Bivio::Biz::Model::FilterQueryForm
    added get/set filter back
  * Bivio::UI::XHTML::ViewShortcuts
    added ScriptOnly() Refresh button to vs_filter_query_form()

  Revision 7.88  2009/05/28 23:53:01  dobbs
  * Bivio::Biz::Action::RealmFile
    access_controlled_load accepts ref for $die_code so can get error on
    failure; $no_die is no longer valid interface
  * Bivio::Biz::Action::WikiValidator
    encapsulate object to text conversion in validate_error
  * Bivio::Biz::Model::BlogList
    added internal_realm_list().  BlogList can now be subclassed to
    aggregate blog entries from multiple realms.
    get_rss_author() now gets the RealmOwner.display_name from the realm
    containing the blog folder (RealmFile.realm_id).
  * Bivio::Biz::Model::FilterQueryForm
    NEW
  * Bivio::Biz::Model::GroupUserList
    filters list using GroupUserQueryForm
  * Bivio::Biz::Model::GroupUserQueryForm
    NEW
  * Bivio::Biz::Model::TaskLogList
    moved filter code into FilterQueryForm
  * Bivio::Biz::Model::TaskLogQueryForm
    removed
  * Bivio::Delegate::TaskId
    changed TaskLogQueryForm to FilterQueryForm
  * Bivio::DieCode
    rm pod, made long descriptions more user-friendly
  * Bivio::UI::FacadeBase
    added clear_on_focus_hint Text
  * Bivio::UI::View::GroupUser
    added selector for list()
  * Bivio::UI::View::TaskLog
    now uses vs_filter_query_form()
  * Bivio::UI::XHTML::ViewShortcuts
    added vs_filter_query_form()
  * Bivio::UI::XHTML::Widget::HelpWiki
    access_controlled_load API changed
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    encapsulate opening file in WikiText
    Produce appropriate errors
  * Bivio::UI::XHTML::Widget::WikiText
    added unsafe_load_realm_file

  Revision 7.87  2009/05/27 22:02:11  nagler
  * Bivio::Agent::Reply
    set_cache_private doesn't need to get set
  * Bivio::ShellUtil
    set filename on send_mail attachment

  Revision 7.86  2009/05/27 18:56:59  moeller
  Release notes:
  * Bivio::Agent::Embed::Dispatcher
    can redirect
  * Bivio::Agent::HTTP::Request
    moved uri parsing in client_redirect to internal_client_redirect_args
    delete FormContext from query if no referer (bookmark or emailed link
    gone bad)
  * Bivio::Agent::Request
    internal_client_redirect_args handles uri args
    client_redirect parses uri and server redirects if not fully-qualified
    added referer to values put on request (non-durable)
    Added delete_from_query
  * Bivio::Biz::FormContext
    use Bivio::Base
  * Bivio::Biz::FormModel
    encapsulate FORM_CONTEXT_QUERY_KEY
  * Bivio::Biz::Model::TaskLogQueryForm
    removed
  * Bivio::Mail::Incoming
    get_reply_subject now calls trim_literal on the subject instead of from_literal
  * Bivio::ShellUtil
    send_mail replaces email_file and email_message
  * Bivio::UI::FacadeBase
    default atom_feed_content
  * Bivio::Util::HTTPLog
    email_message replaced by send_file
  * Bivio::Util::RealmFile
    added send_file_via_mail
  * Bivio::Util::Wiki
    validate_all_realms: accepts email argument which overrides all EventEmail

  Revision 7.85  2009/05/26 20:26:29  nagler
  * Bivio::Biz::Model::BlogList
    rss_author is realm, because we don't want expose end users
  * Bivio::Biz::Model::CRMForm
    default action_id is now set to the assigned owner (if the ticket is assigned)
  * Bivio::UI::XML::Widget::AtomFeed
    don't display emails in RSS feeds, becasue they are public

  Revision 7.84  2009/05/26 17:41:06  moeller
  * Bivio::Agent::Dispatcher
    save current task_id in process_request()
  * Bivio::Agent::Request
    internal_redirect_realm must checks $new_realm
  * Bivio::Biz::Action::WikiValidator
    Remove perl junk from error messages on bOP
    set message, if empty after perl junk stripping
  * Bivio::UI::View::Mail
    add buttons to top of form and make body's text area smaller

  Revision 7.83  2009/05/25 20:35:02  nagler
  * Bivio::UI::ViewLanguageAUTOLOAD
    for some reason the regular expression on $AUTOLOAD was affecting its value

  Revision 7.82  2009/05/25 18:55:07  nagler
  * Bivio::Agent::Dispatcher
    use req->set_task()
  * Bivio::Agent::Request
    added set_task()
  * Bivio::Biz::Action::WikiValidator
    added a cache for URIs, preventing accidental recursion
    do not pass $self to call_embedded_task, b/c don't want to recurse
    various fixes, including set_task to FORUM_WIKI_EDIT
  * Bivio::Biz::Model::BlogList
    set line_num to 1
  * Bivio::IO::Alert
    added calling_context_get
    added internal_as_string
  * Bivio::PetShop::View::Base
    test inline WikiText
    added @invalidwikitag
  * Bivio::UI::FacadeBase
    Validation errors => Wiki errors
  * Bivio::UI::ViewLanguageAUTOLOAD
    added calling_context_of_new for better errors messages (WikiText)
    calling_context_of_new => unsafe_calling_context
  * Bivio::UI::XHTML::Widget::WikiText
    added calling_context support
    put_unless_exists with sub {}
    calling_context_of_new => unsafe_calling_context

  Revision 7.81  2009/05/25 03:36:40  nagler
  * Bivio::Biz::Action::Acknowledgement
    return task int if possible; also allow label to be TaskId
  * Bivio::Biz::Action::JobBase
    execute takes $proto, not $self
  * Bivio::Biz::Action::WikiValidator
    Moved the looping over all realms to ShellUtil.Wiki
    validate_realm working
    added unsafe_load_error_list
  * Bivio::Biz::Action::WikiView
    execute_prepare_html accepts path
  * Bivio::Biz::Action
    puts $req on self
  * Bivio::Biz::Model::BlogCreateForm
    subclass WikiBaseForm so will validate
  * Bivio::Biz::Model::BlogEditForm
    subclass WikiBaseForm so will validate
  * Bivio::Biz::Model::BlogList
    copy
    added RealmFile.path column
  * Bivio::Biz::Model::BlogRecentList
    b_use
  * Bivio::Biz::Model::EventEmailSettingList
    NEW
  * Bivio::Biz::Model::RealmFile
    allow path_lc values to be an array_ref (for SQL IN)
  * Bivio::Biz::Model::WikiBaseForm
    NEW
  * Bivio::Biz::Model::WikiErrorList
    NEW
  * Bivio::Biz::Model::WikiForm
    subclass WikiBaseForm so will validate
  * Bivio::Biz::Model::WikiList
    NEW
  * Bivio::PetShop::Util::SQL
    added /Settings/EventMail.csv
  * Bivio::Type::DocletFileName
    added is_ignored_value
  * Bivio::Type::PrimaryId
    added UNSPECIFIED_VALUE
  * Bivio::UI::FacadeBase
    WikiValidator.subject/title
  * Bivio::UI::HTML::Widget::LineBreak
    NEW
  * Bivio::UI::Text::Widget::LineBreak
    NEW
  * Bivio::UI::View::Wiki
    added validator_mail
  * Bivio::UI::XHTML::Widget::MainErrors::WikiValidator
    export error_list_widget
  * Bivio::UI::XHTML::Widget::WikiText::Embed
    call_embedded_task now handles errors
  * Bivio::UI::XHTML::Widget::WikiText
    added render_error
    added path as an args/state value for better error messages
  * Bivio::Util::Wiki
    added validate_realm and validate_all_realms
    validate_all_realms: sort realm_ids

  Revision 7.80  2009/05/21 23:21:47  aviggio
  * Bivio::Biz::Model::CRMForm
    renamed _with() to _ifelse_req_has_crmthread()
  * Bivio::Biz::t::ListModel::T1List
    added "other" fields used by WidgetFactory.bunit
  * Bivio::Delegate::SimpleWidgetFactory
    moved Year display widget above Integer
  * Bivio::PetShop::Model::FieldTestForm
    allow dynamic initialization
  * Bivio::PetShop::Util::TestCRM
    test tuple default date value in CRMForm
  * Bivio::UI::HTML::ViewShortcuts
    allow dynamic initialization
  * Bivio::UI::HTML::Widget::DateField
    allow_undef is now true for any form field with field constraint of 'NONE'
  * Bivio::UI::HTML::Widget::Form
    allow dynamic initialization
  * Bivio::UI::HTML::Widget::Grid
    allow dynamic initialization
  * Bivio::UI::HTML::Widget::Table
    allow dynamic initialization
  * Bivio::UI::HTML::Widget::TableBase
    allow dynamic initialization
  * Bivio::UI::HTML::Widget::Tag
    allow dynamic initialization
  * Bivio::UI::ViewLanguageAUTOLOAD
    calls b_use('UI.ViewLanguage')
  * Bivio::UI::Widget::Join
    allow dynamic initialization
  * Bivio::UI::XML::Widget::AtomFeed
    allow list items to specify realm
  * Bivio::UI::XML::Widget::CalendarEventContent
    can specify list model

  Revision 7.79  2009/05/19 22:53:54  dobbs
  * Bivio::UI::HTML::Widget::Tag
    Tag no longer renders pre and post if the value is empty

  Revision 7.78  2009/05/19 20:32:39  aviggio
  * Bivio::Biz::Model
    fixed put_on_request()
  * Bivio::ClassWrapper::TupleTag
    added _wrap_x_get_field_error()
  * Bivio::PetShop::Util::TestCRM
    made Priority required
  * Bivio::Type::StringArray
    to_string is same as to_literal, because TextWidget.CSV uses to_string

  Revision 7.77  2009/05/18 21:50:39  aviggio
  * Bivio::Agent::Embed::Request
    moved internal_initialize_with_uri up
  * Bivio::Agent::HTTP::Request
    moved internal_initialize_with_uri up
    client_error, not corrupt_query
  * Bivio::Agent::Reply
    added is_status_ok
  * Bivio::Agent::Request
    added unsafe_get_from_query & internal_initialize_with_uri
    rename unsafe_get_from_query => unsafe_from_query
  * Bivio::BConf
    added MainErrors map
  * Bivio::Biz::Action::WikiValidator
    NEW
  * Bivio::Biz::Action::WikiView
    removed execute_diff
  * Bivio::Biz::Action
    use delete_from_req and put_on_req
  * Bivio::Biz::Model::BlogList
    added get_rss_author()
  * Bivio::Biz::Model::CalendarEventList
    added get_creation_date_time(),
    fixed uninitialized warnings in get_rss_summary()
    removed get_rss_summary(), added get_rss_author()
  * Bivio::Biz::Model::RealmFileTextDiffList
    NEW
  * Bivio::Biz::Model::RealmFileVersionsListForm
    return query as task event arg
    default form state in execute_empty_row
  * Bivio::Biz::Model::TaskLog
    clean_and_trim() the uri
  * Bivio::Biz::Model
    use delete_from_req and put_on_req
  * Bivio::Delegate::TaskId
    updated html_task and html_detail_task for RSS tasks
    added want_basic_authorization=1 to FORUM_CALENDAR_EVENT_LIST_RSS
    use RealmFileTextDiffList
  * Bivio::Type::Enum
    added as_facade_text_default/tag
  * Bivio::Type::FilePath
    added get_versionless_tail
  * Bivio::Type::HTTPStatus
    NEW
  * Bivio::Type::StringArray
    from_sql_column splits on ANY_SEPARATOR_REGEX
  * Bivio::UI::FacadeBase
    added wiki_validator_title and DieCode.MODEL_NOT_FOUND
    added atom_feed_content to BlogList and CalendarEventList
    updated Wiki diff UI elements
  * Bivio::UI::HTML::Widget::Page
    added register_handler and do_filo to render()
  * Bivio::UI::Task
    added is_not_found
    changed return of parse_uri() to include initial_uri so no side effects
  * Bivio::UI::Text
    added facade_text_for_object
  * Bivio::UI::View::CSS
    support for MainErrors
    add styles for version diffs
  * Bivio::UI::View::Calendar
    removed rss link from event detail
    refactored _event_links()
  * Bivio::UI::View::SiteAdmin
    put Prose() widget back on UnapprovedApplicantForm mail_subject and mail_body,
    both values come from the facade
  * Bivio::UI::View::ThreePartPage
    added MainErrors
  * Bivio::UI::View::Wiki
    moved presentation responsibility to view
  * Bivio/UI/XHTML/Widget/MainErrors
    NEW
  * Bivio::UI::XHTML::Widget::MainErrors
    NEW
  * Bivio::UI::XHTML::Widget::WikiText::Embed
    added support for WikiValidator
  * Bivio::UI::XHTML::Widget::WikiText
    added support for WikiValidator
  * Bivio::UI::XML::Widget::AtomFeed
    now supports Atom spec
    replaced summary with content from facade value,
    now calls list for author name
  * Bivio::UI::XML::Widget::CalendarEventContent
    NEW
  * Bivio::UNIVERSAL
    added as_classloader_map_name, as_req_key_value_list, delete_from_req,
    put_on_req, unsafe_self_from_req

  Revision 7.76  2009/05/13 19:48:25  nagler
  * Bivio::Biz::Model::AdmSubstituteUserForm
    in su_logout() the task may not be set yet
  * Bivio::Biz::Model::UserLoginForm
    moved _su_logout() to after super_user_id is set on request
  * Bivio::UI::HTML::Widget::Script
    popup image now hides flash videos in IE
  * Bivio::UI::View::CRM
    added vs_put_pager()
  * Bivio::Util::HTTPConf
    added mail_aliases
  * Bivio::Util::Search
    Add optional date parameter
    Count indexed files
    Added b_info

  Revision 7.75  2009/05/08 20:46:22  nagler
  * Bivio::ClassWrapper::TupleTag
    don't set default_value for QuerySearchBaseForm instances
    structured so not dependent on QuerySearchBaseForm
  * Bivio::Test::Language
    _find_line_number() needed a new regexp

  Revision 7.74  2009/05/07 23:45:15  nagler
  * Bivio::UI::View::CRM
    factored out internal_tuple_tag_form_fields
  * Bivio::UI::XHTML::Widget::WikiText::SWFObject
    set allowfullscreen:'true'

  Revision 7.73  2009/05/07 20:39:51  nagler
  * Bivio::Biz::Model::EmailAlias
    type of incoming is now EmailAliasIncoming
    Added incoming_to_outgoing
  * Bivio::Biz::Model::MailReceiveDispatchForm
    use EmailAlias->incoming_to_outgoing
  * Bivio::Biz::Model::RealmCSSList
    can now put ie6 specific CSS in site/Public/myie6.css
  * Bivio::PetShop::Util::SQL
    added domain alias data
  * Bivio::Type::Email
    added join_parts
  * Bivio::Type::EmailAliasIncoming
    NEW
  * Bivio::Type::EmailAliasOutgoing
    allow @domain.com domain aliases
  * Bivio::UI::FacadeBase
    added EmailAlias.incoming.SYNTAX_ERROR

  Revision 7.72  2009/05/07 02:51:01  nagler
  * Bivio::Biz::FormModel
    added get_visible_field_names
  * Bivio::Biz::Model::CRMQueryForm
    use ClassWrapper.TupleTag
  * Bivio::Biz::Model::ListQueryForm
    use patterns, not explicit names
  * Bivio::ClassWrapper::TupleTag
    if no settings file entry is found, default to all values
    get working with CRMQueryForm
  * Bivio::Delegate::SimpleWidgetFactory
    reverse unknown_label so can be defaulted
  * Bivio::PetShop::Util::TestCRM
    use get_visible_field_names
  * Bivio::ShellUtil
    main() $0 may be undef if called directly, default to ''
  * Bivio::Type::TupleSlotNum
    added is_field_name
  * Bivio::UI::FacadeBase
    fields of ListQueryForm are not unknown_label, just ordinary labels
  * Bivio::UI::HTML::ViewShortcuts
    added vs_unknown_label
  * Bivio::UI::HTML::Widget::Script
    first_focus_onload() now iterates across all forms
  * Bivio::UI::HTML::Widget::Table
    added ClassWrapper.TupleTag support by getting canonical name
    from column
  * Bivio::UI::View::CRM
    get CRMQueryForm working
  * Bivio::UI::View::CSS
    pager div sep is now 1px
  * Bivio::UI::XHTML::ViewShortcuts
    allow wf_type to override
  * Bivio::Util::HTTPConf
    default request body 50_000_000

  Revision 7.71  2009/05/05 00:50:23  nagler
  * Bivio::Agent::Request
    added realm_cache
    look for auth_user/auth_realm. in put and deprecate.  Switch to realm_cache
  * Bivio::BConf
    ClassWrapper
  * Bivio::Base
    removed __PACKAGE__->use, because causing circularities
  * Bivio::Biz::FormModel
    copy values when process called directly
  * Bivio::Biz::ListFormModel
    get_list_model returns singleton instance if no dynamic instance
  * Bivio::Biz::Model::CRMForm
    use ClassWraper.TupleTag
  * Bivio::Biz::Model::CRMQueryForm
    removed TupleTagForm (temporarily)
  * Bivio::Biz::Model::CRMThread
    register with ClassWrapper.TupleTag
  * Bivio::Biz::Model::CRMThreadRootList
    use ClassWraper.TupleTag
  * Bivio::Biz::Model::RealmSettingList
    added as_string and setting_error
    deal with unspecified values correctly
    Fix <undef> code
  * Bivio::Biz::Model::SummaryList
    removed get_list_model
  * Bivio::Biz::Model::TaskLogList
    x_filter => b_filter
  * Bivio::Biz::Model::TaskLogQueryForm
    x_filter => b_filter
  * Bivio::Biz::Model::Tuple
    slot labels are now their own type
  * Bivio::Biz::Model::TupleDef
    use TupleMoniker
  * Bivio::Biz::Model::TupleSlotDef
    use Type.TupleSlotLabel
  * Bivio::Biz::Model::TupleSlotType
    use Type.TupleSlotLabel
  * Bivio::Biz::Model::TupleTag
    fmt
  * Bivio::Biz::Model::TupleTagForm
    removed
  * Bivio::Biz::Model::TupleUse
    use Type.TupleMoniker
  * Bivio::Biz::Model::t::RealmOwnerForm
    removed
  * Bivio/Biz/Model/t/Tuple
    NEW
  * Bivio::Biz::Model
    Added from_req()
    Removed more direct accesses to sql support, instead use existing routines
  * Bivio/ClassWrapper
    NEW
  * Bivio::ClassWrapper
    NEW
  * Bivio::Delegate::SimpleWidgetFactory
    added provide_select_choices and TupleSlotType
  * Bivio::Die
    eval now gets package right for subs and code
    don't strip __END__ in _eval()
  * Bivio::IO::Alert
    fixed debug() when called with context
  * Bivio::IO::ClassLoader
    delete_require was broken (need to delete the hash_ref entry, not
    replace with {})
    set the _importing_pkg() properly
    Added handle_class_loader_delete_require and handle_class_loader_require
  * Bivio::IO::Trace
    use handle_class_loader_require (import() calls this)
  * Bivio::IO::t::ClassLoader::Valid
    get handle_class_loader_require
  * Bivio::PetShop::Util::SQL
    slot labels begin upcase; monikers all lower
    data for tuple tests
    export realm_file_create
  * Bivio::PetShop::Util::TestCRM
    data for tuple tests
    export realm_file_create
  * Bivio::SQL::DDL
    added NOT_NULL to tuple_t.thread_root_id
  * Bivio::SQL::ListQuery
    other_query_keys can now be a pattern
  * Bivio::SQL::Support
    added extract_model_prefix & parse_qualified_field
  * Bivio::Search::Xapian
    must have parens
  * Bivio::Test::Unit
    fixed _called_in_closure to check where it is in the initialization
    before searching the stack
  * Bivio::Test::Widget
    put_and_initialize => initialize_with_parent
  * Bivio::Test
    added unsafe_current_self
  * Bivio::Type::EmailArray
    from_literal_validator isn't needed, because now calls UNDERLYING_TYPE->from_literal
  * Bivio::Type::FilePathArray
    from_literal_validator isn't needed, because now calls
    UNDERLYING_TYPE->from_literal
    subclasses SemicolonStringArray
  * Bivio::Type::SemicolonStringArray
    NEW
  * Bivio::Type::StringArray
    added interesect(), ANY_SEPARATOR_REGEX (from_literal uses),
    _clean_copy now works more intelligently, added as_list
  * Bivio::Type::TupleChoiceList
    NEW
  * Bivio::Type::TupleLabel
    fmt
  * Bivio::Type::TupleMoniker
    NEW
  * Bivio::Type::TupleSlotLabel
    NEW
  * Bivio::Type::TupleSlotLabelArray
    NEW
  * Bivio::UI::Facade
    change "unknown facade uri" message to warn_exactly_once
  * Bivio::UI::FacadeBase
    x_* => b_*
  * Bivio::UI::FacadeComponent
    added handler for handle_internal_unsafe_lc_get_value
  * Bivio::UI::FormError
    put_and_initialize => initialize_with_parent
  * Bivio::UI::HTML::Widget::Grid
    put_and_initialize => initialize_with_parent
  * Bivio::UI::HTML::Widget::ListActions
    put_and_initialize => initialize_with_parent
  * Bivio::UI::HTML::Widget::Radio
    put_and_initialize => initialize_with_parent
  * Bivio::UI::HTML::Widget::Select
    added provide_select_choices
  * Bivio::UI::HTML::Widget::String
    put_and_initialize => initialize_with_parent
  * Bivio::UI::HTML::Widget::Table
    put_and_initialize => initialize_with_parent
    Can be initialized in a dynamic context iwc ListModel will come from
    source_name.
  * Bivio::UI::HTML::Widget::YesNo
    put_and_initialize => initialize_with_parent
  * Bivio::UI::Task
    internal_unsafe_lc_get_value does the downcasing
  * Bivio::UI::Text
    internal_unsafe_lc_get_value does the downcasing
  * Bivio::UI::View::CRM
    refactoring to support dynamic fields (internal_thread_root_list_columns)
    return list of all fields
  * Bivio::UI::View::Mail
    refactoring to support dynamic fields (internal_thread_root_list_columns)
  * Bivio::UI::View::TaskLog
    x_filter => b_filter
  * Bivio::UI::ViewLanguage
    put_and_initialize => initialize_with_parent
  * Bivio::UI::ViewShortcuts
    put_and_initialize->render => initialize_and_render
  * Bivio::UI::Widget::Simple
    use NEW_ARGS
  * Bivio::UI::Widget
    added initialize_with_parent and initialize_and_render
    removed put_and_initialize
    initialize called with $source, if available
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    put_and_initialize->render => initialize_and_render
  * Bivio::UI::XML::Widget::JoinTagField
    use NEW_ARGS
  * Bivio::UNIVERSAL
    added code_ref_for_method, unsafe_super_for_method, replace_subroutine
  * Bivio::Util::RealmAdmin
    delete_user allowed if now email
  * Bivio::Util::SQL
    Tuple.thread_root_id  is NOT NULL
  * Bivio::Util::Search
    add usage_error to rebuild_realm
  * Bivio/t/ClassWrapper
    NEW

  Revision 7.70  2009/04/30 22:46:19  aviggio
  * Bivio::Util::Search
    call Search.Xapian->module_version

  Revision 7.69  2009/04/30 20:13:28  aviggio
  * Bivio::Biz::Registrar
    added do_filo
  * Bivio::Search::Xapian
    added module_version and replace underscores in query phrase with spaces
  * Bivio::Type::DateTime
    added warn_deprecated to to_parts with a unixtime passed in
  * Bivio::Type
    added is_specified_literal
  * Bivio::UI::XHTML::Widget::TaskMenu
    the attribute may not exist, don't know why
  * Bivio::Util::Search
    removed destroy in rebuild_db, added module_version command

  Revision 7.68  2009/04/23 22:57:47  moeller
  * Bivio::Biz::Model::FileChangeForm
    changed require_comment to show_comment, comment is now optional always
  * Bivio::Biz::Model::RealmFileTreeList
    added content_length field
  * Bivio::Biz::Model::TaskLogList
    left join TaskLog.user_id on Email.realm_id and RealmOwner.realm_id
  * Bivio::Biz::Model::TupleSlotListForm
    execute the tuple state from the email data immediately, not on mail receive
  * Bivio::Delegate::TaskId
    added mail_reflector_task to FORUM_TUPLE_EDIT task
  * Bivio::UI::FacadeBase
    updated tuple add/update ack,
    changed "realm not found" from warning to trace
    added label
  * Bivio::UI::HTML::Widget::Script
    clear_on_focus was not assigning new className
    first_focus only on fields without onfocus
  * Bivio::UI::View::File
    added content_length columnto file tree list
  * Bivio::UI::View::TaskLog
    only render user info if there is a user
  * Bivio::UI::View::Tuple
    changed edit_mail() to edit_imail() for in-place rendering

  Revision 7.67  2009/04/22 17:58:49  aviggio
  * Bivio::BConf
    fpc: Need to merge two hashes in default_merge_overrides so don't
    clobber Bivio::Test::Language::HTTP config
  * Bivio::Mail::Common
    doc
  * Bivio::Util::HTTPD
    search lib64  for apache2
  * Bivio::Util::HTTPStats
    awstats isn't available on SuSE so make import of icons conditional

  Revision 7.66  2009/04/22 05:59:04  aviggio
  * Bivio::PetShop::Util::SQL
    Create search test files

  Revision 7.65  2009/04/21 22:42:36  aviggio
  * Bivio::Biz::Model::SearchList
    Prevent undef result field values
  * Bivio::Search::Parser
    Add path to Xapian postings, factor underscores
  * Bivio::Search::Xapian
    Remove unreferenced $_MRF

  Revision 7.64  2009/04/20 22:59:04  moeller
  * Bivio::Biz::Model::CRMThreadRootList
    added order_by columns back

  Revision 7.63  2009/04/18 01:06:01  nagler
  * Bivio::BConf
    v9: enable_log => 1, unused_classes => [], ignore_dashes_in_recipient,
    and deprecated_text_patterns => 0
  * Bivio::Biz::Action::UserCreateDone
    temporary fix: redirect to site_root if no UserRegisterForm
  * Bivio::Biz::Model::CRMForm
    use TupleTagForm.TUPLE_TAG_PREFIX
  * Bivio::Biz::Model::CRMThread
    defined TUPLE_TAG_PREFIX
  * Bivio::Biz::Model::CRMThreadRootList
    moved most order_by fields to other
    left join on TupleTag and customer info
    Added tuple_tag_find_slot_value/type
  * Bivio::Biz::Model::SearchForm
    fpc
  * Bivio::Biz::Model::TaskLogList
    added CLEAR_ON_FOCUS_HINT & get_filter_value()
    detecting which type of query word was incorrect
  * Bivio::Biz::Model::TaskLogQueryForm
    added CLEAR_ON_FOCUS_HINT & get_filter_value()
    bug in get_filter_value
  * Bivio::Biz::Model::TupleSlotDefList
    b_use
  * Bivio::Biz::Model::TupleSlotType
    use Bivio::Base
  * Bivio::Biz::Model::TupleTagForm
    added tuple_tag_find_slot_type/value
  * Bivio::IO::Config
    added assert_version
  * Bivio::PetShop::BConf
    in Bivio.BConf
  * Bivio::ShellUtil
    assert_have_user
  * Bivio::Test::WikiText
    added wiki_uri_to_req
  * Bivio::Type::CRMThreadStatus
    PENDING_CUSTOMER
  * Bivio::UI::FacadeBase
    rename ?/bp/* is FORUM_WIKI_VIEW
  * Bivio::UI::HTML::Widget::Script
    fixed onload function call list
    added support for image thumbnail popups
  * Bivio::UI::View::CRM
    factored out internal_thread_root_list_columns
  * Bivio::UI::View::CSS
    added support for image thumbnail popups
    .msg .actions => border none
  * Bivio::UI::View::TaskLog
    use ClearOnFocus and increase size of box
    increased size of x_filter field
  * Bivio::UI::XHTML::Widget::TupleTagSlotLabel
    added internal_as_string
  * Bivio::UI::XHTML::Widget::TupleTagSlotValue
    NEW
  * Bivio::Util::CRM
    b_use
  * Bivio::Util::HTTPStats
    init_report_forum => init_forum
  * Bivio::Util::SiteForum
    init_realms calls HTTPStats->init_forum if config v3

  Revision 7.62  2009/04/16 13:01:18  nagler
  Release notes:
  * Bivio::Biz::Model::RealmMailBounce
    fixed base to be Bivio::Base
    copy
  * Bivio::Biz::Model::TupleDefListForm
    allow deleting a schema tuple def slot, remap existing data
    changed tuple iteration to be unauth, to catch def used across realms
  * Bivio::Delegate::SimpleWidgetFactory
    rmpod
    copy and more syntax
    Integers now route to Integer widget
  * Bivio::UI::FacadeBase
    removed unused FormError label
    factored out _unsafe_realm_id()
    Added xlink_site_reports
  * Bivio::UI::View::CSS
    tools are now a border
    border color for separator
  * Bivio::UI::Widget::URI
    format_method can be overriden
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    site_reports added
    alphabetized (by hand, need sortign)
  * Bivio::Util::SQL
    need initialize fully
    fpc

  Revision 7.61  2009/04/15 02:55:05  nagler
  * Bivio::Biz::Model::SearchForm
    Added get_search_value and CLEAR_ON_FOCUS_HINT
  * Bivio::Biz::Model::SearchList
    fixed CRM link rendering
  * Bivio::UI::HTML::Widget::JavaScriptString
    NEW
  * Bivio::UI::HTML::Widget::Script
    added JAVASCRIPT_B_CLEAR_ON_FOCUS
  * Bivio::UI::XHTML::Widget::ClearOnFocus
    NEW
  * Bivio::UI::XHTML::Widget::SearchForm
    Added ClearOnFocus

  Revision 7.60  2009/04/14 22:09:38  moeller
  * Bivio::Biz::Model::CRMThread
    strip mailer noise (e.g. FWD:, RE:, etc) from Subject
  * Bivio::Search::Parser::RealmFile::PDF
    if the pdftotext dies, warn the die attributes to avoid log parser failures
    with Bivio::Die::DIE
  * Bivio::UI::HTML::Widget::Grid
    fixed hide_empty_cells
  * Bivio::Util::SiteForum
    added add_default_staging_suffix

  Revision 7.59  2009/04/14 13:29:07  nagler
  * Bivio::Agent::Embed::Dispatcher
    die in internal_server_redirect_task
  * Bivio::Agent::Request
    format_stateless_uri takes a task_id as a hash now
  * Bivio::Auth::Realm
    added owner_name_equals()
  * Bivio::BConf
    cannot_mail & feature_bulletin
  * Bivio::Biz::Action::RealmMail
    renamed MAIL_LIST_WANT_TO_USER to BULLETIN_MAIL_MODE
  * Bivio::Biz::File
    added write()
  * Bivio::Biz::FormModel
    save_label in process was not working if the returned hash_ref didn't
    have a {query}
  * Bivio::Biz::Model::CRMThread
    bug in _strip_subject; need to clean, then strip
  * Bivio::Biz::Model::Forum
    abstracted get_parent_id() in anticipation of moving parent_realm_id
    to RealmDAG
  * Bivio::Biz::Model::GroupUserForm
    document change_main_role
  * Bivio::Biz::Model::MailForm
    factored out internal_format_incoming
    added $realm_mail to internal_format_from
  * Bivio::Biz::Model::RealmMailBounce
    log file using Bivio::Biz::File->write()
  * Bivio::Biz::Model::UserCreateForm
    added join_site_admin_realm()
  * Bivio::Biz::Model::UserRegisterForm
    added add_site_admin_user()
    moved add_site_admin_user to UserCreateForm->join_site_admin_realm
  * Bivio::Delegate::RowTagKey
    renamed MAIL_LIST_WANT_TO_USER to BULLETIN_MAIL_MODE
  * Bivio::Delegate::SimplePermission
    added FEATURE_BLOG
  * Bivio::Delegate::TaskId
    added GROUP_BULLETIN_FORM and GROUP_BULLETIN_REFLECTOR
  * Bivio::HTML
    escape() should map "'" to &#39; always
  * Bivio::Mail::Address
    added format and format_with_brackets
    format already implemented as RFC822->format_mailbox
  * Bivio::PetShop::Util::SQL
    _init_crm previously moved to TestCRM->_init_bunit
    added _init_bulletin()
    move _init_site_admin() to the top of the list
    added better name generation for display_name of bulletin
  * Bivio::ShellUtil
    _setup_for_main sets is_secure, since this operates locally
    and is by definition secure.  This is important for Agent.Embed
    added is_execute
  * Bivio::Test::Language::HTTP
    send_mail() now accepts multiple emails in $to_email (use an array_ref)
  * Bivio::Type
    Fixed escape_xml to use Bivio::XML->escape
  * Bivio::UI::FacadeBase
    added GROUP_BULLETIN_FORM and GROUP_BULLETIN_REFLECTOR
    removed ?/bp/* change, because not ready for prime time
  * Bivio::UI::HTML::Widget::Grid
    fix hide_empty_cells
  * Bivio::UI::View::CSS
    widen .action in .msg
  * Bivio::UI::View::Mail
    added GROUP_BULLETIN_FORM to actions
  * Bivio::UI::XHTML::ViewShortcuts
    don't override Boolean spacing if wf_class is present
    added hide_empty_cells to vs_grid3
    added vs_can_group_bulletin_form
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    moved WikiText use into method to avoid subclassing problems
  * Bivio::Util::HTTPD
    Real ShellUtil (main is now run)
    run_background added
    updated stderr.log location in print()
  * Bivio::Util::SQL
    added internal_upgrade_bulletin_staging()
    removed bulletin_staging ugprade
  * Bivio::Util::SiteForum
    added BULLETIN and BULLETIN_STAGING forums
    added better name generation for display_name of bulletin

  Revision 7.58  2009/04/03 23:43:50  nagler
  * Bivio::Biz::Model::TaskLogList
    added can_iterate,
    interprets [\d\-]+ as date
    generalize date code
  * Bivio::Biz::Model::TaskLogQueryForm
    added set_filter()
    fixed execute_empty() order so hint doesn't get clobbered
  * Bivio::Type::DateTime
    set_local_time_part handles Date properly
  * Bivio::UI::View::TaskLog
    moved filter field to internal_add_filter() for subclasses

  Revision 7.57  2009/04/03 17:43:10  nagler
  * Bivio::Biz::Model::CRMThread
    fix bug where subject matches, but no number, and there references
    pointing back to original message.  Might be a reply from Gmail which
    tosses subject-modified message for the sender
  * Bivio::Biz::Model::Tuple
    be explicit about thread changes
  * Bivio::Biz::Registrar
    import object, if not a ref
  * Bivio::Type::MailFileName
    no longer includes subject
  * Bivio::Util::HTTPD
    apache2 fix
  * Bivio::Util::SQL
    RealmMail->create_from_file went away

  Revision 7.56  2009/04/03 16:35:53  dobbs
  * Bivio::Biz::Model::TaskLogList
    remove putting query on List.  Not sure why

  Revision 7.55  2009/04/02 21:37:22  dobbs
  Release notes:
  * Bivio::BConf
    remove -MAIL_READ from admin_only_forum_email
  * Bivio::Biz::Model::CRMThread
    create a new case, if the thread is old, but subject didn't match
  * Bivio::Biz::Model::RealmFile
    application/x-perl is text
  * Bivio::Biz::Model::TaskLogQueryForm
    removed copied code
  * Bivio::Biz::Model::TupleDefListForm
    handle editing and adding new rows to an in-use schema
  * Bivio::Biz::Model::TupleSlotListForm
    minor refactoring
  * Bivio::Biz::Model::WikiForm
    fixed execute_cancel to go back to page, if it already exists
  * Bivio::Delegate::TaskId
    load TupleSlotTypeList for schema editing
    added _CSV tasks for TaskLog tasks
  * Bivio::PetShop::View::Base
    added "Tables" top level link
  * Bivio::Test::HTMLParser::Cleaner
    decode &#39; and &quot;
  * Bivio::Type::Date
    added get_default()
  * Bivio::UI::FacadeBase
    added all standard tools to xhtml_dock_left_standard
    added new tuple FormErrors
    added TaskLog _CSV tasks
  * Bivio::UI::View::TaskLog
    added list_csv(), link to spreadsheet from tools
  * Bivio::UI::View::Tuple
    allow editing an in-use schema,
    added label_ok to cell class
  * Bivio::Util::SQL
    removed init_project

  Revision 7.54  2009/03/28 04:05:41  moeller
  * Bivio::Biz::Model::UserRegisterForm
    clear_errors() before redirecting to reset password task
  * Bivio::UI::View::Mail
    added excerpt_column()
  * Bivio::Util::Release
    i386 is default
    use i586, and set i386 where appropriate

  Revision 7.53  2009/03/27 23:46:37  dobbs
  * Bivio::Biz::FormModel
    assert that execute result is not set if the form has an error
  * Bivio::UI::View::CSS
    added font-size: 100% for footer so font renders correctly
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    added b-menu-source and b-menu-target

  Revision 7.52  2009/03/26 11:52:32  nagler
  * Bivio::Util::LinuxConfig
    added sh_param
    don't run grpconv unless /etc/gshadow, SuSE doesn't like this
  * Bivio::Util::Release
    don't add copyright
    added license
    configure rpm_arch, don't rely on feature extraction which will vary
    by distro
    Clear out suse_check with a %define

  Revision 7.51  2009/03/25 17:06:59  nagler
  * Bivio::Agent::HTTP::Request
    apache2 port
  * Bivio::Agent::Request
    added apache_version()
    change apache_version to if_apache_version
  * Bivio::IO::Config
    if_version was not checking $else for 'CODE'
  * Bivio::UI::XML::Widget::AtomFeed
    rollback to Atom 0.3

  Revision 7.50  2009/03/24 17:53:03  dobbs
  * Bivio::Agent::HTTP::Form
    avoid use of ?=
  * Bivio::BConf
    changed b-test to bivio test
  * Bivio::Biz::Model::CalendarEvent
    don't add admins as RealmUser
  * Bivio::Biz::Model::GroupUserList
    add registration date to UnapprovedApplicantList
  * Bivio::Biz::Model::RealmMailBounce
    removed (?=)
  * Bivio::Biz::Model::RoleBaseList
    group_concat requires a string in Postgres 8.3 so force ru.role to be
    a string
  * Bivio::PetShop::Util::SQL
    removed ?=
  * Bivio::SQL::Connection::Postgres
    relax contraint violation regexp, because pg guys seem to change it for random reasons
    remove (?=) in certain cases
  * Bivio::Test::Request
    setup_http sets up get_server_port and hostname
  * Bivio::Test::Util
    changed b-test to bivio test
  * Bivio::Type::GeomNumber
    removed ?=
  * Bivio::Type::Secret
    protect calls with eval
  * Bivio::UI::FacadeBase
    add registration date to UnapprovedApplicantList
    use SITE_REALM_NAME to generate other names
  * Bivio::UI::HTML::Widget::Script
    add javascript to enable dropdown menus in IE6
  * Bivio::UI::View::SiteAdmin
    add registration date to UnapprovedApplicantList
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    add javascript to enable dropdown menus in IE6
  * Bivio::UI::XML::Widget::AtomFeed
    update xmlns to match Atom 1.0 spec

  Revision 7.49  2009/03/13 23:01:10  moeller
  * Bivio::Biz::Model
    added tracing for put_on_request(), delete_from_request()
  * Bivio::Delegate::RowTagKey
    added TIME_ZONE
  * Bivio::Type::Time
    now() was broken

  Revision 7.48  2009/03/12 19:23:30  nagler
  * Bivio::Type::Date
    fixed now
  * Bivio::Type::DateTime
    added to_alert
    added to_time_parts and to_date_parts
    is_valid_specified
  * Bivio::Type::Time
    adde to_literal_dammit
    now() was broken
  * Bivio::UI::FacadeBase
    catch db unavailable on fresh create

  Revision 7.47  2009/03/10 23:01:41  moeller
  * Bivio::Agent::HTTP::Request
    get_content() now accepts an IO::File for the data,
    read request data in chunks
    cleaned up get_content to check errors
  * Bivio::Biz::Action::RemoteCopy
    added uri to remote_list err
  * Bivio::Biz::Action::SVNTunnel
    use a response_file for results
  * Bivio::Biz::Action::TunnelBase
    if content-length of request is too big, buffer it in a file and send chunks
    buffer responses to a file as well
    fixed content() call
    close content file, then reopen in 'w' mode
  * Bivio::Biz::Model::RemoteCopyListForm
    execute_ok_end may be called in_error so need to return
  * Bivio::Biz::Model::TaskLogList
    put the x_filter on the query so that $list->format_uri works
  * Bivio::PetShop::Util::SQL
    factored out create_user_with_account
    root is created in TestUser->init_adm so SiteForum->init_files works
  * Bivio::PetShop::Util::TestUser
    root is created in TestUser->init_adm so SiteForum->init_files works
  * Bivio::UI::FacadeBase
    fix RemoteCopyListForm.want_realm.SYNTAX_ERROR
    added HelpWiki.title for GROUP_USER_FORM
  * Bivio::UNIVERSAL
    internal_data_section accepts $op to callback on lines
  * Bivio::Util::RealmUser
    audit_all_users was iterating over all RealmUser records instead of
    unique users in realm.  Output needed to be sorted by name so
    predictable for tests.
  * Bivio::Util::TestUser
    cleaned up init_adm so feature tests what it is doing

  Revision 7.46  2009/03/08 22:19:45  nagler
  * Bivio::Biz::Model::TaskLogList
    added NOT_ILIKE
  * Bivio::Delegate::Role
    remove UNUSED_11
  * Bivio::Delegate::TaskId
    missing FEATURE_TASK_LOG on GROUP_TASK_LOG
  * Bivio::SQL::Statement
    added NOT_ILIKE
  * Bivio::Util::SQL
    added feature_task_log2
    mark sentinel on unused_11 and site_admin_forum_users on db create

  Revision 7.45  2009/03/08 12:54:03  nagler
  * Bivio::Biz::Model::RealmFileMD5List
    don't treat root specially, just an optimization

  Revision 7.44  2009/03/07 22:20:06  nagler
  * Bivio::Biz::Model::SearchForm
    revert 1.2
  * Bivio::PetShop::Util::SQL
    must be https to petshop
    data for remote-copy.btest
  * Bivio::UI::FacadeBase
    fixed RemoteCopyListForm.to_update/delete/create
    added RemoteCopyListForm.empty_realm
  * Bivio::UI::HTML::Widget::Tag
    added tag_empty_value
  * Bivio::UI::View::SiteAdmin
    wrap to_update in prose
    messages for empty_realm

  Revision 7.43  2009/03/07 14:25:07  nagler
  * Bivio::Biz::Action::UnadornedPage
    surround result with <html><body> if text/html is result
  * Bivio::Biz::Model::SearchForm
  * Bivio::Delegate::TaskId
    require_secure on site_admin tasks
  * Bivio::PetShop::Util::SQL
    added PublicPage
  * Bivio::UI::FacadeBase
    renamed Realm Hits => Hits
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    remote_file_copy => remote_copy

  Revision 7.42  2009/03/07 02:50:38  nagler
  * Bivio::Biz::Model::SearchForm
  * Bivio::Delegate::TaskId
    renamed RemoteFileCopy => RemoteCopy
  * Bivio::PetShop::Util::SQL
    renamed RemoteFileCopy => RemoteCopy
  * Bivio::UI::FacadeBase
    renamed RemoteFileCopy => RemoteCopy
  * Bivio::UI::View::SiteAdmin
    renamed RemoteFileCopy => RemoteCopy

  Revision 7.41  2009/03/07 00:06:59  moeller
  * Bivio::BConf
    feature_task_log
  * Bivio::Biz::Action::BasicAuthorization
    enable with Config version 1
  * Bivio::Biz::Model::RemoteFileCopyList
    uri could be empty if it was /
  * Bivio::Biz::Model::TaskLogList
    added auth_id
    split the filter on spaces
    added internal_left_join_model_list()
  * Bivio::Biz::PropertyModel
    added test_unauth_delete_all
  * Bivio::Delegate::SimplePermission
    added FEATURE_TASK_LOG
  * Bivio::Delegate::TaskId
    added GROUP_TASK_LOG
  * Bivio::PetShop::Util::SQL
    task_log support
  * Bivio::PetShop::View::Base
    added GROUP_TASK_LOG
  * Bivio::SQL::ListQuery
    auth_id checked only in ListModel
  * Bivio::UI::FacadeBase
    removed Install Files => Remote Copy
  * Bivio::UI::View::SiteAdmin
    moved to TaskLog.pm

  Revision 7.40  2009/03/06 18:01:15  moeller
  * Bivio::Biz::Model::TaskLog
    don't import UserLoginForm unless enabled, because UserLoginForm
    registers with the cookie handler
  * Bivio::PetShop::Util::SQL
    Fixed RemoteFileCopy tests to use different folders
  * Bivio::SQL::PropertySupport
    added TaskLog to unused_classes

  Revision 7.39  2009/03/06 00:48:28  nagler
  * Bivio::Agent::Dispatcher
    factored out internal_server_redirect_task
  * Bivio::Agent::Embed::Dispatcher
    factored out internal_server_redirect_task
  * Bivio::Agent::Reply
    Added set_http_status, set_output, etc. from AgentHTTP.Reply
  * Bivio::Agent::Task
    handle_post_execute_task gets called for redirects now
    added a warning so $_COMMITED doesn't get set if not in an execute() scope
  * Bivio::BConf
    Added AgentEmbed
  * Bivio::Biz::Action::Acknowledgement
    save_label should be called in handle_pre_execute_task, not
    handle_pre_auth_task
  * Bivio::Biz::Action::EasyForm
    RealmSettingsList renamed get_value to get_setting
    RealmSettingsList renamed get_value to get_setting
  * Bivio::Biz::Action::TunnelBase
    use response->content_ref rather than response->content to avoid data copy
  * Bivio::Biz::Model::EditDAVList
    include offending value in error message when dav_put() blows up on an
    invalid column value
  * Bivio::Biz::Model::FileChangeForm
    added require_comment config value, false by default
  * Bivio::Biz::Model
    allow hash_ref in field_decl
  * Bivio::Delegate::SimpleTypeError
    added NO_ACCESS
    removed NO_ACCESS
  * Bivio::Delegate::TaskId
    Added UNADORNED_PAGE, REMOTE_FILE_GET, REMOTE_FILE_COPY_FORM
    added SITE_ADMIN_TASK_LOG
    Moved REMOTE_FILE_GET & REMOTE_FILE_COPY_FORM to sys_admin
    TaskLogQueryForm
  * Bivio::PetShop::BConf
    set TaskLog.enable_log config
  * Bivio::PetShop::Delegate::TaskId
    Task2.bunit support
    want_basic_authorization
  * Bivio::PetShop::Test::PetShop
    call basic_authorization() from do_logout
    create_forum() now accepts a hash to set forum settings
    added create_crm_forum()
  * Bivio::PetShop::View::Base
    added link to SITE_ADMIN_TASK_LOG
    fixed link from FORUM_FILE to FORUM_FILE_TREE_LIST
    moved TaskLog to SiteAdminDropDown
  * Bivio::SQL::DDL
    added task_log_t
  * Bivio::Test::Language::HTTP
    basic_authorization clears Authorization if given no credentials
    do_logout calls basic_authorization()
  * Bivio::Test::Reply
    Moved set_http_status, set_output, etc. to Agent.Reply
  * Bivio::Test::Request
    use new_mode of Bean so can set/get headers, etc.
  * Bivio::Type::EmailArray
    added UNDERLYING_TYPE
  * Bivio::Type::StringArray
    sort_unique returns StringArray
    added UNDERLYING_TYPE
    sort_unique returns instance when no $value ($self)
  * Bivio::UI::Constant
    added unsafe_get_value
  * Bivio::UI::FacadeBase
    Added UNADORNED_PAGE, REMOTE_FILE_GET, REMOTE_FILE_COPY_FORM
    added TaskLog related labels
    _merge now reverses components so that base gets executed first
    tasklog formatting
  * Bivio::UI::HTML::Widget::StyleSheet
    AgentEmbed call_task returns AgentEmbed.Reply so get_output needs to
    be called
    fpc
  * Bivio::UI::HTML::Widget::Table
    removed newlines around table title
  * Bivio::UI::View::Base
    Comment xhtml() Director usage
  * Bivio::UI::View::CSS
    tasklog formatting
    fpc
  * Bivio::UI::Widget::With
    supports StringArray
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    standards control on Xlink via want_* in Facade
  * Bivio::UI::XHTML::Widget::StandardSubmit
    call Prose() on label
  * Bivio::UI::XHTML::Widget::WikiText::Embed
    AgentEmbed call_task returns AgentEmbed.Reply so get_output needs to
    be called
  * Bivio::Util::CSV
    parse_records can return the headings
  * Bivio::Util::RealmAdmin
    doc
  * Bivio::Util::SQL
    added internal_upgrade_db_task_log()

  Revision 7.38  2009/02/27 15:30:34  nagler
  * Bivio::Agent::HTTP::Reply
    add task name to error message when a task is missing a UI item
  * Bivio::Biz::Action::UserCreateDone
    Use UserCreateForm->if_unapproved_applicant_mode
  * Bivio::Biz::Model::RealmUser
    unauth_delete_user: use if_unapproved_applicant_mode to delete, too
  * Bivio::Biz::PropertyModel
    added unsafe_load_first
    fixed unauth_/iterate_start to allow query or order_by as first param
  * Bivio::PetShop::BConf
    moved unapproved_applicant_mode to UserCreateForm
  * Bivio::SQL::PropertySupport
    attempt to change primary key field warning is removed
  * Bivio::ShellUtil
    added verbose
  * Bivio::Test::ForumUserUnit
    initialize_fully
  * Bivio::Test::Language::HTTP
    added uri_and_local_mail()
  * Bivio::Test::Unit
    initialize_fully
  * Bivio::Test::Util
    output failure if -verbose
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    use if_unapproved_applicant_mode
  * Bivio::Util::SQL
    use if_unapproved_applicant_mode

  Revision 7.37  2009/02/20 16:38:10  moeller
  * Bivio::Type::Number
    don't use 1e-20 format when talking to GMP
  * Bivio::Type::Time
    $am_pm may be uppercase
  * Bivio::UI::FacadeBase
    fixed bug in dock_left_standard FORUM_FILE_TREE_LIST instead of
    FORUM_FILE_LIST
  * Bivio::UI::HTML::Widget::Checkbox
    use MultiCheckHandler for ListForms
  * Bivio::UI::XHTML::Widget::WikiText
    test anchors (^M#a)

  Revision 7.36  2009/02/13 23:16:05  dobbs
  * Bivio::ShellUtil
    -input must be Text (not FilePath) because -input is sometimes a pipe

  Revision 7.35  2009/02/12 22:45:00  nagler
  * Bivio::Biz::Action::EasyForm
    Added EasyForm RealmSetting
  * Bivio::Delegate::RowTagKey
    EASY_FORM_UPDATE_MAIL_TO removed
  * Bivio::IO::Alert
    added warn_exactly_once
  * Bivio::PetShop::Util::SQL
    Added RealmSettingsList test data
  * Bivio::ShellUtil
    -input should be a FilePath
  * Bivio::Type::FilePath
    added SETTINGS_FOLDER
  * Bivio::UI::HTML::Widget::Form
    render attributes using ControlBase

  Revision 7.34  2009/02/11 18:59:39  dobbs
  * Bivio::Test::Reload
    _modified_ddl() return empty array if no DDL directory
  * Bivio::UI::FacadeBase
    FILE_WRITER in site-admin is just Editor, not Site Editor
    SiteAdminDropDown widget now uses xlinks
  * Bivio::UI::View::CSS
    added margin after div.alphabetical_chooser
  * Bivio::UI::XHTML::Widget::SiteAdminDropDown
    SiteAdminDropDown widget now uses xlinks

  Revision 7.33  2009/02/05 02:47:49  dobbs
  * Bivio::UI::HTML::Widget::Tag
    renamed $a -> $x and $b -> $buf
    add support tag_pre_value and tag_post_value attributes
  * Bivio::UI::View::Base
    fix mime type for feeds
  * Bivio::UI::View::ThreePartPage
    fix mime type for feeds
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    added internal_submenu() to allow subclasses some control over
    rendering of submenus

  Revision 7.32  2009/02/03 04:48:02  dobbs
  * Bivio::Biz::Model::ForbiddenForm
    added unsafe_realm_name_from_context()
  * Bivio::UI::View::Error
    simpler hooks to allow more informative forbidden error messages

  Revision 7.31  2009/01/31 05:19:08  dobbs
  * Bivio::Biz::Action::RealmFile
    empty assert_access
  * Bivio::Biz::Model::RealmFileVersionsList
    minor refactoring
  * Bivio::Biz::Model::UserCreateForm
    want_bulletin was not defaulting correctly
  * Bivio::IO::File
    fix do_lines and map_lines to deal with files which end without a newline
  * Bivio::UI::FacadeBase
    ?/file/* and ?/files/* are two different tasks, now
  * Bivio::UI::View::Error
    add hooks to allow more informative forbidden error messages
  * Bivio::UI::ViewShortcuts
    add hooks to allow more informative forbidden error messages

  Revision 7.30  2009/01/26 22:20:07  dobbs
  * Bivio::Biz::FormModel
    better error message when get_field_as_html() is called on a field
    that is not visible or hidden
  * Bivio::Search::Parser::RealmFile::PDF
    make error checking more robust by checking for Error.*Error
  * Bivio::UI::View::UserAuth
    add hook for subclasses to add extra fields in settings form
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    bmenus now search in site_realm_id if a bmenu is not found in the
    current realm
  * Bivio::Util::Backup
    added rsync_flags to config

  Revision 7.29  2009/01/16 18:46:25  nagler
  * Bivio::SQL::Connection
    made long_query_seconds configurable
  * Bivio::Search::Parser::RealmFile::PDF
    don't treat "continuing anyway" messages as errors
  * Bivio::Type::DateTime
    moved max/min to Type.pm
  * Bivio::Type::Number
    moved max/min to Type.pm
  * Bivio::Type
    moved max/min from Number.pm
  * Bivio::Util::Disk
    afacli needs a valid curses terminal
  * Bivio::Util::HTTPConf
    can_secure off by default
    set SSLRequireSSL and Options +StrictRequire

  Revision 7.28  2009/01/14 18:30:22  dobbs
  * Bivio::Biz::Model::CRMThreadRootList
    make coupling to CRMThreadStatus explicit
  * Bivio::Type::CRMThreadStatus
    corrected coding style:
        get_desc_for_crmqueryform() => get_desc_for_query_form()
    make coupling from CRMThreadRootList explicit
  * Bivio::UI::View::CRM
    corrected coding style:
        get_desc_for_crmqueryform() => get_desc_for_query_form()

  Revision 7.27  2009/01/14 00:16:34  nagler
  * Bivio::Agent::Dispatcher
    rmpod
    undo prev
  * Bivio::Agent::Job::Dispatcher
    rmpod
    copy is_secure and client_addr in params, unless defined
  * Bivio::Biz::Model::CRMThreadRootList
    included LOCKED threads with the OPEN filter -- OPEN now means "Not Closed"
  * Bivio::Test::Language::HTTP
    parameters for extract_uri_from_local_mail() now matches verify_local_mail()
  * Bivio::Type::CRMThreadStatus
    OPEN label is now "Not Closed" in the CRMQueryForm
  * Bivio::UI::View::CRM
    OPEN label is now "Not Closed" in the CRMQueryForm

  Revision 7.26  2009/01/12 22:57:21  nagler
  * Bivio::Agent::Request
    Set no_form = 0 so that form context is carried if trying to format_uri
  * Bivio::Agent::Task
    added better tracing
  * Bivio::Agent::TaskEvent
    set method to server_redirect if there's no uri on the task
    fpc
  * Bivio::Biz::FormContext
    simplified return_redirect
  * Bivio::UI::Task
    do not override no_form, if already set

  Revision 7.25  2009/01/10 01:24:30  nagler
  * Bivio::Delegate::TaskId
    added GROUP_MAIL_RECEIVE_NIGHTLY_TEST_OUTPUT
    require_secure on tasks with passwords
  * Bivio::PetShop::Facade::PetShop
    added mail_receive_task_list and mail_receive_uri to modularize
    MailReceiveDispatchForm tasks
    Added GROUP_MAIL_RECEIVE_NIGHTLY_TEST_OUTPUT
  * Bivio::Test::Language
    allow _ in functions if in Bivio::UNIVERSAL
  * Bivio::Test::Request
    initialize_fully() now accepts facade_name
  * Bivio::Test::Util
    task() now accepts an optional facade name
    nightly_output_to_wiki can take a scalar_ref as an arg
  * Bivio::UI::FacadeBase
    added mail_receive_task_list and mail_receive_uri to modularize
    MailReceiveDispatchForm tasks

  Revision 7.24  2009/01/09 00:34:27  nagler
  * Bivio::Agent::HTTP::Request
    Increased request size limit
    Added put_client_redirect_state and internal_client_redirect
    Fixed up secure redirects
    b_use
  * Bivio::Agent::Request
    factored out need_to_secure_task
    Added CLIENT_REDIRECT_PARAMETERS and EXTRA_URI_PARAM_LIST and
    SERVER_REDIRECT_PARAMETERS
    format_http_toggling_secure is deprecated in V1 or above
    Added internal_client_redirect_args
  * Bivio::Agent::Task
    call need_to_secure_task in handle_pre_auth_task and return the
    redirect (replaces client_redirect_if_not_secure)
  * Bivio::Agent::TaskEvent
    formatting of as_string as internal_as_string
    Call need_to_secure_task for rendering
  * Bivio::Biz::Action::PingReply
    added register_handler
  * Bivio::Biz::Model::ForbiddenForm
    return login_task instead of throwing a server_redirect
  * Bivio::Biz::Model
    fmt of get_request
  * Bivio::Biz::Registrar
    return result of fifo calls
  * Bivio::Delegate::TaskId
    rmpod
  * Bivio::PetShop::View::Example
    added handle_ping_reply
  * Bivio::SQL::Connection
    added handle_ping_reply
    register for ShellUtil handle_piped_exec_child
  * Bivio::Search::Parser::RealmFile::PDF
    called piped_exec instead of backticks so conections are cleaned up properly
  * Bivio::ShellUtil
    added register_handler and calls to handle_piped_exec_child
  * Bivio::Test::Type
    handle_autoload_ok must check is_valid_name to ensure incoming is valid
  * Bivio::Type::DateYearMonth
    parsing in from_sql_column incorrect
  * Bivio::Util::HTTPConf
    removed Societas module reference
  * Bivio::Util::LinuxConfig
    convert ';' to ',' in _add_aliases
  * Bivio::Util::SQL
    removed spurious error msg

  Revision 7.23  2008/12/29 20:17:17  dobbs
  * Bivio::Test::Type
    correct return value for handle_autoload() to match preivous AUTOLOAD behavior
  * Bivio::Test::Unit
    fixed bug in handle_autoload_ok() and handle_autoload()

  Revision 7.22  2008/12/25 00:54:02  dobbs
  * Bivio::Base
    added b_debug
  * Bivio::Biz::Model::CRMThread
    incoming emails now correctly update modified_by_user_id
  * Bivio::Biz::Model::CRMThreadRootList
    fixed bug getting email for CRMThread.modified_by_user_id
  * Bivio::PetShop::Util::SQL
    refactored Util.SQL, added Util.TestCRM and expanded CRM test data
  * Bivio::SQL::ListSupport
    added to_order_by_value and to_group_by_value hooks for Types
  * Bivio::Test::Type
    use handle_autoload instead of overriding AUTOLOAD
  * Bivio::Test::Unit
    AUTOLOAD now calls handle_autoload() if handle_autoload_ok() so
    subclasses have a hook in AUTOLOAD without having to override it.
  * Bivio::Type::DateTime
    added TO_SQL_FORMAT and FROM_SQL_FORMAT
  * Bivio::Type
    added to_order_by_value and to_group_by_value hooks for Types
  * Bivio::UI::XHTML::ViewShortcuts
    removed hide_empty_cells, because didn't work, and doesn't work for
    header when logo is put in empty cell
  * Bivio::UNIVERSAL
    added type()
  * Bivio::Util::SQL
    create_test_db now calls initialize_fully()

  Revision 7.21  2008/12/22 22:04:16  dobbs
  * Bivio::Biz::Model::Email
    set want_bulletin to zero on invalidate
  * Bivio::Biz::Model::ListQueryForm
    fixed bug in setting default_value for Enums
  * Bivio::Type::CRMThreadStatus
    set OPEN as default_value for CRMThreadStatus
  * Bivio::UI::View::UserAuth
    settings_form: don't display empty list widget

  Revision 7.20  2008/12/19 23:56:11  nagler
  * Bivio::Biz::Model::QuerySearchBaseForm
    rmpod
  * Bivio::Biz::Model::RoleBaseList
    added internal_qualifying_roles
  * Bivio::Delegate::Cookie
    was not correctly returning an empty cookie when no cookie
  * Bivio::Delegate::TaskId
    added GROUP_USER_ADD_FORM
  * Bivio::PetShop::Test::PetShop
    added create_user
  * Bivio::PetShop::View::Base
    added link back to PetShop
  * Bivio::Test::Language::HTTP
    internal_assert_no_prose didn't handle multiline
    ignore onblur= events
    internal_assert_no_prose: ignore onfocus & onchange events
    internal_assert_no_prose: ignore all "on" attributes
    fpc
    move email and create user methods to TestUser
  * Bivio::Type::PageSize
    rmpod
    added ROW_TAG_KEY
  * Bivio::UI::FacadeBase
    added GROUP_USER_ADD_FORM
    renamed Users to Roster
  * Bivio::UI::HTML::Widget::AuxiliaryForm
    only TouchCookie if touch_cookie is set
    don't need touch_cookie
  * Bivio::UI::View::CSS
    added .left
    and td.checkbox
  * Bivio::UI::View::GroupUser
    added crosslinks to tasks
    added add_form
  * Bivio::UI::View::UserAuth
    UserSettingsListForm => UserSettingsListForm to allow subscriptions
  * Bivio::Util::SQL
    move email and create user methods to TestUser
  * Bivio::Util::TestUser
    move email and create user methods from SQL
    fixed bug in create

  Revision 7.19  2008/12/15 17:59:35  nagler
  * Bivio::ShellUtil
    todo
  * Bivio::Test::Language::HTTP
    _assert_no_prose => internal_assert_no_prose, and added unit test for
    the code
    fpc
  * Bivio::Test::Util
    check out bOP, too

  Revision 7.18  2008/12/13 22:42:44  nagler
  * Bivio::Test::Language::HTTP
    added _assert_no_prose to validate there are no Prose() elements in
    mail or html responses
  * Bivio::UI::View::SiteAdmin
    vs_text_as_prose
  * Bivio::Util::SQL
    decouple site_admin from site_admin_forum users

  Revision 7.17  2008/12/13 21:31:36  nagler
  * Bivio::BConf
    feature_* is the only permission in category map which should get '*'
    as role.
  * Bivio::Biz::Action::UserCreateDone
    send unapproved_applicant_mail if unapproved_applicant_mode
  * Bivio::Biz::Model::CRMThreadRootList
    CRM status filter now includes New threads in the Open filter
  * Bivio::Biz::Model::GroupUserForm
    created methods to support external calling
  * Bivio::Biz::Model::GroupUserList
    moved internal_qualify_role to RoleBaseList
    use realm_owner_* feature of FacadeComponent.Text
    can_iterate is inherited
  * Bivio::Biz::Model::RealmUserAddForm
    todo
  * Bivio::Biz::Model::RoleBaseList
    UNCONFIRMED_EMAIL no longer a role
    move internal_qualify_role from GroupUserList
    remove export of "auxiliary" roles
  * Bivio::Biz::Model::RoleSelectList
    use realm_owner_* feature of FacadeComponent.Text
  * Bivio::Biz::Model::UnapprovedApplicantForm
    added internal_send_mail
  * Bivio::Biz::Model::UserRegisterForm
    added unapproved_applicant_mode support
  * Bivio::Biz::Model::UserSettingsForm
    todo
  * Bivio::Delegate::Role
    added get_main_list
    fixed calls to not use $proto/$self, because doesn't work in delegation
  * Bivio::Delegate::TaskId
    added lock to unapproved_applicant_form
  * Bivio::PetShop::BConf
    unapproved_applicant_mode is on
    use site-admin
  * Bivio::PetShop::Test::PetShop
    login_as follows register link if there
  * Bivio::PetShop::Util::SQL
    added site_adm and audit_all_users
  * Bivio::PetShop::View::Base
    added call to SiteAdminDropDown()
  * Bivio::Test::Language::HTTP
    follow_link_in_mail uses extract_uri_from_local_mail
  * Bivio::Type::FileField
    todo
  * Bivio::UI::FacadeBase
    added SITE_REPORTS
    UnapprovedApplicantForm support
  * Bivio::UI::Font
    todo
  * Bivio::UI::HTML::Widget::Table
    removed header nowrap
  * Bivio::UI::Text::Widget::Link
    rmpod
    supports widgets as values
    modernized
  * Bivio::UI::Text
    replaced get_value_for_auth_realm with qualifier on get_value of
    realm_owner_<owner_name>.
  * Bivio::UI::View::CSS
    qualified dock dd_menu better so would override dock defaults
  * Bivio::UI::View::SiteAdmin
    unapproved_applicant_form_mail
  * Bivio::UI::View
    doc
    catching missing req argument, because error cascades
  * Bivio::UI::XHTML::ViewShortcuts
    use EmptyTag, not <br />
  * Bivio::UI::XHTML::Widget::TaskMenu
    deprecate lowercase task_ids
  * Bivio::UI::XHTML::Widget::WikiText::SWFObject
    support FLV files in addition to SWF files
  * Bivio::UNIVERSAL
    todo
  * Bivio::Util::HTTPStats
    use site-reports from FacadeBase
    modernize
  * Bivio::Util::RealmUser
    fixed lots of bugs
  * Bivio::Util::Release
    todo
  * Bivio::Util::SQL
    site_admin_forum upgrade
  * Bivio::Util::SiteForum
    added REPORTS_REALM and ADMIN_REALM
  * Bivio::Util::TestUser
    added create()

  Revision 7.16  2008/12/08 05:41:04  nagler
  * Bivio::Agent::Request
    added is_site_admin and match_user_realms
    attributes that begin with 'auth_realm.' and 'auth_user.' are deleted
    when set_realm and set_user are called, respectively.  This allows
    easy caching bound to auth_realm and auth_user state.
  * Bivio::Biz::Model::GroupUserForm
    SELECT_ROLES => internal_select_roles; roles conditional on auth_realm_is_site
    ShellUtil.RealmUser->audit_user is called on execute ok
  * Bivio::Biz::Model::GroupUserList
    use FacadeComponent.Text->get_value_for_auth_realm
  * Bivio::Biz::Model::RoleSelectList
    use FacadeComponent.Text->get_value_for_auth_realm
  * Bivio::Biz::Model::UserCreateForm
    default want_bulletin to true
  * Bivio::Biz::Model::UserRegisterForm
    Added config parameter unapproved_applicant to allow for
    unapproved_applicant workflow
  * Bivio::Delegate::Role
    added get_application_specific_list
  * Bivio::Delegate::TaskId
    SITE_ADMIN_USER_LIST uses SiteAdminUserList
    Fixed UNAPPROVED_APPLICANT workflow
  * Bivio::IO::Zip
    iterate_members() passes contents as string ref now
  * Bivio::PetShop::BConf
    added config for ShellUtil.RealmUser tests
  * Bivio::PetShop::Facade::PetShop
    show ForumDropDown
    support for unapproved_applicant workflow
  * Bivio::PetShop::Test::PetShop
    added groupware mode support, which eases testing for the bOP
    groupware code
  * Bivio::PetShop::Util::SQL
    added support for ShellUtil.RealmUser testign
  * Bivio::PetShop::View::Base
    made menu more flexible; added dropdown for admin tasks
  * Bivio::ShellUtil
    usage_error should always end with an "\n"
  * Bivio::Test::Language::HTTP
    added follow_link_in_mail
    select options are now patterns
  * Bivio::UI::FacadeBase
    name the atom feeds .atom
    FORUM_CALENDAR_EVENT_LIST_RSS is now called .atom too (.rss still supported)
    added auth_realm_is_site
    added support for UNAPPROVED_APPLICANT
  * Bivio::UI::View::SiteAdmin
    unapproved_applicant_form; fix bug in user_list

  Revision 7.15  2008/12/02 22:56:58  dobbs
  * Bivio::Biz::Model::ForumUserAddForm
    use Bivio::Base
  * Bivio::Biz::Model::GroupUserList
    fix realmname before looking up
  * Bivio::Delegate::TaskId
    canceling from FORUM_BLOG_CREATE lands on FORUM_BLOG_LIST (was
    throwing a server error)

  Revision 7.14  2008/12/02 04:15:43  dobbs
  * Bivio::Biz::Model::CRMThread
    replies to existing threads are now bound to the existing thread even
    when they're missing the crm_thread_num
  * Bivio::Biz::Model::RealmRole
    dereference PermissionSet->get_empty value
  * Bivio::UI::Text
    tag parts may now contain realm names,
    removed \w+ constraint for level stripping

  Revision 7.13  2008/12/01 20:31:04  dobbs
  * Bivio::BConf
    feature_site_adm => feature_site_admin
  * Bivio::Biz::ExpandableListFormModel
    internal_initialize_list() is only called once by a check in
    ListFormModel so don't need to duplicate here
  * Bivio::Biz::ListFormModel
    internal_initialize_list() is only called once by a check in _execute_init()
    deprecate returns from execute_empty/ok so we can know if apps are
    actually using this feature, and fix them.
  * Bivio::Biz::Model::GroupUserForm
    don't add MEMBER if ADMINISTRATOR or ACCOUNTANT
  * Bivio::Biz::Model::RealmFile
    call unauth_create_or_update
  * Bivio::Biz::Model::RealmRole
    added EMPTY_PERMISSION_MAP
    get_permission_map() ensures all roles are defaulted
  * Bivio::Biz::Model::RoleBaseList
    don't assume all roles exist
  * Bivio::Biz::Model::UserRegisterForm
    syntax
  * Bivio::Delegate::Role
    remove UNCONFIRMED_EMAIL (wrong approach)
  * Bivio::Delegate::SimpleAuthSupport
    call Model.RealmRole->EMPTY_PERMISSION_MAP to ensure all roles are defaulted
  * Bivio::Delegate::SimplePermission
    site_adm => site_admin
  * Bivio::Delegate::TaskId
    View.GroupAdmin => GroupUser
    site_adm => site_admin
    UserCreateDone action
    SiteAdmSubstituteUserForm => SiteAdminSubstituteUserForm
  * Bivio::PetShop::View::Base
    site_adm => site_admin
  * Bivio::Type::UserAgent
    rmpod
    FF2, FF3, Safari, and Chrome now all identify as BROWSER_HTML4
  * Bivio::UI::FacadeBase
    site_adm => site_admin
  * Bivio::UI::XHTML::ViewShortcuts
    site_adm => site_admin
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    b_submenus now render the selected class
  * Bivio::Util::LinuxConfig
    support dotted-decimal in network config (_dig())
  * Bivio::Util::SQL
    role_unused_11: remove UNCONFIRMED_EMAIL (wrong approach)
  * Bivio::Util::SiteForum
    site_adm => site_admin

  Revision 7.12  2008/11/25 21:42:55  dobbs
  * Bivio::Biz::ExpandableListFormModel
    must return $list in internal_initialize_list
  * Bivio::Biz::FormModel
    internal_pre_execute return checked in _call_execute
  * Bivio::Biz::ListFormModel
    reset the cursor
  * Bivio::Biz::Model::BlogCreateForm
    set path_info on return from execute_ok
  * Bivio::Biz::Model::BlogEditForm
    added carry_query and carry_path_info
    carry_path_info is all that's needed
  * Bivio::Biz::Model::BlogList
    fixed deprecation warning from getting html_task
  * Bivio::Biz::Model::GroupUserForm
    fix bugs
  * Bivio::Biz::Model::RoleBaseList
    remove V1 test code
  * Bivio::Test::FormModel
    added req_state and req_state_merge
  * Bivio::UI::FacadeBase
    added GROUP_USER_FORM
  * Bivio::UI::HTML::Widget::InputBase
    removed info()
  * Bivio::UI::View::GroupAdmin
    Added user_form
  * Bivio::UI::XHTML::Widget::TaskMenu
    Removed optional tag parameter.  Use put_unless_exists() instead.
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    TaskMenu no longer accepts optional tag parameter.
    Changed submenu classname from bsubmenu to b_submenu.
  * Bivio::Util::SQL
    move group_concat to first thing in initialize_db

  Revision 7.11  2008/11/17 22:46:43  moeller
  * Bivio::Util::SQL
    changed function begin/end from $$ to ' for older Postgres versions

  Revision 7.10  2008/11/17 21:45:49  dobbs
  * Bivio::BConf
    UI_HTML => UIHTML
    added UIXHTML and UICSS
  * Bivio::Biz::FormContext
    return_redirect returns the TaskEvent params instead of throwing
    exceptions (via client_redirect calls)
  * Bivio::Biz::FormModel
    v9: carry_path_info and carry_query required on default returns
    internal_redirect_next returns rather than throws exceptions (client_redirect)
    b_use values
  * Bivio::Biz::Model::AdmBulletinForm
    internal_redirect_next may return something
  * Bivio::Biz::Model::ConfirmableForm
    internal_redirect_next may return something
  * Bivio::Biz::Model::ConfirmationForm
    internal_redirect_next may return something
  * Bivio::Biz::Model::FileChangeForm
    return TaskEvent params instead of throwing exceptions
  * Bivio::Biz::Model::ForbiddenForm
    internal_redirect_next may return something
  * Bivio::Biz::Model::ForumUserEditDAVList
    database key changed back to RealmUser.user_id
  * Bivio::Biz::Model::ForumUserList
    push down routines from GroupUserList which are explicit to Forums and
    old behavior
  * Bivio::Biz::Model::GroupUserList
    manage privs using new routines in RoleBaseList
  * Bivio::Biz::Model::RealmFileTreeList
    identify empty nodes/folders
  * Bivio::Biz::Model::RoleBaseList
    use group_concat (requires upgrade_db group_concat) to return a single
    row for each realm/user.
    removed all SIZE methods since computation is one per row
    added roles_in_order and roles_by_category
  * Bivio::Biz::Model::UserForumList
    fmt
  * Bivio::Biz::Model::UserLoginForm
    invalid passwords are checked by validate_login
    validate_login prints warnings based on reason for invalid login
  * Bivio::Biz::Model::UserRealmList
    RoleBaseList handles all RealmUser stuff
  * Bivio::Biz::Model::WikiForm
    throw NOT_FOUND if wiki name is invalid rather than DIE
    carry query explicitly
  * Bivio::Delegate::TaskId
    added group_admin compononent with GROUP_USER_LIST and GROUP_USER_FORM
    (not fully tested)
  * Bivio::PetShop::BConf
    v9: carry_query and carry_path_info explicit
  * Bivio::PetShop::Model::OrderForm
    v9: carry_query and carry_path_info explicit
  * Bivio::SQL::Connection::Postgres
    rmpod
  * Bivio::Test::FormModel
    clear path_info/query/form explciity
  * Bivio::Type::Array
    rmpod
    use Bivio::Base
  * Bivio::Type::TreeListNode
    add NODE_EMPTY
  * Bivio::UI::Constant
    added get_widget_value
  * Bivio::UI::FacadeBase
    element for empty node
    Added group_admin component
  * Bivio::UI::HTML::Widget::AuxiliaryForm
    touch the cookie, needed for form posts
  * Bivio::UI::View::Base
    use map name for loading shortcuts
  * Bivio::UI::View::CSS
    specify tree node name font
    put space up between dock and header
  * Bivio::UI::View::File
    Hide change icon if node is read only
  * Bivio::UI::View::Wiki
    Action.WikiText may not be present for invalid wiki named pages
  * Bivio::UI::ViewLanguage
    b_use variables
    use maps for loading classes
  * Bivio::UI::ViewShortcuts
    added vs_debug (not fully tested)
    and b_use
  * Bivio::UI::XHTML::ViewShortcuts
    rename UI_HTML to UIHTML
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    the top level of nested bmenus now get rendered for use as drop down menus
  * Bivio::Util::SQL
    Added internal_upgrade_db_group_concat which simulates MySQL's
    group_concat in Postgres

  Revision 7.9  2008/11/12 22:38:10  nagler
  * Bivio::Auth::Realm
    use b_use
  * Bivio::Auth::RealmType
    get_any_group_list no longer includes GENERAL
  * Bivio::Delegate::TaskId
    CLUB_HOME and FORUM_HOME are ANYBODY and both go to FORUM_WIKI_VIEW
  * Bivio::UI::FacadeBase
    Forum is labed in RealmDropDown
    added RealmDropDown.User
  * Bivio::UI::View::CSS
    fix dd_menu
  * Bivio::UI::XHTML::Widget::TaskMenu
    fmt
    Wrap "xlink" in SPAN if not a Tag or Link
  * Bivio::Util::HTTPConf
    fixed mdc code to include virtual hosts
  * Bivio::Util::SQL
    fmt

  Revision 7.8  2008/11/12 19:13:31  nagler
  * Bivio::Agent::Task
    want_scalar around return value of $method in execute_items
  * Bivio::Biz::FormModel
    want_scalar around return from execute_ok
  * Bivio::Biz::Model::GroupUserList
    fixed cross-join
  * Bivio::Test::Unit
    added builtin_go_dir
  * Bivio::UI::HTML::Widget::SourceCode
    perl2html needs absolute path
  * Bivio::UNIVERSAL
    Added want_scalar
  * Bivio::Util::HTTPConf
    added ssl_mdc attribute for configuring multi-domain ssl certificates
  * Bivio::Util::SQL
    don't run upgrade in Oracle

  Revision 7.7  2008/11/11 23:14:49  dobbs
  * Bivio::Biz::ListModel
    new delegate_method interface
    internal_post_load_row is now defaulted
  * Bivio::Biz::Model::AdmUserList
    new delegator interface
  * Bivio::Biz::Model::ForumUserEditDAVList
    primary key changed on ForumUserList
  * Bivio::Biz::Model::RealmMail
    new delegation interface
  * Bivio::Biz::Model::RealmRole
    minor bug
  * Bivio::Biz::Model::RoleBaseList
    added LOAD_ALL_SIZE and PAGE_SIZE
  * Bivio::Biz::Model::TupleTagForm
    new delegation interface
  * Bivio::Biz::Model::UserCreateForm
    new delegation interface
  * Bivio::Biz::Model
    added get_field_alias_value
  * Bivio::UI::FacadeBase
    ForumUserList -> GroupUserList
  * Bivio::UNIVERSAL
    created better delegate_method interface that uses Bivio::Delegation
    to hold context
  * Bivio::Util::SQL
    forum_features_tuple_motion upgrade
  * Bivio::t::Delegator::I1
    rmpod
  * Bivio::t::UNIVERSAL::DelegateSuper
    test new delegation interface
  * Bivio::t::UNIVERSAL::Delegator
    new delegation interface
  * Bivio::t::UNIVERSAL::DelegatorSuper
    new delegation interface

  Revision 7.6  2008/11/11 00:29:27  dobbs
  * Bivio::Agent::Request
    removed too much tracing on push_txn_resource
    map_user_realms accepts filter which is an array of values
    internal_get_realm_for_task accepts $no_die
  * Bivio::Agent::Task
    use RealmType->equals_or_any_group_check
  * Bivio::Auth::RealmType
    added equals_or_any_group_check, get_any_group_list, and self_or_any_group
  * Bivio::BConf
    Added FEATURE_BLOG/CALENDAR/etc. to respective tasks
    added realm role category maps:
      feature_file
      feature_blog
      feature_wiki
      feature_dav
      feature_mail
      feature_calendar
  * Bivio::Biz::Action::ClientRedirect
    Format uris without carrying query/path_info
    use self_or_any_group
  * Bivio::Biz::Action::MySite
    Fixed my-site to redirect properly if path_info matches user task
  * Bivio::Biz::Action::RealmlessRedirect
    use self_or_any_group and map_user_realms
  * Bivio::Biz::Model::AdmUserList
    added RealmOwner join and Email.want_bulletin
  * Bivio::Biz::Model::CRMForm
    removed call_super_before
  * Bivio::Biz::Model::RealmDAVList
    use RealmType->self_or_any_group
  * Bivio::Biz::Model::RealmOwner
    use get_non_zero_list
  * Bivio::Delegate::RealmType
    renamed UNKNOWN to ANY_GROUP
  * Bivio::Delegate::SimplePermission
    Added FEATURE_BLOG/CALENDAR/etc.
  * Bivio::Die
    stack_trace config always produces a stack trace
  * Bivio::PetShop::Delegate::Permission
    renumber permissions (why were they 21 and 22?)
  * Bivio::Test::Reload
    look for changed files in ddl
  * Bivio::UI::FacadeBase
    added labels for ForumDropDown
  * Bivio::UI::HTML::Widget::AuxiliaryForm
    removed call_super_before
  * Bivio::UI::Task
    renamed RealmType->UNKNOWN to ANY_GROUP
    use RealmType->equals_or_any_group_check
  * Bivio::UI::View::Blog
    add HIDE_IS_PUBLIC to allow override
    added TEXT_AREA_COLS and TEXT_AREA_ROWS to control dimensions of
    edit text area
  * Bivio::UI::View::Wiki
    added TEXT_AREA_COLS and TEXT_AREA_ROWS to control dimensions of
    edit text area
  * Bivio::UI::Widget::Cond
    removed call_super_before
  * Bivio::UI::XHTML::Widget::ForumDropDown
    pushed up to ForumDropDown
    added NEW_ARGS to override RealmDropDown
  * Bivio::UI::XHTML::Widget::WikiText::Embed
    accept value= so doesn't show up in Xapian indexing
  * Bivio::UI::XHTML::Widget::WikiText::Widget
    accept value= so doesn't show up in Xapian indexing
  * Bivio::Util::HTTPConf
    reduce KeepAliveTimeout to 2 seconds
  * Bivio::Util::RealmFile
    added create_or_update
  * Bivio::Util::SQL
    Added FEATURE_BLOG/CALENDAR/etc. to respective tasks
    ANY_GROUP support for initializing permissions
    bundle sentinel defaults to name of table or type name
    added forum_feature upgrade to bundle
    write the sentinel name out when the upgrade runs
  * Bivio::t::UNIVERSAL::Super3
    try to test lexicals

  Revision 7.5  2008/10/29 05:01:13  dobbs
  * Bivio::UI::HTML::Widget::FormButton
    added NEW_ARGS to specify positional Widget attributes; specify ?class explicitly; internal_new_args accepts '?' to mean optional value
  * Bivio::UI::HTML::Widget::Table
    changed vs_call() to vs_new() for older apps
  * Bivio::UI::XHTML::Widget::TaskMenu
    replaced internal_new_args with NEW_ARGS (see recent change to UI::Widget)
    callers can specify the tag in the third parameter (defaults to div)
  * Bivio::UI::XHTML::Widget::XLink
    replace internal_new_args() with NEW_ARGS()

  Revision 7.4  2008/10/28 17:46:31  moeller
  * Bivio::Test::Widget
    removed AUTOLOAD which just obstructs stuff
  * Bivio::Type::Regexp
    added quote_string()
  * Bivio::UI::HTML::Widget::ControlBase
  * Bivio::UI::HTML::Widget::EmptyTag
  * Bivio::UI::HTML::Widget::Form
  * Bivio::UI::HTML::Widget::ImageFormButton
  * Bivio::UI::HTML::Widget::InputBase
  * Bivio::UI::HTML::Widget::Link
  * Bivio::UI::HTML::Widget::Tag
  * Bivio::UI::Widget::If
  * Bivio::UI::XHTML::Widget::FormFieldError
  * Bivio::UI::XHTML::Widget::MailBodyHTML
  * Bivio::UI::XHTML::Widget::MailBodyPlain
  * Bivio::UI::XHTML::Widget::TaskMenu
  * Bivio::UI::XHTML::Widget::TupleTagSlotField
  * Bivio::UI::XHTML::Widget::TupleTagSlotLabel
  * Bivio::UI::XHTML::Widget::Wiki
    added NEW_ARGS to specify positional Widget attributes; specify ?class explicitly; internal_new_args accepts '?' to mean optional value
  * Bivio::UI::HTML::Widget::FormField
    now wraps label value in a Prose,
    removed unused form_field_label_widget case
    removed deprecated _\d+ label lookup
  * Bivio::UI::HTML::Widget::Table
    wrap heading in a Prose
  * Bivio::UI::Text::Widget::CSV
    wrap heading in a Prose
  * Bivio::UI::View::CSS
    spans instead of images for RoundedBox Widget
  * Bivio::UI::View::ThreePartPage
    Added internal_xhtml_grid3 to allow wrapping by sub classes
  * Bivio::UI::Widget
    moved as_string into Bivio::UNIVERSAL
  * Bivio::UI::XHTML::Widget::FormFieldLabel
    now derives from Simple, Prose conversion is handled earlier
  * Bivio::UI::XHTML::Widget::RoundedBox
    spans instead of images
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    bmenus can now be nested.  selected_regexp does the right thing for
    nested menus
    replaced use of $b with $buf
    SPAN doesn't work in unit tests
  * Bivio::UI::XHTML::Widget::WikiText
    restructured implicit tag closures.  Used the DTD to ask the current
    tag if the new tag can be its child, if not, the tag is closed, and we
    iterate.
    textarea is no longer an empty tag.
    don't _close_not_nestable_tags if in $_MY_TAGS
  * Bivio::UNIVERSAL
    code_ref_for_subroutine cleaner
    as_string will recurse properly if there's an internal_as_string
  * Bivio::Util::HTTPConf
    MaxRequestsPerChild to 500
    ratched down MaxRequestsPerChild and MaxKeepAliveRequests
  * Bivio::Util::RealmFile
    ignore ..* and # files

  Revision 7.3  2008/10/24 18:11:10  moeller
  * Bivio::ShellUtil
    fix available class list so test works
  * Bivio::Test::HTMLParser::Forms
    set select name as anon if no parsed label and first value is empty
  * Bivio::Type::YearWindow
    added year_range_config() for other window sizes
  * Bivio::UI::HTML::Widget::Checkbox
    use a Prose label, not String
  * Bivio::UI::HTML::Widget::FormField
    don't escape facade label value
  * Bivio::UI::View::CSS
    removed float and clear for body, causes scrollbar problems in IE6
  * Bivio::UI::ViewShortcuts
    wrap the form error in a Prose in vs_fe()
  * Bivio::UI::XHTML::Widget::TaskMenu
    added attribute selected_label_prefix which is prepended to the label
    of the selected link.
  * Bivio::Util::HTTPConf
    added NameVirtualHost for SSL with default ssl for the hostname of the server
  * Bivio::Util::HTTPStats
    use local_file_prefix instead of uri for reports (local_file_prefix
    defaults to uri anyway)
  * Bivio::Util::RealmFile
    added rename
  * Bivio::Util::Wiki
    refactored to not hack the html, but rather, to snip main_middle or
    main_body from the tree

  Revision 7.2  2008/10/15 22:58:05  moeller
  * Bivio::Biz::Model::ECCreditCardPaymentForm
    changed ECCreditCardExpMonth to Month and ECCreditCardExpYear to YearWindow
  * Bivio::Biz::Model::RealmFile
    fixed _path() in empty case
  * Bivio::MIME::Type
    added types for office 2007 documents
  * Bivio::Type::ECCreditCardExpYear
    deprecated, use YearWindow
  * Bivio::Type::Month
    added get_two_digit_value()
  * Bivio::UI::HTML::Widget::Select
    added enum_display attribute

  Revision 7.1  2008/10/14 00:15:18  dobbs
  * Bivio::Biz::Model::RealmFile
    made several methods public: is_public(), is_backup(), is_mail()
  * Bivio::Test::Language::HTTP
    added audit_links()
  * Bivio::Type::Year
    now uses Bivio::Base, removed TODO
  * Bivio::TypeValue
    rm pod
  * Bivio::UI::HTML::Widget::Select
    rm pod
    unless show_unknown is set, remove the first if it is unknown

  Revision 7.0  2008/10/09 17:46:02  dobbs
  Rollover to 7.0

  Revision 6.96  2008/10/09 17:40:59  dobbs
  Rollover to 7.0

  Revision 6.95  2008/10/09 17:34:17  dobbs
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    make selected regexp case insensitive
    internal_render_label() allows subclasses to add markup or text to a
    selected menu item

  Revision 6.94  2008/10/08 17:10:03  moeller
  * Bivio::Type::Enum
    fixed unsafe_from_int()
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    unsafe_get('uri') so it doesn't die for Xapian search

  Revision 6.93  2008/10/02 02:32:58  moeller
  * Bivio::UI::XHTML::ViewShortcuts
    vs_descriptive_field() - pass attrs along to boolean FormField()
  * Bivio::UI::XHTML::Widget::HelpWiki
    made page_name() public, added NoScript Link directly to wiki view

  Revision 6.92  2008/09/26 01:19:10  moeller
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    changed SPAN() to Tag('SPAN', ) to avoid startup warnings

  Revision 6.91  2008/09/26 00:56:48  moeller
  * Bivio::UI::XHTML::Widget::TaskMenu
    removed previous selected href change
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    added selected_regexp csv attribute to control selection

  Revision 6.90  2008/09/24 20:58:39  moeller
  * Bivio::Biz::Model::FileChangeForm
    fixed deprecated call to is_text_content_type()
  * Bivio::UI::XHTML::Widget::TaskMenu
    check if the widget href matches selected
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    use the current request uri as the selected item
  * Bivio::Util::HTTPStats
    fixed historical import log format
    added tracing

  Revision 6.89  2008/09/19 02:32:08  aviggio
  * Bivio::Agent::HTTP::Request
    fix format_http_toggling_secure to not put on two prefixes
  * Bivio::Biz::Action::WikiView
    move diff byline to facade, re-use Type::FilePath->VERSION_REGEX
  * Bivio::Biz::Model::RealmFile
    reuse Type::FilePath->VERSION_REGEX
  * Bivio::Type::Enum
    added add_to_query() and execute_from_query()
  * Bivio::Type::FilePath
    extend VERSION_REGEX expression
  * Bivio::UI::FacadeBase
    formatting
    move wiki diff byline to facade
  * Bivio::UI::View::Wiki
    drop cancel button in versions list
  * Bivio::Util::HTTPConf
    added NameVirtualHost *:443 of one or more of the certs are the same

  Revision 6.88  2008/09/18 19:02:32  moeller
  * Bivio::Type::Enum
    added add_to_query() and execute_from_query()
  * Bivio::UI::View::Wiki
    drop cancel button in versions list

  Revision 6.87  2008/09/18 04:57:09  aviggio
  * Bivio::Biz::Action::RealmFile
    account for versioned public files
  * Bivio::Biz::Action::WikiView
    support wiki versions diff
  * Bivio::Delegate::TaskId
    add FORUM_WIKI_VERSIONS_DIFF task
  * Bivio::Type::FilePath
    add VERSION_REGEX and account for versioning in to_public and to_absolute
  * Bivio::UI::FacadeBase
    add wiki diff elements
  * Bivio::UI::View::CSS
    add wiki diff styles
  * Bivio::UI::View::Wiki
    support wiki versions diff

  Revision 6.86  2008/09/17 23:12:37  dobbs
  * Bivio::Biz::Model::CRMThread
    Added internal_get_existing_thread().  Pretty much only useful for
    subclasses that override handle_mail_post_create() which use this
    method to adjust behavior depending for existing threads.
  * Bivio::Mail::Incoming
    added get_all_addresses

  Revision 6.85  2008/09/16 14:24:30  moeller
  * Bivio::Biz::Model::CSVImportForm
    don't process records if validation fails
  * Bivio::Type::DateTime
    now ->use() Bivio::Agent::Request
  * Bivio::UI::HTML::Widget::AmountCell
    added css for column_footer_class
  * Bivio::UI::HTML::Widget::LineCell
    now uses line_cell css class
  * Bivio::UI::HTML::Widget::PercentCell
    now sets css class for column_footer_class
  * Bivio::UI::View::CSS
    set padding 0 for line_cell
  * Bivio::UI::View::ThreePartPage
    added xhtml_want_first_focus control
  * Bivio::Util::HTTPStats
    log name format changed

  Revision 6.84  2008/09/12 22:17:14  nagler
  * Bivio::BConf
    remove [notice] from error_list
  * Bivio::Biz::Action::EmptyReply
    execute: added ability to set_output by subclass
  * Bivio::Biz::Model::SearchList
    added realm_type to RealmOwner fields
  * Bivio::Delegate::TaskId
    PUBLIC_PING calls PingReply
  * Bivio::PetShop::Facade::PetShop
    remove support overrides, because getting in the way of testing

  Revision 6.83  2008/09/10 22:24:15  nagler
  * Added Bivio::Agent::RequestId, Bivio::Biz::Model::HashList
  * Bivio::Biz::Action::EasyForm
    Relaxed existence contraints: columns and files added automatically
    Sends email to EASY_FORM_UPDATE_MAIL_TO or site_contact
  * Bivio::Biz::Action
    rmpod
    added get_request
    fpc: get_request needs to call SUPER
  * Bivio::Delegate::RowTagKey
    added EASY_FORM_UPDATE_MAIL_TO
  * Bivio::MIME::Type
    added UNKNOWN_EXTENSION
  * Bivio::PetShop::Util::SQL
    use format_test_email for all emails
  * Bivio::Test::Request
    added handle_prepare_case to RequestId->clear_current
  * Bivio::Test::Util
    In mock_sendmail(), we now lc($recipients).  Acceptance tests that
    send mail with mixed case recipients were not getting delivered.
    better error msgs
  * Bivio::Test
    added register_handler and call on handle_prepare_case
  * Bivio::Type::BLOB
    rmpod
  * Bivio::Type::ECPaymentStatusSet
    rmpod
    fpc
  * Bivio::Type::EnumSet
    allow passing in enum names
  * Bivio::Type::FilePath
    added delete_suffix
  * Bivio::UI::FacadeBase
    easyform support
  * Bivio::UI::Task
    added assert_uri()
  * Bivio::Util::HTTPConf
    reduce max to ensure we don't wrap RequestId
    fpc

  Revision 6.82  2008/09/04 09:08:06  nagler
  * Bivio::Biz::Action::Acknowledgement
    save_label should not override a previously saved label if passed in
    via the $query variable.  Labels on the request and context are not
    overwritten.
  * Bivio::Biz::Model::CRMActionList
    added status_to_id_in_list, fixed status_to_id to convert the value
    without mapping NEW to OPEN
  * Bivio::Biz::Model::CRMForm
    added internal_empty_status_when_exists/new
    call status_to_id_in_list
  * Bivio::Biz::Model::MailForm
    minor stx
  * Bivio::Biz::Model::TupleSlotChoiceSelectList
    Split key and choice so key can be the empty string and Select Value
    isn't saved when the value is required but NULL error is cleared in forms
  * Bivio::Biz::Model::UserCreateForm
    added without_login parameter
  * Bivio::SQL::ListQuery
    included auth_id
  * Bivio::Test::Language::HTTP
    added clear_local_mail, extract_uri_from_local_mail, and find_page_with_text
  * Bivio::Test::Unit
    added builtin_create_mail
  * Bivio::UI::View::Mail
    call vs_simple_form_submit instead of '*'
  * Bivio::UI::XHTML::Widget::TupleTagSlotField
    Split key and choice so key can be the empty string and Select Value
    isn't saved when the value is required but NULL error is cleared in forms

  Revision 6.81  2008/09/03 16:43:03  moeller
  * Bivio::Biz::Model::RowTag
    fpc
  * Bivio::Type::StringArray
    added contains()
    append_uniquely replaced by append
  * Bivio::UI::FacadeBase
    refactor wiki prose to support overrides
  * Bivio::Util::CRM
    added setting reply-to
  * Bivio::Util::HTTPStats
    use Type.Location->get_default instead of Type.Location->HOME
    don't run unless config v3
    renamed init_icons() to init_report_forum()

  Revision 6.80  2008/08/29 05:53:10  aviggio
  * Bivio::Biz::Action::WikiView
    add support for wiki history display
  * Bivio::Biz::Model::RealmFileVersionsList
    added file_name
  * Bivio::Delegate::TaskId
    added FORUM_WIKI_VERSIONS_LIST task
  * Bivio::Type::FilePath
    to_absolute() supports archived file paths
  * Bivio::Type::WikiName
    support archived wiki names
  * Bivio::UI::FacadeBase
    add wiki history elements
  * Bivio::UI::View::Wiki
    version_list() added

  Revision 6.79  2008/08/27 22:19:03  dobbs
  * Bivio::Biz::Action::MySite
    If my_site_redirect_map allows you to set realm explicitly by using a
    lower case name so can get finer control
  * Bivio::Biz::Model::ECCreditCardPaymentForm
    use current user_id when looking for double-click,
    cleaned up imports
  * Bivio::PetShop::Facade::PetShop
    test for MySite.bunit
  * Bivio::Test::Unit
    fix bug in class dispatch for Auth_Role('MEMBER') case
  * Bivio::Type::Email
    added split_parts
  * Bivio::Util::HTTPD
    use Host header value in LogFormat because we don't set ServerName explicitly
  * Bivio::Util::HTTPStats
    gets domain list from latest log file, creates reports in one of the
    following forums:
      <domain>-reports
      <facade uri>-site-reports
      site-reports (default only)
    organizes results into yyyymmdd.html and defailt/yyyymmdd/<subreport>.html

  Revision 6.78  2008/08/21 17:57:26  moeller
  * Bivio::Biz::Model::CRMActionList
    added load_owner_names() to get list of assignable people
  * Bivio::Biz::Model::CRMQueryForm
    added crm_thread_num is_select=0 for owner name list
    now supports filtering on a tuple value,
    fixed x_owner_name filter to use CRMActionList for possible names
    removed dup x_slot1 property
  * Bivio::Biz::Model::CRMThreadRootList
    added filter for TupleTag values
  * Bivio::Mail::Incoming
    added NO_MESSAGE_ID constant, used if mail has no Message-Id value

  Revision 6.77  2008/08/19 17:44:24  moeller
  * Bivio::Biz::Model::ListQueryForm
    get_select_attrs() loads the list dynamically
  * Renamed Bivio::Util::WebStats to Bivio::Util::HTTPStats

  Revision 6.76  2008/08/18 23:36:59  nagler
  * Bivio::UI::HTML::Widget::RealmFilePage
    missing $source on render call(s)
  * Bivio::UI::Widget::URI
    missing $source on render call(s)

  Revision 6.75  2008/08/18 23:08:30  moeller
  * Bivio::Biz::Model::CRMThreadRootList
    left join with TupleTag to get extra CRM values,
    use CRMQueryForm to get status and owner_name filters
  * Bivio::Delegate::TaskId
    added Model.CRMQueryForm to FORUM_CRM_THREAD_ROOT_LIST
  * Bivio::ShellUtil
    required_main accepts case-insensitive class names so "bivio
    RealmAdmin" and "bivio realmadmin" both work.
  * Bivio::Test::Language::HTTP
    verify_pdf() now returns pdf_text
  * Bivio::Type::CRMThreadStatus
    added UNKNOWN
  * Bivio::UI::FacadeBase
    added labels for CRMQueryForm
  * Bivio::UI::XML::Widget::Tag
    Pass along $source

  Revision 6.74  2008/08/16 05:01:44  nagler
  * Bivio::Biz::ListModel
    default $count if PAGE_SIZE user preference not found
  * Bivio::Biz::Model::RowTag
    enable easier access to for auth_id
    b_use
  * Bivio::Delegate::RowTagKey
    added FACADE_CHILD_TYPE and TEXTAREA_WRAP_LINES
  * Bivio::PetShop::Facade::PetShop
    StandardSubmit.bunit support
  * Bivio::UI::Facade
    default $type if not set by default
  * Bivio::UI::HTML::Widget::Image
    missed passing $source to render/resolve
  * Bivio::UI::HTML::Widget::Page
    missed passing $source to render/resolve
  * Bivio::UI::HTML::Widget::Tag
    missed passing $source to render/resolve
  * Bivio::UI::HTML::Widget::Text
    missed passing $source to render/resolve
  * Bivio::UI::View::CRM
    don't render update_only for new tickets
    deprecate $buttons passed to send_form
  * Bivio::UI::View::CSS
    merge form .submit and .standard_submit
  * Bivio::UI::Widget::SimplePage
    missed passing $source to render/resolve
  * Bivio::UI::Widget
    check $source parameter is there before resolving widget value
  * Bivio::UI::XHTML::Widget::StandardSubmit
    deprecate passing buttons as array_ref (string or Widget required)
    buttons is dynamically rendered

  Revision 6.73  2008/08/15 04:12:24  nagler
  * Bivio::Biz::FormModel
    refactored get_model_properties and load_from_model_properties
  * Bivio::Biz::Model::CSVImportForm
    strip spaces around enum values,
    removed deprecated CSV_COLUMN config
  * Bivio::Biz::Model::ForumUserList
    local_field -> field_decl
  * Bivio::Biz::Model::MailPartList
    local_field -> field_decl
  * Bivio::Biz::Model::MonthList
    local_field -> field_decl
  * Bivio::Biz::Model::RealmUserAddForm
    local_field -> field_decl
  * Bivio::Biz::Model::SearchList
    local_field -> field_decl
  * Bivio::Biz::Model::UserPasswordForm
    local_field -> field_decl
  * Bivio::Biz::Model::t::CSVImportForm::T1Form
    added gender enum value
  * Bivio::Biz::Model
    added unsafe_get_model_info and get_model_info
    renamed local_fields to field_decl
    deprecate local_field (just to be safe)
  * Bivio::PetShop::Model::FieldTestForm
    local_field -> field_decl
  * Bivio::UI::XHTML::ViewShortcuts
    added vs_simple_form_submit to abstract '*' usage
  * Bivio::UNIVERSAL
    added is_simple_package_name

  Revision 6.72  2008/08/14 04:25:46  nagler
  * Bivio::Biz::FormModel
    internal_put_field accepts multiple key-values
    check value for HASH (not just ref) in _parse_cols.
    fpc
  * Bivio::Biz::Model::CRMActionList
    decouple lock_user_id from owner_user_id
  * Bivio::Biz::Model::CRMForm
    decouple lock_user_id from owner_user_id
  * Bivio::Biz::Model::CRMThread
    decouple lock_user_id from owner_user_id
    fpc
  * Bivio::Biz::Model::ForumUserList
    use local_field
  * Bivio::Biz::Model::MailForm
    added internal_format_subject
  * Bivio::Biz::Model::MailPartList
    use local_field
  * Bivio::Biz::Model::MonthList
    use local_field
  * Bivio::Biz::Model::RealmUserAddForm
    use local_field
  * Bivio::Biz::Model::SearchList
    use local_field
    use local_field
  * Bivio::Biz::Model::TupleTagForm
    tuple_tag_map_slots API change: gets id from TUPLE_TAG_IDS
  * Bivio::Biz::Model::UserPasswordForm
    use local_field
  * Bivio::Biz::Model
    local_field deprecates internal_initialize_local_fields
  * Bivio::Biz::t::FormModel::T1Form
    test internal_put_field with multiple args
  * Bivio::PetShop::Model::FieldTestForm
    use local_field
  * Bivio::SQL::DDL
    added lock_user_id and customer_realm_id to crm_thread_t
    added unique index to crm_thread_t.thread_root_id
  * Bivio::Search::Xapian
    use local_field
  * Bivio::Test::t::ListModel::T1List
    use local_field
  * Bivio::Type::ForumEmailMode
    use Bivio::Base
  * Bivio::UI::View::CRM
    tuple_tag_map_slots API change
  * Bivio::UNIVERSAL
    added list_if_value
  * Bivio::Util::SQL
    added crm_thread_lock_user_t
    added unique index to crm_thread_t.thread_root_id

  Revision 6.71  2008/08/12 22:07:58  moeller
  * Bivio::Biz::FormModel
    added require_validate which calls validate on directly executed
    forms, if set
  * Bivio::Biz::Model::AdmSubstituteUserForm
    rmpod
    internal_pre_execute moved to validate; use require_validate
    su_logout called on $self so doesn't get passed $req
  * Bivio::Biz::Model::CSVImportForm
    strip out empty rows before processing
  * Bivio::Biz::Model::ForbiddenForm
    removed su-izing to the realm, only worked for user realms
  * Bivio::Biz::Model::UserLoginForm
    call su_logout with AdmSubstituteUserForm instance
  * Bivio::PetShop::Test::PetShop
    do_logout must return after Sign-out
  * Bivio::SQL::FormSupport
    added require_validate
  * Bivio::UI::XHTML::Widget::HelpWiki
    set link_target on iframe links
  * Bivio::UI::XHTML::Widget::WikiText
    don't try to render an unparseable href
    added link_target attribute for '^' and @a

  Revision 6.70  2008/08/08 23:32:11  moeller
  * Bivio::Biz::Model::CSVImportForm
    allow enum with empty value,
    added CONTINUE_VALIDATION_ON_ERROR() to allow subclasses
      to do full file validation
    fixed server error with input file of a single space
  * Bivio::UI::FormError
    html escape error detail, and convert newline to br

  Revision 6.69  2008/08/08 03:24:17  nagler
  * Bivio::Biz::Model::FileChangeForm
    don't check is_text_content_type if is_folder
  * Bivio::Biz::Model::RealmFile
    get_content_type on folders deprecated
  * Bivio::Biz::Model::TextFileForm
    call get_content_type after checking folder

  Revision 6.68  2008/08/07 21:19:12  nagler
  * Bivio::Biz::Action::WikiView
    throw exception from access_controlled_load
  * Bivio::Delegate::SimpleAuthSupport
    factored out "_load_realm"
  * Bivio::Delegate::TaskId
    WikiView throws exception from access_controlled_load
  * Bivio::PetShop::Test::PetShop
    do_logout looks for logout, too
  * Bivio::UI::XHTML::Widget::WikiText
    RealmFile throws exception from access_controlled_load, which is
    better handling behavior (forces login on private pages)

  Revision 6.67  2008/08/07 18:34:18  nagler
  * Bivio::Biz::Action::EmptyReply
    added execute_server_error
  * Bivio::Delegate::TaskId
    need not_found_task on SITE_WIKI_VIEW
  * Bivio::UI::FacadeBase
    added xhtml_dock_left_standard
  * Bivio::UI::View::ThreePartPage
    allow subclasses to override internal_xhtml_adorned_attrs setting view_pre_execute
  * Bivio::UI::View::Wiki
    remove spurious comment
  * Bivio::UI::Widget::URI
    always set query to undef
    unneeded import
  * Bivio::UI::XHTML::Widget::TaskMenu
    URI clears query and path_info, don't need version 8
  * Bivio::Util::Backup
    added chmod -R ug+w to trim directories

  Revision 6.66  2008/08/06 04:20:08  nagler
  * Bivio::Agent::Request
    use return_scalar_or_array in _with()
  * Bivio::BConf
    config trace
  * Bivio::Biz::Action::RealmMail
    allow reflector_task to be passed in
  * Bivio::Biz::FormModel
    call internal_post_execute() if validate() fails
  * Bivio::Biz::Model::CRMForm
    remove show_action
    reference button by unsafe_get, not explicitly
  * Bivio::Biz::Model::UserTaskDAVList
    Agent.Task get value deprecation
  * Bivio::Collection::Attributes
    pass name of key to code_ref calls
  * Bivio::Delegate::SimpleRealmName
    added clean_and_trim
  * Bivio::IO::Config
    pick off --trace=config
  * Bivio::ShellUtil
    name_args: accept Type => code_ref
  * Bivio::Type::String
    added clean_and_trim & get_min_width
  * Bivio::UI::FacadeBase
    dropdown doesn't work right
  * Bivio::UI::View::CRM
    added $no_action to internal_crm_send_form_extra_fields
  * Bivio::UI::View::CSS
    put z-index on .dd_menu (not dd_menu a)
  * Bivio::UI::View::Mail
    added DEFAULT_COLS and internal_subject_body_attachments
  * Bivio::UNIVERSAL
    return_scalar_or_array returns undef in scalar context if empty array
  * Bivio::Util::RealmAdmin
    create_user simplified to use name_args better
  * Bivio::Util::RowTag
    named_args() no longer works for array values
  * Bivio::Util::SQL
    remove unnecessary messages
    create_test_user uses name_args
    fpc
  * Bivio::Util::SiteForum
    added init_admin_user
  * Bivio::Util::TestUser
    added init_adm

  Revision 6.65  2008/07/29 02:06:25  moeller
  * Bivio::Biz::Action::ClientRedirect
    fixed deprecated task->unsafe_get() call
  * Bivio::Biz::Model::AdmSubstituteUserForm
    call task->unsafe_get_attr_as_id to avoid deprecated warning
  * Bivio::Biz::Model::ForbiddenForm
    replaced req->get_nested() with task->get_attr_as_id
  * Bivio::UI::View::ThreePartPage
    return an empty value if no _header_right() value is set from the task
  * Bivio::UI::Widget::URI
    set version 8 defaults before warn_deprecated()

  Revision 6.64  2008/07/27 03:17:49  nagler
  * Bivio::Agent::HTTP::Request
    server_redirect with uri was deprecated, and now is no longer used
    removed retain_query_and_path_info reference
    use internal_copy_implicit()
    use carry_*
  * Bivio::Agent::Task
    v8: Task does not call get_instance on items This allows
    reloading of task items dynamically, and was unnecessary except for
    much older code
    TaskEvent restructuring
    get(<task attribute>) is deprecated; use unsafe_/get_attr_as_id
    to get new behavior, use dep_{unsafe_}get_attr until deprecation removed
    added put_attr_for_test()
    map item attributes accept [cause, params] where params can be hash
    as accepted by TaskEvent or TaskId (or name)
  * Bivio::Agent::t::Mock::TaskId
    test new interfaces
  * Bivio::Biz::Action::DAV
    TaskEvent
  * Bivio::Biz::Action::RealmMail
    use mail_reflector_task instaled of $job_task param
  * Bivio::Biz::Action::UserPasswordQuery
    task_event
  * Bivio::Biz::Action::WikiView
    refactored internal_model_not_found() to execute_not_found()
    Use edit_task
  * Bivio::Biz::FormContext
    TaskEvent
  * Bivio::Biz::FormModel
    TaskEvent
  * Bivio::Biz::Model::MailForm
    use mail_reflector_task instead of $job_task param
  * Bivio::Biz::Model::MailThreadRootList
    TaskEvent
  * Bivio::Biz::Model::RealmDAVList
    TaskEvent
  * Bivio::Biz::Model::RealmFileTreeList
    TaskEvent
  * Bivio::Biz::Model::RealmOwner
    Debug info
    Back out accidental debug check in
  * Bivio::Biz::Model::UserTaskDAVList
    TaskEvent
  * Bivio::Collection::Attributes
    unsafe/get_nested call unsafe/get so can be overridden by subclasses
  * Bivio::Delegate::TaskId
    FORUM_HOME.next is FORUM_WIKI_VIEW
    mail_reflector_task on appropriate tasks
  * Bivio::PetShop::BConf
    v8
  * Bivio::PetShop::Facade::PetShop
    xlink_bunit3
  * Bivio::PetShop::View::Base
    use dock
  * Bivio::Test::FormModel
    use put_attr_for_test
    TaskEvent
  * Bivio::Test::Request
    TaskEvent
  * Bivio::Test::Unit
    added builtin_model_exists
    _model() allows $expect to be undef, which means do the iteration, but
    don't assert_contains
  * Bivio::UI::FacadeBase
    XLink (v8) requires query => undef
  * Bivio::UI::View::CRM
    dead code
  * Bivio::UI::View::CSS
    relax support for DropDown so can be used in dock
  * Bivio::UI::View::ThreePartPage
    v8: ForumDropDown in dock
  * Bivio::UI::Widget::URI
    v8: require query and path_info to be set if task_id
  * Bivio::UI::XHTML::Widget::ForumDropDown
    put => put_unless_exists
  * Bivio::UI::XHTML::Widget::TaskMenu
    v8: query and path_info forced to undef if not set
  * Bivio::UI::XHTML::Widget::XLink
    v8: query and path_info forced to undef if not set
  * Bivio::UI::XML::Widget::AtomFeed
    TaskEvent

  Revision 6.63  2008/07/23 18:25:19  dobbs
  * Bivio::Agent::Dispatcher
    don't need to register
  * Bivio::Biz::Model::RealmFile
    added _is_backup() to ignore files in is_searchable
  * Bivio::Biz::Model::UserLoginForm
    don't send password back to client in error case
  * Bivio::Biz::Model::UserRegisterForm
    $res unused
  * Bivio::Collection::Attributes
    use return_scalar_or_array
  * Bivio::ShellUtil
    USAGE now provides a default usage string.  Subclasses are no longer
    required to override it.  Commands for that string come from the new
    shell_commands() function which finds the methods in the $proto symbol
    table.  Does not yet find methods on parent ShellUtils.
    Subclasses can now specify command usage by creating foo_USAGE methods
    that return the usage details for that command.  For example:
    sub score_USAGE {'type year -- set the current scoring year'}
  * Bivio::Test::Reload
    added ability to register handlers
  * Bivio::UNIVERSAL
    added return_scalar_or_array
  * Bivio::t::ShellUtil::T2
    USAGE now provides a default usage string.  Subclasses are no longer
    required to override it.  Commands for that string come from the new
    shell_commands() function which finds the methods in the $proto symbol

    Subclasses can now specify command usage by creating foo_USAGE methods
    that return the usage details for that command.  For example:
    sub score_USAGE {'type year -- set the current scoring year'}

  Revision 6.62  2008/07/15 22:24:58  dobbs
  * Bivio::Biz::Model::CRMThreadList
    parent_id changed from CRMThread.thread_root_id to CRMThread.crm_thread_num
  * Bivio::Biz::Model::CRMThreadRootList
    parent_id changed from CRMThread.thread_root_id to CRMThread.crm_thread_num
  * Bivio::Biz::Model::MailForm
    added Message-Id to headers so fixed for all recipients
  * Bivio::Biz::Model::MailThreadList
    make DATE_SORT_ORDER explicit and overridable by subclasses
  * Bivio::Biz::Model::MailThreadRootList
    moved date sort order from the query params to internal_initialize()
  * Bivio::Biz::Model::RealmFile
    added path_info_to_id
  * Bivio::Biz::Model::RealmFileTreeList
    default_expand is gone; expand top level
  * Bivio::Delegate::TaskId
    added next redirect for SITE_ADM_SUBSTITUTE_USER_DONE for stale links
  * Bivio::Mail::Outgoing
    Message-Id not removed on set_headers_for_list_send
    added generate_message_id

  Revision 6.61  2008/07/11 20:05:28  dobbs
  * Bivio::Biz::Action::RealmFile
    added execute_show_original() to override content type for
    Show Originial link
  * Bivio::Biz::Model::CRMForm
    minor refactor
  * Bivio::Biz::Model::UserSettingsForm
    added page_size to UserSettingsForm
  * Bivio::Delegate::SimpleWidgetFactory
    added page_size to UserSettingsForm
  * Bivio::Delegate::TaskId
    added FORUM_MAIL_SHOW_ORIGINAL_FILE for Mail and CRM
    Show Originial link
  * Bivio::MIME::Type
    Changing the MIME for .eml files was too drastic.  Using
    a new task for the Show Original link.
  * Bivio::UI::FacadeBase
    added page_size to UserSettingsForm
    added FORUM_MAIL_SHOW_ORIGINAL_FILE
  * Bivio::UI::View::CRM
    make to/cc rendered in MailForm
  * Bivio::UI::View::Mail
    make to/cc always visible
    use FORUM_MAIL_SHOW_ORIGINAL_FILE for Show Original link
  * Bivio::UI::View::UserAuth
    added page_size to UserSettingsForm

  Revision 6.60  2008/07/09 23:33:00  dobbs
  * Bivio::Biz::Action::RealmMail
    call format_realm_as_sender to format the sender address
  * Bivio::Biz::Model::CRMForm
    subclasses can now override DEFAULT_CRM_THREAD_STATUS
  * Bivio::Biz::Model::EmailAlias
    added format_realm_as_sender
  * Bivio::Biz::Model::MailForm
    call EmailAlias to format_realm_as_sender
  * Bivio::MIME::Type
    change mime type for CRM "Show Original"
  * Bivio::Type::TextArea
    clean up lines properly

  Revision 6.59  2008/07/07 23:36:49  dobbs
  * Bivio::Biz::Model::RoleBaseList
    can_iterate is false for all lists of this type
  * Bivio::Delegate::TaskId
    make default SITE_WIKI_VIEW and FORUM_WIKI_VIEW the same
  * Bivio::ShellUtil
    Only initialize Agent.Dispatcher and facades when running from command line
  * Bivio::UI::FacadeBase
    catch_quietly in looking up *_id
    Votes are now called Polls
    make default SITE_WIKI_VIEW and FORUM_WIKI_VIEW the same
  * Bivio::UI::View::Wiki
    make default SITE_WIKI_VIEW and FORUM_WIKI_VIEW the same
  * Bivio::Util::SQL
    catch_quietly in drop

  Revision 6.58  2008/07/01 21:01:22  nagler
  * Bivio::Biz::Action::RealmMail
    escape the list_title
  * Bivio::Biz::Model::MailForm
    added want_reply_to check in to internal_format_reply_to
  * Bivio::Mail::Address
    *** empty log message ***
  * Bivio::Mail::Outgoing
    call Type.Address->escape_comment
  * Bivio::PetShop::Util::SQL
    turn on want_reply_to everywhere

  Revision 6.57  2008/07/01 00:00:47  nagler
  * Bivio::Biz::Model::CRMForm
    use unsafe_get on a field, not 'eq' on the $button
    internal_format_from() no longer uses auth_user display_name to
    describe the email address (less is more)
    format_realm_as_incoming for internal_format_from
  * Bivio::Biz::Model::CRMThread
    use CRM_SUBJECT_PREFIX
  * Bivio::Biz::Model::CRMThreadRootList
    fix cross-join problem
  * Bivio::Biz::Model::EmailAlias
    handle user "get_all_emails" and format_realm_as_incoming
  * Bivio::Biz::Model::MailForm
    removed sender fix
    restructure to use EMailAlias exclusively to generate email addresses
  * Bivio::Delegate::RowTagKey
    added CANONICAL_EMAIL_ALIAS, CANONICAL_SENDER_EMAIL, and CRM_SUBJECT_PREFIX
  * Bivio::Mail::Incoming
    pass canonical_email to get_reply_email_arrays
  * Bivio::PetShop::Util::SQL
    added two email addresses for CRM_TECH1
    test data for aliases and CANONICAL_EMAIL_ALIAS
  * Bivio::Util::HTTPConf
    error, access, and ssl_log are the only logs (no referer)
    don't create an ssl_log, just use error_log
  * Bivio::Util::SQL
    parse_trace_output accepts string as argument

  Revision 6.56  2008/06/24 17:45:04  nagler
  * Bivio::Biz::ListModel
    fixed typo
  * Bivio::HTML
    use explicit scalar() around HTML::Entities instead of separate copy
  * Bivio::UI::View::ThreePartPage
    dock is not available until version 7

  Revision 6.55  2008/06/18 21:22:27  moeller
  * Bivio::Biz::Model::AdmBulletinForm
    fpc
  * Bivio::Biz::Model::ECPayment
    rm pod
    now derives from RealmBase
    default values for status and point_of_sale
  * Bivio::Biz::Model::ECSubscription
    rm pod
    now derived from RealmBase,
    added is_active()
    added optional date argument to is_active()
  * Bivio::Delegate::TaskId
    fpc
  * Bivio::UI::View::Blog
    fpc
  * Bivio::UI::View::Calendar
    fixed detail end time
  * Bivio::Util::HTTPConf
    Add child process ID to custom LogFormat
  * Bivio::Util::HTTPD
    Add vhost and child process ID to custom LogFormat

  Revision 6.54  2008/06/17 04:18:21  nagler
  * Bivio::Biz::Action::CalendarEventICS
    removed copied code, now calls CalendarEventDAVList directly
  * Bivio::Biz::Action::WikiView
    new WikiText interface
  * Bivio::Biz::Model::BlogList
    use new_excerpt
    added query for rss fead
  * Bivio::Biz::Model::CRMForm
    switched to b_use
    set action to Open for new requests
  * Bivio::Biz::Model::CalendarEventDAVList
    added vcalendar_list() to allow sharing with Action.CalendarEventICS
  * Bivio::Biz::Model::CalendarEventForm
    load the edit CalendarEvent from 'this' if present
    default tz
  * Bivio::Biz::Model::CalendarEventList
    added computed fields dtstart_in_tz, dtend_in_tz
    added rss support
  * Bivio::Biz::Model::MailThreadRootList
    new Search.Parser interface
  * Bivio::Biz::Model::RealmFile
    new Xapian interface
  * Bivio::Biz::Model::SearchList
    Use new_excerpt to generate excerpts
  * Bivio::Delegate::TaskId
    added calendar tasks
    added rss support for calendar
  * Bivio::Mail::Address
    added parse_local_part
  * Bivio::PetShop::View::Base
    added link to Calendar
  * Bivio::Search::Parseable
    new_text/excerpt restructuring so can support different models
  * Bivio::Search::Parser::RealmFile::MessageRFC822
    new_text/excerpt restructuring so can support different models
  * Bivio::Search::Parser::RealmFile::PDF
    new_text/excerpt restructuring so can support different models
  * Bivio::Search::Parser::RealmFile::TextHTML
    new_text/excerpt restructuring so can support different models
  * Bivio::Search::Parser::RealmFile::TextPlain
    new_text/excerpt restructuring so can support different models
  * Bivio::Search::Parser::RealmFile::Unknown
    new_text/excerpt restructuring so can support different models
  * Bivio::Search::Parser::RealmFile::Wiki
    new_text/excerpt restructuring so can support different models
  * Bivio::Search::Parser::RealmFile
    new_text/excerpt restructuring so can support different models
  * Bivio::Search::Xapian
    new_text/excerpt restructuring so can support different models
  * Bivio::Test::Language::HTTP
    poll_page was calling unsafe_op incorrectly
  * Bivio::Test::Unit
    give more info when unexpected match
  * Bivio::Test::Util
    wiki requires full initialization
  * Bivio::Test::Widget
    assert actual->[0]
  * Bivio::Type::BlogContent
    v7 uses WikiName->TITLE_TAG
  * Bivio::Type::WikiName
    export TITLE_TAG
  * Bivio::UI::FacadeBase
    add ActionError.wiki_name for SERVER_ERROR
    Make request status more obvious in CRMActionList labels
    added calendar text and tasks
    new searchlist interface
    added rss support for calendar
  * Bivio::UI::View::Blog
    use render_plain_text_excerpt
  * Bivio::UI::View::CRM
    added to/cc to extra send fields
  * Bivio::UI::View::CSS
    added calendar related css
    support new search_results
  * Bivio::UI::View::Mail
    if to/cc are not present on send_form(), then add as hidden fields
  * Bivio::UI::XHTML::ViewShortcuts
    fpc - use ['->get_list_model'] for tree fields
  * Bivio::UI::XHTML::Widget::WikiText
    new interface to prepare_html unifies render_html_without_view and render_html
  * Bivio::UI::XML::Widget::AtomFeed
    allow queries in rss
  * Bivio::Util::HTTPConf
    compress logs

  Revision 6.53  2008/06/16 04:31:35  moeller
  * Bivio::Biz::Model::MailThreadList
    added RealmOwner.display_name (User's name)
  * Bivio::Biz::Model::MailThreadRootList
    added reply and message count and excerpt
  * Bivio::Test::Language::HTTP
    undef fields compare as '' in verify_form()
  * Bivio::UI::View::Mail
    show mail threads as excerpts, not date-subject
    don't show to/cc on send form

  Revision 6.52  2008/06/16 00:09:15  moeller
  * Bivio::UI::View::ThreePartPage
    moved xhtml_header_right to second view_put() because xhtml_dock_right
    needs to be defined

  Revision 6.51  2008/06/15 01:14:25  nagler
  * Bivio::Agent::HTTP::Reply
    move delete_output up to Agent.Reply
  * Bivio::Agent::Request
    simplified
    v7: can_user_execute_task checks FacadeComponent.Task to see if task
    is defined for facade
  * Bivio::Agent::t::Mock::TaskId
    don't need TEST_MULTI_ROLES1 here
  * Bivio::BConf
    UI_HTML
  * Bivio::Biz::Action::Error
    simplified and made more robust to errors related to not having
    SiteForum or wikiview
    Changed name of text attributes to ActionError.wiki_name
  * Bivio::Biz::ListModel
    added get_list_class
  * Bivio::Biz::Model::RealmFileVersionsList
    sort by RealmFile.modified_date_time first
  * Bivio::Delegate::SimpleTypeError
    doc @h3 > @h1
  * Bivio::Delegate::TaskId
    change back to FORUM from ANY until sure about security
  * Bivio::PetShop::BConf
    config v7
  * Bivio::PetShop::Delegate::TaskId
    added TEST_MULTI_ROLES1/2
  * Bivio::PetShop::Facade::PetShop
    added TEST_MULTI_ROLES1/2
  * Bivio::PetShop::Util::SQL
    @h1 change
  * Bivio::Search::Parser::RealmFile::Wiki
    call render_ascii
  * Bivio::Test::Language::HTTP
    test_trace goes back
  * Bivio::UI::FacadeBase
    support ThreePartPage dock
    Action.Error: Changed name of text attributes to ActionError.wiki_name
    need to add all DAV tasks to _cfg_dav
  * Bivio::UI::Font
    test-align => text-align
  * Bivio::UI::Icon
    added get_statically_configured_files
    undo
  * Bivio::UI::View::CSS
    support ThreePartPage dock
  * Bivio::UI::XHTML::ViewShortcuts
    vs_tree_list_control use Replicator()
    fpc & vs_tree_list_control simplified more
  * Bivio::UI::XHTML::Widget::SearchForm
    allow dynamic image_form_button and text_size
  * Bivio::UI::XHTML::Widget::WikiText
    WikiText calls render_html_without_view

  Revision 6.50  2008/06/14 15:52:04  nagler
  * Bivio::UI::Task
    delay import of UI.Facade

  Revision 6.49  2008/06/14 14:22:06  dobbs
  * Bivio::Biz::Action::Error
    NOT_FOUND and FORBIDDEN errors can now show a wiki page instead of our
    default error messages
  * Bivio::UI::FacadeBase
    added default paths for wiki pages to show with NOT_FOUND and FORBIDDEN errors

  Revision 6.48  2008/06/13 20:56:14  nagler
  * Bivio::Agent::Embed::Reply
    b_use
  * Bivio::Agent::Task
    has_realm_type accepts UNKNOWN as a valid realm type
  * Bivio::Auth::Realm
    use has_realm_type
  * Bivio::Base
    added b_use
  * Bivio::Biz::Action::AdmGetBulletinAttachment
    b_use & rmpod
  * Bivio::Biz::Action::AdmMailBulletin
    b_use & rmpod
  * Bivio::Biz::Action::LocalFilePlain
    b_use & rmpod & use IO::File for handles
  * Bivio::Biz::Action::WikiView
    call WikiText->prepare_html
  * Bivio::Biz::Model::CalendarEvent
    pass any remaining arguments to SUPER during create_realm()
  * Bivio::Biz::Model::Club
    rm pod
    now derived from RealmOwnerBase, refactored create_realm()
  * Bivio::Biz::Model::Forum
    now derived from RealmOwnerBase, refactored create_realm()
  * Bivio::Biz::Model::RealmFile
    b_use & rmpod
  * Bivio::Biz::Model::RealmOwnerBase
    create_realm() takes an admin_id as an optional third argument
  * Bivio::Biz::Model::User
    refactored create_realm()
  * Bivio::Biz::Model::UserTaskDAVList
    b_use & rmpod
  * Bivio::Delegate::RealmType
    rmpod & added "any" alias for UNKNOWN
  * Bivio::Delegate::RowTagKey
    added PAGE_SIZE preference
  * Bivio::Delegate::SimpleAuthSupport
    added PAGE_SIZE user_pref
  * Bivio::Delegate::TaskId
    Most FORUM_* tasks map to UNKNOWN (ANY) RealmType so can be used by
    any realm except general
  * Bivio::IO::Zip
    die if file to add is unreadable,
    fixed mime type,
    use IO::File for file handle
  * Bivio::Mail::Outgoing
    b_use
  * Bivio::Search::Parseable
    pass all realm_file values to object
  * Bivio::Search::Parser::RealmFile::Wiki
    use WikiText for stripping
    fpc
    use render_html_without_view
  * Bivio::Test::Language::HTTP
    poll_page() now reuses the mail_tries config for number of times to
    try a page.
  * Bivio::Test::Widget
    assert no refs in output
  * Bivio::Type::DecimalDegree
    compute to 6 decimal places
  * Bivio::Type::FileField
    b_use & rmpod
  * Bivio::UI::FacadeBase
    unused
  * Bivio::UI::Task
    _from_uri accepts UNKNOWN as a valid realm type
  * Bivio::UI::View::Inline
    added render_code_as_string
  * Bivio::UI::Widget::MIMEEntityRealmFile
    b_use & rmpod
  * Bivio::UI::Widget::Simple
    maded executable but without a content-type so can't be used as a
    regular view.
  * Bivio::UI::XHTML::Widget::WikiStyle
    moved prepare_html to WikiText -- WikiStyle should probably be
    completely deprecated
    DEPRECATED
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    inlined WikiStrippedText
  * Bivio::UI::XHTML::Widget::WikiText
    added prepare_html from WikiStyle
    fpc
    added render_html_without_view
  * Bivio::Util::HTTPD
    Add paths for OS X 10.5 Apache 1.3 built from source

  Revision 6.47  2008/06/09 20:24:12  moeller
  * Bivio::Biz::Model::RealmFileTreeList
    added default_expand config value, (all_rows, none)
  * Bivio::UI::View::File
    don't link name to email in file tree
  * Bivio::Util::SQL
    removed _write_icons()

  Revision 6.46  2008/06/07 22:44:36  moeller
  * Bivio::Biz::Model::RealmFileTreeList
    constrain list results by path_info
    expand all folders by default
  * Bivio::Biz::Model::RealmFileVersionsList
    sort by modified_date_time first
  * Bivio::UI::FacadeBase
    constrain FORUM_FILE list results by path_info
    set title to path_info if it exists
    remove Prose stuff from title.FORUM_FILE 'cos that title only
    sometimes gets treated as Prose()
  * Bivio::UI::Icon
    added get_icon_dir()
  * Bivio::UI::View::File
    added Unlock link for file change page,
    removed Change link, replaced with change icon next to the file name
  * Bivio::UI::XHTML::ViewShortcuts
    turned off sorting for trees,
    added tree_list_control_suffix_widget value for tree icon
  * Bivio::Util::SQL
    now uses Bivio::UI::Icons to unzip default icons
  * Bivio::Util::User
    fixed indentation for USAGE

  Revision 6.45  2008/06/05 23:05:39  moeller
  * Bivio::Biz::Action::SFEETunnel
    loosened /do/login check in case there are query arguments,
    fixes problems with bookmarked sfee pages
  * Bivio::Mail::Common
    removed -U flag, not used in modern sendmails or postfixes
  * Bivio::Test::Util
    misspelled PERLLIB in previous commit
    doc
  * Bivio::Util::LinuxConfig
    remove dadd_postfix_http_agent

  Revision 6.44  2008/06/05 15:42:57  dobbs
  * Bivio::Biz::Model::CRMForm
    allow action_id be set with a new request
  * Bivio::Biz::Model::FileChangeForm
    corrected _release_lock() return value
  * Bivio::UI::Task
    improved "uri already mapped" error message

  Revision 6.43  2008/06/03 19:57:27  nagler
  * Bivio::Test::Util
    add output to b-test nightly to make it easier to recreate the test
    environment when debugging test failures
  * Bivio::Util::Release
    allow for optional files

  Revision 6.42  2008/06/01 00:51:32  nagler
  * Bivio::Util::LinuxConfig
    removed allow_any_postfix_smtp
    add_postfix_http_agent wasn't adding uri properly

  Revision 6.41  2008/05/31 23:52:25  nagler
  * "bivio" program can call any class in ShellUtil map
  * Bivio::Util::LinuxConfig
    add_postfix_http_agent: program is configurable

  Revision 6.40  2008/05/31 23:43:06  nagler
  * Bivio::Type::DomainName
    minor syntax
  * Bivio::Util::LinuxConfig
    added allow_any_postfix_smtp and add_postfix_http_agent

  Revision 6.39  2008/05/30 23:24:55  dobbs
  * Bivio::Biz::Model::SearchList
    conceal <realm>/wikidata in xapian search result URIs
  * Bivio::Search::Parser::RealmFile::PDF
    emit warning when pdfinfo isn't found
  * Bivio::Type::DocletFileName
    pushed uri_hash_for_realm_and_path() from Bivio::Type::WikiName to
    Bivio::Type::DocletFileName so that Bivio::Type::WikiDataName could
    conceal <realm>/wikidata in xapian search result URIs
  * Bivio::Type::WikiDataName
    add REGEX to make from_absolute work properly so WikiDataName could
    conceal <realm>/wikidata in xapian search result URIs
  * Bivio::Type::WikiName
    pushed uri_hash_for_realm_and_path() from Bivio::Type::WikiName to
    Bivio::Type::DocletFileName so that Bivio::Type::WikiDataName could
    also hide share it to conceal <realm>/wikidata in xapian search result
    URIs
  * Bivio::Util::SSL
    added read_crt & self_signed_mdc
    doc
    simplify v3_req section

  Revision 6.38  2008/05/29 23:20:14  dobbs
  * Bivio::Type::WikiName
    logic was backwards for conceal <realm>/wiki in xapian search result URIs

  Revision 6.37  2008/05/29 22:11:57  dobbs
  * Bivio::Biz::Model::SearchList
    conceal <realm>/wiki in xapian search result URIs
  * Bivio::PetShop::Test::PetShop
    moved fixup_files_uri to Bivio::PetShop::Test::PetShop
  * Bivio::Type::WikiName
    conceal <realm>/wiki in xapian search result URIs
  * Bivio::UI::FacadeBase
    added is_site_realm_name() so we have a way to explicity ask that question

  Revision 6.36  2008/05/28 23:13:33  moeller
  * Bivio::Base
    b_die calls throw_or_die
  * Bivio::BConf
    GIS map
  * Bivio::Biz::Model::CRMThread
    changed RealmMail register to use package map name
  * Bivio::Biz::Model::MailReceiveDispatchForm
    throw a FORBIDDEN if there is no from_email, avoid DB_ERROR later on
  * Bivio::Biz::Model::RealmMail
    when registerring a handler, ->use() the name
  * Bivio::Biz::Model::Tuple
    changed RealmMail register to use package map name
  * Bivio::Biz::Util::ListModel
    include all columns in csv()
  * Bivio::Collection::Attributes
    map_each returns sorted keys
  * Bivio::Delegate::TaskId
    added FORBIDDEN handler for FORUM_MAIL_RECEIVE
  * Bivio::IO::Trace
    set_named_filters defaults to /$name/ if $name is not found
    set_named_filters needs to check that name is simple name
    before calling Config->unsafe_get
    handle_config calls set_named_filters directly
    set_named_filters: $name can be '' or 0 to indicate "off"
  * Bivio::Search::Parser::RealmFile::PDF
    fixed method name and args
  * Bivio::SQL::Connection
    added do_execute_rows and map_execute_rows
  * Bivio::UI::FacadeBase
    added missing task entry for MAIL_RECEIVE_FORBIDDEN

  Revision 6.35  2008/05/22 21:54:30  moeller
  * Bivio::Biz::Model::SearchList
    added '...' to trimmed text in excerpt
  * Bivio::Search::Parser::RealmFile::Wiki
    remove wiki markup:
     xxx="a b" and xxx=yyy
     ^ prefix from email addresses
     CamelCase words
     ^words
  * Bivio::Search::Xapian
    delete file from xapian if it becomes non searchable
  * Bivio::Test::Language::HTTP
    call $req->process_cleanup() during handle_cleanup() to remove tmp files
  * Bivio::Test::Unit
    added builtin_to_string
    assert_eval returns the result of the eval

  Revision 6.34  2008/05/20 17:13:21  moeller
  * Bivio::Biz::ListFormModel
    die() if get_field_name_for_html() can't determine the form_name for the col
  * Bivio::IO::File
    added optional $suffix parameter to temp_file()
  * Bivio::Test::Language::HTTP
    tmp_file() now uses Bivio::IO::File->temp_file() for proper cleanup
  * Bivio::UI::XHTML::Widget::WikiText
    render empty tag attributes if specified explicitly

  Revision 6.33  2008/05/15 23:37:12  moeller
  * Bivio::Biz::Action::RealmMail
    allow passing the job task to execute_receive()
  * Bivio::Biz::Model::MailForm
    added MAIL_REFLECTOR_TASK constant
  * Bivio::UI::View::CSS
    rm label_ok top padding

  Revision 6.32  2008/05/14 20:48:07  moeller
  * Bivio::Biz::FormModel
    process() calls assert_not_singleton() to avoid global model corruption
  * Bivio::Biz::Model::AdmSubstituteUserForm
    fixed call to UserLoginForm->substitute_user() to be on an instance,
    not the singleton
  * Bivio::UI::FacadeBase
    added old uri ?/files to FORUM_FILE task
  * Bivio::UI::View::CSS
    nowrap the anchors in .tree_list .nodes to fix display in safari
  * Bivio::UI::XHTML::Widget::WikiText
    add fieldset and legend tags

  Revision 6.31  2008/05/13 22:51:09  moeller
  * Bivio::Biz::Model::RealmLogoList Bivio::Delegate::SimpleTaskId
    Bivio::Delegate::TaskId Bivio::Type::WikiDataName Bivio::UI::FacadeBase
    removed FORUM_PUBLIC_FILE

  Revision 6.30  2008/05/13 21:28:34  moeller
  * Bivio::Delegate::TaskId
    removed FORUM_FILE_TREE_LIST
  * Bivio::Die
    put $_TRACE in more places
  * Bivio::PetShop::Util::SQL
    allow form and input tags in WikiText to enable EasyForms from Wiki
  * Bivio::UI::FacadeBase
    removed FORUM_FILE_TREE_LIST, updated task heading
  * Bivio::UI::View::File
    added 'leave file locked' link on change file page,
    improved file change page heading
  * Bivio::UI::XHTML::Widget::WikiText
    allow form and input tags in WikiText to enable EasyForms from Wiki
    added support for select and option tags
  * Bivio::Util::TestUser
    set_user() right after the ADM user is created

  Revision 6.29  2008/05/11 13:29:09  nagler
  * Bivio::Agent::Request
    move towards multi-realm tasks by using assert_realm_type and has_realm_type
  * Bivio::Base
    b_die/b_info/b_trace/b_warn utility imports
  * Bivio::Biz::Model::ECCreditCardPaymentForm
    when determining double-click, only compare recent cc payments
  * Bivio::Biz::Model::RealmAdminList
    map import
  * Bivio::Biz::Model::RealmOwnerBase
    todo
  * Bivio::Biz::Model::RealmUserDeleteForm
    use with_realm
  * Bivio::Die
    added support for calling_context
  * Bivio::IO::Alert
    added calling_context and support for carrying calling_context
  * Bivio::IO::ClassLoader
    added list_simple_packages_in_map
  * Bivio::IO::File
    added get_modified_date_time
  * Bivio::PetShop::Util::SQL
    fmt
  * Bivio::ShellUtil
    added required_main() for command line utilities
    required_main produces better error message
  * Bivio::Test::Request
    internal_redirect_realm_guess => internal_redirect_user_realm
  * Bivio::Test::Unit
    class map
  * Bivio::Type
    to_sql_param() converts '' to undef
  * Bivio::UI::FacadeBase
    englush
  * Bivio::UI::View::CSS
    changed label padding so label_ok better aligns with text boxes
  * Bivio::UI::View::Error
    added space between messages, changed [auth_user] to [auth_user_id] to
    avoid rendering ref as string warning
  * Bivio::UI::View::ThreePartPage
    added want_page_print
  * Bivio::Util::SiteForum
    call TestUser->init_adm in init() b/c needed for proper realm setup
  * Bivio::Util::TestUser
    factored out init_adm
  * Bivio::t::Base::T1
    added test_b_die/info

  Revision 6.28  2008/05/06 02:04:53  moeller
  * Bivio::Biz::Model::RealmFileTreeList
    added can_write() and is_archive()
  * Bivio::Biz::Model::User
    remove ignore_empty_name_fields
  * Bivio::Biz::Model::UserRegisterForm
    fixed uninitialized warning in internal_initialize()
  * Bivio::SQL::PropertySupport
    added RealmFileLock to unused_classes
  * Bivio::UI::FacadeBase
    remove files area
  * Bivio::UI::Task
    die if general uri begins with ?
  * Bivio::UI::View::CSS
    set textare white-space: pre, to fix MSIE textare newline bug
  * Bivio::UI::View::File
    tree list display is based on RealmFileTreeList->can_write(),
    non-writers see a simplified view
  * Bivio::UI::Widget::URI
    intitialize => initialize

  Revision 6.27  2008/05/04 15:45:50  moeller
  * Bivio::Biz::Action::SFEETunnel
    Before creating new user, check for existing user and update password to shared value
  * Bivio::Biz::Model::FileUnlockForm
    moved file forms into FileChangeForm.pm
    initial revision
  * Bivio::Biz::Model::RealmFileTreeList
    removed unused helper methods,
    left join with RealmFileLock
    added ->is_locked()
  * Bivio::Biz::Model::RealmFileVersionsList
    left join with RealmFileLock
    added is_locked()
  * Bivio::Delegate::RowTagKey
    removed file lock and comment,
    added REALM_FILE_LOCKING
  * Bivio::Delegate::SimpleTypeError
    added INVALID_FOLDER
    added STALE_LOCK_FILE error
  * Bivio::Delegate::TaskId
    replaced file tasks with FORUM_FILE_CHANGE
    added FORUM_FILE_OVERRIDE_LOCK
  * Bivio::IO::Alert
    rmpod
  * Bivio::SQL::DDL
    added realm_file_lock_t and realm_file_lock_s
  * Bivio::UI::FacadeBase
    combine all file tasks into FORUM_FILE_CHANGE
    added FORUM_FILE_OVERRIDE_LOCK task
  * Bivio::UI::HTML::Widget::Script
    do first focus in a try/catch block to avoid errors when focussing a
    non visible field
  * Bivio::UI::View::CSS
    added .hidden_file_field and .visible_file_field for Files area
  * Bivio::UI::View::File
    replaced multiple file method views with file_change()
    removed abort button,
    moved common name and who columns into widget methods
  * Bivio::UI::XHTML::ViewShortcuts
    added no_submit parameter to vs_simple_form()
  * Bivio::Util::SQL
    added bundle ugrade for realm_file_lock_t

  Revision 6.26  2008/05/01 22:09:49  david
  * Bivio::Biz::Model::User
    ignore_empty_name_fields allows creation of User records with empty name
    fields
  * Bivio::Test::Language::HTTP
    added escape_html
  * Bivio::UI::FacadeBase
    site_name must be html

  Revision 6.25  2008/04/30 05:11:45  nagler
  * Bivio::Agent::Task
    DEFAULT_ERROR_REDIRECT is the default task when DEFAULT_ERROR_REDIRECT_*
    doesn't match anything
  * Bivio::Biz::Action::Acknowledgement
    Acknowledgement->extract_label returns the label in all cases it is available
    fmt
  * Bivio::Biz::Action::EmptyReply
    use map classes
    handle MODEL_NOT_FOUND (NOT_FOUND)
    If output already set, don't set it.  Allows for custom error replies
  * Bivio::Biz::Model::CalendarEvent
    now derived from RealmOwnerBase
  * Bivio::Biz::Model::CalendarEventList
    added missing import
  * Bivio::Biz::Model::ForbiddenForm
    rmpod & cruft
  * Bivio::Biz::Model::RealmFile
    added related "other" models
  * Bivio::Biz::Model::RealmFileTreeList
    added can_check_in() can_checkout_out(), can_unlock()
  * Bivio::Biz::Model::RealmOwnerBase
    don't allow delete() to be called except from cascade_delete()
  * Bivio::Biz::PropertyModel
    added unauth_load_user which always returns self
  * Bivio::Delegate::Cookie
    removed server_domain change
  * Bivio::Delegate::RowTagKey
    added REALM_FILE_LOCK and REALM_FILE_COMMENT
  * Bivio::Delegate::TaskId
    added new file tasks
    call Action.Error
    added DEFAULT_ERROR_REDIRECT (default server_error task)
  * Bivio::PetShop::View::Base
    so password.btest would get error on reset password with ack
  * Bivio::Test::Language::HTTP
    allow test to override referer
  * Bivio::Test::Language
    added test_self()
  * Bivio::Type::TreeListNode
    added LOCKED_LEAF_NODE
  * Bivio::UI::FacadeBase
    added file tasks and labels
    support for View.Error (XLink)
  * Bivio::UI::HTML::ViewShortcuts
    added vs_mailto_for_user_id()
    Acknowledgement->extract_label returns the label in all cases it is available
  * Bivio::UI::View::CSS
    not_found => page_error
  * Bivio::UI::View::Error
    support for any errors (driven by Action.Error)
  * Bivio::UI::View::File
    added view methods for file add/delete/update/lock/unlock
  * Bivio::UI::ViewShortcuts
    added vs_unsafe
    remove vs_unsafe
  * Bivio::UI::Widget::LogicalOpBase
    use Bivio::Base
  * Bivio::UI::Widget::URI
    query and path_info are empty
  * Bivio::UI::WidgetValueSource
    fmpt
  * Bivio::UI::XHTML::ViewShortcuts
    Acknowledgement->extract_label returns the label in all cases
  * Bivio::UI::XHTML::Widget::Acknowledgement
    Acknowledgement->extract_label returns the label in all cases it is available
    call extra_label instead of implicit coupling of Acknowledgement.label
  * Bivio::UI::XHTML::Widget::TaskMenu
    query and path_info cleared by URI
  * Bivio::UI::XHTML::Widget::XLink
    restructured to be fully dynamic
  * Bivio::UI::XHTML::Widget::XLinkLabel
    restructured to be fully dynamic
  * Bivio::UNIVERSAL
    added do_by_two
    pass index as third param to map_by_two and do_by_two

  Revision 6.24  2008/04/26 15:47:43  nagler
  * Bivio::Biz::Action::WikiView
    route non-WikiNames through WikiDataName
  * Bivio::ShellUtil
    Removed all explicit Bivio:: imports (except Bivio::IO::Trace)
    Added -detach_log
    put ref_to_string back, not really deprecated
  * Bivio::Type::WikiDataName
    v6: route through args->{task_id}; WikiView understands how to route
    non-wiki names
  * Bivio::UI::FacadeBase
    misc

  Revision 6.23  2008/04/26 06:16:48  nagler
  Release notes:
  * Bivio::Biz::Action::RealmFile
    added set_output_for_get
  * Bivio::Biz::Model::Email
    added internal_prepare_query and downcase in create/update
  * Bivio::Biz::Model::MailReceiveDispatchForm
    todo
  * Bivio::Biz::Model::MailThreadList
    added RealmFile.path for view_rfc822
  * Bivio::Biz::Model::RealmFileList
    added base_name field
  * Bivio::Biz::Model::RealmMail
    from email is used to get user_id;  should not rely on current user
  * Bivio::Biz::Model
    added field_equals
  * Bivio::UI::FacadeBase
    added view_rfc822
  * Bivio::UI::View::CSS
    extend actions
  * Bivio::UI::View::Mail
    added view_rfc822

  Revision 6.22  2008/04/25 17:49:51  dobbs
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    allow WikiText in b-menu Label
  * Bivio::UI::XHTML::Widget::WikiText
    added WikiStrippedText to support use of WikiText in b-menu Label

  Revision 6.21  2008/04/25 01:31:14  nagler
  * Bivio::Agent::Request
    added with_realm_and_user
  * Bivio::Biz::FormModel
    validate_and_execute_ok now calls internal_post_execute
    internal_post_execute can override $res from validate_and_execute_ok
  * Bivio::Biz::Model::RealmFile
    added is_searchable
  * Bivio::Biz::Model::RealmUser
    added unsafe_get_any_online_admin
  * Bivio::Biz::Model::RealmUserAddForm
    use dynamic superclass
  * Bivio::Biz::Model::UserPasswordQueryForm
    added QUERY_KEY which is checked in execute_empty for email to use
  * Bivio::Delegate::TaskId
    Added user_exists_task to USER_CREATE
  * Bivio::SQL::Connection::Postgres
    catch (rare) case where _fixup_outer_join removes all predicates, leaving a (malformed) empty WHERE clause
  * Bivio::Search::Xapian
    update_realm_file checks is_searchable
  * Bivio::ShellUtil
    set_user_to_any added, and now the default for set_user in startup
    rm comment
  * Bivio::UI::FacadeBase
    user_exists ack
  * Bivio::UI::HTML::Widget::Form
    fix Form widget to set model from request
  * Bivio::UI::HTML::Widget::FormFieldLabel
    fix Form widget to set model from request
  * Bivio::UI::XHTML::Widget::TaskMenu
    let pages define a class for links in the TaskMenu
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    add Class column for bmenu CSV definition
    added value= option
  * Bivio::UI::XHTML::Widget::WikiText
    let html entities appear inline
    fpc
  * Bivio::UNIVERSAL
    added ureq()

  Revision 6.20  2008/04/24 19:23:42  moeller
  * Bivio::Biz::Model::RealmFile
    added is_searchable
  * Bivio::Biz::Model::RealmUserAddForm
    use dynamic superclass
  * Bivio::Biz::Model::RealmUser
    added unsafe_get_any_online_admin
  * Bivio::Search::Xapian
    update_realm_file checks is_searchable
  * Bivio::ShellUtil
    set_user_to_any added, and now the default for set_user in startup
    rm comment
  * Bivio::SQL::Connection::Postgres
    catch (rare) case where _fixup_outer_join removes all predicates, leaving a (malformed) empty WHERE clause
  * Bivio::UI::HTML::Widget::FormFieldLabel
    fix Form widget to set model from request
  * Bivio::UI::HTML::Widget::Form
    fix Form widget to set model from request
  * Bivio::UNIVERSAL
    added ureq()

  Revision 6.19  2008/04/23 02:09:40  nagler
  * Bivio::Biz::FormModel
    added unauth_create_or_update_model_properties
  * Bivio::Biz::Model::CRMForm
    cleaned up the way edit mode was being detected
  * Bivio::Biz::Model::MailForm
    cleaned up the way edit mode was being detected
  * Bivio::Biz::Model::RealmMailList
    added RealmFile.user_id
  * Bivio::Biz::Model::TupleTagForm
    call_super in delegation is tricky.  Need to specify package relative
    to super
  * Bivio::Test::HTMLParser::Forms
    identical fields are no longer replicated as <field>#1, ...
  * Bivio::UI::View::CRM
    hooks for subcalsses to override extra fields
  * Bivio::UI::View::Mail
    buttons are extra fields by default
  * Bivio::UI::XHTML::ViewShortcuts
    vs_list_form now inlines table of list fields whereever need be
  * Bivio::UNIVERSAL
    call_super and call_super_before didn't work if called in subclasses.
    See the tests as to why
  * Bivio::t::UNIVERSAL::Delegate
    call_super and call_super_before didn't work if called in subclasses.
    See the tests as to why
  * Bivio::t::UNIVERSAL::Delegator
    call_super and call_super_before didn't work if called in subclasses.
    See the tests as to why

  Revision 6.18  2008/04/21 19:08:30  dobbs
  * Bivio::Agent::Request
    assert_* returns $self
  * Bivio::Agent::Task
    fix handle_rollback call in _call_txn_resources
  * Bivio::Biz::Action::RealmFile
    fall through on folder if want_folder_fall_thru
  * Bivio::Biz::Action::TestBackdoor
    use Bivio::Base
  * Bivio::Biz::Action::WikiView
    added author_name support
  * Bivio::Biz::Model::CRMForm
    use email of user when creating a new CRMThread
  * Bivio::Biz::Model::RealmFile
    added override_versioning
    don't call methods without $sefl->
    added is_text_content_type()
  * Bivio::Biz::Model::RealmFileList
    use BIvio::Base
    fpc
  * Bivio::Biz::Model::RealmFileTreeList
    is_text_content_type
  * Bivio::Delegate::TaskId
    TEST_BACKDOOR: Action.AssertClient
    FORUM_TEXT_FILE_FORM
  * Bivio::MIME::Type
    bmenu
  * Bivio::PetShop::Facade::PetShop
    define support_name
  * Bivio::PetShop::View::Base
    added FORUM_FILE and FORUM_WIKI_VIEW
  * Bivio::Test::Unit
    builtin_realm_id calls RealmAdmin->to_id
  * Bivio::Test::Util
    catch quietly on error
  * Bivio::UI::FacadeBase
    support for text file forms
  * Bivio::Util::RealmAdmin
    added to_id()
  * Bivio::Util::SQL
    added parse_trace_output
    parse_trace_output includes trailing ;
  * Bivio::Util::SiteForum
    create service-tac forum

  Revision 6.17  2008/04/15 22:53:58  moeller
  * Bivio::Mail::Incoming
    wrap get_message_id value in scalar() so it returns undef, not ()
  * Bivio::SQL::Connection::MySQL
    retry after 15 seconds if mysql is not running
  * Bivio::UI::XHTML::Widget::WikiText
    change catch on widget to catch_quietly

  Revision 6.16  2008/04/15 02:31:56  moeller
  * Bivio::Agent::HTTP::Reply
    CLIENT_ERROR maps to HTTP error code HTTP_SERVICE_UNAVAILABLE

  Revision 6.15  2008/04/13 04:11:41  nagler
  * Bivio::Delegate::Cookie
    need to import Bivio::IO::Trace
  * Bivio::Type::DateTime
    english_day_of_week_list
  * Bivio::UI::View::CSS
    amount_cell nowrap
  * Bivio::Util::Backup
    fix _which_archive() so does not die if archive|weekly exists
    document what is archived
    archive_mirror_link works on 5.6 now

  Revision 6.14  2008/04/10 23:02:40  nagler
  * Bivio::Test::Unit
    trim_directories: does the "rm" itself instead of outputing it
  * Bivio::Util::Backup
    trim_directories deletes last N dirs
    archive_mirror_link copies to weekly (once a week) or archive (once a month)

  Revision 6.13  2008/04/08 17:25:21  moeller
  * Bivio::Biz::Model::RealmFile
    factored out get_content_type_for_path
  * Bivio::UI::XHTML::Widget::FormFieldError
    put internal_new_args() back

  Revision 6.12  2008/04/07 04:50:54  nagler
  * Bivio::Biz::Model::CRMForm
    ticket -> b_ticket
  * Bivio::PetShop::Util::SQL
    ticket -> b_ticket
  * Bivio::UI::View::CRM
    ticket -> b_ticket

  Revision 6.11  2008/04/05 20:54:22  nagler
  * Bivio::Biz::Model::MailForm
    factor out internal_send_to_realm for subclases

  Revision 6.10  2008/04/05 15:11:17  nagler
  * Bivio::Agent::HTTP::Request
    added retain_query_and_path_info support, but can't be configured to
    false until query retention dependencies are removed
  * Bivio::Agent::Request
    added retain_query_and_path_info support, but can't be configured to
    false until query retention dependencies are removed
  * Bivio::Biz::Action::ECCreditCardProcessor
    don't send card zip if it has no value, allows non AVS transactions
  * Bivio::Biz::Action::RealmMail
    execute_receive can be called inline with $rfc822
  * Bivio::Biz::ListModel
    execute_load_page clears "this" on the query
  * Bivio::Biz::Model::CRMForm
    delegate to TupleTagForm
    set thread id after create
    added update_only support
    tag_id is now "ticket."
    added support for rendering slots
  * Bivio::Biz::Model::CRMThread
    added update_only support
  * Bivio::Biz::Model::CRMThreadRootList
    fixed Email.location problem
  * Bivio::Biz::Model::MailForm
    render the mail message (form_imail) inline and then enqueue
    first step towards storing mails directly
    mail stored first (if sent to realm) and then forwarded to other
    recipients and the list
  * Bivio::Biz::Model::SearchList
    todo
  * Bivio::Biz::Model::TupleSlotChoiceList
    load_all_from_slot_type accepts a Type.TupleSlotType
  * Bivio::Biz::Model::TupleSlotChoiceSelectList
    fmt
  * Bivio::Biz::Model::TupleSlotDefList
    added tuple_slot_info field & MISSING_SLOT_INFO()
  * Bivio::Biz::Model::TupleUse
    fmt
  * Bivio::Mail::Outgoing
    improved Message-ID generation
    new() accepts a scalar_ref which it passes on to Incoming
  * Bivio::PetShop::Util::SQL
    added tuple_tag data
    tag_id is now "ticket."
  * Bivio::SQL::DDL
    added tuple_tag
    tuple_tag_t no longer includes modified_date_time
  * Bivio::SQL::FormSupport
    rmpod
    added extract_column_from_classes
  * Bivio::SQL::PropertySupport
    exclude TupleTag
  * Bivio::SQL::Support
    added extract_qualified_prefix
  * Bivio::Test::Type
    allow unit to be structured like a normal test (first element is [])
  * Bivio::Type::StringArray
    added do_iterate
    added as_length
    don't need as_length
  * Bivio::Type::TupleSlot
    fmt
  * Bivio::Type::TupleSlotNum
    added field_name_to_num
  * Bivio::UI::FacadeBase
    TupleTag support
    added CRMForm.update_only support
  * Bivio::UI::HTML::Widget::FormField
    don't need IDI
  * Bivio::UI::HTML::Widget::FormFieldError
    simplified and rmpod
  * Bivio::UI::Mail::Widget::Message
    factored out _render() so can share with render()
  * Bivio::UI::View::Base
    added imail() base type (inline mail)
    added internal_base_attr
  * Bivio::UI::View::CRM
    added update_only support
    render slots
  * Bivio::UI::View::Mail
    render the mail message (form_imail) inline and then enqueue
    first step towards storing mails directly
    send_form() internface changed
  * Bivio::UI::ViewShortcuts
    added vs_form_method_call
  * Bivio::UI::Widget::If
    rmpod
  * Bivio::UI::Widget
    added resolve_form_model
  * Bivio::UI::XHTML::ViewShortcuts
    cleaned up vs_simple_form config
  * Bivio::UI::XHTML::Widget::FormFieldError
    simplified
  * Bivio::UI::XHTML::Widget::FormFieldLabel
    use IfFieldError, resolve_form_model
  * Bivio::UNIVERSAL
    added call_super
  * Bivio::Util::CRM
    needs initialize_fully
  * Bivio::Util::SQL
    added internal_upgrade_db_tuple_tag
    tuple_tag_t no longer includes modified_date_time

  Revision 6.9  2008/04/01 20:57:13  moeller
  * Bivio::Delegate::TaskId
    SITE_ADM_SUBSTITUTE_USER_DONE must be ANYBODY
  * Bivio::Type::USZipCode9
    allow dashes
    relax length constraints on zip
  * Bivio::UI::HTML::Widget::Checkbox
    use get_or_default() - label may be ''

  Revision 6.8  2008/03/28 03:54:45  nagler
  * New classes: Action.SiteForum.pm, XHTMLWidget.JoinMenu,
    XHTMLWidget.SearchForm, XHTMLWidget.UserSettingsForm,
    XHTMLWidget.UserState, XHTMLWidget.XLinkLabel
  * Bivio::Delegate::TaskId
    added SITE_WIKI_VIEW
  * Bivio::PetShop::Delegate::TaskId
    FIELD_TEST_FORM
  * Bivio::PetShop::Facade::PetShop
    FIELD_TEST_FORM
  * Bivio::PetShop::Util::SQL
    added index page
  * Bivio::Test::WikiText
    renamed $new_params to $create_params
  * Bivio::Test
    display stack when "Error in custom"
  * Bivio::UI::FacadeBase
    Added ThreePartPage_want_* control
    SITE_WIKI_VIEW
  * Bivio::UI::HTML::Widget::Form
    subclass ControlBase
  * Bivio::UI::View::CSS
    .settings => .user_settings
    organized .user_state into widgets
  * Bivio::UI::View::ThreePartPage
    internal_search_form gone
    organized DIV_user_state into into widgets: HelpWiki,
    UserSettingsForm, UserState, and SearchForm
  * Bivio::UI::View::Wiki
    added site_view()
  * Bivio::UI::Widget::Director
    rmpod and IDI
    keys in values may a regular expression
  * Bivio::UI::XHTML::Widget::XLink
    use XLinkLabel

  Revision 6.7  2008/03/27 20:57:23  moeller
  * Bivio::UI::HTML::Widget::DateField
    fixed method name, calls super

  Revision 6.6  2008/03/27 19:50:43  nagler
  * Bivio::BConf
    html_attrs named trace filter
  * Bivio::Delegate::SimpleAuthSupport
    rmpod
  * Bivio::Delegate::TaskId
    test_trace task
  * Bivio::ShellUtil
    fmt
  * Bivio::Test::Language::HTTP
    do_test_trace
  * Bivio::Test::Language
    catch_quietly in deviance case
  * Bivio::Test::Unit
    added builtin_random_alpha_string
  * Bivio::Test::Util
    added remote_trace
    refactored _mock_sendmail_facade into _uri_for_task
    fpc
    fpc
  * Bivio::Test
    catch_quietly and only output stack when conformance failure or
    deviance mismatch
  * Bivio::Type::USZipCode
    REGEX must return $1
  * Bivio::UI::FacadeBase
    test_trace task
  * Bivio::UI::HTML::Widget::InputBase
    type not defaulted
  * Bivio::UI::HTML::Widget::InputTextBase
    generate type= dynamically for password or text
  * Bivio::UI::View::ThreePartPage
    xhtml_outermost_class unused
  * Bivio::Util::Backup
    bzip2 is too slow

  Revision 6.5  2008/03/27 00:20:43  nagler
  * Bivio::Agent::HTTP::Reply
    incorrect comment
  * Bivio::Biz::Action::WikiView
    internal_model_not_found is thrown quietly
  * Bivio::Biz::Model::RealmFile
    get_content_type must strip version before checking type
  * Bivio::Biz::Model::SearchList
    excerpt length is 250 chars
  * Bivio::Biz::Model
    put_on_request returns $self
  * Bivio::IO::Config
    if_version allows values to be returned, not just code_ref calls
    allow if_version(3)
  * Bivio::PetShop::BConf
    v6
  * Bivio::PetShop::Facade::PetShop
    use Phone_2 and Address_2 for shipping address
  * Bivio::Type::FilePath
    WIKI_DATA_FOLDER
    default REGEX
  * Bivio::Type::WikiName
    REGEX must return $1
  * Bivio::UI::HTML::ViewShortcuts
    factored out vs_html_attrs_render_one
  * Bivio::UI::HTML::Widget::Grid
    call vs_html_attrs_render_one for most attrs
  * Bivio::UI::HTML::Widget::Page
    call vs_html_attrs_render_one for body_class
  * Bivio::UI::HTML::Widget::Table
    call vs_html_attrs_render_one for most attrs
  * Bivio::UI::HTML::Widget::Tag
    factored out internal_tag_render_attrs
  * Bivio::UI::View::CSS
    .b_prose support for wiki (leaving existing .prose)
  * Bivio::UI::View::ThreePartPage
    extract out internal_search_form
  * Bivio::Util::Backup
    glob is very strange and shouldn't be used in a scalar context with functions
  * Bivio::Util::HTTPConf
    document validate_vars

  Revision 6.4  2008/03/23 22:23:02  nagler
  * Bivio::Agent::Task
    _call_txn_resources() must loop until there are no more transaction
    resources.  Certain commits will introduce new transaction resources
    (e.g. Search.Xapian adds a lock).  Probably should add
    handle_prepare_commit.
  * Bivio::BConf
    added HTML, SearchParser, SearchParserRealmFile
    more maps
  * Bivio::Biz::Action::RealmFile
    set_cache_private if the file is not public
  * Bivio::Biz::Model::CRMThread
    handle_mail_post_create was not checking is_enabled_for_auth_realm
  * Bivio::Biz::Model::SearchList
    result_excerpt, result_title, and result_who work properly
  * Bivio::Biz::Random
    string() defaults $length to 8
  * Bivio::Delegate::TaskId
    improved search support
  * Bivio::MIME::Type
    changed application/x-bwiki to text/x-bivio-wiki
  * Bivio::Search::RealmFile
    Refactored to support excerpting in SearchList and better modularization for new searchable objects
  * Bivio::Test::HTMLParser::Forms
    fpc
  * Bivio::Test::Language::HTTP
    random_string() passes all args through
  * Bivio::Test::Request
    use Test.Bean
  * Bivio::Type::BlogTitle
    added empty_value
  * Bivio::Type::Number
    sum calls iterate_reduce
  * Bivio::UI::FacadeBase
    label for SEARCH_LIST
    support for search
  * Bivio::UI::View::CSS
    support for search
  * Bivio::UI::View::Mail
    added id for part
  * Bivio::UI::View::Search
    added result_who, title, and excerpt
  * Bivio::UI::View::ThreePartPage
    added SearchForm support
  * Bivio::UI::ViewLanguage
    fmt
  * Bivio::Util::SQL
    destroy_dbms does not destroy realm files

  Revision 6.3  2008/03/20 03:16:17  nagler
  * Bivio::Biz::Action::ECCreditCardProcessor
    rm pod
  * Bivio::PetShop::Test::PetShop
    moved Util.SQL
  * Bivio::ShellUtil
    piped_exec supports array for $command
  * Bivio::Test::Language::HTTP
    verify_link supports patterns properly
  * Bivio::UI::HTML::Widget::Form
    added html_attrs
  * Bivio::Util::Backup
    use array_ref for piped_exec command of tar to avoid escape issues

  Revision 6.2  2008/03/18 20:01:54  nagler
  * Bivio::Test::HTMLParser::Forms
    do not label selects with the selected value, rather call them _anon
    if no obvious label
  * Bivio::UI::FacadeBase
    fpc

  Revision 6.1  2008/03/18 14:51:11  nagler
  * Bivio::Test::HTMLParser::Forms
    _start_option has to clear text so that first option label doesn't
    have junk in it
  * Bivio::Test::Unit
    fix output for inverted _assert_expect
    added Map_SimpleClass() dispatch to tests and allowed SimpleClass() if
    in the list of known maps already
  * Bivio::Test::Util
    added nightly_output_to_wiki
    nightly_output_to_wiki: date already in local time
    nightly_output_to_wiki properly strips output
  * Bivio::Type::Number
    iterate_reduce replaces reduce
  * Bivio::UI::FacadeBase
    added SITE_ADM_REALM_NAME
    added DEFAULT_ERROR_REDIRECT_FORBIDDEN title
    Cleaned up links for titles
  * Bivio::UNIVERSAL
    iterate_reduce replaces reduce
  * Bivio::Util::SiteForum
    give SITE_ADM_REALM_NAME feature_site_adm

  Revision 6.0  2008/03/14 03:00:54  nagler
  Rollover to 6.0

  Revision 5.93  2008/03/14 02:59:57  nagler
  * Bivio::Biz::File
    call rm_children
  * Bivio::IO::File
    added rm_children
  * Bivio::PetShop::BConf
    ShellUtil is now Bivio::PetShop::Util
  * Bivio::Test::Unit
    added assert_eval
  * Bivio::Type::Number
    added sum(),
    max() and min() now take a variable number of values to compare
  * Bivio::UI::View::CSS
    fmt
  * Bivio::UNIVERSAL
    added reduce()
  * Bivio::Util::Dev
    support pet-sql
  * Bivio::Util::SQL
    use IO.File->rm_children

  Revision 5.92  2008/03/11 02:31:57  nagler
  * Bivio::Util::CRM (b-crm) added
  * Bivio::Biz::Action::RealmMail
    call EmailAlias->format_realm_as_incoming
  * Bivio::Biz::Model::MailForm
    Reply-To: must be set
    Moved EmailAlias lookup to EmailAlias->format_realm_as_incoming
  * Bivio::PetShop::Util
    use ShellUtil.CRM
  * Bivio::UI::Widget::ControlBase
    renamed control_is_on to is_control_on
  * Bivio::UI::XHTML::Widget::TaskMenu
    renamed control_is_on to is_control_on

  Revision 5.91  2008/03/09 00:23:48  nagler
  * Bivio::Auth::Realm
    call RealmType.is_default_id
  * Bivio::Auth::RealmType
    added as_default_owner_id, as_default_owner_name, and is_default_id
  * Bivio::Biz::FormContext
    rmpod
  * Bivio::Biz::Model::ECPaymentList
    Let Bivio::Biz::Model get_instance on RealmOwner
  * Bivio::Biz::Model::MailPartList
    internal_format_uri as hook to change realm_name
  * Bivio::Biz::Model::RealmOwner
    use as_default_owner_name and as_default_owner_id
  * Bivio::Test::Language::HTTP
    added poll_page()
  * Bivio::Test::Language
    added test_now()
  * Bivio::Type::BlogTitle
    Bivio::Base
  * Bivio::Type::Enum
    added unsafe_from_int
  * Bivio::UI::HTML::Widget::Table
    want_sorting true if column_order_by is set
    undo previous change
  * Bivio::UI::Task
    Let Bivio::Biz::Model get_instance on RealmOwner
  * Bivio::UI::View::CSS
    message attachment formatting
    fix spacing on download attachment link
  * Bivio::UI::View::Mail
    changed thread formatting to be inside an attachment
    added "download" class to attachment link
  * Bivio::UI::Widget::ControlBase
    rmpod
    export control_is_on
  * Bivio::UI::XHTML::Widget::MailBodyPlain
    initial indents handled by nbsp
  * Bivio::UI::XHTML::Widget::TaskMenu
    call control_is_on if available on widget before calling can_user_execute_task
    fpc
  * Bivio::UNIVERSAL
    remove deprecation on call_super_before
  * Bivio::Util::SQL
    use "use" to reference modules

  Revision 5.90  2008/03/08 00:09:50  aviggio
  * Bivio::Biz::ListModel
    unsafe_load_this_or_first should return a result
  * Bivio::Biz::Model::AdmUserList
    expose NAME_COLUMNS
  * Bivio::Biz::Model::ForumUserList
    specify Email.location in internal_initialize
  * Bivio::Biz::Model::MailReceiveDispatchForm
    mail loop detection improvements to reduce memory use
  * Bivio::UI::View::SiteAdm
    use vs_user_email_list
  * Bivio::UI::XHTML::ViewShortcuts
    add vs_user_email_list
  * Bivio::UNIVERSAL
    fix delegation to work with all types of parameters
  * Bivio::Util::Release
    added list_projects

  Revision 5.89  2008/03/06 17:32:17  moeller
  * Bivio::Biz::Model::ECCreditCardPaymentForm
    fixed _possible_double_click(), added info() when payment is processed
  * Bivio::UI::View::Base
    added mail_cc for mail views

  Revision 5.88  2008/03/05 22:38:57  david
  * Bivio::BConf
    added Search map
  * Bivio::Biz::Action::RealmMail
    added MAIL_LIST_WANT_TO_USER
  * Bivio::Delegate::RowTagKey
    added MAIL_LIST_WANT_TO_USER
  * Bivio::Search::RealmFile
    don't print errors when title not found by pdfinfo
  * Bivio::UI::HTML::Widget::Tag
    uppercase attributes pushed up to ControlBase

  Revision 5.87  2008/02/26 14:58:58  nagler
  * Bivio::BConf
    added feature_site_adm
  * Bivio::Biz::Model::MailForm
    added internal_return_value
  * Bivio::Biz::Model::MailReceiveDispatchForm
    v5: ignore_dashes_in_recipient is true
    canonicalize warning
  * Bivio::Biz::Model::UserCreateForm
    use Bivio::Base
  * Bivio::Biz::Model::UserLoginForm
    fpc
    via_mta with user with invalid password, don't login, but don't die
  * Bivio::Biz::Model::UserRegisterForm
    RealmOwner.password is an other, not visible field
  * Bivio::Delegate::SimplePermission
    added feature_site_adm
  * Bivio::Delegate::TaskId
    added USER_SETTINGS_FORM
    added site_adm component
  * Bivio::PetShop::BConf
    v5: ignore_dashes_in_recipient is true
  * Bivio::PetShop::Facade::PetShop
    support for UserSettingsForm
    want_user_state_settings => want_user_settings
    want_user_settings defaults to one in v5
  * Bivio::PetShop::Util
    added invalidated_user
  * Bivio::PetShop::View::Base
    added SITE_ADM_USER_LIST
  * Bivio::ShellUtil
    _setup_for_call was not calling _parse_realm for user/realm
  * Bivio::SuperAUTOLOAD
    deprecated
  * Bivio::Test::Language::HTTP
    always replace underscores
    _fixup_pattern does not escape underscores if a stringified regexp
  * Bivio::Test::Unit
    addded builtin_assert_not_equals
    builtin_random_string calls string, not hex_digits
  * Bivio::Type::WikiName
    task_to_help => title_to_help
  * Bivio::UI::FacadeBase
    support for UserSettingsForm
    want_user_state_settings => want_user_settings
    added site_adm component
    v5: exit substitute user is SITE_ADM_SUBSTITUTE_USER_DONE
    move to/cc/subject to outer level
  * Bivio::UI::HTML::Widget::Form
    added want_hidden_fields
  * Bivio::UI::View::CSS
    *** empty log message ***
    added padding .5em to form .submit
    alphabetical_chooser: leave case alone
    labels vertical-align: top
    align form fields
  * Bivio::UI::View::Mail
    added internal_standard_tools & internal_part_list
  * Bivio::UI::View::ThreePartPage
    added USER_SETTINGS_FORM link
    want_user_state_settings => want_user_settings & added user_state qualifier
  * Bivio::UI::View::UserAuth
    added settings_form
  * Bivio::UI::ViewShortcuts
    added vs_render_widget
  * Bivio::UI::XHTML::ViewShortcuts
    Form separators are now Prose
    vs_alphabetical_chooser: fixed to manage names (All)  properly
  * Bivio::UI::XHTML::Widget::HelpWiki
    Fix to support Prose titles
  * Bivio::UNIVERSAL
    fixed call_super_before explicitly
  * Bivio::Util::SiteForum
    added feature_site_adm to SITE_REALM
  * Bivio::Util::TestUser
    added leave_and_delete

  Revision 5.86  2008/02/21 21:13:22  moeller
  * Bivio::Biz::Model::UserLoginForm
    added third argument to validate_login() for login field name
  * Bivio::PetShop::View::Base
    only render menu if FORUM

  Revision 5.85  2008/02/20 04:35:28  aviggio
  * Bivio::Biz::Model::MailReceiveDispatchForm
    restrict mail loop detection to a one hour window
  * Bivio::IO::Template
    added replace_in_file
  * Bivio::ShellUtil
    get_project_root gives you the root directory of your project
  * Bivio::Test::ShellUtil
    new_unit returns a single value
  * Bivio::Test::Unit
    added builtin_template
  * Bivio::Util::HTTPD
    cleanup and error if cant set want_local_file_cache
  * Bivio::Util::SQL
    automatically cd to ddl directory when creating a test database

  Revision 5.84  2008/02/16 03:54:23  nagler
  * Bivio::Biz::Model::CRMForm
    comment
    call_super_before was corrupting symbol table
  * Bivio::Biz::Model::CRMThread
    fix status change in incoming update mail
    fixed status update code to include forum in list of valid addresses
  * Bivio::Biz::Model::MailForm
    added get_realm_emails
    call_super_before broken
  * Bivio::PetShop::Util
    call_super_before removed
  * Bivio::PetShop::View::Base
    call_super_before is deprecated
  * Bivio::Test::ShellUtil
    call_super_before removed
  * Bivio::UNIVERSAL
    super_for_method/call_super_before are deprecated, because referencing
    the package hash for methods corrupts entire symbol table
  * Bivio::Util::SQL
    my to our
    our to my

  Revision 5.83  2008/02/14 02:20:15  nagler
  * Bivio::Biz::Model::CRMForm
    execute_cancel needs to call SUPER
  * Bivio::Mail::Incoming
    get_reply_email_arrays puts realm in Cc: unless there is no To:
  * Bivio::Util::SiteForum
    set site-contact display name to support_name

  Revision 5.82  2008/02/13 22:46:40  aviggio
  * Bivio::Biz::Action::MailForward
    Call Bivio::Mail::Outgoing->set_headers_for_forward
  * Bivio::Biz::Model::MailReceiveDispatchForm
    Detect mail loops related to invalid forwarding or auto-responders
  * Bivio::Biz::Model::RealmMailBounce
    Handle bounce for duplicate message
  * Bivio::Mail::Outgoing
    Add set_headers_for_forward
  * Bivio::SQL::DDL
    Include copyright at top of generated file

  Revision 5.81  2008/02/13 21:51:41  nagler
  * Bivio::UI::HTML::ViewShortcuts
    can't inherit UI.ViewShortcuts, because may map ViewShortcuts in package

  Revision 5.80  2008/02/13 21:31:14  nagler
  * Bivio::BConf
    Replace NoMotionType with SimpleMotionType
  * Bivio::Biz::ListModel
    Added unsafe_load_this_or_first
  * Bivio::Biz::Model::CRMForm
    Package my's changed to ours's.   Seems that mod_perl has a bug with
    package lexicals, which causes them to disappear, and to corrupt the
    symbol table
  * Bivio::Biz::Model::MailForm
    Package my's changed to ours's.   Seems that mod_perl has a bug with
    package lexicals, which causes them to disappear, and to corrupt the
    symbol table
  * Bivio::Biz::Model::RealmFile
    Specify current time stamp when versioning file
  * Bivio::Biz::Util::RealmRole
    list_enabled_categories wasn't handling missing role values properly
  * Bivio::UI::HTML::ViewShortcuts
    rmpod
    added vs_edit
  * Bivio::UI::View::Tuple
    used vs_edit, not vs_display for form fields
  * Bivio::Util::SQL
    run _sentinel_permissions51 in initialize_db so doesn't get run on
    clean dbs
    added crm_thread upgrade
    fix bug in permissions51
    generate ddl
    Support new motion test
    must reverse the bits in permissions51 upgrade so don't stomp on
    changes

  Revision 5.79  2008/02/11 04:54:37  nagler
  * Bivio::BConf
    added feature_crm
  * Bivio::Biz::Action::RealmMail
    added RowTag MAIL_SUBJECT_PREFIX
  * Bivio::Biz::Model::MailForm
    added hooks for CRM support
  * Bivio::Biz::Model::OrdinalBase
    factored out internal_next_ord
  * Bivio::Biz::Model::RealmEmailList
    added Email.location
  * Bivio::Biz::Model::RealmMail
    added registered handles
  * Bivio::Biz::Model::RealmMailList
    added RealmMail.thread_root_id
  * Bivio::Biz::Model::RealmUserList
    added roles query key
    use Biz.ListModel
  * Bivio::Biz::Model::TreeList
    cruft
  * Bivio::Biz::Model::Tuple
    change realm_mail_hook => handle_mail_*
  * Bivio::Delegate::RowTagKey
    added RowTag MAIL_SUBJECT_PREFIX
  * Bivio::Delegate::SimplePermission
    added FEATURE_ERP and other FEATURE_*
    fix FEATURE_CRM
    moved FEATURE_* permissions to fit better with existing apps
  * Bivio::Delegate::TaskId
    added info_crm
  * Bivio::Mail::Incoming
    get_reply_email_arrays takes realm_emails
  * Bivio::PetShop::Util
    init_crm
  * Bivio::PetShop::View::CSS
    align task_menu in header
  * Bivio::SQL::PropertySupport
    added CRMThread
  * Bivio::Test::Unit
    added autoloading of Types and Models
  * Bivio::Type::Email
    get_local_part
  * Bivio::UI::FacadeBase
    added crm support
  * Bivio::UI::HTML::ViewShortcuts
    added wf_want_display to vs_display
  * Bivio::UI::View::CSS
    aligning text areas
  * Bivio::UI::View::Mail
    hooks to allow CRM code to work
  * Bivio::UI::Widget
    format errors with () instead of [], b/c confuses with widget values
  * Bivio::Util::SQL
    added permissions51 upgrade
    internal_upgrade_db_permissions51 adds FEATURE_MOTION/TUPLE if *_READ

  Revision 5.78  2008/02/07 21:43:53  nagler
  * Bivio::BConf
    MIME map
    added Bivio map
  * Bivio::Biz::ListModel
    set_cursor allows -1 as cursor; reset_cursor calls set_cursor(RESET_CURSOR)
    added save_excursion
  * Bivio::Biz::Model::RealmMail
    added get_rfc822 & get_mail_part_list
  * Bivio::Biz::Model::User
    keep RealmOwner.display_name in sync with User->format_full_name
  * Bivio::Biz::Model
    add comment to do_iterate
  * Bivio::Biz::PropertyModel
    load_auth_user dies if doesn't load
  * Bivio::Delegate::SimpleTaskId
    sort components so base is first
  * Bivio::Delegate::SimpleWidgetFactory
    added StringArray
  * Bivio::IO::Config
    remove warning
  * Bivio::MIME::Type
    cruft
  * Bivio::Mail::Incoming
    added get_reply_email_arrays
    initialize allows object which can(get_rfc822)
  * Bivio::Mail::Outgoing
    added quoted-printable encoding
    upgraded imports
  * Bivio::PetShop::BConf
    version 4
    deprecated_text_patterns is off in version 4
  * Bivio::PetShop::Facade::PetShop
    example_background is white (violet too hard to deal with)
  * Bivio::PetShop::Test::PetShop
    added next_message_id
  * Bivio::SQL::ListQuery
    don't add n= if at or before first page
    fix format_uri_for_this_child to accept ListQuery.order_by in $this_row
  * Bivio::SQL::Support
    show the model class name in the column alias warning
    don't die() if 'class' is missing from decl - used for debugging only
  * Bivio::Test::Language::HTTP
    fixed send_email to not make regexps into emails
    deprecated_text_patterns is off in version 4
  * Bivio::Test::Request
    unsafe_get_captured_mail greps txn_resources and no longer uses
    Test::MockObject
  * Bivio::Test::Unit
    use IO.File
    added builtin_remote_email
  * Bivio::Test::Util
    don't split output between test name on "ok"
  * Bivio::Type::DisplayName
    return empty values for first/last/middle if not parsed
  * Bivio::Type::Enum
    added as_uri()
  * Bivio::Type::MailSubject
    added EMPTY_VALUE as constant (NO Subject)
  * Bivio::Type::StringArray
    from_literal_validator was not being called
  * Bivio::UI::Color
    rmpod
  * Bivio::UI::DateTimeMode
    default is DATE_TIME in v4
  * Bivio::UI::FacadeComponent
    fmt
  * Bivio::UI::HTML::Widget::FormField
    added row_class
  * Bivio::UI::HTML::Widget::Link
    misc fix
  * Bivio::UI::HTML::Widget::Tag
    tag_if_empty defaults to true if the value is constant empty string ('')
  * Bivio::UI::Text::Widget::CSV
    AUTOLOAD vs_text
    undo prev change, because may be used in non-view environments
  * Bivio::UI::View::Tuple
    fixed pre_compile
  * Bivio::UI::View::UserAuth
    general_contact_mail: don't cc user, because could be used as spam engine
  * Bivio::UI::XHTML::Widget::FormFieldLabel
    added "label" as extra class to label_ok and label_err
  * Bivio::UI::XHTML::Widget::Pager
    added want_sep
  * Bivio::UI::XHTML::Widget::WikiText
    use Mail.RFC822
  * Bivio::UI::XHTML::Widget::XLink
    base fix
  * Bivio::Util::SQL
    change order of petshop backups
    create_test_user returns user_id
    cleaned up imports
  * Bivio::Util::TestRealm
    name_args replaces arg_list
  * Bivio::Util::Wiki
    removed extraneous file write

  Revision 5.77  2008/01/18 00:17:35  nagler
  * Bivio::BConf
    Collection map
  * Bivio::Delegate::RealmDAG
    PARENT_IS_AUTHORIZED_ACCESS
  * Bivio::IO::Trace
    added set_named_filters
  * Bivio::Test::Unit
    replaced inline_trace_* with inline_/trace which uses named filters
  * Bivio::Util::SQL
    use mapped classes

  Revision 5.76  2008/01/17 03:25:28  nagler
  * Bivio::Agent::Task
    protect resources when committing/rollingback
  * Bivio::BConf
    added Bivio::IO::Trace.sql configu
  * Bivio::Biz::ExpandableListFormModel
    added EMPTY_AND_CANNOT_BE_SPECIFIED_FIELDS
  * Bivio::Biz::FormModel
    fix create_model_properties et al to support qualified models
  * Bivio::Biz::Model::NumberedList
    rmpod
  * Bivio::Biz::Model::RealmUser
    added unauth_delete_user
  * Bivio::Biz::Model::User
    added unauth_delete_realm that deletes "self" realm
  * Bivio::Biz::Model::UserCreateForm
    moved parse_display_name to Type.DisplayName
    added parse_to_names
  * Bivio::Biz::Model
    new_other supports qualified model names
  * Bivio::Biz::t::ExpandableListFormModel::T1ListForm
    rmpod
  * Bivio::IO::Config
    changed --TRACE= to set Bivio::IO::Trace.command_line_arg
    allow --trace=
  * Bivio::IO::Trace
    rmpod
    added command_line_arg config
  * Bivio::PetShop::Model::UserAccountForm
    parse_display_name => parse_to_names
  * Bivio::SQL::ListSupport
    added qualified names that begin with "<Qualifier>."
  * Bivio::SQL::PropertySupport
    added NonuniqueEmail
  * Bivio::SQL::Statement
    refactored to use parse_column_name and parse_model_name
  * Bivio::SQL::Support
    added qualified names that begin with "<Qualifier>."
    added parse_model_name and parse_column_name
    restrict qualifiers to lowercase
    is_qualified_model_name must accept null names
    don't die if column is equivalenced
  * Bivio::Type::DisplayName
    added parse_to_names (originally UserCreateForm.parse_display_name)
  * Bivio::Type::PrimaryId
    fmt
  * Bivio::UI::FacadeBase
    make email just plain old email
    fpc: not sure why can't say [qw(login email)]
  * Bivio::Util::TestRealm
    delete_by_regexp now accepts optional Auth.RealmType

  Revision 5.75  2008/01/15 16:25:20  moeller
  * Bvio::Biz::Model::AdmBulletinForm
    use $self->new_other instead $self->new
  * Bivio::Test::FormModel
    allow var() (or any sub) to be used as form value
  * Bivio::Test::Unit
    builtin_var checks for calls from Test.FormModel
  * Bivio::Type::USState
    added unsafe_from_zip()

  Revision 5.74  2008/01/14 21:11:41  nagler
  * Bivio::Collection::Attributes
    fix error msg
  * Bivio::PetShop::Util
    Corrected paths in db setup comments
  * Bivio::UI::View::CSS
    pre line-height needs to be 60^
  * Bivio::UI::Widget::MIMEEntityView
    handle case when control is false

  Revision 5.73  2008/01/11 03:45:43  nagler
  * Bivio::Biz::Model
    get_primary_id/name pushed up from ListModel
  * Bivio::Biz::PropertyModel
    push up get_primary_id/name
  * Bivio::PetShop::Facade::PetShop
    added ProductSelectList
    don't need SelectBaseList, use unknown_label
  * Bivio::UI::Font
    rmpod
    Added CSS options: capitalize, center, justify, left, normal,
    normal_align, normal_decoration, normal_size, normal_style,
    normal_transform, normal_weight, normal_wrap, pre, pre_line, pre_wrap, right,

  Revision 5.72  2008/01/10 22:50:34  nagler
  * Bivio::Biz::Model::RoleBaseList
    use Bivio::Base
  * Bivio::Biz::Model::UserRealmList
    use Bivio::Base
  * Bivio::Delegate::TaskId
    MY_SITE now users Action.MySite
    fixed up some comments
  * Bivio::PetShop::Delegate::TaskId
    MY_SITE now handled by MySite
  * Bivio::PetShop::Facade::PetShop
    Added my_site_redirect_map for Action.MySite
  * Bivio::UI::FacadeBase
    Added my_site_redirect_map for Action.MySite

  Revision 5.71  2008/01/10 20:47:03  nagler
  * Bivio::Biz::FormModel
    there always has to be a reset_instance_state so new can call it.  The
    old code was working around a bug in Model->new_other
    fmt
  * Bivio::Biz::ListFormModel
    delegation fixed
  * Bivio::Biz::ListModel
    delegation of do_rows and map_rows
  * Bivio::Biz::Model::RealmOwner
    added unauth_delete_realm
  * Bivio::Biz::Model::User
    subclass RealmOwnerBase
  * Bivio::Biz::Model
    new_other() doesn't call new on current instance
    fix throw_die to throw_die not die formatting message
  * Bivio::Biz::PropertyModel
    added get_primary_id and get_primary_id_name
  * Bivio::Biz::t::ListFormModel::T1ListForm
    fix execute_empty_row
  * Bivio::Delegate::RealmDAG
    added GRAPH, RECIPROCAL_RIGHTS, and LAST_RESERVED_VALUE
  * Bivio::MIME::Type
    added more MS types
  * Bivio::SQL::Support
    incorrect use (Bivio::Die)
    fmt
  * Bivio::Type::DisplayName
    moved to_camel_case String
  * Bivio::Type::EnumDelegator
    all delegates are probably not continuous
  * Bivio::Type::Hash
    use $_R
  * Bivio::Type::RealmDAG
    Type.EnumDelegator
  * Bivio::UI::HTML::Widget::Table
    Join() must not be called directly
  * Bivio::UI::XHTML::Widget::RealmCSS
    use Type.Regexp to validate the regexp

  Revision 5.70  2008/01/06 23:50:27  nagler
  * Bivio::Biz::Model::ContactForm
    version 3 configuration uses UserAuth->general_contact_mail
  * Bivio::Delegate::SimpleWidgetFactory
    if wf_list_link is string, convert it to a hash with THIS_DETAIL as query
  * Bivio::UI::Facade
    static components need to be initialized again for each child
  * Bivio::UI::FacadeBase
    GENERAL_CONTACT task_menu.title
  * Bivio::UI::HTML::Widget::Table
    in xhtml mode, use up/down arrow chars instead of images
  * Bivio::UI::View::CSS
    don't decorate logo ' ' header_left
  * Bivio::UI::View::UserAuth
    added general_contact_mail
    fix subject of general_contact
  * Bivio::UI::View::Wiki
    make wiki page wider
  * Bivio::UI::XHTML::Widget::DropDown
    look up indicator in facade
  * Bivio::UI::XHTML::Widget::FormFieldLabel
    error indicator is a string from facade now

  Revision 5.69  2007/12/30 23:10:03  nagler
  * Bivio::UI::XML::Widget::AtomFeed
    added
  * Bivio::UI::XML::Widget::DateTime
    added
  * Bivio::UI::XML::Widget::String
    added
  * Bivio::Agent::Request
    added require_absolute to FORMAT_URI_PARAMETERS
  * Bivio::BConf
    added XHTML and HTML to XMLWidget map
    Test map added
  * Bivio::Biz::Model::BlogList
    added get_rss_summary and get_modified_date_time for AtomFeed
  * Bivio::Biz::Model::SearchList
    added RESULT_EXCERPT_LENGTH
  * Bivio::Biz::QueryType
    rmpod
  * Bivio::Delegate::TaskId
    AtomFeed support
  * Bivio::HTML
    added escape_xml
  * Bivio::PetShop::Util
    added a blog entry
  * Bivio::Test::FormModel
    mock the task if the incoming task is SHELL_UTIL
  * Bivio::Test::HTMLParser::Cleaner
    rmpod
    replace &#\d+; chars with ' ', not '*'
  * Bivio::Test::Language::HTTP
    added deprecated_text_patterns() to allow tests to be migrated
    _fixup_pattern replaces '_' with '.' not ' '.
  * Bivio::Type
    rmpod
    to_xml calls Bivio::HTML->to_xml
  * Bivio::UI::FacadeBase
    added support for AtomFeed and new style of table rendering
  * Bivio::UI::HTML::Widget::EmptyTag
    base is HTMLWidget.Tag
  * Bivio::UI::HTML::Widget::Table
    rmpod
  * Bivio::UI::HTML::Widget::Tag
    HTMLWidget.Tag is the subclass
  * Bivio::UI::View::Base
    better rss support
  * Bivio::UI::View::Blog
    better rss support
  * Bivio::UI::Widget::Simple
    rmpod
    fmt
  * Bivio::UI::XHTML::Widget::WikiText
    added simple render_ascii

  Revision 5.68  2007/12/28 03:20:48  nagler
  * Bivio::Delegate::SimpleRealmName
    don't cache regex variables (/o)
  * Bivio::Test::FormModel
    don't mock the task if the request already has a task configured
  * Bivio::Test::HTMLParser::Forms
    allow single field form which is unlableld
  * Bivio::Test::Request
    added put_on_query().  Now say req()->put_on_query(this => foo) instead of
    req()->get_if_defined_else_put(query => {})
       ->{Bivio::SQL::ListQuery->to_char('this')} = foo
  * Bivio::UI::Email
    call new_static()
  * Bivio::UI::Facade
    initialize static_components before dynamic
  * Bivio::UI::HTML::ViewShortcuts
    vs_html_attrs must define the string before calling unsafe_render_attr
  * Bivio::UI::HTML::Widget::Tag
    upper case tag attributes are now sorted alphabetically
  * Bivio::UI::View::CSS
    css can't be static.  Icons might not be
    label td.footer always
    table.footer, not td.footer
    a.logo height has to be height of ico
  * Bivio::UI::View
    remove comments

  Revision 5.67  2007/12/25 22:42:09  nagler
  * Bivio::Agent::Request
    added get_current_or_die
  * Bivio::Biz::Action::ClientRedirect
    call format_uri on the uris that come in via path_info and query
  * Bivio::Biz::Model::RealmFileList
    added get_os_path
  * Bivio::UI::FacadeBase
    site_copyright is now text_as_prose
  * Bivio::UI::FacadeComponent
    added new_static
  * Bivio::UI::Task
    factored out internal_setup_facade
  * Bivio::UI::XHTML::Widget::WikiText::Embed
    renamed format_uri to internal_format_uri
  * Bivio::UI::XHTML::Widget::WikiText::Menu
    renamed format_uri to internal_format_uri
  * Bivio::UI::XHTML::Widget::WikiText
    renamed format_uri to internal_format_uri
    call internal_format_uri instead of _abs_href
  * Bivio::Util::SiteForum
    make_admin accepts $realm
    update doc
  * Bivio::Util::TestUser
    export ADM

  Revision 5.66  2007/12/21 04:47:39  nagler
  * Bivio::Biz::Model::ImageUploadForm
    remove unnecessary ImageMagick calls

  Revision 5.65  2007/12/21 04:30:23  nagler
  * Bivio::Biz::Model::RealmMail
    fix uninitialized eq value in update
  * Bivio::Biz::Model::UserPasswordQueryForm
    define query in execute_ok now that Acknowledgement handled by FormModel
  * Bivio::Test::Unit
    builtin_var() was not flexible enough to handle subclassing of Test.Unit
    Try another approach for _called_in_closure
  * Bivio::UI::ViewLanguageAUTOLOAD
    removed unnecessary code
  * Bivio::UNIVERSAL
    super_for_method

  Revision 5.64  2007/12/20 00:24:35  nagler
  * Bivio::Biz::Model::CSVImportForm
    added process_content
  * Bivio::Biz::Model::ECCreditCardPaymentForm
    added missing import
  * Bivio::Biz::Model::RealmBase
    allow override of REALM_ID_FIELD and USER_ID_FIELD
  * Bivio::Biz::Model::RealmUser
    subclasses Model.RealmBase
    is_sole_admin cleaned up a bit
    rmpod
  * Bivio::Biz::t::ListModel::T1List
    rmpod
  * Bivio::Biz::t::ListModel::T2List
    rmpod
  * Bivio::Biz::t::ListModel::T3List
    rmpod
    rollback
  * Bivio::Biz::t::ListModel::T4List
    rmpod
    rollback
  * Bivio::PetShop::Util
    added BTEST_ADMIN
  * Bivio::Test::ShellUtil
    create Test.Request
  * Bivio::Test::Unit
    new_unit added so subclasses can override easily
    run_unit overrides options() on the instance
    builtin_realm_id added
  * Bivio::Type::FileField
    added from_string_ref()
    rmpod
  * Bivio::UI::View::Error
    set status in all cases
  * Bivio::Util::POD
    perserve type info when removing POD
  * Bivio::Util::SQL
    added destroy_dbms, and restore_dbms_dump uses this (not destroy db)

  Revision 5.63  2007/12/13 23:48:10  nagler
  * Bivio::Mail::Incoming
    send deprecated
  * Bivio::Type::Geom
    don't assert srid or type
  * Bivio::Type::GeomPoint
    from_long_lat creates with a constant now
  * Bivio::Type::GeomPolygon
    added from_shape

  Revision 5.62  2007/12/13 04:54:11  nagler
  * Bivio::Biz::Action::MailForward
    Was not working, because Mail.Outgoing->new does not take content as a param
  * Bivio::Biz::Model::Tuple
    Fix more whitespace problems in parsing

  Revision 5.61  2007/12/13 04:13:47  nagler
  * Bivio::Biz::Action::MailForward
    Refactored to use Outgoing
  * Bivio::Biz::Model::Tuple
    added DEFAULT_TUPLE_MONIKER
    Fixed bug when msg bodies had no slots to update (just comment)
  * Bivio::Delegate::RowTagKey
    added DEFAULT_TUPLE_MONIKER
  * Bivio::Mail::Incoming
    rmpod
  * Bivio::Mail::Outgoing
    rmpod
  * Bivio::PetShop::Facade::PetShop
    no need for $_SELF
  * Bivio::PetShop::Util
    added CRM
  * Bivio::UI::Facade
    uri's are fixed up properly for test system

  Revision 5.60  2007/12/12 04:12:25  nagler
  * Bivio::Biz::Action::Acknowledgement
    save_label() guards against non-hash query
  * Bivio::Biz::Action::DAV
    if a server_redirect is thrown, check task_id for
    DEFAULT_ERROR_REDIRECT and transform the error to the original die
    code.
  * Bivio::Biz::Action::RealmFile
    execute_private should not pass in defined value for 'is public'
  * Bivio::Delegate::TaskId
    added DEFAULT_ERROR_REDIRECT_NOT_FOUND and
    DEFAULT_ERROR_REDIRECT_MODEL_NOT_FOUND
  * Bivio::Test::Language::HTTP
    table operations now convert to regexes if not deprecated_text_patterns.
  * Bivio::Test::PropertyModel
    create a request in new_unit
  * Bivio::Type::Hash
    added to_string
    to_string handles undef and non-refs itself to get simplified view
  * Bivio::UI::FacadeBase
    listactions for motions
    added DEFAULT_ERROR_REDIRECT_NOT_FOUND and DEFAULT_ERROR_REDIRECT_MODEL_NOT_FOUND
  * Bivio::UI::HTML::Widget::Image
    alt was broken
  * Bivio::UI::HTML::Widget::ListActions
    allow use of undefined value as label which implies to use task
  * Bivio::UI::Task
    look for DEFAULT_ERROR_REDIRECT_NOT_FOUND in tasks during init; if
    there, don't throw NOT_FOUND exception, rather return not_found task
    with URI of object not found.
  * Bivio::UI::View::Base
    return self from internal_put_base_attr
  * Bivio::UI::View::CSS
    added .not_found

  Revision 5.59  2007/12/07 06:44:57  nagler
  * Bivio::Agent::Request
    preserve() preserves items on the request after a block of code is executed
    removed preserve.  see Model::set_ephemeral
  * Bivio::Biz::Action::WikiView
    use title from WikiStyle
  * Bivio::Biz::FormModel
    Acknowledgements now put on query if execute_ok returns query in a hash
  * Bivio::Biz::ListModel
    ->set_ephemeral will block PropertyModels and ListModels instances from automatically being loaded onto the request
  * Bivio::Biz::Model::MailReceiveDispatchForm
    rpmpod
    fmt
  * Bivio::Biz::Model::RealmLogoList
    FORUM_PUBLIC_FILE not available in version 3
  * Bivio::Biz::Model::RealmRole
    don't throw exception if Role is missing from default set;  Not all
    realms get all roles
  * Bivio::Biz::Model::SearchList
    FORUM_PUBLIC_* has gone away
  * Bivio::Biz::Model::UserLoginForm
    Added internal_validate_login_value so could share code in validate_login
  * Bivio::Biz::Model
    ->set_ephemeral will block PropertyModels and ListModels instances from automatically being loaded onto the request
  * Bivio::Biz::PropertyModel
    ->set_ephemeral will block PropertyModels and ListModels instances from automatically being loaded onto the request
  * Bivio::Delegate::SimpleRealmName
    added SPECIAL_PLACEHOLDER (my) which is used by WikiText and RealmCSS
  * Bivio::Delegate::TaskId
    FORUM_CSS has gone away
  * Bivio::PetShop::Facade::PetShop
    test data
  * Bivio::PetShop::Util
    test data for Wiki and CSS
  * Bivio::Test::Language::HTTP
    _facade() does not initialize_fully if there's already a facade
    home_page_uri: don't change uri if facade_uri and default are the same
    set $ENV{USER} for email_user;  used to be $ENV{LOGNAME} first, which
    seems unnecessary
  * Bivio::Test::Unit
    model needs to use(Bivio::ShellUtil)
  * Bivio::Test::Util
    mock_sendmail sets up facade correctly
    remove debug statement
  * Bivio::Type::PrimaryId
    rmpod
    is_valid is stricter
  * Bivio::UI::FacadeBase
    FORUM_CSS has gone away
    WikiView converts title to HTML
  * Bivio::UI::FacadeComponent
    rmpod
    internal_get_self uses get_from_source
  * Bivio::UI::HTML::Widget::StyleSheet
    use Bivio::Base HTMLWidget.ControlBase
  * Bivio::UI::HTML::Widget::Table
    before_row widget is no longer renders before a table heading
  * Bivio::UI::HTML::Widget::Tag
    added bracket_value_in_comment attribute
  * Bivio::UI::View::CSS
    FORUM_CSS has gone away
  * Bivio::UI::View::ThreePartPage
    refactored internal_xhtml_adorned_body
    xhtml_style is now RealmCSS
  * Bivio::UI::View::Wiki
    body_class is gone
    topic is now title
  * Bivio::UI::ViewShortcuts
    *** empty log message ***
    fpc: Can't relax check on vs_constant to Bivio::UI::WidgetValueSource,
    must use Bivio::Agent::Request
    fpc
  * Bivio::UI::XHTML::ViewShortcuts
    added vs_tuple_use_list_as_task_menu_list
  * Bivio::UI::XHTML::Widget::WikiStyle
    RealmCSSList obviates need for embedded CSS here
  * Bivio::UI::XHTML::Widget::WikiText
    allow embedded objects
    use SPECIAL_PLACEHOLDER
  * Bivio::Util::HTTPConf
    sleep 3 seconds on restart
    fmt

  Revision 5.58  2007/11/29 23:16:43  nagler
  * Bivio::Agent::Request
    is_production now pulls from $self, if it can
  * Bivio::UI::HTML::Widget::RealmFilePage
    render TAG-ERR

  Revision 5.57  2007/11/29 17:13:20  moeller
  * Bivio::Biz::Util::RealmRole
    make_super_user: if already a super_user, just ignore
  * Bivio::Util::HTTPConf
    allow overriding Bivio::Agent::Request can_secure config

  Revision 5.56  2007/11/28 23:04:19  nagler
  * Bivio::BConf
    named DBI database "dbms" connects as postgres
    template1 DBI database is template1/postgres
  * Bivio::SQL::Connection
    do_execute & map_execute needs to check st->Active
  * Bivio::Util::SQL
    _dbms_run -> _run_other

  Revision 5.55  2007/11/28 21:15:23  nagler
  * Bivio::Agent::Request
    push_txn_resources does not insert duplicates
  * Bivio::Agent::Task
    SQL::Connection is now a transaction resource
  * Bivio::BConf
    added dbms DBI config and Agent to maps
  * Bivio::IO::Config
    added DEFAULT_NAME ('')
    get: treats undef and '' as the same
  * Bivio::SQL::Connection
    you can get_dbi_config before you can make a connection
  * Bivio::UI::HTML::Widget::PercentCell
    default column and cell class to 'amount'
  * Bivio::Util::HTTPConf
    allow overriding PerlTransHandler
  * Bivio::Util::LinuxConfig
    ifcfg: gateway needs to be digged before seen comparison
  * Bivio::Util::SQL
    added --encoding SQL_ASCII if >= 8
    init_dbms supports PostGIS
    run_command removed

  Revision 5.54  2007/11/26 00:39:04  nagler
  * Bivio::Mail::Common
    make -U conditional on what sendmail accepts
  * Bivio::PetShop::Facade::PetShop
    don't specify webmaster's host
  * Bivio::Util::LinuxConfig
    allow no gateway

  Revision 5.53  2007/11/25 18:33:21  nagler
  * Bivio::Biz::ListModel
    reverted internal_post_load_rows() logic, needs to edit 'rows' in place
  * Bivio::Delegate::SimpleTypeError
    TOO_FEW
    added TOO_SHORT
  * Bivio::Delegate::TaskId
    added cancel_task for USER_CREATE
  * Bivio::SQL::ListSupport
    fmt
  * Bivio::SQL::PropertySupport
    sql_pos_param_for_insert
  * Bivio::SQL::Support
    set in_select and sql_name if select_value is set
  * Bivio::ShellUtil
    arg_list handles types in other maps, e.g Auth.Role
    do_sh
  * Bivio::Test::FormModel
    moved file_field to TestUnit.Unit
  * Bivio::Test::Type
    from_literal_error
  * Bivio::Test::Unit
    Added builtin_file_field
  * Bivio::Type::Date
    now uses SUPER::now (not time())
    rmpod
  * Bivio::Type::SyntacticString
    defaults TYPE_ERROR
    TYPE_ERROR => SYNTAX_ERROR
    Added length() check
  * Bivio::Type::Time
    now uses SUPER::now (not time())
  * Bivio::UI::HTML::Widget::ProgressBar
    UI.ViewShortcuts
  * Bivio::Util::Backup
    dates_to_trim
    rmpod
    directories to trim
  * Bivio::Util::LinuxConfig
    move _sendmail_cf
    postgres_base added
    _replace_param allows for easier param replacements
    ignore result of chkconfig, because doesn't work on CentOS if the
    service is not already configured (very odd)
  * Bivio::Util::RealmAdmin
    join_user handles multiple roles
  * Bivio::Util::RealmMail
    commit successful mbox imports in case of die

  Revision 5.52  2007/11/08 21:41:04  aviggio
  * Bivio::Biz::Action::RealmFile
    remove potential security holes in model() calls and
    Action.RealmFile
  * Bivio::Biz::FormModel
    create_or_update_model_properties now accepts an optional hash of
    values which will override what's found in the model properties
    replaced Carp with Bivio::Die
  * Bivio::Biz::ListModel
    replaced Carp with Bivio::Die
  * Bivio::Biz::Model::CSVImportForm
    fix 5.6 bug
    added "field" decl and column_info()
    convert_columns_to_fields
    fixed convert_columns_to_fields to ignore extra fields
    record_to_model_properties
    return with internal_source_error is ok
  * Bivio::Biz::Model::RealmFile
    undo 1.55.  unauth_load is incorrect
    Rename copy_deep to unauth_copy_deep and delete_deep to
    unauth_delete_deep
    Deprecated warnings for copy_deep and delete_deep
  * Bivio::Biz::Model::RealmFileDAVList
    dav_put uses with_realm to resolve auth issue in RealmFile
    versioning
    Change copy_deep and delete_deep to unauth calls
  * Bivio::Biz::Model::t::CSVImportForm::T1Form
    added "field" decl and column_info()
    convert_columns_to_fields
    record_to_model_properties
  * Bivio::Biz::PropertyModel
    remove potential security holes in model() calls and
    Action.RealmFile
    replaced Carp with Bivio::Die
  * Bivio::Delegate::SimpleTaskId
    execute_private
  * Bivio::Delegate::TaskId
    remove potential security holes in model() calls and
    Action.RealmFile
  * Bivio::Ext::NetFTP
    improve error messages
  * Bivio::PetShop::Delegate::TaskId
    execute_private
  * Bivio::PetShop::Util
    Dedicated users for Xapian tests
  * Bivio::ShellUtil
    remove potential security holes in model() calls and
    Action.RealmFile
  * Bivio::Test::ListModel
    ListModel() unit tests now apply result declarations to load_this
    and unauth_load_this (this is in addition to previous support for
    load and unauth_load and find_row_by)
  * Bivio::Test::Unit
    remove potential security holes in model() calls and
    Action.RealmFile
  * Bivio::Type::Hash
    extract_by_keys
  * Bivio::UI::FormError
    remove potential security holes in model() calls and
    Action.RealmFile
  * Bivio::UI::HTML::Widget::FormField
    fixed label lookup to die if not found
  * Bivio::UNIVERSAL
    map_together is a proto
  * Bivio::Util::RealmAdmin
    remove potential security holes in model() calls and
    Action.RealmFile
  * Bivio::Util::RealmFile
    Change delete_deep to unauth call
  * Bivio::Util::SQL
    --owner, not --username

  Revision 5.51  2007/11/07 01:01:06  aviggio
  * Bivio::BConf
    added SQL map
  * Bivio::Biz::Model::CSVImportForm
    new API to match models better
  * Bivio::Biz::Model::CalendarEventDAVList
    UTF-8 encode non-datetime values in generated VEVENT
    dav_reply_get replaces EOL characters to address blank lines in .ics
  * Bivio::SQL::PropertySupport
    add error message for when the "table_name" key is misspelled
  * Bivio::Test::FormModel
    add detail to the field_err
  * Bivio::Test::Language::HTTP
    send_mail: wasn't setting headers

  Revision 5.50  2007/11/03 05:40:55  aviggio
  * Bivio::BConf
    added Auth map
  * Bivio::Biz::Action::CalendarEventListRSS removed, not in use
  * Bivio::Biz::Action::RealmlessRedirect
    internal_choose_realm => _choose_realm, b/c not in use right now
  * Bivio::Biz::FormModel
    form_error_task
    don't rollback if form_error_task
    form_error_task: put self durably and method server_redirect
    form_error_task does rollback
    test get_visible_non_button_names
  * Bivio::Biz::ListModel
    rows can now be sorted manually
    revert changes to support manual sorting
  * Bivio::Biz::Model::MotionVote
    Add comment column
  * Bivio::Biz::Model::MotionVoteForm
    Add comment field
  * Bivio::Biz::Model::MotionVoteList
    Add comment field
  * Bivio::Biz::Model::RowTag
    get_value added
    create does not create if value is undef
  * Bivio::Delegate::RowTagKey
    remove []
  * Bivio::IO::ClassLoader
    use _catch because Bivio::Die might not be loaded
  * Bivio::SQL::Connection::Postgres
    tweak SQL fix-up to handle inserting LEFT JOIN on a table that is already in a LEFT JOIN
  * Bivio::SQL::ListSupport
    allow non-db fields in order by
    revert changes to support manual sorting
  * Bivio::Test::FormModel
    get class from args, if there
    actual_return put on request
  * Bivio::Test::Language::HTTP
    added headers & body to send_mail
  * Bivio::Test::Request
    setup_facade accepts argument
  * Bivio::UI::FacadeBase
    Add comment label
    support ForumDropDown
  * Bivio::UI::View::Blog
    attributes are uppercase like HTML.Tag
  * Bivio::UI::View::CSS
    added .pager .page_link padding
    support ForumDropDown
  * Bivio::UI::View::Motion
    Add vote comment
  * Bivio::UI::XHTML::Widget::DropDown
    Support a drop down widget
  * Bivio::UI::XHTML::Widget::ForumDropDown
    Support forum selection
  * Bivio::UI::XHTML::Widget::Pager
    refactored, replaced __PACKAGE__ names with $self
    replaced $fields with '_' attributes
    removed vs_blank_cell() with css class name 'page_link'
  * Bivio::UI::XHTML::Widget::XLink
    fix Bivio::Base
  * Bivio::UI::XML::Widget::JoinTagField
    renders fields as TagFields
  * Bivio::UI::XML::Widget::Tag
    handle undef value for unsafe_render_attr
    attributes are uppercase like HTML.Tag
  * Bivio::Util::SQL
    Added internal_upgrade_db_motion_vote_comment

  Revision 5.49  2007/10/27 01:20:00  david
  * Bivio::Biz::ListModel->internal_load refactored calls to
    internal_post_load_row to support manual sorting
  * Bivio::IO::ClassLoader->unsafe_map_require replaced use of
    Bivio::Die->catch with _catch
  * Bivio::SQL::Connection::Postgres tweak SQL fix-up to handle inserting LEFT
    JOIN on a table that is already in a LEFT JOIN
  * Bivio::Test::Language::HTTP->send_mail added headers & body
  * Bivio::UI::View::CSS added .pager .page_link padding
  * Bivio::UI::XHTML::Widget::Pager
      refactored, replaced __PACKAGE__ names with $self
      replaced $fields with '_' attributes
      removed vs_blank_cell() with css class name 'page_link'
  * added Bivio::UI::XML::Widget::JoinTagField
  * Bivio::UI::XML::Widget::Tag handle undef value for unsafe_render_attr

  Revision 5.48  2007/10/25 21:54:36  nagler
  * Widget.With resets cursor on list

  Revision 5.47  2007/10/25 19:21:50  nagler
  * Bivio::Test::Unit->from_type added
  * Bivio::Test::Enum supports NAME => 3 syntax; also refactored compile()

  Revision 5.46  2007/10/25 05:36:32  aviggio
  * Bivio/Biz/Model/RealmFile _delete_args calls unauth_load

  Revision 5.45  2007/10/24 23:43:10  aviggio
  * Bivio::BConf added Mail map; XML and UI maps
  * Bivio::Biz::FormModel get_error_details added; form error alerts
    includes details
  * Bivio::Biz::ListFormModel->internal_put_error_and_detail replaces
    internal_put_error
  * Bivio::Biz::Model::RealmFile semicolon moved from end of versioned
    file names to preceding file suffix
  * Bivio::Collection::Attributes->get_shallow_copy accepts key_re
  * Bivio::Delegate::SimpleLocation identify 3 standard locations
  * Bivio::Delegate::TaskId recent_rss => recent_xml
  * Bivio::Test::Unit->builtin_self added
  * Bivio::Test::Widget AUTOLOAD supported
  * Bivio::Type::FilePath rename versions folder
  * Bivio::Type::Number round and trunc default decimals
  * Bivio::Type::Time from_literal support 1210 as 12:10:00
  * Bivio::UI::FacadeBase defines prose.rsspage
  * Bivio::UI::HTML::Widget::Field added
  * Bivio::UI::HTML::Widget::FormField deprecate _\d+ stripping in label
    lookup
  * Bivio::UI::Text unsafe_get_value returns tag that matched
  * Bivio::UI::Widget->unsafe_resolve_attr added
  * Bivio::UI::View::Base xml() uses XMLwidget
  * Bivio::UI::View::Blog use recent_xml
  * Bivio::UI::Widget::Field added
  * Bivio::UI::Widget::With added
  * Bivio::UI::Widget::WithModel subclass With
  * Bivio::UI::XHTML::Widget::RSSPage replaced by XMLWidget
  * Bivio::UI::XML::Widget::CDATA added
  * Bivio::UI::XML::Widget::Field added
  * Bivio::UI::XML::Widget::Page added
  * Bivio::UI::XML::Widget::Tag added
  * Bivio::UI::XML::Widget::TagField added
  * Bivio::UI::XML::Widget::XML added

  Revision 5.44  2007/10/18 23:17:52  aviggio
  * Bivio::BConf sets Bivio::IO::Config.version
  * Bivio::Biz::Action::RealmFile added access_is_public_only
  * Bivio::Biz::Model::BlogList use access_is_public_only
  * Bivio::Biz::Model::ConfirmableForm support for comfirmable forms
  * Bivio::Biz::Model::ECCreditCardPaymentForm->process_payment now takes
    the payment info as a hash
  * Bivio::Biz::Model::RealmFile adds file-level versioning so that file
    operations are not destructive, with the exception of delete_all
  * Bivio::Biz::Model::RowTag supports metadata tagging
  * Bivio::Delegate::SimpleTaskId drop WebDAV and calendar tasks
  * Bivio::Delegate::TaskId breaks out info_calendar tasks and add new
    DAV_FORUM_DELETED_FILE task, and uses if_version to control
    blog/wiki/file access
  * Bivio::IO::Config->if_version added
  * Bivio::IO::Log use if_version()
  * Bivio::Delegate::RowTagKey defines standard keys
  * Bivio::SQL::Support support Model.Foo syntax for type init
  * Bivio::SQL::PropertySupport fixed delete_all so no value query works
  * Bivio::Test::FormModel subclass TestUnit.Unit to allow for overrides
    by apps
  * Bivio::Test::Inline subclass TestUnit.Unit
  * Bivio::Test::ListModel subclass TestUnit.Unit
  * Bivio::Test::PropertyModel subclass TestUnit.Unit
  * Bivio::Test::Request subclass TestUnit.Unit, added delete_class and
    delete_class_from_self
  * Bivio::Test::ShellUtil subclass TestUnit.Unit
  * Bivio::Test::Type subclass TestUnit.Unit
  * Bivio::Test::Unit subclass TestUnit.Unit, add inline_trace_on/off
  * Bivio::Test::Util subclass TestUnit.Unit, ignore junk and CVS dirs
  * Bivio::Test::Widget subclass TestUnit.Unit
  * Bivio::Test::HTMLParser::Forms process left-over input after a select
    widget
  * Bivio::Type default to_sql_value to '?'
  * Bivio::Type::DateTime->set_test_now added
  * Bivio::Type::DisplayName->to_camel_case added
  * Bivio::Type::Enum->get_non_zero_list added
  * Bivio::Type::FilePath->VERSIONS_FOLDER added
  * Bivio::Type::Hash useful for storing hashes in the database
  * Bivio::Type::RowTagKey base enum delegator
  * Bivio::Type::RowTagValue base text type to delegate
  * Bivio::UI::FacadeBase use if_version(), break out info_calendar tasks
  * Bivio::UI::HTML::Widget::AmountCell use if_version(), moved config from
    BConf, sets cell_class => amount_cell
  * Bivio::UI::HTML::Widget::FormField use the form_field_label_widget from
    edit_attributes if present
  * Bivio::UI::HTML::Widget::Grid allow row_control to be widget
  * Bivio::UI::View::Blog if_version(3): no longer have PUBLIC_ task
    management
  * Bivio::UI::XHTML::Widget::HelpWiki javascript work-around for IE
    rendering problem if help iframe isn't fully loaded
  * Bivio::Util::SQL row_tag database upgrade added

  Revision 5.43  2007/10/11 23:05:09  aviggio
  * Bivio::Biz::ListModel want_page_count can now be set using the list
    model's config
  * Bivio::SQL::ListSupport support ListModel change
  * Bivio::UI::XHTML::Widget::Pager guard against undefined page_count
  * Bivio::UI::XHTML::Widget::WikiText put spaces in place of underscore
    in wiki words

  Revision 5.42  2007/10/04 15:05:33  moeller
  * Bivio::Biz::Model::RealmDAG added realm_dag_type to primary key
  * Bivio::IO::Log use file_root in dev (probably typo)
  * Bivio::Util::ShellUtil arg_list: when decl is not a ref, need to
    make an array_ref or repeating args didn't work
  * Bivio::Test calls rollback if method, comparitor, etc. dies
  * Bivio::UI:FacadeBase use shift->get_facade in sub {} to get facade
    values
  * Bivio::UI::HTML::Format::Printf render undef as ''
  * Bivio::UI::Text::Widget::CSV refactored to allow column_heading and
    column_widget to be widgets
  * Bivio::UI::Text Evaluates sub {} values
  * Bivio::UI::XHTML::ViewShortcuts vs_paged_list() now uses the Pager
    widget

  Revision 5.41  2007/09/26 23:27:07  moeller
  * Bivio::Biz::Action::ECCreditCardProcessor changed missing gateway
    message from die() to warn()
  * Bivio::Biz::Model::ECCreditCardPaymentForm new module
  * Bivio::Biz::Model::UserLoginForm fix _set_log_user to do best
    efforts at showing user
  * Bivio::UI::FacadeBase Change 'Developed by bivio' to 'Software by
    bivio'
  * Bivio::UI::XHTML::Widget::Page3 Reuse xhtml_copyright

  Revision 5.40  2007/09/25 17:47:30  nagler
  * Bivio::Util::HTTPConf no longer creates log_directory
  * Bivio::BConf.version=2: Bivio::IO::Log directory is /var/log/bop &
    default_merge_overrides returns a hash_ref

  Revision 5.39  2007/09/25 02:48:59  nagler
  * Bivio::Agent::Request->assert_test added
  * Bivio::Agent::Request->assert_http_method fixed

  Revision 5.38  2007/09/24 18:39:26  nagler
  * Ext.NetFTP added.  Wraps active/passive correctly.  Also wraps get
    into a single call.

  Revision 5.37  2007/09/24 14:19:47  nagler
  * ShellUtil.CSV->parse_records supports want_line_numbers correctly.
    Also added from_one_col, from_one_row, and from_rows which deprecate
    to_csv_text
  * Bivio::Biz::PropertyModel->unauth_create_or_update calls
    internal_unique_load_values if primary keys are not available.  See
    Model.RealmFile as an example.
  * Type.Boolean->from_literal understands t, true, y, yes, off, etc.
  * Type.FileField->unsafe_from_disk added
  * Type.FileArg added
  * Action.RealmFile->access_controlled_load accepts $not_die.  Dies if
    !$not_die with FORBIDDEN or MODEL_NOT_FOUND appropriately.
  * HTMLWidget.YesNo supports XHTML
  * Bivio::UI::Facade->get_from_source added
  * Bivio::UI::FacadeBase constants *_realm_id and *_name fixed to call
    facade instance, not static call.
  * Bivio::IO::Log->write/read accepts $req, which allows it to prefix
    directory with facade.  Old form will be deprecated.
  * Bivio::IO::Log->write_compressed added (use instead of appending .gz)
  * Bivio::Agent::Request->assert/is_http_method added
  * b-perl.el better supports class variables.  Enter Type.FilePath and
    it will generate: my($_FP) = __PACKAGE__->use('Type.FilePath');

  Revision 5.36  2007/09/20 00:57:13  nagler
  * Wiki syntax changes:
      + End a line with @, and the newline is eliminated
      + Use ^ form in href= or src= will render the link properly, e.g.
        @a href=^bivio.biz bivio => <a href="http://www.bivio.biz>bivio</a>
        If you don't want www insertion (only if second level domain), just
        don't prefix with ^
      + @a href=bla.com ^foo.jpg: does the right thing
  * Bivio::BConf->default_merge_overrides accepts a hash with a version to
    enable simpler backwards compatibility.  First version (no version) is 0.
  * HTMLWidget.AmountCell is configurable and BConf.version=1 sets to "normal"
    mode (no parens, not padding, etc.).
  * XHTMLWidget.WikiText replaces Type.WikiText.  Custom tags are registered
    dynamically in the WikiText class map. WikiText.Embed implements
    @ins-page (use @b-embed for the future).  App tags should be begin with
    app prefix, e.g. @b-embed begins Bivio:: app tags.
  * WikiText.Menu (@b-menu) implements Wiki menus.  @b-menu Foo will load
    Foo.bmenu which is a csv with at least on column (Label) but may contain
    another column (Link) to direct the menu to.
  * WikiText.Widget (@b-widget) allows wikis to render arbitrary view
    attributes.  Attributes must begin with wiki_widget_ and be lower case.
  * XHTMLWidget.Wiki added
  * Action.WikiView/XHTMLWidget.WikiStyle&Wiki cooperate with rendering so
    that wiki html is rendered within a view (allowing @b-widget)
  * View.Wiki->help replaces View.Help
  * Action.ClientRedirect->execute_query_or_path_info replaces execute_path_info.
  * Action.RealmFile->access_controlled_execute/load wrap the concept of
    loading a file from public or private areas of a realm
  * Action.WikiView->execute_help & execute_prepare_html added
  * Model.RealmOwner deletes OTP record if password not OTP compatible
  * ShellUtil.ListModel->csv does not try to render fields not in_select
  * Bivio::Collection::Attributes->get_or_default deprecates assigning
    a sub {} as the default.  Eventually will behave like put_unless_exists
  * Bivio::Delegate::TaskId:
      + PUBLIC_PING added, which is an Action.EmptyReply
      + CLIENT_REDIRECT calls execute_query_or_path_info
      + HELP replaces FORUM_HELP_IFRAME
  * Various PetShop tests added
  * Test.Widget improved to support Text.WikiText
  * Type.DateTime protects  $_TEST_NOW better
  * Type.FilePath->BLOG_FOLDER, *absolute, etc. pulled up from subclasses
  * Type.EnumSet->compare_defined defined (greatest number of bits is greater)
  * Type.WikiName->task_to_help and to_title added
  * ShellUtil.SiteForum->*NAME gets from Facade
  * Bivio::UI::FacadeBase text and task clean ups
  * HTMLWidget.Page.body_class added
  * View.CSS cleaned up extensively
  * View.ThreePartPage supports body_class.
  * XHTMLWidget.WikiStyle calls facade to get name of css (base.css default, but
    would like to move to wiki.css).  Parses css for elements which look like:
    ^<regexp> where <regexp> is a perl regexp that matches or doesn't match
    the wiki page.  This allows control of all elements on the page in which a
    wiki is displayed.
  * Bivio::UI::ViewLanguage->unsafe_get_eval added for Test.Widget.  Use
    for testing only.
  * XHTMLWidget.HelpWiki refactored and supports all labels from facade.
  * XHTMLWidget.WikiStyle->help_exists and render_help_html added
  * ShellUtil.RealmFile->export_tree added
  * ShellUtil.RealmFile->import_tree fixed to update existing files
  * ShellUtil.SQL->restore_dbms_dump added

  Revision 5.35  2007/09/10 23:17:37  nagler
  * Bivio::Biz::Model::UserOTPForm verifies passphrase used in OTP client is
    not null
  * Bivio::Biz::Action::WikiView.title added which is name with underscores
    replaced with space.  wiki_view_topic uses Action.WikiView.title.
  * Bivio::Biz::Model::UserPasswordForm refactored to simplify UserOTPForm
  * Bivio::UI::HTML::Widget::Table.before_row added
  * Bivio::UI::Widget::Unique added
  * Bivio::Test::Unit->builtin_date_time added
  * Bivio::Test::Language::HTTP.submit_form fixed to support _anon & _radio
  * Bivio::Util::RealmAdmin->reset_password deletes OTP record if it exists

  Revision 5.34  2007/09/04 03:47:05  nagler
  * Bivio::Test::Language::HTTP->follow_link can chase multiple links.
    Also, if you set deprecated_text_patterns to 0, follow_link will
    convert links to patterns, like submit_form does.
  * Bivio::Agent::Request->with_* supports wantarray returns correctly.
    Method will die if wantarray is false and there are multiple return
    values like get()
  * Various OTP fixes.
  * Bivio::Biz::Model::UserPasswordQueryForm refactored
  * Bivio::Util::SiteForum->make_admin added (called by TestUser and
    PetShop::Util)

  Revision 5.33  2007/09/03 07:56:45  aviggio
  * Bivio::Biz::Model::OTP->should_reinit added
  * Bivio::Biz::Model::UserLoginForm supports OTP sequence reinitialization
  * Bivio::Biz::Model::UserOTPForm allow hex password as input
  * Bivio::Biz::Model::UserPasswordQueryForm OTP users cannot reset their
    password
  * Bivio::Delegate::SimpleTypeError PASSWORD_QUERY_OTP added
  * Bivio::UI::FacadeBase support OTP sequence reinitialization
  * Bivio::Util::OTP add facade elements for OTP sequence reinitialization

  Revision 5.32  2007/09/03 05:35:36  nagler
  * Various OTP fixes

  Revision 5.31  2007/09/03 04:00:26  nagler
  * Bivio::Agent::HTTP::Request->format_http_toggling_secure accepts a host
  * Bivio::Biz::Model::MailReceiveDispatchForm puts via_mta on UserLoginForm
  * Bivio::Biz::Model::UserLoginForm acceps via_mta
  * Bivio::Biz::Model::UserOTPForm can re-initialize an OTP sequence
  * Bivio::UI::XHTML::Widget::HelpWiki.postion_over_link added
  * Bivio::Util::HTTPConf.ssl_only added

  Revision 5.30  2007/09/02 22:31:22  nagler
  * Bivio::Util::SQL->internal_upgrade_db_bundle has sentinel mechanism
    for feature tests if tables are too coarsed grained.
  * Fixed a bunch of broken unit tests

  Revision 5.29  2007/09/02 18:24:21  nagler
  * RFC2289 One-time passwords supported.  Use winkey32.exe or Opie
    (*nix) for client or use b-otp (which only works with bOP OTP
    seeds and sequences -- used only for testing).  Various classes
    added including UserOTP.pm.
  * Apply "b-sql upgrade_db bundle" to get all the latest stuff.
    Bivio::Util::SQL->upgrade_db supports typed versions, and
    "bundle" is a special type that only applies upgrades based on
    features (table or row existence tests).
  * Bivio::Biz::Model::Forum->require_otp added
  * Bivio::Biz::Model::Forum->is_leaf added
  * Bivio::Biz::Model::ForumDeleteForm->execute_ok cascades into Forum
    and RealmOwner
  * Bivio::Biz::Model::ForumForm->is_create added (supports OTP)
  * Bivio::Biz::Model::ForumUserAddForm only lets OTP users join
    require_otp forums
  * Bivio::Biz::Model::RealmOwner->require_otp added
  * Fixed up various modules to get types with get_field_type instead
    of hardwired
  * Bivio::Biz::Model::UserLoginForm supports OTP
  * Bivio::Delegate::TaskId has tasks that were in SimpleTaskId except
    for info_base, which is used for deprecated apps.
  * Bivio::Delegate::SimpleTaskId->standard_components deprecates all_components
  * Bivio::IO::Alert->print_literally prints undefined values as <undef>
  * PetShop supports OTP, go to the accounts page
  * Bivio::SQL::Connection->map_execute added
  * Various HelpWiki fixes
  * Bivio::UNIVERSAL->max_number and map_together added
  * Bivio::Biz::Action::BasicAuthorization security exploit fixed.
    Module refactored to use UserLoginForm more intensely for OTP
    and to share code which was correct in UserLoginForm, but not in
    BasicAuthorization.

  Revision 5.28  2007/08/31 19:20:58  moeller
  * Bivio::Agent::Request call "can" on is_secure when printing warning
  * Bivio::IO::File added map_lines
  * Bivio::Test::Language::HTTP added password param to login_as
  * Bivio::UI::FacadeBase OTP in bOP
  * Bivio::UI::HTML::Widget::Grid fixed hide_empty_cells

  Revision 5.27  2007/08/31 01:44:52  moeller
  * Bivio::Base new format use Bivio::Base 'Map';
  * Bivio::Biz::PropertyModel fixed bad assumption in
    unauth_create_or_update_keys
  * Bivio::Delegate::TaskId added FORUM_HELP_IFRAME
  * Bivio::Die defined $cfg->{stack_trace_separator}
  * Bivio::IO::ClassLoader after_in_map
  * Bivio::SQL::PropertySupport potential code for better use of meta
    data when loading related models
  * Bivio::Type::Secret encapsulate Crypt->new, because we will need to
    deal with this at some point.  Tried Crypt::CBC-2.14 and 2.22,
    neither works with Secret.bunit
  * Bivio::UI::FacadeBase added FORUM_HELP_IFRAM
  * Bivio::UI::HTML::Widget::Link is_blessed
  * Bivio::UI::View::CSS fixed text align for IE, help now uses an
    ilayer
  * Bivio::UI::ViewLanguage use is_blessed
  * Bivio::UI::Widget is_blessed
  * Bivio::UI::WidgetValueSource encapsulate _can_recurse
  * Bivio::UI::XHTML::Widget::HelpWiki now uses an ilayer to display
    help box
  * Bivio::Util::Class added info()
  * Bivio::Util::SiteForum addd HELP_REALM

  Revision 5.26  2007/08/27 01:57:41  moeller
  * Bivio::UI::XHTML::Widget::HelpWiki now renders as a link which shows help in a popup

  Revision 5.25  2007/08/26 05:38:32  aviggio
  * Bivio/SQL/Statement allow [{}, ...] in declaration

  Revision 5.24  2007/08/23 19:39:12  moeller
  * Bivio::UI::FacadeBase added help_wiki_background color
  * Bivio::UI::View::CSS added help wiki definitions, work-around IE bug
  * Bivio::UI::XHTML::Widget::HelpWiki added 'id' attribute

  Revision 5.23  2007/08/22 17:30:55  nagler
  * Bivio::Agent::Task->execute_items API change.  items which return a
    hash must set query.  Defaulting query in this case is deprecated,
    use query => $req->get('query'), if you must, but your probably
    don't want this.  server_redirect.<task> is deprecated.  Use
    {method => 'server_redirect', task_id => <task>}
  * Bivio::IO::ClassLoader map init issues a warning (used to die) when
    map directory is empty.
  * Bivio::UNIVERSAL->call_super_before added
  * Bivio::UI::View destroys views properly now.  This was a complicated
    failure that looked like the parent was going away.

  Revision 5.22  2007/08/16 03:40:00  moeller
  * Bivio::UI::HTML::Widget::ListActions no longer renders in target realm,
    instead passes target realm to format_uri()

  Revision 5.21  2007/08/14 17:02:45  moeller
  * Bivio::Biz::Model::RealmFile Add _assert_loaded, call from update
    and is_empty
  * Bivio::UI::HTML::Widget::ListActions if realm is supplied, the links
    will be evaluated within that realm

  Revision 5.20  2007/08/13 21:50:18  nagler
  * Bivio::Agent::Request->redirect added
  * Bivio::Biz::Action::RealmMail->internal_subject_prefix added
  * Bivio::Biz::Model::RealmBase->create sets creation_date_time and
    modified_date_time to exactly same value
  * Bivio::Biz::Model->as_string renders values with Type->to_string
  * Bivio::IO::Alert->warn_deprecated formats arguments like info(), etc.
  * Bivio::IO::File->do_lines handles $! properly now
  * Bivio::UNIVERSAL->is_blessed asks if is_blessed of $proto if no
    second argument.  Call Bivio::UNIVERSAL->is_blessed statically if
    you just want to know if object is blessed, but don't care what class.
  * Bivio::Util::HTTPD.additiona_directives/locations added
  * Bivio::Util::IIF handles quotes
  * Bivio::Util::SQL->init_dbms takes database to clone as argument

  Revision 5.19  2007/08/06 19:03:58  nagler
  * Bivio::UI::HTML::Widet::RealmFilePage does not modify cid: references
  * Bivio::UI::Widget::MIMEEntityRealmFile.mime_disposition/id added
  * Bivio::Test::HTMLParser::Forms->unsafe_get_by_field_names added
  * bivio::IO::Ref now calls code_refs properly
  * b-hours-add.el added

  Revision 5.18  2007/08/03 15:40:37  moeller
  * Bivio::Agent::HTTP::Form new implementation on local parsing
  * Bivio::Agent::HTTP::Request fixed trace and such of get_content
  * Bivio::Agent::Request get_content returns unsafe_get('content') for
    easy tesing
  * Bivio::HTML added parse_www_form_urlencoded
  * Bivio::Test::Bean added ability for signatures
  * Bivio::UI::FacadeBase fixed TEST_BACKDOOR uri
  * Bivio::UI::XHTML::ViewShortcuts fixed _has_submit() when checking
    blessed references
  * Bivio::Util::HTTPD no longer need explicit facade VirtualHost
    sections
  * Bivio::Util::SQL rename postgres_db_and_user to init_dbms

  Revision 5.17  2007/07/30 15:27:39  nagler
  * Bivio::Biz::Model->assert_not_singleton returns $self
  * Bivio::Biz::Model->internal_get_sql_support_no_assert added
  * Bivio::Biz::PropertyModel.cacade_delete_children added so children
    will call cascade_delete
  * Bivio::Biz::PropertyModel->cacade_delete takes query arg iwc it call
    delete_all with $query
  * Bivio::Collection::Attributes->*get_by_regexp returns key it found
    as second return value if in array context
  * Bivio::Delegate::SimpleTypeError->UNSUPPORTED_TYPE added.  Use this for
    values which can't be converted.  For example, CREDITCARD_UNSUPPORTED_TYPE
    could be deprecated with this value, and use FormError to render the error.
  * Bivio::Test::Widget.check_return supported
  * Bivio::SQL::ListQuery->as_string added
  * Bivio::UI::View::Base->xml added -- uses XHTML widgets for now
  * Bivio::SQL::PropertySupport.children format changed to array_ref of
    array_refs in proper (reverse) order.
  * Bivio::Util::SQL->postgres_db_and_user added
  * Bivio::Type::Integer->is_odd added

  Revision 5.16  2007/07/27 01:15:48  aviggio
  * Bivio::Agent::Request call Bivio::UI::Task always when formatting uris
  * Bivio::BConf allow subclasses to override values in RealmRole
    category_map
  * Bivio::Biz::Model::ForumTreeList extract method to support override of
    default where clause by subclasses
  * Bivio::Biz::Model map_iterate with a single string argument will get
    an array of that argument
  * Bivio::SQL::Connection print a warning if a query takes longer than
    30s
  * Bivio::Test::Language::HTTP made suffix be .eml, not .msg
  * Bivio::Type::WikiText call Bivio::UI::Task to allow uris to be cleaned
    up, always call Bivio::UI::Text if not calling req->format_uir
  * Bivio::UI::Task is now completely overridable by apps, format_uri
    accepts {uri => } and returns it unchanged, but subclasses could
    change it
  * Bivio::UI::Task if site_root_realm is configured in the facade, then
    search the corresponding realm file before checking for realms
  * Bivio::Util::HTTPD no longer need explicit facade VirtualHost sections

  Revision 5.15  2007/07/14 17:53:25  nagler
  * Bivio::Collection::Attributes->get_if_defined_else_put/put_unless_defined added
  * Bivio::UI::FacadeBase->new checks if clone is true, iwc it does not
    merge default config.  Cloned facades already have default config.
  * Bivio::Biz::Model::RealmUserAddForm->internal_user/realm_id factored
    out of execute_ok
  * Bivio::ShellUtil->new_other can be called from a static ShellUtil

  Revision 5.14  2007/07/10 03:01:30  nagler
  * Bivio::UI::Widget::MIMEEntityView added
  * Bivio::UI::Widget::MIMEEntity will not attach empty children
  * Bivio::UI::HTML::Widget::RealmFilePage sets output type based on
    RealmFile suffix.  <head> only fixed up if internal_render_head_attrs
    is non-empty.

  Revision 5.13  2007/07/09 04:11:39  nagler
  * Bivio::Agent::Request->with_realm_and_user deleted

  Revision 5.12  2007/07/09 02:48:30  nagler
  * Bivio::Type::StringArray->from_literal now always returns an instance,
    even if the initial value is undef.  This enables null object
    comparisons.  The Tuple code was fixed to support this change.
  * Bivio::Agent::Request->with_realm_and_user added
  * Bivio::UI::Widget->obsolete_attr added
  * Bivio::UI::Widget::MIMEEntity->header_as_string removed.
    mail_headers and mime_entity added.  Now supports nested
    MIME::Entities properly.
  * Bivio::UI::Widget::Join subclass of ControlBase
  * Widget is now a default class map
  * Bivio::UI::Mail::Widget::Message.want_aol_munge is obsolete.  Module
    significantly refactored.
  * Bivio::UI::Widget::After prints value "after" only if main value is
    non-null.
  * Bivio::UI::HTML::Widget::FormField uses Widget.After to print :
  * Bivio::Agent::Task->handle_*_task are now just like regular task
    items.  All behavior is encapsulated by execute_items including
    throwing FORBIDDEN exceptions.  As such, these handlers may return
    "next" actions and control the execution flow of the task in
    addition to throwing exceptions.  handle_*_task have an API change
    that passes the task they are executing.
  * Bivio::Test::Language::HTTP->save_excursion added

  Revision 5.11  2007/06/27 23:41:49  david
  * Bivio::Agent::Embed::Request now accepts data to be put on a newly
    created request
  * Bivio::Agent::HTTP::Form accepts a uri in the query if the method is
    post
  * Bivio::Agent::Request added form_in_query
  * Bivio::Biz::FormModel added get_literals_copy
  * Bivio::Biz::Model::RealmMailBounce wasn't calling
    unauth_create_or_update so it is likely there were wrong user ids on
    bounces
  * Bivio::Type::DateTime->to_dd_mmm_yyyy now accepts a separator
  * Bivio::Type::StringArray was cleaned up
  * Bivio::UI::FormError added support for error_details
  * Bivio::UI::Widget::URI now allows format_method to be passed in
    params
  * Bivio::UI::WidgetValueSource deprecates using array with index
  * Bivio::Util::HTTPConf fixed problem where https wasn't redirecting
    to the odd port after the refactoring to $hc

  Revision 5.10  2007/06/25 17:36:11  moeller
  * Added RealmDAG model for Realm/Realm relationships
  * Bivio::UNIVERSAL added req()
  * Bivio::Util::HTTPConf added aliases, no_proxy, ssl_crt and ssl_chain
  * Bivio::Util::RealmMail Handle errors in mbox import
  * Bivio::Util::SQL added internal_upgrade_db_realm_dag()

  Revision 5.9  2007/06/18 22:23:35  nagler
  * Bivio::UI::HTML::Widget::StyleSheet now generates XHTML <link>
  * Bivio::UI::WidgetValueSource->get_widget_value deprecated arrays
    returned from widget values that are *not* to be evaluated as
    widget values.
  * Bivio::Util::HTTPConf->generate abstracts virtual_hosts which make
    configuration much simpler.  SSL still not directly supported.
  * Bivio::Util::LinuxConfig->split_file added

  Revision 5.8  2007/06/17 20:07:50  nagler
  * Bivio::Biz::FormModel->create_model_properties added
  * Bivio::UI::HTML::Widget::RealmFilePage added.
  * Bivio::UI::HTML::Widget::Page refactored to support RealmFilePage
  * Bivio::UI::View::ThreePartPage refactored to support RealmFilePage
  * Bivio::Util::RealmFile->delete_deep replaces delete (which
    conflicted with Collection::Attributes->delete and also didn't work.
  * Bivio::UNIVERSAL->clone added -- ListQuery, Request, Attributes,
    Model, Enum, Realm, etc. fixed to use clone() or to simple return self.
  * Bivio::IO::Ref->nested_copy added
  * Bivio::Biz::ListModel->unauth_iterate_start now works with order_by
  * Bivio::SQL::ListQuery->unauth_new takes same paramater order as ->new
  * Bivio::Delegate::SimpleWidgetFactory uses
    Bivio::UI::DateTimeMode->get_date_default instead of hardwiring 'DATE'

  Revision 5.7  2007/06/12 21:19:53  nagler
  * Bivio::Biz::Model::RealmFileList supports realm_file_id query key.
    RealmFileDAVList also changed to support realm_file_id.
  * Bivio::Biz::Model::PublicRealmFileDAVList added
  * Bivio::Biz::Model::PublicRealmDAVList added
  * Bivio::Biz::Model::RealmDAVList factored out of UserRealmDAVList
  * Bivio::Test::ListModel support DAVList testing
  * Bivio::Type::FilePath->from_public added

  Revision 5.6  2007/06/11 17:40:02  moeller
  * Bivio::Biz::Model::RealmFile is_empty() iterates, doesn't load list
  * Bivio::Biz::Model remove duplication from new_other
  * Bivio::Delegate::SimpleTypeError fix DATE_TIME error
  * Bivio::Test::Language added test_user
  * Bivio::Test == must be eq in _prepare_case
  * Bivio::Type::StringArray factored out separators and regexps so can
    override
  * Bivio::TYpe::SyntacticString added internal_post_from_literal and
    internal_pre_from_literal
  * Bivio::UI::FacadeBase title to USER_CREATE_DONE
  * Bivio::UI::HTML::Widget::JavaScript render javascript function
    definitions in HEAD
  * Bivio::UI::HTML::Widget::Page render javascript function definitions
    in HEAD
  * Bivio::UI::View::CSS fix th with a, move title to main_middle
  * Bivio::UI::View::ThreePartPage move title to main_middle
  * Bivio::UI::Widget::List support ListFormModel
  * Bivio::Util::RealmFile added -force support to delete()

  Revision 5.5  2007/05/31 08:10:37  nagler
  * Bivio::UI::HTML::Widget::Text.max_width added
  * Bivio::UI::Widget::WithModel added
  * Bivio::Delegate::SimpleWidgetFactory supports any Type.Number for edits
  * Bivio::Type::Enum->to_literal calls from_literal_or_die if $value not ref
  * Bivio::Biz::Action::EmptyReply->execute_task_item added
  * Bivio::Test::Language::HTTP->login_as and do_logout added
  * Bivio::Test::Language::HTTP->send_request now accepts form data in the
    form of an array.
  * Bivio::UI::ViewShortcuts->vs_use added
  * Bivio::Biz::PropertyModel->unauth_create_or_update_keys added

  Revision 5.4  2007/05/30 05:51:56  nagler
  * Bivio::UI::Mail::Widget::MailboxList added
  * Bivio::Biz::ListModel->new_anonymous forces can_iterate to be true
  * Bivio::Biz::Model::RealmAdminEmailList added
  * Bivio::Biz::Model::RealmEmailList->is_ignore added
  * Bivio::SQL::Statement->EQ maps [undef] to IS_NULL
  * Bivio::Test::Widget->prose added
  * Bivio::UI::Widget::List.row_separator added. source_name and
    separator were deleted (widget will die if these attributes are supplied)

  Revision 5.3  2007/05/24 19:52:51  nagler
  * Bivio::Biz::Model::ImageUploadForm now handles updates correctly
  * Bivio::Type::FilePath->PUBLIC_FOLDER_ROOT & to_public moved up from DocletFileName
  * Bivio::Type::FileField->from_disk creates a file field from a "disk" file
  * Bivio::Test::Language::HTTP->tmp_file factored out of file_field

  Revision 5.2  2007/05/22 04:41:44  aviggio
  * Bivio::Biz::Model::RealmFile public bit update validation extended
    to use current path if no new path is specified

  Revision 5.1  2007/05/22 03:09:49  nagler
  * Bivio::Biz::Model::UserPasswordForm fixed (reset_instance_state()
    not available for all Models).
  * Bivio::Biz::Model::RealmFile no longer allows is_public to be true
    outside of the /Public folder.
  * All modules updated from Bivio::*::new() to use shift->SUPER::new
  * Bivio::Test::FormModel->file_field added

  Revision 5.0  2007/05/19 16:20:39  nagler
  * Bivio::Biz::Action::RealmlessRedirect->internal_choose_realm factored out,
    and chooses most recently joined realm with longest name.  This
    means a sub-forum is chosen over a top-forum.
  * Bivio::Biz::FormModel->reset_instance_state added.  This allows
    FormModel.bunits to reuse the instance.  Also added to ListFormModel
    and ExpandableListFormModel.
  * Bivio::Biz::Model::LocationBase->create sets realm_id if not set.
  * Bivio::Biz::Model::RealmBase->create sets creation_date_time,
    user_id, and (update, too) modified_date_time.
  * Bivio::Biz::Model::RealmFile->create_or_update_with_content added
  * Bivio::Biz::Model::UserForumList->LOAD_ALL_SIZE set to 5000.
  * Bivio::Biz::Random->integer accepts an (inclusive) floor.
  * Bivio::Test::Language::HTTP->submit_form recognizes lower case
    strings as regular expressions.  See examples in HTTP.bunit
  * Bivio::Test::Unit->builtin_shell_util added
  * Bivio::Type::ImageFileName added
  * Bivio::Type::FormMode->setup_by_list_this added
  * Bivio::UI::FacadeBase/Font reset more CSS attributes for "normal"
    fonts.  Added more default fonts.  Font "none" is gone.
  * Bivio::UI::HTML::Widget::Form.want_timezone added (defaults true).
    action is now dynamic
  * Bivio::UI::HTML::Widget::Test.is_read_only is now dynamic
  * Bivio::UI::View::CSS->internal_compress added.  Output is
    compressed by default now.
  * Bivio::UI::View::CSS resets all HTML tags to a known state (no
    margin, padding, etc.) and then sets "reasonable" defaults.
    h1-h4 can be controlled with facade Fonts.
  * Bivio::UI::View::SiteRoot->format_uri added.  You can now say
    SiteRoot(view_method) and the view_method will be validated along
    with it being formatted properly as a uri.
  * Bivio::UI::XHTML::Widget::TaskMenu now accepts a Link or XLink
    as an element. It doesn't do a good job of label highlighting,
    but this feature is more flexible for URI generation.
  * Bivio::Util::Class->super was broken.
  * Bivio::Util::POD->to_comments improved.  Methods are now sorted.
  * Bivio::Util::SQL->internal_upgrade_db_bundle added.  It calls
    all the more recent upgrades (forum to motion).

  Revision 4.91  2007/05/02 17:45:51  moeller
  * fixed broken units tests

  Revision 4.90  2007/05/02 16:59:02  moeller
    * Bivio::Agent::Request map_user_realms wasn't handling multiple
      keys in $filter properly (too loose)
    * Bivio::Biz::Action::LocalFilePlain use view for
      execute_uri_as_view
    * Bivio::Biz::ListFormModel fixed bug for ListModels with compound
      primary keys; also implemented delegation to ListModel for do_rows
      and map_rows
    * Bivio::HTML do not encode HTML entities -- the ascii version is
      easier to test
    * Bivio::IO::Config get any package's config
    * Bivio::SQL::Statement die() if an invalid value is passed to
      _build_value()
    * Bivio::Test::HTMLParser::Forms there can be *no* submits
    * Bivio::Test::HTMLParser::Tables odd case with links if the HTML is
      bad.  Makes more flexible for scraping
    * Bivio::Test::Language::HTTP added follow_frame, Convert uris to
      canonical before converting to string.  Removes :80/:443
    * Bivio::UI::FacadeBase my-site has path_info,
      EXISTS NOT_FOUND added to FormErrors
    * Bivio::UI::View::Blog added menu
    * Bivio::UI::View::CSS some std formatting for ThreePartPage
    * Bivio::UI::View::SiteRoot unsafe_new takes over work of
      execute_task_item
    * Bivio::UI::Widget::List extend List widget to handle ListForm
      models
    * Bivio::Util::Class added qualified_name
    * Bivio::Util::POD to_comments added

  Revision 4.89  2007/04/04 04:55:31  aviggio
  * Bivio::Biz::Model::CalendarEventDAVList add 'method' header and
    export all datetimes as UTC
  * Bivio::MIME::Calendar add 'method' to known header elements
  * Bivio::UI::View::Base reflects removal of SimplePage text widget
  * Bivio::UI::View::Tuple reflects removal of SimplePage text widget
  * Bivio::UI::Text::Widget::SimplePage removed, replaced by
    Bivio::UI::Widget::SimplePage

  Revision 4.88  2007/03/29 16:44:01  dobbs
  * Bivio::Biz::FormModel added internal_parse for forms that want to
    show errors on execute_empty
  * Bivio::Test::Unit added auth_realm() and auth_user() builtins
  * Bivio::UI::HTML::Widget::String now checks for empty line last, so
    String("\n") becomes '<br />'

  Revision 4.87  2007/03/27 23:19:03  moeller
  * Bivio::UI::View::Base use explicit SimplePage implementation for CSS and CSV

  Revision 4.86  2007/03/27 21:30:14  nagler
  * Bivio::UI::Widget::SimplePage replaces Bivio::UI::HTML::Widget::SimplePage
    IMPORTANT: If you install from a tarball, make sure you delete the
    old SimplePage.
  * Bivio::UI::Widget::SimplePage.content_type allows any mime type.
  * Bivio::Agent::Embed::Reply->set_output supports GLOB references
  * Bivio::Delegate::TaskId renumbered MOTION tasks, split off file component
    from mail, added SITE_CSS
  * Bivio::UI::View::Base->internal_body_from_name_as_prose deleted.  The
    views should define the text, not the Facade.  Individual reusable elements
    should be vs_text_as_prose.  Use internal_body_prose instead.  See
    examples in View.UserAuth.
  * Bivio::UI::View::Base->css added
  * Bivio::UI::View::Base->PARENT_CLASS added, but don't use it.  It's
    to get around potential problems with multiple Base.pm modules in a
    single application.
  * Bivio::UI::View::CSS added
  * Bivio::UI::FacadeComponent->format_css added, and added to all components
    (Color, Font, etc.)
  * Bivio::UI::FacadeBase added support for CSS views; Added CLIENT_REDIRECT
    (/go) and SITE_CSS (pub/site.css); Removed view bodies; Deprecated
    internal_text_as_prose usage that was requiring view name as a qualifier
    (backward compatible, but should remove if using)
  * Bivio::UI::Font->format_css has larger feature set (lowercase, none, etc.)
    which helps CSS generation
  * Bivio::UI::ViewLanguage->view_unsafe_put for overriding values within
    method views
  * Bivio::UI::Widget->initialize_attr can be supplied with a default_value
  * Bivio::UI::HTML::Widget::StyleSheet->control_off_render (dev mode) can
    render any task, instead of hardwiring that the style sheet is a file.
    You can also supply your own control now.
  * Bivio::UI::View::ThreePartPage added
  * Bivio::UI::XHTML::ViewShortcuts->vs_grid3 added
  * Bivio::Test->IGNORE_RETURN added to allow inline_case to work at object level.
    Bivio::Test::Unit also modified.
  * Bivio::Delegate::TaskId->FORUM_CSS added
  * Bivio::UI::Icon->FILE_SUFFIX_REGEXP added
  * Bivio::Biz::Model::RealmLogoList added
  * Bivio::UI::View::CSS->forum_css added
  * Bivio::UI::ViewShortcuts->vs_task_has_uri added
  * Bivio::UNIVERSAL->map_invoke also takes a closure for method
  * Bivio::Util::RealmAdmin->users allows you to filter by a role, e.g.
    b-realm-admin -r general users administator -- lists all super users
  * Bivio::Test::Request->set_user_state_and_cookie added
  * Bivio::Type::DocletFileName->public_path_info added
  * Bivio::Biz::Action::ClientRedirect->execute_unauth_role_in_realm added
  * Bivio::UI:XHTML::Widget::XLink now allows overrides of value, href, etc.
  * Bivio::UI:XHTML::Widget::TaskMenu.xlink can used instead of task_id/label
  * Bivio::Biz::Model::ForumDeleteForm added
  * Bivio::Biz::Model::Forum->unauth_cascade_delete
  * Bivio::Agent::Request->internal_redirect_realm_guess added to allow override
    by Bivio::Test::Request
  * Bivio::Test::Request->set_user_state_and_cookie added
  * Bivio::Test::Request->server_redirect added and same as client_redirect.
    Added redirect loop test.  ignore_redirects no longer needed
  * Bivio::Biz::Action::ClientRedirect->execute_unauth_role_in_realm added
  * Bivio::Biz::Model::RealmUserDeleteForm.user_name added
  * Bivio::Delegate::TaskId->FORUM_PUBLIC_WIKI_VIEW added. FORUM_WIKI_NOT_FOUND
    has ANYBODY permissions now.
  * Bivio::UI::ViewShortcuts->vs_realm and vs_model added
  * Bivio::UI::ViewShortcuts->vs_text simplified
  * Bivio::UI::View::Wiki->HIDE_IS_PUBLIC added.  Moved text to FacadeBase
  * Bivio::Biz::Util::RealmFile->update added
  * Bivio::Biz::Model::RealmFile->init_realm must be executed within realm
  * Bivio::SQL::ListQuery->clone added
  * Bivio::UI::Widget::List.separator added
  * Bivio::UI::Text::Widget::CSV.column_control added
  * Bivio::UI::HTML::Widget::String.hard_newlines & hard_spaces were conflicting
  * Bivio::Biz::Model::UserCreateForm improved name parsing
  * Bivio::Biz::Model::QuerySearchBaseForm rolled back previous redirect changes
  * Bivio::Biz::FormModel supports Bivio::SQL::Constraint->NOT_NULL_SET

  Revision 4.85  2007/03/14 22:08:07  aviggio
  * Bivio::Biz::Model::TestWidgetForm added to support UI widget unit
    testing
  * Bivio::Test::SampleText added to provide placeholder text content
  * Bivio::UI::Widget::Replicator added to support unit testing
  * Bivio::UI::XHTML::Widget::NestedList added to allow the application
    of dynamic lists based on a single-column XHTML list of items
    containing realm names or other unique identifiers
  * Bivio::Agent::HTTP::Reply->delete_output added
  * Bivio::Agent::TaskId now subclasses Bivio::Type::EnumDelegator
    instead of Enum
  * Bivio::BConf corrected permission category syntax
  * Bivio::Biz::Model::BlogList shorten excerpt length
  * Bivio::Biz::Model::ForumForm refactored ForumEmailMode comparison
  * Bivio::Biz::Model::QuerySearchBaseForm use "return {}" instead of
    calling client_redirect, making it easier to test and simplifying
  * Bivio::Biz::Model::TreeList node_level not in other
  * Bivio::Biz::Model::WikiForm added is_public visible field
  * Bivio::Biz::Model::WikiForm->internal_pre_execute will check for a public
    RealmFile if it is not found in the default private path
  * Bivio::Biz::Util::RealmRole category mapping dies with explicit
    error on invalid params
  * Bivio::Delegate::SimpleTaskId added PERMANENT_REDIRECT task
  * Bivio::Delegate::SimpleTaskId->is_component_included,
    included_components and all_components
  * Bivio::Delegate::SimpleTaskId can't have no such component check,
    because components could be included by subclasses (Delegate:TaskId)
  * Bivio::Delegate::TaskId->ALL_INFO deprecated, calls all_components
  * Bivio::ShellUtil->inheritance_ancestors replaces
    inheritance_ancestor_list
  * Bivio::Type::BlogName share from_literal and added ERROR()
  * Bivio::Type::DocletFileName share from_literal and added ERROR()
  * Bivio::Type::StringArray->sort_unique added
  * Bivio::Type::WikiName share from_literal and added ERROR()
  * Bivio::Type::WikiText naming is now more flexible, but maintain
    old behavior in here, added deprecated_auto_link_mode
  * Bivio::UI::HTML::Widget::Script only run correct table layout for
    netscape/mozilla
  * Bivio::UI::HTML::Widget::Select->unknown_label added, refactored
    some of the list code
  * Bivio::UI::View::Base vs_pager replaces overloaded pager as
    attribute name
  * Bivio::UI::View::Blog added public/private support
  * Bivio::UI::View::Wiki added public/private support
  * Bivio::UI::View fixed bug in _clear_children, passing wrong value
  * Bivio::UI::ViewLanguage->view_instance removed
  * Bivio::UI::XHTML::ViewShortcuts view_instance was a bad idea,
    vs_pager replaces overloaded pager as attribute name

  Revision 4.84  2007/03/13 22:17:40  moeller
  * Bivio::IO::ClassLoader simple_require had too much dynamic binding
    going on
  * Bivio::Biz::Model::BlogCreateForm can't die to see if exists,
    because transaction fails. This is problematic, but there's not
    much that can be done.
  * Bivio::Biz::Random use /dev/urandom when available, because
    /dev/random blocks
  * Bivio::Test::Unit added builtin_chomp_and_return
  * Bivio::Type::BlogFileName share from_literal and added
    from_literal_stripper
  * Bivio::Type::EnumDelegator call static method on delegate if $proto
    is a string; otherwise use instance strip POD
  * Bivio::UI::XHTML::Widget::WikiStyle wiki can be private/public
  * Bivio::UNIVERSAL grep_methods added and inheritance_ancestors replaces
    inheritance_ancestor_list

  Revision 4.83  2007/03/13 17:54:52  moeller
  more info later

  Revision 4.82  2007/03/10 00:45:41  nagler
  * Bug fixes from previous release
  * Bivio::UI::HTML::Widget::Table.column_height added

  Revision 4.81  2007/03/08 05:55:59  aviggio
  * Bivio::SQL::PropertySupport add Motion models to unused_classes
  * Bivio::Util::SQL->internal_upgrade_db_motion added

  Revision 4.80  2007/03/07 06:00:17  aviggio
  * Bivio::Biz::Model::MotionList added execute_load_parent
  * Bivio::Biz::Model::MotionVote added creation date timestamp
  * Bivio::Biz::Model::MotionVoteList added creation date
  * Bivio::Delegate::TaskId FORUM_MOTION_VOTE_LIST loads parent model
  * Bivio::UI::FacadeBase added creation date
  * Bivio::UI::View::Motion creation date and motion info added to
    results list view

  Revision 4.79  2007/03/06 20:16:24  aviggio
  * Bivio::BConf add permission categories and delegation for motions,
    views are now in Bivio::UI::View only
  * Bivio::Biz::Model::BlogList->render_html and render_html_excerpt added
  * Bivio::Biz::Model::BlogList includes email and display_name of owner
  * Bivio::Delegate::SimplePermission added motions permisions
  * Bivio::Delegate::SimpleTaskId added search_list
  * Bivio::Delegate::TaskId added motion tasks
  * Bivio::Delegate::NoMotionType added
  * Bivio::Delegate::SimpleMotionStatus added
  * Bivio::Delegate::SimpleMotionVote added
  * Bivio::IO::File->do_read_write added
  * Bivio::Type::ECCreditCardNumber test number constant added
  * Bivio::Type::WikiText allow ^^ map to ^
  * Bivio::Type::MotionStatus added
  * Bivio::Type::MotionType added
  * Bivio::Type::MotionVote added
  * Bivio::Type::RealmMotionMode added
  * Bivio::UI::FacadeBase added facade elements for motions and blog
  * Bivio::UI::View::Base->internal_body_from_name_as_prose prefixes name (caller)
    with simple_package_name, e.g. Wiki->not_found => wiki.not_found
  * Bivio::Biz::Model::Motion added
  * Bivio::Biz::Model::MotionForm added
  * Bivio::Biz::Model::MotionList added
  * Bivio::Biz::Model::MotionVote added
  * Bivio::Biz::Model::MotionVoteForm added
  * Bivio::Biz::Model::MotionVoteList added
  * Bivio::Biz::Model::RealmMail no longer threads subjects, just in-reply-to
    and references
  * Bivio::Biz::Model::SearchList->internal_post_load_row_with_model added
  * Bivio::Biz::Model::SearchList->internal_realm_ids returns all user realms,
    not just current one.
  * Bivio::UI::Text->regroup removed (superclass does it all)
  * Bivio::UI::View::Base moved from Bivio::UI::XHTML::View
  * Bivio::UI::View::Blog moved from Bivio::UI::XHTML::View
  * Bivio::UI::View::Calendar moved from Bivio::UI::XHTML::View
  * Bivio::UI::View::Motion added
  * Bivio::UI::View::Search moved from Bivio::UI::XHTML::View
  * Bivio::UI::View::SiteRoot moved from Bivio::UI::XHTML::View
  * Bivio::UI::View::Tuple moved from Bivio::UI::XHTML::View
  * Bivio::UI::View::UserAuth moved from Bivio::UI::XHTML::View
  * Bivio::UI::View::Wiki moved from Bivio::UI::XHTML::View
  * Bivio::UI::HTML::Widget::Checkbox hardwires class to "checkbox" (no ability
    to set class before
  * Bivio::UI::XHTML::ViewShortcuts->vs_simple_form adds epilogue & prologue
    unless already there.  Checkboxes handled correctly (single cell, instead
    of two cells)
  * Bivio::UI::XHTML::Widget::HelpWiki puts body in class=help_wiki_body
  * Bivio::UI::XHTML::Widget::RoundedBox puts body in class=rounded_box_body
  * Bivio::UI::XHTML::Widget::Page3.foot3 is now inlined again.  We'll
    be deprecating Page3 eventually
  * Bivio::UI::XHTML::View::Base->internal_xhtml_adorned and
    internal_text_as_prose added
  * Bivio::Util::Backup adjust timeout to 12 hours

  Revision 4.78  2007/02/23 05:50:25  aviggio
  * Bivio::Biz::Model::RealmUserAddForm create_or_update fix and new
    unauth_create_or_update
  * Bivio::Biz::PropertyModel create_or_update fix and new
    unauth_create_or_update
  * Bivio::Biz::Util::RealmRole create_or_update fix and new
    unauth_create_or_update
  * Bivio::MIME::Type added x-icon for favicon.ico
  * Bivio::UI::FacadeBase added wiki not found prose
  * Bivio::UI::XHTML::View::Wiki wiki not found prose moved to facade
  * Bivio::UNIVERSAL map_by_two should init $values properly

  Revision 4.77  2007/02/21 23:12:07  aviggio
  * Bivio::Delegate::SimpleTaskId change rolled back

  Revision 4.76  2007/02/21 22:15:09  aviggio
  * Bivio::Delegate::SimpleTaskId moved up Task.PERMANENT_REDIRECT
    from subclass

  Revision 4.75  2007/02/21 18:04:41  aviggio
  * Bivio::Biz::Action::CalendarEventICS modify .ics format to support
    reading by Outlook 2003
  * Bivio::Biz::Action::RealmFile->unauth_execute accepts a new argument
    'path_info' so clients can override the default
  * Bivio::Biz::PropertyModel Warn if auth_id field is present when
    adding auth_id to query when loading
  * Bivio::Delegate::TaskId Added Task.PERMANENT_REDIRECT and
    Action.PermanentRedirect
  * Bivio::IO::Alert->bootstrap_die has been expanded to use
    Bivio::Die->throw_or_die to support the usage in ClassLoader
  * Bivio::IO::ClassLoader->_die now delegates to
    Bivio::IO::Alert->bootstrap_die
  * Bivio::IO::Ref nested_contains and nested_differences can now
    usefully compare a HASH_REF to a Bivio::Collection::Attributes via
    ->get_shallow_copy
  * Bivio::Test::Reply->set_output will now accept an IO::File in the
    same way as a GLOB, and now returns $self like
    Bivio::Agent::Reply->set_output
  * Bivio::UI::FacadeBase undefined PERMANENT_REDIRECT by default
  * Bivio::Util::HTTPConf allow server_status_allow to be overriden for
    the entire app

  Revision 4.74  2007/02/05 05:55:33  aviggio
  * Bivio::Agent::SimpleTaskId is deprecated by Bivio::Agent::TaskId. The
    deprecated tasks now use Method views, and we will be moving to a
    Method view system to promote more sharing across applications.
  * Bivio::Biz::Model::TupleHistoryList handle undefined slot headers
  * Bivio::Biz::Model::User when creating display_name, don't put spaces
    between ''
  * Bivio::Test::Request->user_state added
  * Bivio::Type::WikiText is deprecating plain text format links, and
    instead all links, WikiWords, etc. must be prefixed with a caret (^).
    Type.WikiText runs in deprecated mode if there are no carets in the
    wiki file.
  * Bivio::UI::FacadeComponent has been simplified so that value, group,
    and regroup are one in the same.  value and regroup are deprecated.
    group no longer checks duplicates.
  * Bivio::UI::FacadeBase implements all strings, tasks, etc. for a complete
    application. TaskId components (base, blog, dav, mail, tuple, wiki,
    user_auth, xapian) bring in the requisite FacadeBase components
    automatically.  See Bivio::PetShop::Delegate::TaskId for an example.
  * Bivio::UI::View::Method added Special case methods that begin with
    internal_, and simplified pre_compile to only insert base if there
    is no view_parent
  * Bivio::UI::ViewShortcuts->vs_text_as_prose added
  * Bivio::UI::XHTML::ViewShortcuts properly reset alpha searches to All
    in vs_alphabetical_chooser

  Revision 4.73  2007/01/23 05:11:03  aviggio
  * Bivio::UI::XHTML::View::Tuple renders MIME attachments in history
    list view
  * Bivio::Util::Class added tasks_for_view, renamed task to tasks_for_label

  Revision 4.72  2007/01/19 05:55:11  aviggio
  * Bivio::Biz::Model::MailPartList decode MIME attachment file names if
    needed, e.g. may be UTF-8 encoded
  * Bivio::Delegate::SimpleTaskId FORUM_TUPLE_LIST_CSV task loads all
    records instead of loading a page
  * Bivio::SQL::PropertySupport use Bivio::Die->die and added debug info
  * Bivio::UI::LocalFileType identify CACHE and REALM_DATA values as
    deprecated for future development
  * Bivio::Util::Class added TaskId config info to output for task

  Revision 4.71  2007/01/17 06:24:34  aviggio
  * Bivio::Biz::Model::MailPartList 4.70 change rolled back

  Revision 4.70  2007/01/17 05:49:39  aviggio
  * Bivio::Biz::Model::MailPartList attachment file name not required in
    task URI path_info
  * Bivio::UI::XHTML::View::Tuple identify required fields on edit view

  Revision 4.69  2007/01/11 02:21:34  aviggio
  * Bivio::UI::Text::Widget::CSV support field type attribute
  * Bivio::UI::XHTML::View::Tuple specify type for CSV record list
    columns
  * Bivio::Util::HTTPConf render app status Location directive after
    default Location directive

  Revision 4.68  2007/01/10 01:00:09  aviggio
  * Bivio::Biz::Model::Tuple update RealmMail thread_root_id on updates
    in case message subject changed

  Revision 4.67  2007/01/09 05:46:53  aviggio
  * Bivio::Biz::Model::MailPartList->execute_from_realm_file_id added
  * Bivio::Biz::Model::Tuple->split_body added
  * Bivio::Biz::Model::TupleHistoryList re-use MailPartList to parse
    message body
  * Bivio::Biz::Model::TupleSlotListForm improve message subject rendering

  Revision 4.66  2006/12/28 16:49:37  aviggio
  * Bivio::Biz::Model::TupleSlotListForm sets the mail subject based on the
    first Bivio::Type::TupleSlot (string line) slot value
  * Bivio::Util::Class added as a home for helpers in introspecting bOP
    classes

  Revision 4.65  2006/12/22 05:55:36  aviggio
  * Bivio::Biz::Model::TupleHistoryList.pm replace hyphens and dashes in
    field names for display purposes
  * Bivio::Delegate::SimpleTaskId add tuple record and history .csv views
  * Bivio::ShellUtil support test cleanup
  * Bivio::UI::FacadeBase add tuple record and history .csv views
  * Bivio::UI::Text::Widget::CSV accept column heading attributes
  * Bivio::UI::XHTML::View::Tuple add tuple record and history .csv views

  Revision 4.64  2006/12/18 16:57:00  moeller
  * Bivio::Delegate::SimpleRealmName added make_offline()
  * Bivio::ShellUtil new() and main() can now take class arguments to
    load mapped classes

  Revision 4.63  2006/12/12 05:33:00  aviggio
  * Bivio::Biz::Model::ContactForm put auth user email, if it exists, in
    local 'from' field
  * Bivio::Biz::Model::TupleList->execute_load_history_list updated to
    match new query
  * Bivio::UI::XHTML::View::Tuple pass thread root id as query parent id
    for history list view

  Revision 4.62  2006/12/08 05:46:13  aviggio
  * Bivio::Biz::Model::RealmRole allow permissions to be specified by a
    list of roles and/or permissions
  * Bivio::Type::EnumSet->get_empty added

  Revision 4.61  2006/12/06 22:59:16  moeller
  * Bivio::Agent::Request use map_user_realms in internal_get_realm_for_task
    map_user_realms defaults to return entire array
  * Bivio::Agent::Task allow next/cancel for return task_id
  * Bivio::Biz::Action::ClientRedirect use returns, not redirect
  * Bivio::Biz::Model::ContactForm load email if logged in
  * Bivio::Biz::PropertyModel load_for_auth_user
  * Bivio::UI::HTML::Widget::Radio fixed internal_new_args() to accept an
    Enum value
  * Bivio::UI::Task general not handled correctly for realmless

  Revision 4.60  2006/12/01 23:32:52  dobbs
  * Bivio::Agent::Request added with_user() to match with_realm()
  * Bivio::Biz::Model::Club defined equivalence for club_id and RealmOwner.realm_id
  * Bivio::Biz::Model::SummaryList added internal_sum() so subclasses can override
  * Bivio::Biz::Model::UserTaskDAVList reverted to revision 1.4
  * Bivio::Biz::Random integer() ceiling now defaults to Bivio::Type::Integer->get_max()
  * Bivio::Type::ForumName now allows subclasses to override SEP_CHAR_REGEXP
  * Bivio::Util::SQL moved data population into initialize_db()

  Revision 4.59  2006/11/16 18:31:01  aviggio
  * Bivio::Agent::Request added with_realm, replaced get_user_realms
    with map_user_realms, added filter to map_user_realms
  * Bivio::Biz::Model::Lock added acquire_unless_exists and
    acquire_general
  * Bivio::Biz::Model::Tuple return comment-only updates
  * Bivio::Biz::Model::TupleHistoryList does not filter out comment-only
    rows
  * Bivio::Type::Time accept 121212 format, from_literal returns (undef,
    undef) in appropriate case
  * Bivio::UI::XHTML/Widget/Page3 support Prose in page meta title

  Revision 4.58  2006/11/13 22:48:46  nagler
  * Bivio::UI::XHTML::Widget::TaskMenu.selected_item replaces
    selected_task_name.  If the widget value resolves to a TaskId, it
    behaves as before.  Otherwise, it string compares the labels against
    the resolution of selected_item
  * Bivio::UI::HTML::Widget::Tag generates empty tags like <br />
    instead of <br></br> if the tag is listed as empty in the XHTML DTD.
  * ShellUtil.bunit is broken pending fixes
  * Various Tuple fixes to handle empty slots properly
  * Bivio::Biz::Random->integer added
  * Bivio::ShellUtil -detach added.  Calls detach_process() to
    disconnect from tty and run in separate process group.  Also writes
    a log file automatically using Bivio::IO::Log.
  * Bivio::IO::Alert does no re-initialize $_LOGGER after the first call
    to handle_config
  * Bivio::Biz::Model::UserTaskDAVList no longer puts spaces between
    CamelCase-generated directory elements.
  * Bivio::Test::Util looks in "t" directory for Foo.bunit/t/btest if it
    doesn't find it in the current directory.
  * Bivio::UI::Widget->resolve_attr added

  Revision 4.57  2006/11/09 00:13:13  nagler
  * Bivio::UI::Widget::HTML::Tag supports arbitrary HTML attribute
    values.  See unit test.  Also renders empty tags as <tag />.
  * Bivio::Auth::Realm->new accepts a RealmType iwc it will return the
    default realm for that type.
  * Bivio::Util::Backup sets a --timeout on rsync
  * Bivio::Test::Reload refactored to use File::Find
  * Bivio::Collection::Attributes->internal_clear_read_only added
  * Bivio::UI::View->call_main will remove cycles (parent) when a
    view is destroyed

  Revision 4.56  2006/11/06 08:11:41  nagler
  * Bivio::Biz::Model::SearchForm->parse_query_from_request checks form_model
    instead of explicit Model.SearchForm.
  * Bivio::Auth::Realm->new returns general realm singleton if realm_id is
    passed in and matches general realm_id (1).
  * Bivio::Delegate::SimpleTaskId->info_xapian introduces search_class config

  Revision 4.55  2006/11/05 21:59:47  nagler
  * Bivio::UI::XHTML::Widget::XLink added.  Interesting example of a
    new style widget implementation
  * Bivio::Type::DisplayName added
  * Bivio::Biz::Model::RealmOwner->unauth_load_by_email_id_or_name and
    unauth_load_by_id_or_name_or_die allow for numeric RealmNames
  * Bivio::Biz::Model::RealmOwner.display_name is Type.DisplayName which is
    500 chars
  * Bivio::Test::Unit->builtin_var allows bunits to save state between
    cases in a convenient manner.  See Unit.bunit and ForumForm.bunit
    for examples.
  * Bivio::ShellUtil->initialize_fully added as alias for intialize_ui(1)
  * Bivio::ShellUtil->model instantiates and (optionally) loads models.
    Refactored from Bivio::Test::Unit->builtin_model
  * Bivio::Agent::Request->format_uri accepts uri as named argument which
    avoids all task specific params.  See URI.bunit for example.
  * Bivio::UI::ViewShortcuts->vs_constant added (like vs_text)
  * Bivio::UI::HTML::Widget::Tag.want_whitespace removed
  * Bivio::UI::HTML::ViewShortcuts->vs_html_attrs_merge added (for XLink)
  * Bivio::Test::HTTPd no longer uses named configuration
  * Bivio::Test::HTTPd.pre_execute_hook added
  * Bivio::Test->unit accepts comparator (nested_contains or nested_equals)
    for checking results
  * Bivio::Biz::PropertyModel->get_qualified_field_name added
  * Bivio::Biz::Action::WikiView->internal_model_not_found added
  * Bivio::Biz::Action::WikiName->START_PAGE added
  * Bivio::Biz::ListQuery.this may be an array_ref
  * Bivio::Test::FormModel releases Model.Lock if held on clear non-durable state.
    If comparator is set to nested_contains, uses it to check results of process.
  * Bivio::Test::Request->setup_http will not UserLogin if there is no user
    or if the user is the "default" user
  * Bivio::Type::ForumName cleans up the name and supports FIRST_CHAR_REGEXP
  * Bivio::Type::SyntacticString added
  * Bivio::Delegate::SimpleTypeError->SYNTAX_ERROR should be used when there
    are syntactic errors (see SyntacticString) and Facade's FormError component
    should be assigned the UI error message
  * Bivio::Type::PrimaryId->is_valid added
  * Bivio::Type::TupleLabel->isa SyntacticString
  * Bivio::UI::View views can call other view classes with Class->name syntax
  * Bivio::UI::Widget::LogicalBase/And/Or return last true value, not (1)
  * Bivio::UI::Widget::Prose renders single capital letter functions, e.g. P()
  * Bivio::UI::XHTML::Widget::BasicPage.basic_page_* attributes replace
    simple_page_* attributes
  * Bivio::MIME::Type refactored to be simpler (with unit test)

  Revision 4.54  2006/11/03 23:13:12  aviggio
  * Bivio::Biz::Model::ForumUserAddForm made _up and _down private methods
    into internal methods to allow override by subclasses
  * Bivio::IO::File->do_in_dir added
  * Bivio::SQL::Statement protect against merging self, self, b/c
    infinite loop

  Revision 4.53  2006/10/27 17:04:49  nagler
  * Bivio::UI::Widget::ControlBase.control will be rendered after it is
    resolved as a widget value.
  * Bivio::UI::Widget::Or and And added
  * Bivio::Test::Unit->builtin_inline_case (inline_case) added
  * Bivio::Biz::Model::MailReceiveDispatchForm.ignore_dashes_in_recipient added
  * Bivio::UI::View view names are cleaned if they are LocalFiles
  * Bivio::UI::HTML::Widget::ListActions renders more dynamically
  * Bivio::UI::HTML::Widget::DateField does not get width from field type,
    because it relies on a cached constant (Type.Date) anyway, and the
    width wasn't appropriate for TupleSlot support
  * Bivio::Test->current_case/self added
  * Bivio::Delegate::SimpleWidgetFactory.wf_type added
  * Bivio::Biz::Model singleton creation no longer caches the request
    from startup.  Singletones should be request-state free.
  * Bivio::Biz::ListModel->load_empty added
  * Tuple support complete: see tuple.btest
  * Bivio::UI::ViewShortcuts->vs_list_form calls vs_simple_form with the
    fields which are not hashes or which aren't in_list in the form.
    See View.Tuple for examples.

  Revision 4.52  2006/10/25 21:05:57  nagler
  * Tuple support partially in.  You need to rebuild your petshop databases.
  * Bivio::UI::View->execute_uri moved to Bivio::Biz::Action::LocalFilePlain
    You will get errors if you used execute_uri in tasks elsewhere.  It
    will likely be a NOT_FOUND with entity=>execute_uri in the message.

  Revision 4.51  2006/10/25 19:02:14  moeller
  * Bivio::Agent::Task Added execute_task_item api
  * Bivio Auth::Realm added do_default()
  * Bivio::BConf added View map, added tuple category
  * Bivio::Biz::ExpandableListForm call get_form
  * Bivio::Biz::Model::TupleSlotType creating TupleSlotType from ListForm
  * Bivio::Delegate::SimplePermission added TUPLE_READ
  * Bivio::Delegate::SImpleTaskId support categories of tasks
  * Bivio::SQL::Connection added handle_commit() and handle_rollback()
    so a connection can be a Request's transaction resource
  * Bivio::Type::StringArray from_literal supports []
  * Bivio::UI::HTML::Widget::String fixed widget check with is_blessed
    If ref implements to_html, then won't blow up in _format
  * Bivio::UI::View Delegated compilation to subclasses: Inline, Method,
    and LocalFile, added support for execute_item,
    allow the case where the view wants a LocalFile parent
  * Bivio::UI::ViewLanaguage Delegated compilation to subclasses.
    Use local() for stack
  * Bivio::UNIVERSAL added is_blessed
  * Bivio::Util::SQL initialize_tuple_permissions

  Revision 4.50  2006/10/20 19:38:04  moeller
  * New PropertyModels Tuple, TupleDef, TupleSlotDef, TupleSlotType, and
    TupleUse
  * Bivio::Biz::FormModel show more info about HTTP request when
    VERSION_MISMATCH occurs
  * Bivio::Biz::ListFormModel added map_rows and get_field_name_in_list
  * Bivio::Biz::Model::Lock read any input from request before acquiring
    lock, renamed to execute_unless_acquired
  * Bivio::Biz::Model::RealmMail added create_hook config
  * Bivio::Mail::Incoming get_field always returns a defined value
  * Bivio::SQL::PropertySupport more unused_classes
  * Bivio::Test::HTTPd linux or perl 5.6 compatibility change
  * Bivio::Test::Language::HTTP allow submit without button to allow AT
    of auto_submit fields
  * Bivio::Test::ListModel support for find_row_by
  * Bivio::Type::Text64K updated get_width to be -1.
  * Bivio::UI::HTML::Widget::Select allow TypeValue with array of Enum value
  * Bivio::UI::Widget::List added source_name like Table
  * Bivio::UNIVERSAL added map_by_two()
  * Bivio::Util::SQL initialize_tuple_slot_types

  Revision 4.49  2006/10/16 20:56:51  moeller
  * Bivio::Agent::Request added get_content()
  * Bivio::Biz::Action::Acknowledgement export QUERY_KEY
  * Bivio::Biz::Model::Lock read any input from request before acquiring
    lock
  * Bivio::Biz::Model preliminary fix to enable Model reloading
  * Bivio::IO::ClassLoader fix delete_require to not stomp on shared
    references
  * Bivio::IO::File added do_lines()
  * Bivio::SQL::ListSupport removed $_TRACE and ->register
  * Bivio::Test::HTTPd export PROJ_ROOT
  * Bivio::Test::Language::HTTP allow submit without button to allow AT
    of auto_submit fields
  * Bivio::Type::BlogName don't compile value in from_literal
  * Bivio::Type::String compare should call compare_defined
  * Bivio::UI::XHTML::ViewShortcuts vs_simple_form accepts 'TEXT_TAG
    which gets mapped to vs_text($form, 'prose', TEXT_TAG) to allow
    inline form_prose
  * Bivio::Util::HTTPPing added db_status()
  * Bivio::Util::SQL added TEST_PASSWORD

  Revision 4.48  2006/09/29 20:30:48  dobbs
    * Bivio::SQL::ListSupport and Bivio::SQL::Statement both fixed to
      re-enable internal_initialize to override FROM
    * Bivio::Search::Xapian now deletes Xapian's db_lock before calling
      Search::Xapian.  The lock may be left over from a dead process

  Revision 4.47  2006/09/27 23:30:48  aviggio
  * Bivio::PetShop::Util fixed db upgrade syntax error
  * Bivio::SQL::ListSupport fixed sorting on tables in FROM clause
  * Bivio::Util::SQL include time_zone field in shared db upgrade code

  Revision 4.46  2006/09/26 17:36:53  aviggio
  * Bivio::IO::Trace allow Reloaded modules to be reprocessed
  * Bivio::MIME::Base64 don't try decoding something under 4 bytes
  * Bivio::SQL::Statement now correctly includes tables in FROM that are
    only mentioned at request time (e.g. in internal_prepare_statement)
  * Bivio::Type::Secret protect against undef returned from
    Base64->http_decode()
  * Bivio::UI::HTML::Format::Link remove 'site' arguments and app
    specific methods
  * Bivio::UI::HTML::Widget::DateTime correct DAY_MONTH3_YEAR rendering
  * Bivio::UI::HTML::Widget::Table allow sorting to be overridden for a
    specific table column

  Revision 4.45  2006/09/23 00:25:47  aviggio
  * calendar_event_t.time_zone field converted to NUMERIC(4)
  * Bivio::BConf removed UniversalTimeZone delegate, now a normal enum
  * Bivio::Biz::Model::CalendarEventForm validates start vs end datetime
  * Bivio::Delegate::SimpleTypeError added INVALID_END_DATETIME error
  * Bivio::Test::Reload and Bivio::Test::HTTPd now allow dynamic
    reloading of changed modules
  * Bivio::Test::Util removed Trace->register
  * Bivio::Type::TimeZone converted to subclass standard enum and to
    encapsulate Olson time zone database with conversion methods
    date_time_to_utc and date_time_from_utc
  * Bivio::UI::DateTimeMode added DAY_MONTH3_YEAR_TIME_PERIOD mode
  * Bivio::UI::HTML::Format::DateTime handle DAY_MONTH3_YEAR_TIME_PERIOD
    formatting mode
  * Bivio::Util::Release back out new %define for Module::Build

  Revision 4.44  2006/09/14 23:07:05  aviggio
  * Added time_zone type field to calendar_event_t bOP table definition
  * Bivio::BConf added UniversalTimeZone delegate
  * Bivio::Biz::Model::CalendarEvent maps new time zone field
  * Bivio::Biz::Model::CalendarEventForm exposes time zone field and
    calls convert_datetime method delegated by Bivio::Type::TimeZone
  * Bivio::Delegate::SimpleWidgetFactory default Date type display mode
    is DATE, render Date and Time values separately, avoiding timezone
    adjustment DateTime
  * Bivio::Delegate::UniversalTimeZone enum delegate added
  * Bivio::Test::Reload fixed move to httpd/; now searches for BConf.pm
    to build list of watched directories
  * Bivio::Type::DateTime $proto-> missing
  * Bivio::Type::Text64K now derived from Text so the WidgetFactory uses
    a TextArea
  * Bivio::Type::Time allow literals with no minutes when rendering,
    don't show sends if 0
  * Bivio::Type::TimeZone enum delegator type added
  * Bivio::UI::HTML::ViewShortcuts->vs_display() added back
  * Bivio::Util::Release modified to generate perl_build_install for
    Module::Build non-traditional makefile support

  Revision 4.43  2006/09/08 00:25:03  aviggio
  * Bivio::ShellUtil don't send email if running -noexecute
  * Bivio::Test::Unit throw_quietly if error in assert_expect/equals
  * Bivio::Type::WikiText->render_html now takes parameter to override
    automatic wiki link creation
  * Bivio::UI::XHTML::Widget::RSSPage renders link as absolute URI

  Revision 4.42  2006/09/01 17:12:53  aviggio
  * Bivio::BConf added system_user_forum_email permission category
  * Bivio::Biz::Model::ForumEditDAVList added email related columns
  * Bivio::Biz::Model::ForumForm reference permission categories directly
    instead of denormalizing permission settings in the database
  * Bivio::Biz::Model::ForumList added local fields for permission settings
  * Bivio::Biz::Util::RealmRole->edit_categories sorts permission
    category list order to prevent side effects
  * Bivio::Delegate::SimpleTypeError define new MUTUALLY_EXCLUSIVE error
  * Bivio::SQL::Connection::Postgres fixed case where (+) left join was
    last term in WHERE clause--when (+) was removed, it left an AND
  * Bivio::Util::SQL->create_test_user needs to preserve old behavior of
    $user, and not put generated email local part into display_name and
    user_name, if an email wasn't supplied

  Revision 4.41  2006/08/23 17:05:54  moeller
  * Bivio::Agent::HTTP::Request throws a CLIENT_ERROR if a timeout
    occurs while reading the request body
  * Bivio::Auth::Realm no longer calls lc() on name,
    Bivio::Type::RealmName determines lc() behavior
  * Bivio::HTML::Scraper doesn't write to log file unless the filename
    is provided

  Revision 4.40  2006/08/23 04:55:53  aviggio
  * Bivio::Auth::Realm->clone added and called from new
  * Bivio::Auth::Realm->get_default_id added
  * Bivio::Biz::Action::TestBackdoor accepts shell_util in query to
    execute shell_util
  * Bivio::Biz::Model::ForumForm pass hash to RealmRole.edit_categories
  * Bivio::Biz::Model::RealmOwner use map lookup for types
  * Bivio::Biz::Model::RealmRole->get_permission_map added and modified
    get_roles_for_permission to call it
  * Bivio::Biz::Model::UserPasswordForm->PASSWORD_FIELD_LIST added
  * Bivio::Biz::Util::RealmRole->list_all_categories and
    list_enabled_categories added, edit_categories now accepts hash refs
  * Bivio::Test::Language::HTTP->do_test_backdoor accepts ShellUtil class
    and command string to passed to Action.TestBackdoor
  * Bivio::Test::Unit->builtin_create_user returns auth_user
  * Bivio::Util::SQL->create_test_user accepts an email, and generates
    user and display_name from that

  Revision 4.39  2006/08/17 17:03:21  moeller
  * Bivio::SQL::ListSupport added count_distinct option to list
    declarationto support paging on lists that use want_select_distinct
  * Bivio::Test::Unit $_TYPE_CAN_AUTOLOAD needed to avoid recursion on
    AUTOLOAD when the function does not exist
  * Bivio::Test wrap nested_differences, which can execute code, so we
    don't get caught with bad code in test.
    Fixed test harness t() to handle FAILURE in output as a failure
    Don't call nested_differences if custom check return and die
  * Bivio::UI::Text::Widget::CSV added header option
  * Bivio::UI::Widget::URI coding standard cleanup

  Revision 4.38  2006/08/14 02:09:50  nagler
  * Bivio::Type::Boolean->get_default added
  * Bivio::Type::Year->get_default/now added
  * Bivio::Type::Enum->get_instance removed
  * Bivio::Type->get_instance returns self if no args
  * Bivio::UI::ViewLanguage->view_use added
  * Bivio::Test::HTMLParser::Forms only includes text at start of tag
    which contains class or color

  Revision 4.37  2006/08/08 21:06:24  aviggio
  * Bivio::Biz::Model::QuerySearchBaseForm fix for auxillary forms on
    request
  * Bivio::Test::HTMLParser::Forms improve form parsing for XHTML pages
  * Bivio::Util::HTTPConf Identify virtual host names in access logs

  Revision 4.36  2006/08/03 19:38:32  moeller
  * Bivio::Biz::Action::MailForward undo X-Bivio-Test-Recipient hack
  * Bivio::Biz::FormModel internal_catch_field_constraint_error can now
    handle extra error information
  * Bivio::Biz::Model::RealmMail get_references ifc change
  * Bivio::Die catch can be called within handle_die
  * Bivio::IO::ClassLoader include map_class in the trace output
  * Bivio::IO::File append/write take offset,
    ls and foreach_line gone,
    _open() refactoring
  * Bivio::Mail::Common queue of msgs is now queue of Common instances,
    reimplemented get_last_queued_message
  * Bivio::Mail::Incoming pushed more in Mail::Common, and is Attributes
    now
  * Bivio::Mail::Outgoing pushed more in Mail::Common, and is Attributes
    now
  * Bivio::ShellUtil initialize_ui accepts boolean for initialization of
    all facades and tasks.
  * Bivio::Test::Language::HTTP fix matching in verify_local_mail to
    match only the first keyword that exists,
    verify_local_mail checks X-Bivio-Test-Recipient:
     then To: in that order.  MTA may bounce msg, and
     X-Bivio-Test-Recipient: won't be set.
  * Bivio::Test::Language SELF_IN_EVAL is dynamic var
  * Bivio::Test::Unit tmp_dir,
    req() now accepts parameters so you can get_widget_value off the
     requests,
    string_ref, rm_rf, assert_equals
  * Bivio::Test::Util refactor
  * Bivio::UI::Facade missing local_file_root is now a warning
  * Bivio::UI::HTML::Widget::Form use ViewShortcuts to render the
    TimezoneField so that projects can customize the TimezoneField
  * Bivio::UI::HTML::Widget::Text let Text widgets have a class
  * Bivio::UI::HTML::Widget::TextArea use edit_attributes instead of
    attributes so they work with FormField,
    change superclass from Widget to ControlBase and allow arbitrary
    attributes to be included in the opening tag
  * Bivio::UI::Icon Simplified initialize_by_facade and removed die
  * Bivio::UI::Task format_realmless_id can take a simple string for
    task_id
  * Bivio::Util::CSV changed calls to _is_row_empty() to reflect the
    actual method name,
    fixed blank line problem,
    no longer modifies input buffer during parse()
  * Bivio::Util::HTTPConf Added VirtualHost to common log format
    (combined) in LogFormat
  * Bivio::Util::HTTPPing process_status compares loadavg only

  Revision 4.35  2006/07/17 20:53:16  moeller
  * Bivio::Delegate::SimpleTaskId changed optional search task to be
    dependent on Search::Xapian
  * Bivio::Search::RealmFile removed ascii7 option to pdftotext

  Revision 4.34  2006/07/17 04:33:12  nagler
  Note: the Xapian/Search unit test will fail if you don't have Xapian
  installed.  See README.

  * Bivio::Agent::Task::_call_txn_resources calls resources with pop(),
    which is the reverse of how they were being called before.
    This was a fairly serious defect, because locks should be released
    last, not first.  Now a lock will be released after all resources
    which depend on it.
  * Bivio::Test::ShellUtil added
  * Bivio::Util::Search (b-search) added
  * Bivio::Auth::Realm->id_from_any added
  * Bivio::Biz::File->destroy_db added
  * Bivio::Util::SQL->destroy_db cannot be called on production, and
    now calls Bivio::Biz::File->destroy_db
  * Bivio::Biz::Model::BlogList->execute_load_this calls from_literal
    to convert path_info to "this".
  * Bivio::Delegate::SimpleTaskId->JOB_XAPIAN_COMMIT added
  * Bivio::Search::Xapian calculates all data in background if the
    general realm is not locked.  Xapian is single writer so general
    must be locked, and we can't know a task needs a general lock until
    there's a file modification.  The JOB_XAPIAN_COMMIT will process
    all the files in background that it can load.  Given the way files
    are managed, this is relatively safe, that is, once a file is
    deleted, it never reappears with the same realm_file_id, which is
    the unique identifier Xapian manages.  No files will be lost, but
    there may be files added in a race condition with a subsequent
    delete that could mean files remain in the Xapian db after they are
    deleted in SQL.  This isn't a tragedy since you can't load a file
    that doesn't exist.
  * Bivio::Biz::Model::Lock->is_acquired accepts a realm/id as an
    argument.
  * Bivio::Biz::Model::Lock->is_general_acquired added
  * Bivio::Search::RealmFile handles missing values now
  * Bivio::Search::Xapian->query accepts list of public/private realms.
    API was too simple before.  Need to restrict public realm list sometimes.
  * Bivio::Type::BlogFileName->from_absolute replaces from_path()
  * Bivio::Type::BlogTitle->from_content added
  * Bivio::Type::DocletFileName->from_absolute added
  * Bivio::UI::HTML::Widget::Image->render outputs "alt" only once
  * Bivio::Util::RealmFile->import_tree prunes CVS dirs now
  * Bivio::Biz::Action::WikiView correctly loads all types of files (not
    just images) from wiki folder.  If the name isn't a wiki name, it
    assumes it is a file to be loaded in the folder or subfolder of the
    wiki folder.
  * Bivio::Biz::Model::RealmMail uses MailSubject and MailFileName
  * Bivio::Biz::Model::SearchList supports have_hext/prev and realm_id config
  * Bivio::Biz::Model::WikiForm uses new Doclet interface
  * Bivio::Search::RealmFile uses new DocletFileName interface
  * Bivio::Search::Xapian->query_list_model_initialize added
  * Bivio::IO::Ref->nested_differences/contains serializes in a line
    (Data::Dumper format without indents)
  * Bivio::Type::BlogFileName subclasses Bivio::Type::DocletFileName.
    API standardized (to_absolute, is_absolute, PATH_REGEX, REGEX).
  * Bivio::Type::FileName subclasses Bivio::Type::FilePath (was the
    other way around)/Users/nagler/src/perl/Bivio/Type/MailFileName.pm
  * Bivio::Type::FilePath is superclass Bivio::Type::FileName
  * Bivio::Type::WikiName uses DocletFileName api
  * Bivio::Type::WikiText handles automatic linking of domain names better
  * Bivio::Test->unit uses nested_differences instead of doing some
    compares locally
  * Bivio::Agent::Request->get_user_realms added
  * Bivio::Agent::Job::Dispatcher->enqueue accepts auth_id and auth_user_id in
    params
  * Bivio::IO::Alert now adds a "slop factor" (5) to the warn count when
    warn count limit is hit.  This allows handle_die() routines to output
    errors during handling of a TOO MANY WARNINGS error.
  * Bivio::Test::Unit allows unit test to be <Module>N.bunit, where N is a
    single digit.  It tries <Module>N.pm first, in case that's the name
    of the module.
  * Bivio::Biz::Model::SearchForm added
  * Bivio::Biz::Model::SearchList plays nice with SearchForm.
  * Bivio::Test::Language::HTTP->random_string accepts a length arg, and
    generates string with [0-9a-z] chars
  * Bivio::Biz::Model::UserRealmList now includes RealmUser.role in order_by
    so sort order is predictable.
  * Bivio::PetShop::Util->initialize_test_data sets test forum display names
    so they order properly
  * b-perl-agile.el has a ListModel template for bunit
  * Bivio::Test::Language->test_equals added

  Revision 4.33  2006/07/08 19:07:49  aviggio
  * Bivio::Agent::Request->unsafe_get_txn_resource added
  * Bivio::Biz::Model::BlogCreateForm class added
  * Bivio::Biz::Model::BlogEditForm class added
  * Bivio::Biz::Model::BlogList class added
  * Bivio::Biz::Model::BlogRecentList class added
  * Bivio::Biz::Model::MailPartList->load_from_content added
  * Bivio::Biz::Model::RealmFile added search_class hook,
    corrected handle_rollback, use files instead of holding content in
    memory, use internal_get_target values return so can be used in
    internal_post_load_row in BlogList, added unauth_load_by_os_path and
    removed old_filename
  * Bivio::Biz::PropertyModel->default_order_by added for iterate
  * Bivio::Delegate::SimpleTypeError added BLOG_TITLE/FILE/BODY errors
  * Bivio::IO::File->absolute_path and unique_name_for_process added
  * Bivio::IO::Ref handle scalar case in nested-*, added
    nested_contains which shares code with nested_differences.
    Refactored nested_differences into parts, and added ability to use
    CODE to compare results
  * Bivio::Test::FormModel added commit, rollback and random_string to
    builtin functions
  * Bivio::Test::Unit model(Model, query) returns model in all three
    cases, added expect_contains, assert_contains, model, commit,
    rollback, random_string, read_file and write_file
  * Bivio::Type::AccessMode class added
  * Bivio::Type::BlogBody class added
  * Bivio::Type::BlogContent class added
  * Bivio::Type::BlogFileName class added
  * Bivio::Type::BlogTitle class added
  * Bivio::Type::Enum->as_xml added
  * Bivio::Type::FilePath added *_FOLDER
  * Bivio::UI::HTML::Widget::DateTime removed NS3 hack
  * Bivio::UI::HTML::Widget::Form proper method (downcase) and
    trailing />
  * Bivio::UI::HTML::Widget::JavaScript removed VERSION code
  * Bivio::UI::HTML::Widget::Script style must have type=
  * Bivio::UI::HTML::Widget::ScriptOnly style must have type=
  * Bivio::UI::HTML::Widget::Style style must have type=
  * Bivio::UI::HTML::Widget::StyleSheet style must have type=
  * Bivio::UI::XHTML::ViewShortcuts allow List() for vs_paged_list
  * Bivio::UI::XHTML::Widget::WikiStyle style must have type=
  * Bivio::UNIVERSAL->my_caller added

  Revision 4.32  2006/06/30 20:52:34  aviggio
  * Bivio::Biz::Action::EasyForm use admin user_id if form submitter is
    not authenticated
  * Bivio::UI::HTML::Widget::FormField allow widget value as form field
    label instead of Facade text
  * Bivio::Util::LinuxConfig don't add gateway line if it's this ip

  Revision 4.31  2006/06/27 17:21:15  moeller
  * Bivio::BConf fixed db password string to interpolate
  * Bivio::Biz::Action::EasyForm added file field upload
  * Bivio::Biz::Action::MailForward fixup the bivio test recipient
    header on the message to be forwarded
  * Bivio::Mail::Incoming get_date_time uses DateTime->from_literal
  * Bivio::Test::Language::HTTP send_request() now wraps $header in
    HTTP::Headers for older versions of perl,
    ensure that an option submit value matches the label or an existing
    value
  * Bivio::Type::FileName added get_clean_tail
  * Bivio::Biz::Action::EasyForm added file field upload

  Revision 4.30  2006/06/22 20:37:31  moeller
  * Bivio::SQL::Statement convert * in "like" to % for power users
    call quotemeta() when searching enum values

  Revision 4.29  2006/06/22 07:12:36  dobbs
  * Bivio::Biz::Model::WikiForm added name_type() to allow subclasses to
    override
  * Bivio::Delegate::SimpleTaskId added blog tasks
  * Bivio::Delegate::SimpleTypeError added blog errors
  * Bivio::HTML::Scraper added to_text() and modified html_parser_text()
    for easier testing
  * Bivio::MIME::Type added MIME suffix mappings for wiki markup and email
  * Bivio::Test::Language moved do_deviance() functionality into
    test_deviance() and removed do_deviance() function
  * Bivio::Type::FileName added get_suffix()
  * Bivio::Type::FilePath now subclasses Bivio::Type::FileName
  * Bivio::Type::WikiName added is_absolute_path()
  * Bivio::UI::HTML::Widget::Tag added want_whitespace declaration for
    pretty html rendering
  * Bivio::UI::Widget::List added empty_list_widget attribute

  Revision 4.28  2006/06/18 21:13:07  nagler
  * Bivio::ShellUtil->assert_not_general added
  * Bivio::Auth::Realm->is_general added
  * Model.UserRegisterForm->execute_ok requires password_ok to be set so
    that RealmOwner.password will be used (and password reset_task ignored).
  * Bivio::Biz::Model::RealmUserAddForm->copy_admins accepts parent_realm_id
  * Bivio::IO::Alert.strip_bit8 will strip chars 0x80 to 0xff from any
    info/warn/error output if set.
  * Bivio::UI::XHTML::ViewShortcuts->vs_descriptive_field applies row_*
    attributes instead of row_class to outer Join, e.g. row_class.
  * Bivio::UI::XHTML::ViewShortcuts->vs_actions_column added
  * Bivio::UI::HTML::Widget::ListActions accepts single value (SOME_TASK)
    as a configurable element which will get the label ListActions.SOME_TASK
    from the facade.  If the first element is a valid task name (upper case)
    only, you don't need to supply a label.
  * Bivio::Biz::Model::Club->create_realm added
  * Bivio::Biz::Random->string added
  * Bivio::Test::FormModel->inline_commit added
  * Bivio::Test::Unit->builtin_commit added
  * Bivio::Test::Language::HTTP->verify_table handles empty columns
  * Bivio::Test::Language->test_ok added
  * Bivio::Type::FileName->get_tail handles undef (returns '')

  Revision 4.27  2006/06/18 21:12:35  nagler
  *** empty log message ***

  Revision 4.26  2006/06/15 12:38:57  nagler
  * Action.WikiView doesn't die if neither StartPage nor DefaultStartPage exist
  * Model.UserLoginForm->unsafe_get_cookie_user_id added
  * Bivio::Biz::Random->bytes only uses /dev/random if it exists, else uses rand()
  * Bivio::Test::Language->do_deviance added.
  * Type.FileName->get_clean-base and get_base() added.  get_tail()
    now returns 'a' for '/a/'.
  * Model.UserCreateForm parses PE (professional engineer) correctly

  Revision 4.25  2006/06/12 21:52:38  aviggio
  * Bivio::Biz::Action::RealmMail->execute_reflector error fixed
  * Bivio::Biz::Model::ContactForm message field is now required
  * Bivio::Biz::Model::RealmFileList->delete added
  * Bivio::Biz::Model::RealmFileList allow sorting by realm_file_id
  * Bivio::Biz::Model::UserCreateForm use Random->hex_digits instead of
    time and format_ignore instead of IGNORE_PREFIX
  * Bivio::Biz::Random->hex_digits added
  * Bivio::ShellUtil->assert_not_root added which allows preventing some methods from executing for the root user
  * Bivio::Type::Email->format_ignore added
  * Bivio::Type::FilePath->join added

  Revision 4.24  2006/06/10 06:25:45  aviggio
  * Bivio::Biz::Action::RealmMail replaces ForumMail, split into two
    executes: receiving and reflecting
  * Bivio::Biz::Action::ForumMail replaced by RealmMail
  * Bivio::Delegate::SimpleTaskId reflects RealmMail change and adds
    FORUM_MAIL_REFLECTOR task
  * Bivio::Biz::Model::RealmMailBounce handle unable_parse correctly
  * Bivio::PetShop::Facade::PetShop defines FORUM_MAIL_REFLECTOR

  Revision 4.23  2006/06/09 20:40:36  dobbs
  * Bivio::Biz::Model::ForumUserList can now get the related User model
  * Bivio::Biz::Model::UserLoginForm now sets explicit html form field
    names to accommodate a bug in Firefox that could display the values
    of password fields
  * Bivio::Test::Language::HTTP no longer depends on URI::QueryForm for
    compatibility with perl 5.6

  Revision 4.22  2006/06/07 17:13:57  moeller
  * Bivio::Biz::ListModel new_anonymous defaults can_iterate to true
  * Bivio::SQL::PropertySupport allow literal identifiers in value lists
  * Bivio::Type::Number to_literal() removes leading 0s
  * Bivio::Util::HTTPConf added $timeout

  Revision 4.21  2006/06/02 02:18:03  dobbs
  * Bivio::Biz::Action::ForumMail now commits changes before sending
    messages because bounces may start getting returned before we're
    done sending messages.
  * Bivio::Biz::Model::MailReceiveDispatchForm->parse_recipient now dies
    with NOT_FOUND if recipient is not syntactically valid.
  * Bivio::Test::Language::HTTP added extra_query_params() and
    clear_extra_query_params() to allow tests to pass in extra
    information for testing, for example to control "today's" date.
  * Bivio::Test::PropertyModel now allows tests to specify
    compute_object or other directives in the attributes passed to the
    constructor.
  * Bivio::Type::DateTime now allows test code to override the current
    date and time by passing date_time_test_now as a query parameter.
  * Bivio::Type::ECService is no longer continuous so subclasses can
    remove one service without affecting another.
  * Bivio::Util::SQL->delete_realm_files() added to allow subclasses to
    override the deletion of files.

  Revision 4.20  2006/05/30 15:32:33  moeller
  * Bivio::Agent::HTTP::Reply added additional_http_headers config value
    which allows adding additional items to the HTTP header for every
    reply
  * Bivio::Delegate::Cookie issue a warning if the cookie contains
    duplicate keys

  Revision 4.19  2006/05/26 17:44:56  moeller
  * Bivio::UI::HTML::Widget::Style added execute(), can now be used as a
    top-level widget within a page
  * Bivio::Util::Disk doc afa0 status

  Revision 4.18  2006/05/24 20:27:34  dobbs
  * Bivio::BConf added admin_only_forum_email to realm role categories
    for use in announcement-style mail lists
  * Bivio::BConf filters SIGTERM and MaxClients warnings unless they
    exceed the standard count
  * Bivio::Biz::Model::UserLoginForm->assert_can_substitute_user() added
    so subclasses can relax the is_super_user() constraint for
    substitute_user()
  * Bivio::Test::Language::HTTP->verify_no_link() added
  * Bivio::Test::Language::HTTP->generate_local_email() removed
    deprecation warnings -- you now *must* pass a suffix for the address

  Revision 4.17  2006/05/23 18:38:50  nagler
  * Bivio::PetShop::BConf configures database as pet, not petdb.  You
    will need to rebuild your petshop databases with this new name or
    configure locally.
  * Bivio::Util::DarwinConfig->add_launch_daemon correctly configures
    daemon to start on boot.
  * Bivio::SQL::ListQuery->format_uri_for_any_list accepts optional new_attrs
  * Bivio::BConf->merge_http_log ignores File does not exist:*.php due
    to increase in php virii.

  Revision 4.16  2006/05/18 07:50:31  aviggio
  * Bivio::Agent::HTTP::Form use req->get_content
  * Bivio::Agent::HTTP::Reply added INPUT_TOO_LARGE
  * Bivio::Agent::HTTP::Request->get_content added and client_redirect
    handles hashes correctly
  * Bivio::Agent::Request task_id is not a required parameter to
    format_uri
  * Bivio::Agent::Task changed interface to execute_items to allow
    arbitrary format_uri args
  * Bivio::Biz::Action::DAV use req->get_content and s->{content} now a
    ref
  * Bivio::Biz::Action::MailReceiveStatus subclasses EmptyReply
  * Bivio::Biz::Action::RealmFile return 1 in unauth_execute
  * Bivio::Biz::Action::UserPasswordQuery use Random
  * Bivio::Biz::Action::WikiView copy default start page if not found
  * Bivio::Biz::Model::UserRegisterForm use Random
  * Bivio::DieCode added INPUT_TOO_LARGE
  * Bivio::Test::Language::HTTP->get_response added
  * Bivio::Test::Language test_log_output does nothing if not in eval
  * Bivio::Test::FormModel renamed methods new => new_unit, unit =>
    run_unit
  * Bivio::Test::ListModel renamed method unit => run_unit
  * Bivio::Test::PropertyModel renamed method unit => run_unit
  * Bivio::Test::Request run_unit works more independently
  * Bivio::Test::Unit don't new again in run_unit if already a ref
  * Bivio::UI::HTML::Widget::DateTime removed warning if no parent is
    set during initialize
  * Bivio::UI::HTML::Widget::Table use column_heading_class for sort
    headings
  * Bivio::Util::RealmFile added create, delete, list_folder, and read
  * Bivio::Util::SQL->create_test_user added

  Revision 4.15  2006/05/12 07:41:30  aviggio
  * Biz::Model::RealmFileTreeList->is_child_folder added
  * Bivio::Test::FormModel extended to support new unit tests, FileField
  * Bivio::Util::Disk added "task list" to afacli in the event the drive
    is rebuilding

  Revision 4.14  2006/05/11 01:28:07  nagler
  * Bivio::Util::Disk (b-disk) added.

  Revision 4.13  2006/05/09 21:10:42  dobbs
  * Bivio::Util::LinuxConfig generate_network() now generates only one
    GATEWAY= per net in /etc/sysconfig/network-scripts/ifcfg-eth0*

  Revision 4.12  2006/05/09 19:56:58  dobbs
  * Bivio::Util::LinuxConfig generate_network() now correctly names the
    file /etc/sysconfig/static-routes

  Revision 4.11  2006/05/09 19:35:06  dobbs
  * Bivio::Util::LinuxConfig generate_network() now correctly names the
    files generated in /etc/sysconfig/network-scripts

  Revision 4.10  2006/05/09 17:14:31  dobbs
  * Bivio::Util::HTTPConf generate() now supports 'aux_http_conf'
    directive to support multiple SSL addresses

  Revision 4.9  2006/05/08 19:31:50  dobbs
  * Bivio::Agent::HTTP::Request now considers all odd ports secure
  * Bivio::Biz::ListModel can now use 'auth_user_id' in the same way as
    'auth_id' to constrain a list
  * Bivio::SQL::ListSupport now supports auth_user_id declaration
  * Bivio::Test::Language::HTTP verify_local_mail() now looks for the
    recipient only in the mail header
  * Bivio::Test::Unit assert_eq() supports regexp_ref against strings
    and string_refs
  * Bivio::Test::Util mock_sendmail() now sets Return-Path mail header
  * Bivio::Util::LinuxConfig generate_network() added to support
    multiple ip addresses on a single network interface and also
    generates all network related config files -- see also the unit tests

  Revision 4.8  2006/05/05 17:24:21  moeller
  * Bivio::Util::HTTPLog fixed return value for parse_errors()

  Revision 4.7  2006/05/05 07:50:31  aviggio
  * Bivio::Biz::Random improved support for passwords
  * Bivio::Mail::Outgoing setting return-path calls set_envelope_from
  * Bivio::ShellUtil return result of lock
  * Bivio::Test::Language::HTTP visit_uri(undef) fails
  * Bivio::Util::HTTPLog->parse_errors lock action

  Revision 4.6  2006/05/03 05:31:28  aviggio
  * Bivio::BConf filter additional log records
  * Bivio::Biz::Model::RealmFile fix is_public handling for /Public
    folder and files
  * Bivio::Biz::Model::RealmFile fix is_read_only handling for /Mail
    folder and files
  * Bivio::Util::LinuxConfig sendmail will now drop double bounces

  Revision 4.5  2006/05/01 20:41:22  aviggio
  * Bivio::Biz::Model::Email->invalidate an email address
  * Bivio::Biz::Model::User moved email invalidate logic to
    Email->invalidate()
  * Bivio::Biz::Model 'missing key' trace replaced with a warning
  * Bivio::Delegate::SimpleTaskId calendar list rss view renamed
    calendar-event-list-rss
  * Bivio::Delegate::SimpleTaskId added FORUM_FILE
  * Bivio::Test::Unit->builtin_assert_eq added
  * Bivio::Test::Unit->builtin_create_user added
  * Bivio::Util::LinuxConfig added delete_file and replace_file
  * Bivio::Util::RealmMail->import_mbox added

  Revision 4.4  2006/04/26 17:10:36  dobbs
  * Bivio::IO::Config now looks for application specific configuration
    in /etc/bconf.d/<project>-only.bconf where <project> is taken from
    the basename of $BCONF

  * Bivio::Test::FormModel compute_params() no longer assumes
    $params->[0] is a hash_ref

  * Bivio::Test::HTMLParser::Tables find_row() no longer dies if a row
    doesn't have the value

  Revision 4.3  2006/04/21 23:47:12  aviggio
  * Bivio::Biz::ListFormModel changes to better support testing
  * Bivio::Biz::Model::UserCreateForm improved error when names not
    specified
  * Bivio::IO::ClassLoader major rewrite, renamed is_loaded =>
    was_required, unsafe_simple_require dies on syntax errors,
    unsafe_map_require added
  * Bivio::Test::FormModel support for testing ListFormModels
  * Bivio::Test::HTMLParser::Tables improved error for tables with no
    rows
  * Bivio::UI::HTML::Widget::SourceCode handle recursive symbolic links
  * Bivio::UI::ViewLanguage->call_method calls
    ViewShortcuts->view_autoload if the class or method can't be found
  * Bivio::UI::ViewShortcutsBase removed fixup_args and added
    view_autoload
  * Bivio::UI::Widget is_loaded => was_required
  * Bivio::UI::XHTML::ViewShortcuts added view_autoload which loads tags
    explicitly
  * Bivio::UNIVERSAL added use() and die()

  Revision 4.2  2006/04/18 06:37:03  aviggio
  * Bivio::Biz::Model::ForumForm refactored CREATE_REALM_MODELS to support subclasses

  Revision 4.1  2006/04/18 03:00:12  moeller
  * Bivio::Biz::ListModel fixed bug which assumed arg to new_anonymous()
    was HASH, it may be a CODEREF
  * Bivio::Mail::Address Added local delivery address (root) renamed
    from Address.t
  * Bivio::Test::Language::HTTP fix follow_link_in_table() to allow
    following link_text '0'
  * Bivio::Type::ForumName Added extract_bottom()

  Revision 4.0  2006/04/17 04:12:52  nagler
  NOTE: The following change is not consistent with previous releases.
  * Bivio::Biz::ListModel->internal_load_rows signature is now:
      my($self, $query, $stmt, $where, $params, $sql_support) = @_;
    $stmt is taking over for $where and $params.  Eventually, $where, $params,
    and $sql_support will go away.
  * Bivio::Biz::ListModel now generates all SQL dynamically which allows for
    easy creation of queries that convert to/from types automatically.
  * Bivio::SQL::ListSupport mostly rewritten to support dynamic statements.
  * Bivio::Mail::Address->parse_list added
  * Bivio::Mail::Common->TEST_RECIPIENT_HDR replaces RECIPIENTS_HDR.  In test
    mode, msgs are sent individually by Common->send and an X-Bivio-Test-Recipient
    header is added to allow Bivio::Test::Language::HTTP->verify_local_mail
    validate the recipients of group sends individually.
  * Bivio::Mail::Common.reroute_address removed.
  * Bivio::Mail::Outgoing->set_recipients requires $req; splits the recipients
    so they contain only addresses (see X-Bivio-Test-Recipient above).
  * Bivio::UI::XHTML::Widget::HelpWiki uses Constant.help_wiki_realm_id,
    instead of Text.help_wiki_realm_id.
  * Bivio::UI::Constant is a new facade component for constants.  It behaves
    like Bivio::UI::HTML in that you can compute values with code_refs attached
    to the values.
  * Bivio::Agent::Request->FORMAT_URI_PARAMETERS added.
  * Bivio::Biz::Model::RealmFile->update sets the user_id to auth_user_id
    by default, instead of keeping it the same.
  * Bivio::Test::HTMLParser::Forms->get_ok_button added.  There must be one
    and only one non-cancel button.
  * Bivio::Test::Language::HTTP->verify_local_mail allows explicit list of
    recipients instead of just a count
  * Bivio::Test::Language::HTTP->submit_form({...}) signature calls
    get_ok_button (see above) to find the ok button.
  * Bivio::UI::ViewShortcuts->vs_text accepts multiple/mixed widget values
    and strings, and will combine them into dotted form to find a qualified
    name.
  * Bivio::UI::Widget->render_simple_value added
  * Bivio::UI::XHTML::Widget::TaskMenu supports hash for elements of menu.
    Values are passed to URI, if 'uri' param not supplied.
  * Bivio::Util::Backup->mirror no longer passes -C to rsync so all files
    including CVS directories are copied.  This can fill up disk space,
    but CVS directories contain too much data to lose.
  *

  Revision 3.92  2006/04/07 23:56:52  aviggio
  * Bivio::Biz::Action::CalendarEventICS added
  * Bivio::Biz::Model::CalendarEvent->create_realm added
  * Bivio::Biz::Model::CalendarEventForm added
  * Bivio::Delegate::SimpleWidgetFactory added simple form case for Time types
  * Bivio::PetShop::Facade::PetShop modified for create_test_db
    bootstrap
  * Bivio::Type::Date added from_datetime
  * Bivio::Type::DateTime added from_date_and_time and is_time
  * Bivio::Type::Time added from_datetime
  * Bivio::UI::Widget::URI added internal_new_args

  Revision 3.91  2006/04/03 20:11:18  nagler
  * Bivio::Biz::Model::RealmFile creates MAIL_FOLDER and PUBLIC_FOLDER on the
    fly with appropriate permissions.  This is for all realms.  Forum no
    longer creates folders the folders at create time
  * Bivio::Biz::Model::RealmFile->init_realm added to create '/'
  * Bivio::Test::Language::HTTP->follow_link_in_table allows you to select
    a single link with $find_value even if there are multiple links in the
    cell as long as the $find_value matches exactly.
  * Bivio::Mail::Outgoing->set_headers_for_list_send $keep_to_cc added
  * Bivio::Biz::Action::ForumMail sets $keep_to_cc to true

  Revision 3.90  2006/04/03 04:08:17  nagler
  * Bivio::Biz::Model::UserRealmList/RealmUserList/ForumUserList subclass
    RoleBaseList which produces "roles" field.  UserRealmList is now
    order_by RealmOwner.name (previously unordered).
  * Bivio::Type::ForumName->is_top added
  * Bivio::UI::HTML::Widget::Tag.tag_if_empty must be true for the tag to
    render in the event the value is empty (null string).
  * Bivio::Biz::Model::RealmFileTreeList includes '/'
  * Bivio::UI::XHTML::ViewShortcuts->vs_alphabetical_chooser added.  This
    may break existing uses for XHTML users which were depending on
    old HTML behavior.  Check your code.
  * Bivio::UI::XHTML::ViewShortcuts->vs_paged* now put "pager" on view
    which can be inserted anywhere (twice, if need be).  This breaks
    previous paged behavior.
  * Bivio::UI::XHTML::Widget::TaskMenu label and control allowed for
    each task.
  * Bivio::UI::XHTML::Widget::Page3.title is rendered as a Prose value
  * Bivio::UI::XHTML::Widget::FormField.label is rendered as a Prose value
    no longer a string.
  * Bivio::Biz::Model::ForumUserList only loads default location emails

  Revision 3.89  2006/03/24 07:56:15  nagler
  * Bivio::SQL::ListQuery->DEFAULT_MAX_COUNT defines this value and
    Bivio::Biz::ListModel->LOAD_ALL_SIZE uses it by reference.  count
    will never be allowed to be larger than this when coming in from
    the request.  This is not likely to be used much, except perhaps
    with @ins-page (see below).
  * Bivio::Agent::Embed::Dispatcher->call_task lets you call any task
    from another task and get the result.
  * Bivio::Type::WikiText @ins-page uses call_task() to embed any page
    into a wiki.  Errors are no longer written to html, but are instead
    written to server log -- alternative is a potential security hole.
    Errors have line numbers now, and a bit improved.
  * Bivio::Agent::Reply is now a Bivio::Collection::Attributes.  This
    was a minor refactoring, because it and its subclasses were
    using fields before.
  * Bivio::Agent::HTTP::Reply refactored to new Reply interface
  * Bivio::UI::XHTML::Widget::BasicPage renamed from SimplePage to avoid
    collisions with HTML SimplePage
  * Bivio::UI::XHTML::ViewShortcuts->vs_paged_list puts table.list,
    not table.paged_list, because already in a div.paged_list.
  * Bivio::UI::Task->parse_uri was checking "facade" on $req, but
    should have been checking for "Bivio::UI::Facade".  This only
    seems to have an effect with Embed::Request.
  * Bivio::Agent::Request->internal_clear_current added.
  * Bivio::SQL::ListQuery fixed so it allows long names (e.g. this) to come
    in from the request (clean_raw() fixed), and count can be passed in.
  * Bivio::UI::HTML::Widget::Table.column_heading_class is gotten from
    data column unless set on column_heading widget already.
  * Bivio::Biz::Model::ForumTreeList.root_forum_id may be passed in, and
    if so, the tree is limited to that forum.

  Revision 3.88  2006/03/23 05:06:04  nagler
  * Bivio::UI::Widget::URI.format_method added.  Allows you to format_http,
    if you need to.
  * Bivio::UI::HTML::Widget::ControlBase.html_attrs added.  Allows you to
    render any attributes, e.g. for meta links in header.
  * Bivio::UI::XHTML::Widget::RSSPage added.  Allows you to render RSS feeds
    from ListModels.
  * Bivio::Delegate::SimpleWidgetFactory no longer defaults mode for
    DateTime widget, which was already defaulting the mode.
  * Bivio::UI::DateTimeMode.default and widget_default are configurable
    parameters for how DateTime formatter and widget behave.
  * Bivio::UI::HTML::{Widget,Format}::DateTime support RFC822, DAY_MONTH3_YEAR,
    and DAY_MONTH3_YEAR_TIME
  * Bivio::UI::HTML::Widget::Form.method now wrapped in quotes (for XHTML)
  * Bivio::UI::HTML::Widget::DateField->render calls to_html (was incorrectly
    calling to_literal)

  Revision 3.87  2006/03/22 06:18:06  nagler
  * Bivio::UI::ViewLanguageAUTOLOAD allows you to refer to widgets and
    ViewShortcuts in classes just like you can in bviews.  This is more
    than an optimization, because it enforces the behavior of view_shortcuts
    and view_class_map in widgets.
  * Bivio::UI::Widget->put_and_initialize only calls $self->initialize once.
    This
  * Bivio::UI::XHTML::Widget::HelpWiki.class is help_wiki (as an id)
  * Bivio::UI::XHTML::Widget::RoundedBox fixed to be subclass of Tag.  There's
    a div on the outside (rounded_box) and on the inside (body).
  * Bivio::UI::XHTML::Widget::TaskMenu added
  * Bivio::UI::HTML::Widget::Tag->control_on_render calls $self->render_tag_value
    if it can, otherwise renders "value" attribute
  * Bivio::UI::Widget->put_and_initialize only calls initialize once.  This
    codifies the concept that initialize() is idempotent without having all
    widgets protect themselves.  initialize() semantics were meant to be
    call once.
  * Bivio::UI::HTML::Widget::ControlBase->internal_compute_new_args added
    and all subclasses updated to new interface.  Old form of calling
    shift->SUPER::internal_new_args is deprecated, because it didn't allow
    sub-sub-classes to handle arguments properly.
  * Bivio::Test::Widget->new_params hook added

  Revision 3.86  2006/03/17 06:24:53  nagler
  * Bivio::Biz::Model::RealmFileTreeList->is_folder/file added
  * Bivio::Biz::Model::RealmOwner and Bivio::Biz::Model::UserLoginForm
    refactored to put login validation in RealmOwner.
  * Bivio::Biz::Model::WikiForm->execute_cancel added and execute_* validates
    names better
  * Bivio::Test::Language::HTTP.server_startup_timeout lets setup
    wait for remote server to start before continuing.
  * Bivio::UI::XHTML::Widget::RoundedBox added
  * Bivio::UI::Widget::Director accepts dynamic values
  * Bivio::Type::WikiText enhanced to support @p class="prose" only for
    non-enclosed paragraphs.  Also supports special chars (@&nbsp;)
  * Bivio::Biz::Action::WikiView->execute_help added
  * Bivio::UI::XHTML::Widget::WikiStyle inserts style tag in header if
    base.css exists in directory from which Wiki Page is rendered.
  * Bivio::UI::XHTML::Widget::HelpWiki inserts a RoundedBox with Wiki
    content on any page (including WikiStyle) insert
  * Bivio::Util::RealmFile->import_tree ignores CVS, *~, and .* files
  * Bivio::Biz::Action::RealmFile->unauth_execute added
  * Bivio::UI::Widget::Prose.value is now rendered dynamically.  If value is
    static, still rendered statically so will not affect prior behavior.

  Revision 3.85  2006/03/15 05:15:44  nagler
  * Various Wiki fixes
  * Bivio::Biz::Model::RealmFileTreeList uses path, not path_lc for links

  Revision 3.84  2006/03/15 04:16:13  nagler
  * Bivio::Biz::Model::WikiForm and Bivio::Biz::Action::WikiView added
    to create, edit, and view wiki pages.  Wiki pages are stored in the
    realm's files area in the /Wiki folder.  Bivio::Type::WikiName
    defines the wiki link syntax, and Bivio::Type::WikiText defines the
    page syntax, which includes access to a large subset of HTML 4.0.

  Revision 3.83  2006/03/10 22:59:05  david
  * Bivio::SQL::Statement fixes bug on rendering complex select columns

  Revision 3.82  2006/03/10 21:44:19  dobbs
  * Bivio::Test::Language::HTTP->generate_test_name to replace list
    context functionality removed from generate_local_email in bOP
    revision 3.78
  * Bivio::Test::Language::HTTP->verify_form now accepts a regexp for
    the expected value of a form
  * Bivio::UI::HTML::ViewShortcuts->vs_simple_form now accepts a
    hash_ref which is passed on to the internal Table widget
  * Bivio::UI::HTML::Widget::Page corrected spelling of uri for xhtml
    transitional dtd
  * Bivio::UI::XHTML::Widget::SimplePage added -- simpler version of Page3

  Revision 3.81  2006/03/08 22:00:38  david
  * Bivio::Agent::Request->format_email checks that the Email facade
    component exists before using it to format email
  * Bivio::SQL::Statement fixes a couple of bugs from Robs recent
    changes, especially with regards to using new_anonymous(CODEREF)

  Revision 3.80  2006/03/08 06:57:14  nagler
  * Bivio::SQL::Statement->union_hack is an attempt at supporting UNION which
    works, but will be modified in the future.  select() has been generalized.
    SELECT_AS() and SELECT_LITERAL() added.
  * Bivio::SQL::ListSupport refactored to support complete statements
    coming from internal_prepare_statement or internal_pre_load, but still
    allows paging.
  * Bivio::Biz::ListModel.want_page_count is configurable
  * Bivio::SQL::Support.sql_name is settable
  * Bivio::Biz::Model::ForumTreeList->parent_map added
  * Bivio::UI::HTML::Format::CalendarEventDescription added
  * Bivio::UI::Widget::URI added.  Calls req->format_uri with hash
    args rendered as values
  * Bivio::UI::XHTML::ViewShortcuts->vs_empty_list_prose added, and
    paged_detail.list.empty changed to empty_list_prose.  vs_*_list changed
    to use prose.
  * Bivio::UI::HTML::Widget::ListAction.format_uri can now be a widget, e.g.
    URI().

  Revision 3.79  2006/03/04 04:47:28  nagler
  * Bivio::Biz::Model::RealmMailBounce implements automatic bounce processing
    for Bivio::Biz::Action::ForumMail.  Bounces are stored in the database
    bound to a user and email.
  * Bivio::Mail::Outgoing->new accepts $self, and makes a copy of all fields
    except the body.  set_headers_for_list_send handles sender and
    return_path properly.
  * Bivio::Biz::Model::MailReceiveDispatchForm lets subclasses assume dashes
    in domain names.  Sets plus_tag as field.
  * Bivio::Biz::Model::RealmUserList->get_recipients accepts iterate handler
  * Bivio::Biz::Action::MailReceiveStatus->execute_forbidden added, and
  * Bivio::Delegate::SimpleTaskId added MAIL_RECEIVE_FORBIDDEN and
    USER_MAIL_BOUNCE
  * Bivio::Mail::Common->format_as_bounce has better format so bounce software
    can be tested more easily
  * Bivio::Util::SQL->internal_upgrade_db_mail_bounce added
  * Bivio::UI::XHTML::ViewShortcuts->vs_list and vs_table_attrs added.  All
    tables have odd/even classes for rows.

  Revision 3.78  2006/03/03 00:28:36  david
  * Bivio::SQL::PropertySupport support for RealmMailBounce
  * Bivio::Test::Language::HTTP->generate_local_email only returns the
    generated email, not the email/username pair when called in list context

  Revision 3.77  2006/03/02 06:18:01  aviggio
  * Bivio::Delegate::SimpleTaskId GENERAL_CONTACT task added
  * Bivio::Test::Language::HTTP support for email facade testing
  * Bivio::UI::Mail::Widget::Mailbox->internal_new_args added
  * Bivio::Util::Release preserve permissions

  Revision 3.76  2006/02/25 20:10:48  nagler
  * Bivio::Biz::Model::UserPasswordQueryForm->execute_ok subsumes code
    that was in validate so can be directly executed.

  Revision 3.75  2006/02/25 04:27:06  nagler
  * Bivio::Agent::Request->format_email uses Email facade component
  * Bivio::UI::Email is a new FacadeComponent that allows email formatting
    overrides.
  * Bivio::Mail::Outgoing->set_headers_for_list_send allows named parameters
    and sets To: to completely override any incoming context.
  * Bivio::Biz::Model::MailReceiveDispatchForm->internal_set_realm allows
    overrides for setting realm
  * Bivio::UI::Icon/View->initialize_by_facade return static references
    which are bound to facade.  Static facade components generalized with
    Bivio::UI::Email being one of them.
  * Bivio::UNIVERSAL->name_parameters converts positional to named params
  * Bivio::Util::LinuxConfig->delete_aliases added
  * Bivio::Biz::Model::UserCreateForm allows want_bulletin override

  Revision 3.74  2006/02/16 16:53:25  moeller
  * Bivio::Biz::Model::ECPayment Bivio::Biz::Model::RealmOwner corrected
    unsafe_get_model() to always return an instance
  * Bivio::Biz::Model::ForumEditDAVList Bivio::Biz::Model::ForumForm
    switch to Forum.forum_id
  * Bivio::SQL::Statement revert bad edit

  Revision 3.73  2006/02/14 17:40:58  nagler
  * Bivio::Biz::Model::ForumTreeList optimized a bit
  * Bivio::Biz::Model::RealmFileTreeList no longer passes query on leaf

  Revision 3.72  2006/02/14 07:44:05  nagler
  * Bivio::Biz::Model::TreeList added, and old TreeBaseListForm,
    TreeBaseList, and FullTreeBaseList deleted.  New interface uses
    links, which have memory for expanded nodes.
  * Bivio::Biz::Model::RealmFileTreeList upgraded
  * Bivio::UI::XHTML::ViewShortcuts->vs_tree_list_control split out of
    vs_tree_list
  * Bivio::SQL::ListQuery->format_uri added
  * Bivio::Biz::Model::UserForumList added
  * Bivio::Biz::Model::ForumTreeList/Form added
  * Bivio::Biz::Model::RealmFile.folder_id added to simplify tree views.
    No API changes.  folder_id is simply a denormalization
  * Bivio::Util::SQL->internal_upgrade_db_folder_id added

  Revision 3.71  2006/02/13 21:59:11  dobbs
  * Bivio::SQL::Statement fix typo in LIKE/ILIKE in-memory Enum search

  Revision 3.70  2006/02/11 05:39:08  nagler
  * Bivio::Biz::ListModel cleaned up use of empty_properties so is always a copy
  * Bivio::SQL::Statement->LIKE/ILIKE do an in-memory search on short_desc
    if the field is a Bivio:::Type::Enum
  * Bivio::SQL::Statement->NOT_LIKE added
  * Bivio::Biz::Model::*TreeList* and
    Bivio::UI::XHTML::ViewShortcuts->vs_tree_list added.  These routines
    allow you to build a tree view with collapsible nodes.  No examples
    in PetShop as yet, because API is still under development in other app.
  * Bivio::Biz::ListFormModel->set_cursor/set_cursor_or_die/LAST_ROW added
  * Bivio::UI::XHTML::Widget::Page3.style added
  * Bivio::UI::HTML::Widget::Table.column_*_class works now
  * Bivio::UI::HTML::Widget::ImageFormButton rewritten to look like Image
    and FormButton.  Not specifying the "field" is deprecated.

  Revision 3.69  2006/02/03 04:05:27  nagler
  * Bivio::Biz::Action::EasyForm added (see easy-form.btest and
    Bivio::PetShop::Util for an example)
  * Bivio::Test::Request->client_redirect added, but only takes effect
    if ignore_client_redirect is set
  * Bivio::Util::CSV->parse can read from input or takes a string (not
    just a ref)
  * Bivio::Biz::Model::RealmFile->append_content added as a convenience
    routine.  It is not more efficient than appending to get_content.

  Revision 3.68  2006/01/28 21:34:51  nagler
  * Rolled back 1.27 revision (bOP 3.58) of Bivio::Biz::Action::DAV,
    because it was to strict, and didn't allow proper traversals (user
    only needs read access to follow the path).

  Revision 3.67  2006/01/28 17:47:37  nagler
  * Bivio::Biz::Model::RealmMail->create was storing mail in folders
    without leading zeros (2006-1) after the 1/24 release.
  * Bivio-bOP.spec works with rpm 4.3

  Revision 3.66  2006/01/26 23:17:26  nagler
  * Bivio::Test::Language::HTTP->send_mail added
  * Bivio::Biz::Model::Forum.is_public_email and want_reply_to added with
    support to all the Forum forms and lists
  * Bivio::Util::SQL->internal_upgrade_db_job_lock and
    internal_db_upgrade_forum_bits added
  * Bivio::SQL::Statement supports "from" clause in anonymous models

  Revision 3.65  2006/01/26 17:38:04  moeller
  * Bivio::SQL::Connection increased database MAX_BLOB size to 0x4_000_000
  * Bivio::Test::HTMLParser::Cleaner match change to <br /> in
      UI/HTML/Widget/String

  Revision 3.64  2006/01/24 05:34:15  nagler
  * Bivio::Type::DateTime->from_literal supports full RFC822 date parsing
    including time zone.
  * Bivio::Mail::Incoming->get_date_time uses DateTime->from_literal
  * Bivio::Biz::Model::MailPartList added
  * Bivio::UI::HTML::Widget::Image supports any href, not just Icons
  * Bivio::UI::Widget::List moved from Bivio::UI::Text::Widget::List
  * Bivio::UI::HTML::Widget::String.hard_newlines convert generates
    proper XHTML
  * Bivio::Biz::Model::UserBaseDAVList added
  * Bivio::Biz::Model::UserForumDAVList subclasses above
  * Bivio::Biz::Model:RealmUserAddForm.other_roles allows arbitrary number
    of roles to be added per user

  Revision 3.63  2006/01/20 20:42:03  moeller
  * Bivio::Agent::Dispatcher calls Request->process_cleanup() when
    request has completed
  * Bivio::Agent::Request added process_cleanup() to do any work outside
    of the database commit
  * Bivio::Delegate::SimpleTaskId loosen up locks
  * Bivio::IO::File added temp_file() which returns the name of a
    temporary file which is automatically cleaned up when the request
    completes
  * Bivio::SQL::PropertySupport added JobLock to unused_classes
  * Bivio::ShellUtil calls Request->process_cleanup() when the request
    has completed
  * Bivio::UI::XHTML::ViewShortcuts added vs_paged_detail()
  * added Bivio::UI::HTML::Widget::ProgressBar
  * Bivio::Util::LinuxConfig _add_aliases needs to handle :include:/foo

  Revision 3.62  2006/01/19 21:46:05  nagler
  * Bivio::Biz::Model::EmailAlias added
  * Bivio::Biz::Model::MailReceiveDispatchForm checks for aliases if
    an email_alias_task is attr defined and exists in the facade.  Also
    manages ignore_task for ignored emails (see Type.Email for what is ignored).
  * Bivio::Delegate::SimpleTaskId configured with MAIL_RECEIVE_DISPATCH tasks
    that can be included completely by defining a few facade uris (see previous
    item).  See Bivio::Petshop::Delegate::TaskId and PetShop facade for details
  * Bivio::Agent::Task->unsafe_get_redirect added
  * Bivio::Agent::Task->execute_items accepts a TaskId name (upper case only)
    returned from the item.  It looks up an attribute by that name, first,
    however.
  * Bivio::Biz::Model::EditDAVList was calling row_update every row.
    Refactored to use Bivio::Util::CSV->parse
  * Bivio::UI::Task->has_* and is_defined_for_facade loosened up to allow the
    task to not exist in facade.
  * Bivio::UI::XHTML::ViewShortcuts->vs_paged_list added

  Revision 3.61  2006/01/18 20:55:19  dobbs
  * Bivio::Biz::Model::UserCreateForm name parsing now handles more suffixes
  * Bivio::SQL::Statement LT now correctly emits '<' (was '<=')

  Revision 3.60  2006/01/17 06:05:20  nagler
  * Bivio::Type::DateTime->get_parts replaces get_part (deprecated)
  * Bivio::Biz::{Model,Util}::RealmMail supports threaded mail archives
  * Bivio::Biz::Model::Website supports Type.Location-based URLs for realms
  * Bivio::Biz::Action::ForumMail updated to use Model.RealmMail
  * Bivio::Util::SQL->internal_db_upgrade_mail added to upgrade
    RealmFiles of forums to RealmMail
  * Bivio::Mail::Incoming->get_references added
  * Bivio::Test::PropertyModel simplifies testing of PropertyModels
    (see RealmMail.bunit)
  * Bivio::Biz::Model::UserLoginForm->validate_login accepts (and sets field to)
    login argument
  * Bivio::Biz::Model->new gets request off of $self if available and not
    supplied.
  * Bivio::Biz::Model::LocationBase->DEFAULT_LOCATION added
  * Bivio::Biz::Action::BasicAuthorization supports substitute user
  * Bivio::Test::Unit defers loading of class until requested by *.bunit

  Revision 3.59  2006/01/13 08:26:45  nagler
  * Bivio::Biz::Action::TouchCookie added

  Revision 3.58  2006/01/11 07:28:42  nagler
  * Bivio::Auth::Realm->equals added
  * Bivio::Agent::HTTP::Reply->unsafe_get_output added
  * Bivio::Agent::HTTP::Request->reset_reply added
  * Bivio::Biz::Model::UserTaskDAVList sets size on propfind so broken DAV client
    implementations (Novell and Apple) which cache getcontentlength from the
    directory list work with any task.
  * Bivio::Biz::Action::DAV loading was testing write permissions after executing
    the task.  While this wasn't a security hole (due to rollback on forbidden),
    it was doing work when it didn't need to.
  * Bivio::SQL::Statement->PARENS added

  Revision 3.57  2006/01/04 23:53:11  moeller
  * Bivio::Delegate::SimpleTaskId WebDAV calendar task is now accessible
    by normal members
  * Bivio::SQL::Statement add OR() method

  Revision 3.56  2005/12/28 07:13:19  nagler
  * Bivio::Biz::Action::ForumMail defaults reply-to to false
  * Bivio::Type::DateTime->is_date & set_local_time_part added
  * Bivio::Type::DateTime->from_literal parses XML dates (loosely)
  * Bivio::Type::DateTime various bugs fixed in local time, added ability to
    set timezone explicitly to some calls.
  * Bivio::Biz::Model::CalendarEvent with DAV and RSS support added
  * Bivio::UI::XHTML::Page3.page3_meta_info for extra header tags
  * Bivio::Util::CSV->parse and to_csv_text added
  * Bivio::Util::RealmAdmin->info and users added
  * Bivio::Biz::Model::RealmOwner->init_realm_type
  * Bivio::IO::File->foreach_line added

  Revision 3.55  2005/12/17 07:14:17  nagler
  * Bivio::Type::DateTime->get_next_year added
  * Bivio::Type::DateTime->to_dd_mmm_yyyy added
  * Bivio::Delegate::SimpleTaskId added DAV tasks
  * Bivio::Delegate::Role->FILE_WRITER added
  * Bivio::Biz::Model::RealmFileDAVList ignores dot files

  Revision 3.54  2005/12/13 23:33:45  aviggio
  * b-perl-agile.el updates to b-perl-project-prefix and
    b-perl-insert-method-usage Emacs functions
  * Bivio::Biz::Model::Forum, ForumUserAddForm,
    ForumUserEditDAVList, RealmUserAddForm modified to support
    multiple realm roles (admin and mail recipient)
  * Bivio::Biz::Model::RealmFileDAVList fixed improper setting
    of getlastmodified property

  Revision 3.53  2005/12/12 03:10:50  nagler
  * Bivio::Type::FileName/Path->ILLEGAL_CHAR_REGEXP added
  * Bivio::Biz::Action::ForumMail drops more illegal chars for the file name

  Revision 3.53  2005/12/12 03:10:50  nagler
  * Bivio::Type::FileName/Path->ILLEGAL_CHAR_REGEXP added
  * Bivio::Biz::Action::ForumMail drops more illegal chars for the file name

  Revision 3.52  2005/12/10 20:06:07  nagler
  * Bivio::Biz::Model::ForumList needs to override type of
    RealmOwner.name to ForumName

  Revision 3.51  2005/12/10 18:49:45  nagler
  * Bivio::Biz::Model::RealmEmailList was broken
  * Bivio::Biz::Action::ForumMail was broken
  * Fixed some POD errors
  * PetShop tests updated and UserTaskDAVList allows 3 & 4 char file suffixes

  Revision 3.50  2005/12/10 07:15:11  nagler
  * Bivio::Biz::Model::RealmFile correctly passes override_is_read_only
    to created parent folders
  * Bivio::Biz::Model::UserRealmDAVList and UserForumDAVList communicate
    about RealmOwner.name which has to be a ForumName

  Revision 3.49  2005/12/10 05:47:31  nagler
  * Bivio::BConf->merge_realm_role_category_map added
  * Added following models ForumForum, RealmUserList,
    RealmUserAddForum, RealmUserDeleteForum, ForumUserAddForum,
    ForumUserDeleteForum, and RealmEmailList, RealmAdminList, ForumUserEditDAVList
    EditDAVList, ForumEditDAVList
  * Bivio::Test::ForumUserUnit added
  * Bivio::Biz::Model::UserForumDAVList allows tasks to be included
  * Bivio::Biz::Model::UserRealmDAVList uri and displayname are same
  * Bivio::Biz::FormModel->update_model_properties accepts simple pkg name
  * Bivio::Biz::Action::ForumMail added
  * Bivio::MIME::Type->unsafe_from_extension and text/csv added
  * Forums can now have children
  * RealmFile supports is_read_only and is_public (correctly)
  * Bivio::Type::ForumName added
  * Bivio::Type::FormMode added (used by ForumForm)
  * Bivio::Biz::Action::DAV returns complete lock response;
  * Bivio::Type::DateTime->to_local_file_name added
  * Bivio::Test::FormModel allows imperative cases also calls
    clear_nondurable_state in compute_params
  * Bivio::Biz::FormModel->process doesn't require $req
  * Bivio::Util::DAV/b-dav added
  * Bivio::Util::RealmAdmin->leave_user delete all roles
  * PetShop has forums available via DAV

  Revision 3.48  2005/12/08 19:07:58  moeller
  * Bivio::Agent::Job::Request refactored
  * Bivio::Agent::Request show GENERAL in as_string
  * Bivio::Auth::Realm as_string shows entery realm
  * Bivio::Biz::Action::UserPasswordQuery fix bug when reseting password
    without a site cookie, no longer validates cookie in UserLoginForm
  * Bivio::Biz::Model::UserLoginForm added disable_assert_cookie field
    so cookie is not validated in some cases
  * Bivio::Delegate::SimpleTaskId added
    DEFAULT_ERROR_REDIRECT_MISSING_COOKIES
    USER_PASSWORD redirects FORBIDDEN errors to the missing cookies task

  Revision 3.47  2005/12/06 20:03:01  moeller
  * Bivio::Agent::Request named args are no longer directly modified in
    calls to redirect() and format_uri() methods
  * Bivio::Auth::PermanentSet added clear() method
  * Bivio::Biz::Action::ECCreditCardProcessor warn when result_code 3
  * Bivio::Biz::Model::RealmFile supports is_read_only and is_public (correctly)
    and no longer supports volumes, instead files are stored in known directories
    (Public, Mail, etc.).
  * Bivio::Biz::File stores site wide files (outside the concept of a
    facade's local files).  The default location is /var/db/<prefix>.
  * Bivio::Biz::Model::RealmFile stores its files using Bivio::Biz::File
  * Bivio::Biz::Model::RealmFileList replaces RealmFile->map_folder
  * Bivio::Biz::ShellUtil->piped_exec traces output a line at a time when
    $_TRACE is true.
  * Bivio::Biz::Model->unsafe_get_model avoids loading from the database
    when all the fields of  PropertyModel are available from the parent
    model.
  * Bivio::Biz::Model->internal_load_properties loads a model from a hash_ref
  * Bivio::Biz::Model->internal_unload unloads a model
  * Bivio::Biz::Action no longer deletes object before copy, and only
    deletes on move if exists
  * Bivio::Biz::Action::RealmFile uses new Model.RealmFile interface.
  * Bivio::Biz::Model::RealmFileDAVList uses new RealmFile
  * Bivio::Test::Case->as_string calls as_string on the object if it can to
    help identify tests better
  * Bivio::Type::Enum->get_list is sorted by as_int
  * Bivio::Type::Enum->eq_<identifier> is equivalent to
    equals_by_name('<identifier>').
  * Bivio::Test::FormModel allows end-to-end testing of FormModels.  See
    ForumForum.bunit as example (may not be in this release, but will be
    soon!)

  Revision 3.46  2005/11/22 02:04:09  nagler
  * Bivio::Collection::Attributes->are_defined added
  * Bivio::Type::Text64K isa Bivio::Type::Text

  Revision 3.45  2005/11/21 18:09:49  nagler
  * Bivio::Biz::Action::DAV was removing folder if overwrite was set
    on copy and move

  Revision 3.44  2005/11/17 17:47:10  nagler
  * Bivio::Util::SQL->format_email added
  * Bivio::Delegate::SimpleTaskId.USER_PASSWORD.next is MY_SITE (was SITE_ROOT)
  * Bivio::Delegate::SimpleTaskId.GENERALUSER_PASSWORD_QUERY.cancel is SITE_ROO

  Revision 3.43  2005/11/17 03:22:57  nagler
  * Bivio::Biz::Model::UserRealmDAVList added
  * Bivio::Biz::Model::UserForumDAVList added
  * Bivio::Biz::Model::UserTaskDAVList added
  * Bivio::Biz::Model::AnyTaskDAVList added
  * Bivio::Agent::Request->task_ok deleted
  * Bivio::Type::Enum->format_short_desc added
  * Bivio::Biz::Model::RealmFileDAVList preserves case properly
  * Bivio::Biz::Action::DAV supports any task execution via AnyTaskDAVList
  * Bivio::PetShop allows you to brows orders via DAV.

  Revision 3.42  2005/11/15 20:48:20  nagler
  NOTE: Model.t is failing, but will be fixed shortly
  * Bivio::Biz::ListModel->unauth_parse_query/unauth_iterate_start added
  * Bivio::Agent::Task->execute_items calls items on a task, and returns
    redirect.
  * Bivio::Biz::Action::DAV redesigned to interface via Tasks.  Effectively,
    Action.DAV->execute is a dispatcher loop.
  * Bivio::SQL::Statement->NOT_IN added
  * Bivio::Util::LinuxConfig->add_aliases/virtusers added
  * Bivio::Type::EnumSet->to_array added
  * Bivio::Biz::Model::DAVList added

  Revision 3.41  2005/11/10 23:16:34  nagler
  * Bivio::UI:Task dynamically computes site_root by finding GENERAL
    task with /* as URI.
  * Bivio::Biz::Model::RealmFile->copy_deep accepts a query
  * Bivio::Biz::Model::RealmFile->get_* accepts (model, prefix) args so
    other lists can use (RealmFileDAVList)
  * Bivio::Biz::ListModel->unsafe_load_this added
  * Bivio::Biz::Action::DAV redesigned to interface with lists that support
    dav_* interface (RealmFileDAVList)
  * Bivio::Biz::Model::RealmFileDAVList added
  * Bivio::Biz::PropertyModel query/values arguments are copied
  * Bivio::Auth::Realm->does_user_have_permissions added
  * Bivio::Type::EnumSet->from_array added
  * Bivio::UI::Task->parse_uri no longer throws NOT_FOUND if USER_HOME is
    not found.  Rather returns SITE_ROOT.
  * Bivio::SQL::Statement allows FUNCTION(Model.column) format for colums

  Revision 3.40  2005/11/09 21:04:14  moeller
  * Bivio::Biz::Action::DAV no longer descendent of Action.RealmFile
  * Bivio::Biz::Model::Forum allow multiple admin_ids
  * Bivio::Biz::QuerySearchBaseForm checks defined($value) to see if
    value is present, allows boolean query arguments
  * Bivio::Biz::Model::RealmFile map_folder was broken
  * Bivio::Biz::Util::RealmRole can't lock the realm

  Revision 3.39  2005/11/08 02:49:00  nagler
  * Bivio::Biz::Action::DAV PROPFIND only returns public files is is_public
  * Bivio::Biz::*Model->merge_initialize refactored to remove complexity
    and to allow visible/hidden/other to be managed properly between
    parent and child.
  * Bivio::Biz::Model::RealmFile->map_folder* supports $query instead of
    just is_public
  * Bivio::Delegate::SimpleRealmName->REGEXP defined to allow overrides of
    the pattern used for RealmNames
  * Bivio::UI::HTML::Widget::Select->render calls get_field_type on
    field value so comparison works for any type
  * Bivio::UI::XHMTL::ViewShortcuts->vs_list_form clears label attribute
    if field does not have one -- avoids labelling checkboxes in a column

  Revision 3.38  2005/11/01 08:49:44  nagler
  * Bivio::Biz::Action::BasicAuthorization supports WWW-Authenticate/Authorization
  * Bivio::Biz::Action::DAV tests authorization (hardwired to ADMINISTRATOR
    and MEMBER for now)
  * Bivio::Biz::Model::UserLoginForm->validate accepts user/password as args
  * Bivio::Biz::Util::HTTPConf.limit_request_body added
  * Bivio::Type::FilePath (RealmFile)
  * Bivio::Biz::Model::UserRealmList cannot iterate (can_iterate was incorrect)
  * Bivio::Biz::Model::RealmFile->delete/copy_deep
  * Bivio::Test::Util->mock_sendmail looks up MAIL_RECEIVE_DISPATCH uri correctly
  * Bivio::Delegate::Role->MAIL_RECIPIENT added
  * Bivio::Test::Language::HTTP->basic_authorization added
  * Bivio::Test::Language::HTTP->send_request and absolute_uri added so you can
    make arbitrary web requests (see dav.btest)
  * Bivio::Agent::HTTP::Reply only calls set_last_modified if Last-Modified not set

  Revision 3.37  2005/10/28 20:48:02  nagler
  * Bivio::Util::Shell/b-shell enables batch execution of shell
    utilities.  Here's an example:
      b-shell batch <<'EOF'
      HTTPPing(page => 'http://www.bivio.biz');
      page('http://www.bivio.com');
      EOF
    The first use of a ShellUtil (map_required) imports it and changes
    the "name space" to that method.  You can switch back and forth
    between various utilities easily, and you save load time.  Another
    use is for rpm spec files:

      %pre -p b-shell batch
      LinuxConfig();
      add_user('joe:29');
      add_user('mary:30');
  * Bivio::Delegate::SimpleTaskId->ADM_SUBSTITUTE_USER includes a
    view (adm-substitute-user.bview).
  * Bivio::Biz::ListModel->is_loaded is added.

  Revision 3.36  2005/10/27 20:14:44  moeller
  * Bivio::Biz::FormModel restored validate_greater_than_zero(),
    validate_not_negative() and validate_not_zero () behavior to accept
    undef values
  * Bivio::Biz::ListFormModel renamed load_from_model_properties() to
    load_from_list_model_properties(), so superclass behavior is not
    changed.
  * Bivio::Util::RealmAdmin join_user calls from_name instead of direct
    call

  Revision 3.35  2005/10/27 06:56:17  nagler
  * Bivio::Biz::Action::DAV escapes displayname
  * Bivio::Util::RealmFile->import_tree does create or update

  Revision 3.34  2005/10/27 05:58:31  nagler
  * Bivio::Biz::Action::DAV->execute sets any online admin for realm
    (Don't use this on production just yet, because there's no security.)
  * Bivio::Biz::Model::Forum->create_realm creates root folder

  Revision 3.33  2005/10/27 03:33:32  nagler
  * Bivio::Biz::Action::DAV is a class 2 web dav server that's mostly
    working.  We'll be updating it over the time.
  * Bivio::Biz::Model::RealmFile has been fleshed out.  Supports
    everything except folder moves/deletes correctly.
    creation_date_time is now modified_date_time.
  * Bivio::Type::FilePath->to_os is gone.   RealmFiles are stored
    without path.  Makes easier for renames.
  * Bivio::Type::DateTime->from_literal supports rfc822 format.
  * Bivio::UI::Text::Widget::String can render scalar_refs.
  * Bivio::Agent::Test::Request->commit added.
  * Bivio::SQL::Statement/ListSupport expanded to allow DISTINCT and
    nested left joins.
  * Bivio::PetShop has a DAV task that doesn't authenticate right now.
  * Bivio::Ext::ApacheConstants->MULTI_STATUS added
  * Bivio::DieCode->INVALID_OP added
  * Bivio::Biz::PropertyModel->internal_prepare_query added.  Allows you
    to twiddle the query before it its PropertySupport.
  * Bivio::Delegate::SimpleRealmName/RealmOwner
  * Bivio::Biz::ListFormModel->load_from_model_properties added.
  * Bivio::Biz::Action::UserPasswordQuery->execute fixed to not redirect
    with context.
  * Bivio::Agent::Reply/HTTP::Reply return $self on more methods.
  * Bivio::Agent::Reply maps CORRUPT_QUERY, CORRUPT_FORM, and INVALID_OP
    to BAD_REQUEST.

  Revision 3.32  2005/10/25 17:50:07  moeller
  * Bivio::Auth::Realm calls lc() on owner_name in new()
  * Bivio::Biz::Model::RealmOwner no longer calls lc() on name,
    uses Bivio::Type::RealmName->from_literal() to do this
  * Bivio::Biz::Model::UserLoginForm->validate_login no longer emulates
    Type::RealmName by stripping spaces and calling lc()
  * Bivio::Delegate::SimpleRealmName now calls internal_lc() to covert
    name to lowercase. Allows overrides by subclasses.
  * Bivio::Test::HTMLParser::Forms set default error_class to match
    XHTMLWidget.FormFieldError _start/end_font -> _start/end_maybe_err which
    also checks spans and divs

  Revision 3.31  2005/10/24 22:02:36  nagler
  * Bivio::Biz::Model::RealmFile->create downcases path_lc
  * Bivio::Util::RealmFile->import_tree works
  * Various tests have been fixed

  Revision 3.30  2005/10/24 20:54:13  nagler
  * Bivio::Biz::FormModel->validate_greater/* return false if validation fails
  * Bivio::Test::Language::HTTP->generate_local_email deprecates the no params
    call.  Use generate_local_email(random_string()) if you really want a random
    email address.  Better to write a test like PetShop/Test/t/password.btest
    which reuses the user for every test.
  * Bivio::Test::Language::HTTP->unsafe_op wraps Die->catch
  * Bivio::Test::Language::HTTP->default_password returns standard test password
  * Bivio::Test::Language::HTTP->random_string returns a random 8 char string
  * Bivio::Test::Language::HTTP->verify_content_type asserts mime type
  * Bivio::UI::XHTML::Widget::Page3->new adds a "top" anchor
  * Bivio::Agent::Request->server_redirect adds $req->query if not already set
  * Bivio::Agent::Task->execute supports task item return values of the
    form: "server_redirect.<task>" where <task> is a task attribute or task name.
  * Bivio::Agent::Task->execute no longer supports arbitrary true return
    values.  Must be 1 or task/attribute.  This behavior was deprecated fro
    some time.
  * Bivio::Biz::Action->put_on_request accepts a $durable param.
  * Bivio::Biz::Action::UserPasswordQuery and Model.UserPasswordQueryForm replace
    UserLostPasswordForm, and integrates with Model.UserPassword.
  * Bivio::Biz::Model::RealmOwner->update_password added
  * Bivio::Delegate::SimpleTaskId added PASSWORD support tasks.  The view names
    are recommended, but not required.  For best results, use the names specified
    in the tasks to avoid denormalizing tasks in app TaskId files.
  * Bivio::Delegate::SimpleTypeError->PASSWORD_QUERY_SUPER_USER added.  Super
    users can't request password resets
  * Bivio::Test::Util->mock_sendmail no longer requires Facade
  * Bivio::UI::ViewShortcuts->vs_site_name added from HTML::ViewShortcuts
  * Bivio::PetShop::* supports password reset
  * Bivio::ShellUtil allows literals for option defaults
  * Bivio::Agent::Reply->set_output allows IO::File
  * Bivio::Biz::Model::RealmFile supports longer file names (500), is_public,
    and user_id
  * Bivio::Biz::Action::RealmFile returns files like LocalFilePlain
  * Bivio::Util::RealmFile (b-realm-file) allows you to import a file tree
  * Bivio::PetShop::Util (b-petshop) integrates with create_test_db
  * Bivio::PetShop supports realm files and reset password
  * Bivio::Util::HTTPConf (b-http-conf) supports facade_redirects

  Revision 3.29  2005/10/20 21:03:54  moeller
  * Bivio::Biz::Util::ListModel->csv() fixed multi-line column output

  Revision 3.28  2005/10/20 04:11:59  nagler
  * Bivio::ShellUtil->detach_process makes an effort at detaching the
    process from the controlling terminal.  It forks, parent exits, and
    child closes STD* and calls POSIX::setsid.  This will detach on most
    modern Unixen including MacOS.
  * Bivio::ShellUtil -email doesn't cause initialize_ui.
  * Bivio::Agent::Request->format_email checks for existence of a
    facade to get the mailhost.  If not available, uses hostname.  This
    allows command line utilities to work without a UI, and for
    web-based emails to be formatted properly in multi-hosted/facade
    environments.

  Revision 3.27  2005/10/18 22:13:19  nagler
  * Bivio::BConf update to include Bivio::UI::Text::Widget in MailWidget
    map, because Bivio::UI::Mail::Link moved to Bivio::UI::Text::Link in the last
    release.

  Revision 3.26  2005/10/17 23:48:37  nagler
  * Bivio::UI::Widget::Join->render inserts separator correctly with null elements
  * Bivio::Type::PrimaryId->is_specified returns false if is
    Bivio::Biz::ListModel->EMPTY_KEY_VALUE

  Revision 3.25  2005/10/17 21:20:33  nagler
  * b-perl.el and b-perl-agile.el bind C-c ; as comment-or-uncomment-region.
    A few other fixes to new style.
  * realm_user_t6 (ddl/bOP-constraints.sql) checks role > 0.
  * Bivio::Auth::Realm->has_owner added -- same as ! is_default, but clearer
  * Bivio::Auth::RoleSet calls initialize so works now
  * Bivio::BConf includes XHTMLWidget map
  * Bivio::Biz::Action::Acknowledgement->save_label stores value in
    req.form_model's context if defined.
  * Bivio::Biz::Model::UserLostPasswordForm->execute_empty added
    (logs in via creds in query)
  * Bivio::Collection::Attributes refactored to reuse put/get/delete/delete_all
    instead of inlining all manips.  Allows more overrides.
  * Bivio::Collection::Attributes->put_unless_exists added
  * Bivio::Delegate::SimpleRealmName->unsafe_from_uri downcases uri
  * Bivio::SQL::PropertySupport.unused_classes is config that allows you
    to avoid adding new property models (which are autoloaded) when they
    are added to bOP.
  * Bivio::SQL::Statement->NE added.
  * Bivio::Test::Widget->new_unit allows class_name override.
  * Bivio::UI::HTML::ViewShortcuts->view_ok works when Bivio::UI::View
    isn't loaded.
  * Bivio::UI::HTML::Widget::FormButton fixed to be XHTML compatible and dynamic
  * Bivio::UI::HTML::Widget::FormFieldLabel is dynamic
  * Bivio::UI::HTML::Widget::Grid.cell_class and row_class are dynamic
  * Bivio::UI::HTML::Widget::ImageFormButton is XHTML compatible
  * Bivio::UI::HTML::Widget::Table.heading_separator not rendered by
    default if XHTML
  * Bivio::UI::HTML::Widget::Tag->initialize no longer wraps value as String
  * Bivio::UI::View->call_main added
  * Bivio::UI::Widget::ControlBase->render resolves control recursively
    and no longer considers a constant control of "0" or "" to be true.
    Refactored to evaluate dynamically.
  * Bivio::UI::Widget::If refactored to be dynamic
  * Bivio::Util::SQL->internal_upgrade_db_forum added
  * Bivio::Type::Location->get_default calls from_int(1)
  * Bivio::Biz::Model::LocationBase uses get_default instead of HOME
  * Bivio::Biz::Action::ECSecureSourceProcessor and
    Bivio::Biz::Model::UserCreateForm no longer refer to location explicitly

  Revision 3.24  2005/10/10 23:08:00  nagler
  * Bivio::SQL::PropertySupport.unused_classes allows you to avoid db
    upgrades when new tables are added to bOP.  cascade_delete fails,
    otherwise.  The default unused_classes is [qw(RealmFile Forum)].
    See Bivio::PetShop::BConf for how to override.
  * Bivio::Type::Location->get_default added, and
    Bivio::Biz::Model::LocationBase uses it instead of hardwired HOME.
    Remove other references to get_default/HOME in Action.ECSecureSourceProcessor,
    Model.Email, and Model.UserCreateForm.

  Revision 3.23  2005/10/10 22:21:14  moeller
  * Bivio::UI::HTML::Widget::Image fixed escape of icon uri

  Revision 3.22  2005/10/10 05:01:08  nagler
  * Bivio::UI::Task->parse_uri/format_uri use Type.Realm->unsafe_from_uri
    which allows '-' as a valid uri RealmName.  This change is backwards
    compatible, because would otherwise have gotten NOT_FOUND exception.
    Cleaned up some of the indentation, too.
  * Bivio::Delegate::SimpleRealmName->unsafe_from_uri added
  * Bivio::Biz::Model->is_instance added
  * Bivio::Biz::Model::RealmFile->delete_all allows realm_id in query
  * Bivio::Util::SQL->init_realm_role will copy permissions of CLUB to
    FORUM if Bivio::Auth::RealmType->FORUM exists
  * Bivio::Delegate::RealmType->FORUM added
  * Bivio::Delegate::SimpleTaskId->FORUM_HOME added
  * Bivio::Delegate::SimpleTypeError->FILE_PATH added
  * Bivio::Test::Type->UNDEF added

  Revision 3.21  2005/10/08 04:07:00  moeller
  * Bivio::ShellUtil fix deprecated call to $msg->send()

  Revision 3.20  2005/10/07 20:09:17  nagler
  * Bivio::UI::HTML::Widget::FormButton is fixed.

  Revision 3.19  2005/10/06 18:39:43  nagler
  * Bivio::UI::HTML::Widget::Page puts xhtml on request if it has xhtml
    as an attribute
  * Bivio::UI::HTML::ViewShortcuts->vs_xhtml checks html on request
  * Bivio::UI::HTML::Widget::Table will not set alignments or add
    extra padding if xhtml
  * Bivio::UI::HTML::Widget::Table includes image in link for sorting
  * Bivio::UI::HTML::Widget::Image/FormButton refactored to be fully
    dynamic and support xhtml.  If vs_xhtml Image will use src as
    class if not already has class.
  * Bivio::IO::Ref uses Algorithm::Diff::diff if available to print
    differences on multi-line strings
  * Bivio::UI::Widget->resolve_ancestral_attr is useful for getting
    form_model
  * Bivio::UI::Widget->render_simple_attr converts attribute to defined
    (but possibly empty) string always
  * Bivio::UI::Facade->get_from_request_or_self accepts anything that
    can get_request
  * Bivio::Type::DateTime->set_local_beginning_of_day added
  * Bivio::Test::Unit->builtin_req added.  req() now works for all
    bunit tests.
  * Bivio::Test::Unit->builtin_config calls Bivio::IO::Config->introduce_values
  * Bivio::Test::Language::HTTP->verify_local_mail wasn't waiting for
    all msgs to come in before failing
  * Bivio::Mail::Common->RECIPIENTS_HDR added, and it is added to all
    outgoing message if $req->is_test
  * Bivio::Agent::TaskId->handle_commit/rollback get $req
  * Bivio::Biz::List(Form)Model->is_empty_row tests primary keys equal to
    EMPTY_KEY_VALUE. Bivio::Biz::ExpandableListFormModel->is_empty_row
    adjusted to take into that account.
  * Bivio::Biz::Action::Acknowledgement->save/extract_label will default
    the label to the TaskId->as_int if label is undef.
  * When Bivio::Biz::FormModel->validate_and_execute_ok is called,
    Action.Acknowledgement->save_label will be called.
  * Bivio::Mail::Common/Outgoing->*send* require $req (deprecated)

  Revision 3.18  2005/10/06 18:18:06  nagler
  * Bivio::IO::Ref uses Algorithm::Diff::diff if available to print
    differences on multi-line strings

  Revision 3.17  2005/10/03 20:52:58  nagler
  * Perl 5.8.6 (on darwin at least) seems to have a defect loading dynamic
    libraries inside multiple evals.  Added use of Image::Size and
    HTML::Parser in Bivio::IO::Config to avoid problems.
  * Bivio::ShellUtil::*email* routines refactored to share code
  * Bivio::Test::Unit->email returns email address for testing
  * Bivio::Test::Language->test_name returns the script base name
  * Bivio::Delegate::SimpleTaskId.TEST_BACKDOOR allows you to call any
    FormModel with arguments if TEST_TRANSIENT is true.  See
    test-backdoor.btest in PetShop.
  * Bivio::Test::Language::HTTP->do_test_backdoor is API for TEST_BACKDOOR
  * Bivio::Delegate::SimplePermission.MAIL_READ/WRITE/SEND/POST added
  * Bivio::Util::SQL sets MAIL_* on standard realms

  Revision 3.16  2005/09/30 16:58:02  moeller
  * Bivio::UI::HTML::Widget::DateField fpc - now works in list forms
    again
  * Bivio::Test::Util if no MAIL_RECEIVE_DISPATCH, build bogus URL,
    which will fail
  * Bivio::ShellUtil, Bivio::Biz::Action::AdmMailBulletin fix deprecated
    Mail calls

  Revision 3.15  2005/09/29 04:42:18  nagler
  * b-test/Bivio::Test::Util->mock_sendmail bypasses sendmail so
    acceptance tests run without a local MTA.  This is the default
    sendmail in the "dev" environment for Bivio::Mail::Common as
    set in Bivio::BConf->dev.   Most of the bivions are using
    Mac OS X for development, and now we can test apps which use
    MailReceiveDispatchForm locally.
  * b-realm-role/Bivio::Biz::Util::RealmRole->edit_categories enables
    named complex realm/role grant/revoke operations.  Configuration
    resides in BConf as a lambda/code_ref, e.g.
          'Bivio::Biz::Util::RealmRole' => {
              category_map => sub {
  		return [[
  		    public_forum => [
  			[qw(ANONYMOUS USER WITHDRAWN)] => 'DATA_WRITE',
  		    ],
  		], [
  		    semi_public_forum => [
  			USER => 'DATA_WRITE',
  		    ],
  		]];
  	    },
          },
    Calling b-realm-role edit_categories +public_forum turns on
    DATA_WRITE for ANONYMOUS, USER and WITHDRAWN.
    b-realm-role edit_categories -public_forum clears DATA_WRITE
    for all three roles.
  * Bivio::Test::Language::HTTP.remote_mail_host added.
  * Bivio::Mail::Common->format_as_bounce exposes bounce generation
    for mock_sendmail.
  * Bivio::Mail::Common/Outgoing/Incoming refactored to more modern
    style.  A few more tests added.
  * Bivio::Mail::Outgoing->set_from_with_user requires $req; old
    form deprecated.
  * Bivio::Mail::Outgoing->add_missing_headers inserts Date, Message-ID,
    From, and Return-Path, just like an MTA, for mock_sendmail.
  * Bivio::Mail::Outgoing->unsafe_get_header returns header values
  * Bivio::Mail::Outgoing->unsafe_get_recipients returns the string
    of recipients. (set_recipients now joins recipients instead of
    deferring to Common.)
  * Various minor bugs fixes (e.g. Grid colspan was bad)

  Revision 3.14  2005/09/29 03:35:05  moeller
  * Bivio::UI::HTML::Widget::Grid fix bug in colspan

  Revision 3.13  2005/09/28 03:27:30  moeller
  * Bivio::UI::HTML::Widget::ImageFormButton sets "name" and "id" attributes
    to allow access from javascript. <input type=image ...> items do not
    exist in javascript form.elements

  Revision 3.12  2005/09/27 16:34:47  nagler
  * freiker.org is using XHTML syntax.  Source will be available at some
    point.
  * Bivio::Biz::ListModel->find_row_by allows you to find a row by a
    particular field value
  * Bivio::Biz::Model::QuerySearchBaseForm uses form_name of fields,
    in case it has been set explicitly
  * Bivio::Biz::Model::UserRealmList->find_row_by_type uses find_row_by
  * Bivio::SQL::Statement->ILIKE added
  * Bivio::SQL::Statement does nested left joins properly and columns no
    longer have to be mentioned in internal_initialize to be mentioned
    from or where.
  * Bivio::Test::Language::HTTP->submit/verify_form allows regexp for
    select options
  * Bivio::Test::Unit->builtin_not_die (not_die()) is a synonym for "undef"
  * Bivio::Type::DateTime->english_day_of_week added
  * Bivio::Type::USZipCode9->to_html formats with '-'
  * Bivio::UI::HTML::ViewShortcuts->vs_simple_form and vs_descriptive_field
    better organized and allows fields of the form [name, {attrs}]
  * Bivio::UI::HTML::Widget::Checkbox.is_read_only added
  * Bivio::UI::HTML::Widget::Image.alt_text can resolve to nothing
  * Various small bug fixes in XHTML changes

  Revision 3.11  2005/09/23 16:22:11  nagler
  * Bivio:UI::HTML::Widget:Page.xhtml allows you to create XHTML pages:
    <!doctype html public "-//w3c//dtd xhtml 1.0 transitional//en"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transititional.dtd">
  * Bivio::UI::HTML::Widget::* and Bivio::UI:* have been upgraded to
    be XHTML compliant.   A variety of bugs were fixed and code
    refactored along with these changes.
  * Bivio::UI::HTML::ViewShortcuts->vs_alphabetic_chooser has been added
  * Bivio::UI::HTML::ViewShortcuts->vs_simple_form $epilogue and
    $prologue have been removed -- just put the widgets in the list.
    Buttons may be specified with leading '*', like separators.
    Otherwise, StandardSubmit is appended to the form.
  * Bivio::UI::HTML::ViewShortcuts->vs_site_name has been updated to
    include
  * Bivio::Biz::Model::MailReceiveDispatchForm->parse_recipient can
    return model, name, or realm_id for realm
  * Bivio::Biz::Model::MailReceiveDispatchForm->execute_ok handles empty
    $op correctly.
  * Bivio::Biz::Model::RealmOwner->unauth_load_by_email accepts hash_ref
    for $query.  hash (%query) is deprecated.
  * Bivio::Die works better with HTML::Parser now.  HTML::Parser seems
    to reset $@.  This fix may cause unexpected failures due to implicit
    couplings, but we haven't seen this in our testing.
  * Bivio::Mail::Outgoing returns $self for more methods
  * Bivio::Mail::Common->enqueue_send requires $req.  Implicit $req
    is deprecated.
  * Bivio::Mail::Outgoing->set_headers_for_list_send accepts
    subject_prefix (list_in_subject form is deprecated).  $list_name is
    relaxed to include period ('.').
  * Bivio::PetShop expanded MAIL_RECEIVE interface for testing/examples
  * Bivio::PetShop::Util->DEMO_EMAIL/format_email added
  * Bivio::ShellUtil->initialize_ui returns $req
  * Bivio::Test::Language::HTTP->generate_remote_email added
  * Bivio::Test::Unit->builtin_simple_require (maps to simple_require()
    in bunit tests) added.  Ex. RealmOwner.bunit
  * Bivio::Type::Date->from_literal accepts YYYY-MM-DD and YYYY-MM-DD.

  Revision 3.10  2005/09/16 20:54:01  nagler
  * Bivio::Biz::ListModel->internal_prepare_statement and
    Bivio::SQL::Statement changed to support more powerful API for creating
    statements on the fly with automatic type conversions.
  * emacs/b-perl.el and b-site-start.el added to bOP
  * Bivio::Test::Unit (bunit tests) restructured to support dynamic
    calls from *.bunit file via AUTOLOAD.
  * Various bunit tests created.  *.t versions still available to ensure
    backwards compatibility and for comparison purposes
  * Bivio::Biz::Action::Acknowledgement->extract_label factored out of
    execute()
  * Bivio::UI::HTML::ViewShortcuts->vs_acknowledgement calls
    Bivio::Biz::Action::Acknowledgement->extract_label if there isn't
    already a Action.Acknowledgement on the request.
  * Bivio::Biz::Action::Acknowledgement->execute deletes Action.Acknowledgement
    from request if there's no label.
  * Bivio::Biz::Action->delete_from_request removes the action from the
    request.
  * Bivio::Test->CLASS deleted; Bivio::Test::Unit->class implements
    better
  * Bivio::UI::HTML::Widget::String->render initializes widget if
    returned by widget value.  Also uses unsafe_resolve_widget_value so
    can unwrap several levels of indirections.

  Revision 3.9  2005/09/12 16:48:24  moeller
  * Bivio::UI::HTML::Widget::Table render headings if empty and
    no empty_list_widget
  * Bivio::Test::Util added bunit
  * Bivio::Test added CLASS()

  Revision 3.8  2005/09/09 22:21:22  moeller
  * Bivio::UI::HTML::Widget::Table fixed subclass_is_table()

  Revision 3.7  2005/09/07 22:53:36  moeller
  * Bivio::UI::HTML::Widget::TextArea re-add support for class and id
    attributes

  Revision 3.6  2005/08/31 21:36:53  moeller
  * Bivio::UI::HTML::Widget::Style put explicit tags back for the default font

  Revision 3.5  2005/08/30 22:53:20  nagler
  * Bivio::Biz::Action::RealmlessRedirect allows you to redirect a
    realmless redirect to one with a realm depending on your login
    state.

  Revision 3.4  2005/08/29 19:17:41  nagler
  NOTE: Major refactoring of Table and Grid widgets in this release

  * Bivio::UI::HTML::Widget::TableBase is the common base class for Grid
    and Table widgets.  cellpadding, cellspacing, bgcolor, background,
    etc. have been moved to TableBase.  These attributes are rendered
    dynamically (except "expand"), and are common to both Grid and
    Table.
  * Bivio::UI::HTML::Grid/Table.class allows you to turn off defaulting
    of parameters, e.g. Grid([['x']], {class => 'y'}) yields
  	<table class="y"><tr>
  	<td>x</td>
  	</tr></table>
    whereas Grid([['x]]) yields:
  	<table border="0" cellpadding="0" cellspacing="0"><tr>
  	<td>x</td>
  	</tr></table>
    Thusly, Table and Grid are fully CSS compatible.
  * Bivio::UI::HTML::Grid/Table.*_class, e.g. odd_row_class, row_class,
    summary_line_class, allow full class tagging at row and cell levels
    for data, heading, and footer cells.  See the code and tests for details.
  * Bivio::Biz::ExpandableListFormModel->validate_row uses
    MUST_BE_SPECIFIED_FIELDS() to figure out if a row is empty iwc all
    errors on MUST_BE_SPECIFIED_FIELDS() are cleared.  If
    MUST_BE_SPECIFIED_FIELDS() is undef, validate_row does nothing.
  * Bivio::Biz::ExpandableListFormModel->is_empty_row uses
    MUST_BE_SPECIFIED_FIELDS() to determine if the row is empty.
  * Bivio::Biz::ExpandableListFormModel->execute_empty_row calls
    internal_load_field on all visible fields that also exist in
    in list_model.
  * Bivio::Biz::FormModel-GLOBAL_ERROR_FIELD formally couples the
    implicit coupling of '_' meaning a general form error.
  * Bivio::Biz::List/FormModel->get_errors/internal_clear_error/etc. reuse
    get_errors as much as possible to increase explicit coupling.
    Fixed defect in internal_clear_error for ListForms where get_errors
    would return an empty hash (not allowed).
  * Bivio::Type->is_specified returns false if value is undef.
  * Bivio::Type::Enum->is_specified returns false if value is undef
    or as_int is 0.  Creates overridable explicit coupling.
  * Bivio::Biz::FormModel::_parse_cols() uses Bivio::Type->is_specified
    to validate NOT_ZERO_ENUM constraint.
  * Bivio::Biz::Model::RealmOwner->create sets $name to first letter of
    realm_type + realm_id and always downcases $name.
  * Bivio::Biz::Model::User->create_realm encapsulates the work of
    creating a User realm.
  * Bivio::Biz::Model::UserCreateForm->internal_create_models refactored
    to use User->create_realm.
  * Bivio::Biz::Model::UserRealmList->find_row_by_type sets the cursor
    to the first row with specified RealmType.
  * Bivio::Biz::Model->internal_initialize no longer dies when called
    from a subclasses internal_initialize.
  * Bivio::Biz::Util::RealmRole->copy_all copies permissions from
    one realm to another.  Useful for initializing new realm types.
  * Bivio::PetShop::Util->DEMO_USER defines the demo user name for
    PetShop.
  * Bivio::UI::HTML::ViewShortcuts->vs_html_attrs_initialize defaults
    to unsafe_initializing class and id for widgets.  Can also pass in
    a list.  See Tag, Link, and TableBase.
  * Bivio::UI::HTML::ViewShortcuts->vs_html_attrs_render renders class
    and id by default, but can also unsafe_render other html attrs.
  * Bivio::UI::HTML::Widget::ControlBase uses vs_html_attrs_initialize
    and vs_html_attrs_render.
  * Bivio::UI::HTML::Widget::ControlBase->internal_new_args ifc
    simplified for subclasses.  See Tag and Link.
  * Bivio::UI::HTML::Widget::Tag renders arbitrary html tags with class
    and id attribles.
  * Bivio::UI::HTML::Widget::StyleSheet renders style sheet file as a
    link if want_local_file_cache is true.  Otherwise, typically for
    development, renders css inline.  Enables rapid CSS edit-debug
    loops.
  * Bivio::UI::HTML::Widget::Image.class defined and will not render
    border=0 if set.
  * Bivio::UI::HTML::Widget::Page->render sets font_with_style on
    request.  Style data was being duplicated unnecessarily when Style()
    widget was in use after Script() was added in release 2.83.  Not
    functional problem, but possible performance problem.
  * Bivio::UI::HTML::Widget::Style->render uses "body" instead of
    explicit lists of tags to set default font.  Observes
    font_with_style as passed in by Page.
  * Bivio::UI::Task->parse_uri was not handling path_info empty case
    properly for realm case.  Was producing an uninitialized variable
    error.
  * Bivio::Util::RealmAdmin->delete_with_users deletes current realm and
    all its users.  Userful for testing.
  * Bivio::Type::USZipCode9 enforces 9 digit zip codes

  Revision 3.3  2005/08/26 21:36:47  moeller
  * added Bivio::Type::CountryCode enum

  Revision 3.2  2005/08/26 05:26:13  moeller
  * Bivio::Biz::Action::AdmMailBulletin allow sending bulletin on
    non-production servers if the email matches localhost or the current
    hostname
  * Bivio::Biz::Model::AdmBulletinForm added internal_create_bulletin()
    which allow subclasses to perform additional work when the bulletin
    is created
  * Bivio::Biz::Model::RealmOwner default name in create
  * Bivio::Biz::Model::UserCreateForm RealmOwner.name is now defaulted
    by RealmOwner->create
  * Bivio::UI::HTML::ViewShortcuts added vs_simple_form and
    vs_descriptive_field

  Revision 3.1  2005/08/18 19:34:24  moeller
  * Bivio::ShellUtil removed set_current() call in put_request()
    Job::Request->new is already doing this
  * Bivio::Test::HTMLParser::Forms added config value
    'disable_checkbox_heading' which disables the default table checkbox
    labeling for a named table heading
  * Bivio::Test::Language::HTTP ensures that input submitted to a text
    control is not multi-line

  Revision 3.0  2005/08/16 23:34:35  nagler
  Roll over major verison number

  Revision 2.97  2005/08/16 23:33:12  nagler
  * Bivio::Util::HTTPLog Subject: is the log name without date or host,
    because they are elsewhere

  Revision 2.96  2005/08/15 23:21:45  nagler
  * Bivio::Agent::Request->internal_set_current warns if a request is
    already current.  There may be a defect with Apache not calling
    the clean up handlers if a request aborts.
  * Bivio::Util::HTTPConf (b-http-conf) generates configuration for a
    bOP application server allowing you to run multiple bOP applications
    on the same machine.  The front-end is an Apache proxy server that
    also servers static files (RewriteRule ^/./ - [L]).  HTTPConf.t
    is a good place to start to try to understand what this command does.
  * Bivio::Delegate::SimpleTypeError->PASSWORD_MISMATCH description
    changed to be more suitable.  If you have (deviance) acceptance
    tests that rely on the old value (invalid password), they will
    fail.

  Revision 2.95  2005/08/15 16:10:24  moeller
  * Added new type Bivio::Type::Text64K which replaces
    Bivio::Type::ReallyLongText.
  * Bivio::Biz::Model::Bulletin now uses Text64K type.
  * Bivio::SQL::Connection::Oracle treats Text64K type as CLOB,
    Bivio::SQL::Connection::Postgres treats Text64K as TEXT.
  * Bivio::IO::File simplified mkdir_parent_only
  * SQL unit tests no longer execute Postgres specific test when running
    against an Oracle database.

  Revision 2.94  2005/08/10 22:35:20  nagler
  * Major refactoring of Bivio::Agent::Request to support named args
    (hash_ref) for most APIs that generate URIs or do redirects.
    task_id may now be "any", and will default to current task if
    not supplied for all routines.
  * Bivio::Agent::Request->server_redirect/client_redirect/format_uri
    accept require_context, which allows a task to force a redirect
    back to itself on successful completion of the form.
  * Bivio::Agent::Task.want_workflow allows tasks to "chain" context,
    instead of stacking.  See Bivio/PetShop/Test/t/workflow.btest for
    an example workflow.
  * Bivio::Agent::Request->client_redirect_contextless was removed.
    Use $req->client_redirect({task_id => 'bla', no_context => 1})
    with considerations whether you should add path_info => undef or
    query => undef.
  * Bivio::Biz::FormModel->format_context_as_query and
    get_context_from_request interface changed;  These routines
    are not used by applications.
  * FORBIDDEN exceptions without an auth_user (i.e. to force login)
    are invoked with throw_quietly to avoid messages and stack traces.
  * Bivio::Test::Language::HTTP->generate_local_email returns a name
    as well as an email.  Use (generate_local_email())[0] in a scalar
    context, a form which is now deprectated.

  Revision 2.93  2005/08/09 17:46:43  moeller
  * Bivio::Type::UserAgent detects MSIE_7
    fixed bug where unknown type BROWSER was referenced
  * Bivio::Util::SQL push up the create_test_db and
    initialize_test_data methods

  Revision 2.92  2005/08/04 19:36:47  david
  * Bivio::Mail::Common adds X-Bivio-Reroute-Address header if
    reroute_address is specified in bconf.
  * Bivio::Test::Language::HTTP->submit_form can now submit forms
    without reference to a button (mimicking Javascript autosubmit).

  Revision 2.91  2005/07/30 15:50:19  nagler
  * Bivio::Util::Release->build primitive _b_release_files accepts
    shell-meta-chars, which will complete *, ?, and [].
  * Bivio::Util::Release->install_host_stream calls install_stream
    with $(hostname) and -force
  * Bivio::Util::Release->install with $ENV{http_proxy} downloads the
    packages first before installing.  This works around an rpm 4.0.4
    bug.
  * Bivio::ShellUtil->new_other calls __PACKAGE__->OPTIONS, not OPTIONS()
  * Bivio::Test::Language::HTTP->submit_form accepts expected_content_type
    to allow other types of form responses than text/html.

  Revision 2.90  2005/07/27 17:09:46  nagler
  * Bivio::BConf->default_merge_overrides specifies reasonable defaults
    for many common values
  * Bivio::PetShop::BConf uses default_merge_overrides
  * Bivio::PetShop::Model::UserAccountForm refactored to share more code

  Revision 2.89  2005/07/21 23:43:28  nagler
  * Bivio::Biz::Model::UserCreateForm->parse_display_name understands
    prefixes (Dr., Mr., etc.) and suffixes (Jr, III, etc.).  Length
    errors on User.*_name's are checked, and parse_display_name returns
    false after putting an error on RealmOwner.display_name if that is
    the case.
  * Bivio::Delegate::SimpleWidgetFactory treats Bivio::Type::Year as a
    right justified string, instead of an AmountCell.

  Revision 2.88  2005/07/19 20:59:13  nagler
  * Bivio::UI::Widget::Join.join_separator is rendered between elements
    that are non-zero length
  * Bivio::UI::HTML::Widget::Form->initialize no longer calls
    ancestral_get for form_class and form_model.  This was a defect.
  * Bivio::Test::Widget->unit no longer requires setup_render to be
    passed.

  Revision 2.87  2005/07/14 22:14:56  moeller
  * Bivio::Type::UserAgent now detects many common browser types,
    MSIE_5, MSIE_6, FIREFOX and MOZILLA.
    Added methods has_over_caching_bug(), has_table_layout_bug() and
    is_css_compatible() methods for determining browser features.
    Removed BROWSER item.
  * Bivio::UI::HTML::ViewShortcuts added vs_correct_table_layout_bug()
    which adds javascript to fix layout problems in Mozilla and Firefox
  * Bivio::UI::HTML::Widget::Page asks UserAgent if there are caching
    bugs
  * Bivio::UI::HTML::Widget::Style asks UserAgent if css is supported
  * PetShop application now uses the correct_table_layout_bug script.
  * Bivio::IO::Ref nested_differences now handles Regexp matches
  * Bivio::Test::Request now defaults the user agent to BROWSER_HTML4

  Revision 2.86  2005/07/07 16:45:50  moeller
  * Bivio::Mail::Common added sanity check - warn if mail queue has items,
    but self is not a transaction resource on the request

  Revision 2.85  2005/07/01 23:15:30  moeller
  * Bivio::SQL::Statement doesn't wrap where clause in parenthesis,
    old code may include ORDER BY there

  Revision 2.84  2005/07/01 20:15:25  nagler
  * Bivio::UI::Widget::HTML::Page->initialize avoids vs_call unless
    script/style need to be put on Page

  Revision 2.83  2005/07/01 04:55:18  nagler
  * Bivio::UI::HTML::Widget::Page.style defaults to Style() widget, if not
    set explicitly to undef or another value.
  * Bivio::UI::HTML::Widget::Page.script defaults to Script() widget, if not
    set explicitly to undef or another value.
  * As a part of this change, body is rendered before style or script.
    This should have no effect, but some apps may depend on evaluation
    orders.  You should avoid like the plague.
  * Script('name') enables views to include JavaScript in the <head>
    tag.  The currently implementation is designed for limited
    JavaScript, but the interface hides much, and will allow for
    a new implementation as needs grow.
  * Bivio::UI::HTML::Widget::FirstFocus has been replaced by
    vs_first_focus(), which accepts a control, and uses new Script()
    interface.
  * Bivio::UI::HTML::Widget::Page implements positional args (head,
    body, attrs)
  * Bivio::Test::Widget->unit wraps Bivio::Test->unit call in a view to
    enable use of vs_call, among other view APIs.
  * Bivio::Test->compute_return handles regular expressions correctly
  * Bivio::Test::ListModel implemented to match Bivio::Test::Widget
  * Bivio::PetShop/files/view/header & order-commit.bviews use
    vs_first_focus and want_page_print

  Revision 2.82  2005/06/30 03:15:16  nagler
  * Bivio::Biz::FormModel->OK_BUTTON_NAME is exported
  * Bivio::Biz::Model::AdmSubstituteUserForm accepts query string again
    (broken in 2.81)

  Revision 2.81  2005/06/29 22:13:06  nagler
  * Bivio::Biz::Model::AdmUserList provides list of all users with
    last name search capability
  * Bivio::Test::ListModel simplifies ListModel testing.  See unit test
    and AdmUserList.t
  * Bivio::Agent::HTTP::Cooke->internal_notify_handlers exported to
    allow for easier testing
  * Bivio::Test::Cookie is a mock object for testing delegates
  * Bivio::SQL::Statement encapsulates params and where clause of SQL
  * Bivio::Biz::ListModel->internal_prepare_statement deprecates
    internal_pre_load.  internal_prepare_statement uses a
    Bivio::SQL::Statement object to encapsulate where/params manipulation.
    internal_pre_load is called by ListModel's implementation of
    internal_prepare_statement.  Subclasses wishing to use
    internal_prepare_statement should NOT call
    SUPER::internal_prepare_statement if ListModel is direct super class.
  * Bivio::Biz::Model::AdmSubstituteUserForm exports and mostly
    handles SUPER_USER_FIELD.
    Bivio::Biz::Model::UserLoginForm->SUPER_USER_FIELD is deprecated.
  * Bivio::Collection::Attributes->unsafe_get_nested returns undef if
    one of the keys is not found.
  * Bivio::PetShop::Util->DEMO_USER_LAST_NAME returns constant last name
    of demo users
  * Bivio::PetShop::Util->demo_users returns array_ref of demo user
    names
  * Bivio::SQL::Connection::Oracle->internal_get_error_code works correctly.
  * Bivio::SQL::Connection->internal_execute allows subclasses to wrap
    call to DBI execute.
  * Bivio::SQL::Connection::Postgres->internal_execute ignores
    "PRIMARY KEY will create implicit index" msg.
  * Bivio::SQL::Connection->commit/rollback shares code
  * Bivio::SQL::Connection->do_execute wraps execute, fetchrow_arrayref,
    and finish_statement loop
  * Bivio::SQL::ListSupport.order_by is initialized when want_select
    is false.
  * Bivio::Test.compute_return is called before check_return to modify
    the actual return.  Will probably eliminate many calls to
    check_return in favor of simpler code.
  * Bivio::test.failed and passed are attributes set after unit() returns.
    Makes it easier to test specializations.
  * Bivio::Type::Year->from_literal checks range after windowing
    happens.
  * Bivio::Util::SQL->backup_model and restore_model allow backup and
    restore of model to/from files.
  * Bivio::Util::SQL->backup_model->internal_upgrade_db_multiple_realm_roles
    implements the upgrade for the multiple realm role fix.
    b-db-upgrade is gone.  Instead, call internal_upgrade_db_multiple_realm_roles
    from internal_upgrade_db in your ::Util::SQL.
  * Bivio::Util::SQL->run/drop/drop_and_run can take $sql as an
    argument or reads input (backwards compatible).
  * Bivio::Util::SQL->run allows ';' for separating statements
  * Bivio::SQL::t::Connection.t runs on freshly loaded database.

  Revision 2.80  2005/06/24 23:14:45  moeller
  * Bivio::Agent::Dispatcher does not set request task_id,
    lets internal_redirect_realm() handle it
  * Bivio::Agent::Request
    puts the task on the request at the end of internal_redirect_realm(),
    can_user_execute_task() now takes an optional realm_id argument,
    renamed get_realm_for_task() to internal_get_realm_for_task(),
    it is now deprecated to get a realm for a task other than
     the current realm, GENERAL or USER
  * Bivio::Biz::Model::RealmRole
    fixed bug: not all roles have defined permissions for all realms
  * Bivio::UI::HTML::ViewShortcuts
    added vs_task_link() and vs_acknowledgement()
  * Bivio::UI::HTML::Widget::ListActions
    added forth argument for the realm for the task,
    avoid deprecated warning when linking to a different realm

  Revision 2.79  2005/06/20 17:56:38  moeller
  * Bivio::Test::Language added test_script()
  * Bivio::UI::HTML::Widget::Link subclassed to use new ControlBase which
    will add in class, id

  Revision 2.78  2005/06/13 16:22:14  moeller
  * PetShop demo app, Order model is a proper realm, no longer
    references Club.
  * Bivio::Biz::Model::RealmOwner no longer references CLUB directly,
    now creates HOME tasks for all realm types except UNKNOWN and
    GENERAL
  * Bivio::IO::ClassLoader dump value of "maps" config in handle_config
    die

  Revision 2.77  2005/06/09 23:27:33  moeller
  * Bivio::Agent::Request
    can_user_execute_task() returns true if the task permissions
      include ANYBODY or ANY_USER
    removed references to CLUB realm type
    _get_realm() now allows any realm type
  * Bivio::Auth::PermissionSet includes() now accepts one or more
      permission names
  * Bivio::Biz::Model::RealmUser added update_role()
      to delete/recreate RealmUser with a new role
  * PetShop application uses a custom realm type ORDER

  Revision 2.76  2005/06/09 17:50:26  moeller
  * Bivio::Biz::Model::Club removed override for cascade_delete()
  * Bivio::Biz::Model::RealmUser removed role sets and many is_xxx()
    methods which were either deleted or moved to the Role delegate.
  * Bivio::Delegate::Role added is_admin()
  * Bivio::Type::EnumDelegator now uses UNIVERSAL->can() to lookup
    dispatch method which allows delegates to be subclassed

  Revision 2.75  2005/06/08 14:33:19  nagler
  * Bivio::Type::Year->from_literal calculates date window (+20 years)
    for two digit dates.  get_min() returns 100

  Revision 2.74  2005/06/07 19:29:51  david
  * fix bad release scope on Util/b-db-upgrade

  Revision 2.73  2005/06/07 19:17:56  david
  * clean up Util/b-db-upgrade

  Revision 2.72  2005/06/07 03:53:02  moeller
  * Bivio::Biz::Model::RealmUser removed honorific property
  * Allow multiple RealmUser roles for one realm, modules changed:
    Bivio::Agent::Request
    Bivio::Agent::Task
    Bivio::Auth::Realm
    Bivio::Auth::Role
    Bivio::Biz::Model::RealmRole
    Bivio::Biz::Model::UserCreateForm
    Bivio::Biz::Model::UserRealmList
    Bivio::Biz::Util::RealmAdmin
    Bivio::Biz::Util::RealmRole
  * Bivio::UI::Facade renamed arrays() to make_groups()
  * Bivio::UI::HTML::Widget::Grid added cell_class
  * Bivio::UNIVERSAL renamed mapcar() to map_invoke()

  Revision 2.71  2005/06/01 21:25:48  moeller
  * Bivio::UI::Facade added arrays() for cleaner config formatting
  * Bivio::PetShop::Facade::PetShop uses new format

  Revision 2.70  2005/05/27 18:55:35  nagler
  * Bivio::UI::Facade allows flexible configuration:
    Color => [[blue => 0xff], [red => 0xff0000]],
    or Color => sub {shift->group(blue => 0xff)}
  * Bivio::PetShop::Facade::PetShop refactored to simplified Facade config

  Revision 2.69  2005/05/26 19:27:11  nagler
  * Bivio::Auth::PermissionSet->includes simplified
  * Bivio::IO::Ref->to_string calls Sortkeys if Data::Dumper supports it
  * Bivio::Test::Language::HTTP handles case where email_user is not set
  * Bivio::UNIVERSAL->mapcar calls a method on $self repeatedly
  * Bivio::UNIVERSAL->is_equal uses 'eq'
  * Bivio::UNIVERSAL->as_string concats result with '' to force string
  * Bivio::UI::HTML::ViewShortcuts->vs_link_target_as_html can be called
    from render() with $source
  * Bivio::UI::HTML::Widget::Link is fully dynamic, and also allows
    resolved href to be a hash_ref, which results in a call to $req->format_uri
  * Bivio::UI::Widget::MIMEBodyWithAttachment won't include headers if empty
  * All tests run on Mac OS 10.4 (Tiger) and Perl 5.8.6 (Release.t skips
    all tests if no /bin/rpm).

  Revision 2.68  2005/05/24 16:12:07  moeller
  * RealmType delegation affected the following modules
    Bivio::Agent::Job::Request
    Bivio::Agent::Request
    Bivio::Auth::Realm
    Bivio::Auth::RealmType
    Bivio::BConf
    Bivio::Biz::Action::PublicRealm
    Bivio::Biz::Model::Lock
    Bivio::Biz::Model::RealmOwner
    Bivio::Biz::Model::UserPasswordForm
    Bivio::PetShop::Action::UserRedirect
    Bivio::ShellUtil
    Bivio::UI::Task
  * Bivio::Auth::Role configurable roles
  * Bivio::HTML fix escaping of ? in query
  * Bivio::PetShop::Facade::PetShop use FormError FacadeComponent
  * Bivio::Test::Reply fixed deprecated call to Bivio::IO::File->read()
  * Bivio::UI::HTML::ViewShortcuts added vs_fe to wrap super's vs_fe
  * Bivio::UI::HTML::Widget::FormFieldError Call FormError facade
    component if it exists else FormErrors
  * Bivio::UI::HTML::Widget::SourceCode strip trailing slash from
    $_SOURCE_DIR config. Escape in pattern match
  * Bivio::UI::Text refactored and added unsafe_get_value
  * Bivio::UI::ViewShortcuts added vs_fe (calls Bivio:UI::FormError)
  * Bivio::UI::Widget::MIMEBodyWIthAttachment fixed uninitialized value
    warning
  * Bivio::Util::Release Need extra ) on list_projects_el
  * Bivio::Util::SQL drop() now drops functions

  Revision 2.67  2005/05/17 21:04:30  moeller
  * Bivio::Test::HTMLParser tables with the same name use the name,
    name#1, name#2 sequence
  * Bivio::Test::Language::HTTP text_exists() now calls \Q on string arg

  Revision 2.66  2005/05/10 18:28:51  nagler
  * Bivio::Agent::Request->is_test returns ! is_production()
  * Bivio::Delegate::SimplePermission->TEST_TRANSIENT added
  * Bivio::Delegate::SimpleAuthSupport->task_permission_ok supports
    TEST_TRANSIENT, a permission that is set when $res->is_test() is true
  * Bivio::Biz::ListModel->execute_load_page shares code with execute_load_all
  * Bivio::ShellUtil->new_other dies explicitly if class not found (was
    relying on Bivio::IO::ClassLoader before, which calls throw_quietly)
  * Bivio::Test::Request->is_test returns is_test attribute if exists
    else calls SUPER::is_test
  * Bivio::Test::HTMLParser::Tables->find_row only uses value as regex
    if value is a Regexp ref

  Revision 2.65  2005/05/05 23:01:57  moeller
  * Bivio::ShellUtil->new_other() explicitly dies if the class is not
    found
  * Bivio::Test::HTMLParser::Forms added error_class
  * Bivio::Test::Language::HTTP allow regexp as arg to follow_link
  * Bivio::UI::Mail::Widget::Message +26 -19 lines
  * Bivio::UI::Widget::MIMEEntity incomplete refactoring -- harmless
  * Bivio::UI::Widget added unsafe_resolve_widget_value()

  Revision 2.64  2005/04/29 16:54:16  moeller
  * Bivio::SQL::ListSupport includes DISTINCT in COUNT() clause if
    present
  * Bivio::Test::HTMLParser::Tables doesn't map undef columns in
    do_rows()
  * Bivio::UI::HTML::Widget::AmountCell added internal_new_args()

  Revision 2.63  2005/04/26 22:29:55  nagler
  * Bivio::MIME::Type supports xml, xhtml, and css
  * Bivio::Biz::Model::RealmRole refactored to share code between add/remove
  * Widget String('some text', {attr => 'a'}) supported
  * Bivio::UI::Widget::Simple takes a "value" attribute and renders it
  * Bivio::UI::HTML::Widget::SimplePage is an executable Simple widget
    that sets the content type to text/html

  Revision 2.62  2005/04/15 19:23:58  moeller
  * Bivio::Agent::Request deprecated task_ok(),
    use can_user_execute_task() instead
  * Bivio::Biz::Model::ForbiddenForm now uses $req->can_user_execute_task()
  * Bivio::Test::HTMLParser::Tables improved error message when table
    not found by name
  * Bivio::Type::Enum deprecated calls to to_sql_param() with a scalar value
  * Bivio::Type::Number deprecated math calls with undef arguments
  * Bivio::UI::HTML::Widget::ListActions now uses $req->can_user_execute_task()
  * Date.t added more from_literal() and to_xml() test cases

  Revision 2.61  2005/04/04 19:24:22  moeller
  * Bivio::UI::HTML::Widget::Enum added internal_new_args()

  Revision 2.60  2005/03/24 23:19:20  moeller
  * Bivio::Biz::Model::QuerySearchBaseForm added
    OMIT_DEFAULT_VALUES_FROM_QUERY to control rendering query values
  * Bivio::Biz::Model::UserLostPasswordForm removed to_query() calls,
    should only be used if passing as a string
  * Bivio::UI::HTML::Widget::Select defaults list_id_field to ListModel
    primary key. Allow a string, widget value or Widget for
    list_display_field.

  Revision 2.59  2005/03/18 23:48:27  moeller
  * Bivio::Type::ECCreditCardType add support for discover

  Revision 2.58  2005/03/14 20:23:18  moeller
  * Bivio::Agent::Task allow modules with AUTOLOAD to have any 'execute_'
    method called
  * Bivio::UI::HTML::Format::Amount returns blank if zero_as_blank and
    rounded amount is zero
  * Bivio::UI::HTML::Widget::FormFieldLabel corrected &nbsp;

  Revision 2.57  2005/03/08 20:34:15  moeller
  * Bivio::Delegate::SimpleTaskId added default ROBOTS_TXT task,
    allow robot browsing only for production sites
  * Bivio::Biz::Action::LocalFilePlain->execute_robots_txt

  Revision 2.56  2005/02/27 18:23:36  nagler
  * Bivio::Test::Language::HTTP->verify_no_text validates text doesn't exist
  * Bivio::Test::Language::HTTP->verify_text uses text_exists
  * Bivio::Biz::Model::ECSubscription->INFINITE_END_DATE exports
    constant used by make_infinite

  Revision 2.55  2005/02/24 23:28:40  nagler
  * Bivio::Biz::Model::RealmRole->change_public_permissions removed
  * Bivio::Test::Language::HTTP->verify_local_mail returns string(s)
    (formerly returned string_refs)
  * Bivio::Test::Language::HTTP::_fixup_uri calls URI to make absolute
    (expands possibilities, and does right thing directory relative
    uris)

  Revision 2.54  2005/02/24 23:00:30  moeller
  * Bivio::Agent::Task doesn't issue warning for FORBIDDEN when there is
    no auth user. A redirect to the LOGIN task will happen
    automatically.
  * Bivio::BConf remove unnecessary value in default http_log config,
    [notice] happens on any signal, don't ignore in general,
  * Bivio::Biz::ListModel added do_rows()
  * Bivio::Biz::Model added do_iterate()
  * Bivio::Mail::Common added hooks to process outgoing mail
  * Bivio::Mail::Outgoing added hooks to process outgoing mail
  * Bivio::Type::DateTime get_part accepts upper case part name (second test),
    get_part refactored
  * Bivio::Type::EnumSet improved error msg,
    clear wasn't return $vector
  * Bivio::Type::Number catches divide by undef

  Revision 2.53  2005/02/18 00:27:15  moeller
  * Bivio::Biz::Model, Bivio::Biz::ListModel, and Bivio::Biz::PropertyModel
    throw MODEL_NOT_FOUND DieCode rather than NOT_FOUND.
  * Bivio::Biz::Model::User added related model config
  * Bivio::Mail::Outgoing->set_headers_for_list_send requires $req to
    format_email
  * Bivio::Test::Language added test_script()

  Revision 2.52  2005/02/09 20:32:04  nagler
  * Default Bivio::Util::HTTPLog config ignores NOT_FOUND, FORBIDDEN,
    Invalid URI and URI too long
  * Bivio::Collection::Attributes->map_each iterates over keys and values
  * Bivio::UI::HTML::Widget::SourceCode renders the "=for html" sections

  Revision 2.51  2005/02/02 22:11:23  moeller
  * Bivio::Biz::FormModel corrected load_from_model_properties() so it
    also works for ListFormModels
  * Bivio::Util::Release update() may not update anything so need to
    check before calling install()

  Revision 2.50  2005/01/27 18:33:01  nagler
  * Added contrib/ directory with tutorial by Tom Vilot and E-R diagram
    from Terrence Brannon
  * Updated READM
  * Various changes to PetShop and bOP doc thanks to Terrence Brannon
  * Bivio::HTML->escape_query escapes '+' properly (was double escaping
    to %252B)
  * Bivio::IO::File->chown_by_name calls getgrnam for group (was calling
    getpwnam, which only worked on Red Hat)
  * Bivio::Test::Language::HTTP->text_exists is like verify_text but
    doesn't die if text doesn't match.
  * Bivio::Test::Language::HTTP->unsafe_get_uri lets you test for the
    existence of a base uri.
  * Bivio::Test::Language::HTTP->verify_pdf uses pdftotext and behaves
    like verify_text
  * Bivio::Test::Language->test_log_output returns log file and can
    be called from scripts
  * Bivio::Type::Date->from_sql_column ensures time component of date
    is expected constant value.
  * Bivio::Type::DateTime->english_month3_to_int converts Jan, Feb, ...
    to 1, 2, ...
  * Bivio::Type::Number->div dies if dividing by 0 (was returning "inf")

  Revision 2.49  2005/01/11 21:44:04  nagler
  * Unit and acceptance tests have been released in "tests" directory.
    Please read the README.
  * Bivio::Util::Release->build supports recursive _b_release_include
  * Bivio::XML::DocBook->to_pdf indents examples by 2 and fixed some
    font problems.  Still problems with margins and some example
    indentation.

  Revision 2.48  2005/01/05 23:35:30  nagler
  * IMPORTANT: Bivio::Type::Number now uses GMP available from:
    http://www.gnu.org/software/gmp/
    You need to install the GMP.pm files.  Here's what works on Unix:

      tar xzf gmp-4.1.4.tar.gz
      cd gmp-4.1.4
      ./configure --enable-mpbsd
      make install
      cd demos/perl
      perl Makefile.PL GMP_BUILDDIR=../..
      make install

    This change makes Bivio::Type::Number much faster.
  * Bivio::type::DateTime->from_literal recognizes to_file_name format
  * Removed Bivio::UI::Color->format_pdf
  * Bivio::UI::PDF::* removed

  Revision 2.47  2004/12/29 20:33:38  moeller
  * Bivio::Biz::PropertyModel dies if update() is called on an unloaded model
  * Bivio::Type::Secret allows for multiple encryption keys, which are
    tried sequentially. Used to transition to a new key.

  Revision 2.46  2004/12/23 22:53:29  nagler
  * Bivio::Biz::FormModel->process outputs form values if executed
    directly with invalid values
  * Bivio::Util::Release->update/list_updates only installs/shows
    packages already installed on current host
  * Bivio::Util::Release->create_stream creates stream file from
    rpms or what's on current host
  * Bivio::Util::Release->install_stream updates all rpms in stream
    whether they are on the host or not

  Revision 2.45  2004/12/07 19:44:06  moeller
  * PetShop warning color now different from error color so the
    acceptance tests don't think the page is in error
  * Bivio::Biz::Model::ECPayment added get_amount_sum()
  * PetShop OrderForm now requires address fields
  * Bivio::SQL::PropertySupport prints a warning if a primary key value
    is changed in update()
  * Bivio::Test::HTMLParser::Tables, Bivio::Test::Language::HTTP
    improved error messages
  * Bivio::TypeValue added equals( and as_string()

  Revision 2.44  2004/11/10 17:24:32  nagler
  * Bivio::Delegate::SimpleWidgetFactory supports DollarCell widget
  * Bivio::UI::HTML::Widget::DollarCell added
  * Bivio::UI::HTML::Format::Dollar added
  * Bivio::UI::HTML::Widget::Page.want_page_print pops up print dialogue if set

  Revision 2.43  2004/11/09 17:48:32  moeller
  * Refactored the PetShop demo. Now uses bOP Address, Phone, and
    ECPayment models.

  Revision 2.42  2004/11/05 20:45:56  moeller
  * Bivio::Test::HTMLParser::Links now correctly parses links with '0' text
  * Bivio::Type::Password added is_secure_data() so it will not appear in logs

  Revision 2.41  2004/11/04 15:14:56  moeller
  * Bivio::UI::HTML::Widget::FirstFocus new widget which sets focus to
    the first form field on the page
  * Added FirstFocus widget to PetShop demo
  * Bivio::Agent::HTTP::Request Bivio::Type::UserAgent->put_on_request
    no longer exists, now call from_header and put_on_request
  * Bivio::Test::HTMLParser::Forms duplicate forms get duplicate labels,
    unless they are identical, iwc only one form is entered.
  * Bivio::Test::HTMLParser::Links changed missing href on <a> to info,
    not die.
  * Bivio::Test::Language::HTTP added go_back(), set the browser to
    something other than just the script
  * Bivio::Type::Date removed to_local_date(), use local_today() instead
  * Bivio::Type::Enum move put_on_request to Type.pm
  * Bivio::Type::UserAgent renamed put_on_request to from_header
  * Bivio::Type added put_on_request
  * Bivio::UI::HTML::Widget::Search Use Model.SearchList to be more
    general than specific class name
  * Bivio::Util::Release added get_projects helper function

  Revision 2.40  2004/10/28 20:19:13  moeller
  * Bivio::BConf HTTPLog conf ignores /favicon.ico access
  * Bivio::Biz::ListModel->format_uri_for_sort() now resets page to first
  * Bivio::Test::HTMLParser::Forms empty textarea now has value '', not undef,
    remove duplicates, but leave duplicate labels
  * Bivio::Test::Language::HTTP updated doc,
    verify_link() fixed, and pattern arg is optional for old tests
  * Bivio::Type::DateInterval added IRS_TAX_SEASON
  * Bivio::Util::Release first pass at custom up2date-like management

  Revision 2.39  2004/10/19 22:58:21  nagler
  * Bivio::Biz::Model->internal_initialize_local_fields accepts a list
    of (class, fields) tuples
  * Bivio::Delegator refactored and optimized with unit test
  * Bivio::IO::ClassLoader->delegate_require refactored
  * Bivio::Mail::Outgoing->set_headers_for_list_send no longer sets
    Precedence: list -- too many spam filters catch this
  * Bivio::Test::HTMLParser::Forms->unsafe/get_field look up fields in
    forms using string or regexp. get_by_field_names uses these new
    routines.
  * Bivio::Test::Language::HTTP uses (above) get_field to allow more
    flexible verification and form submission.
  * Bivio::Test::Language::HTTP->verify_form accepts option values or
    labels for radios and selects.
  * Bivio::Type::DateInterval->THREE_MONTHS added
  * Bivio::Type::Enum->equals_by_name accepts multipe names
  * Bivio::Type::EnumDelegator allows calls directly on delegated enum
    values.
  * Bivio::Type::ECService subclasses (above) EnumDelegator
  * Bivio::Type::Number->max/min supported
  * Bivio::UI::HTML::Widget::Select refactored

  Revision 2.38  2004/10/14 17:48:12  moeller
  * Bivio::UI::HTML::Widget::Select fixed doc
  * Bivio::Biz::ListModel fixed previous check-in, _format_uri_args()
    only dies if uri is ref and not a Bivio::Agent::TaskId

  Revision 2.37  2004/10/13 21:08:43  moeller
  * Bivio::Biz::ListModel _format_uri_args() fixed to allow task name
  * Bivio::Biz::Model::RealmOwner, Bivio::Biz::Model::Club
    code format and minor refactoring
  * UserLostPasswordForm, UserPasswordForm self->new() changed to
    self->new_other()
  * PetShop models, self->new() change to self->new_other()

  Revision 2.36  2004/10/12 23:04:56  moeller
  * Bivio::Agent::HTTP::Reply->set_cache_private() removed Pragma: no-cache
    to avoid problems accessing non-html pages over https
  * Bivio::Biz::Model::SummaryList no longer adds undef values
  * Bivio::Biz::Model::UserCreateForm, Bivio::Biz::Model::UserLoginForm
    replaced model->new() with model->new_other()
  * Bivio::Test::Language::HTTP->verify_local_mail() now treats search
    email case insensitive

  Revision 2.35  2004/10/01 22:37:44  nagler
  * Bivio::Agent::HTTP::Request->client_redirect calls throw_quietly to
    avoid stack traces
  * Bivio::Agent::Request->server_redirect calls throw_quietly.
  * Bivio::Biz::FormModel refactored a bit to call methods, instead
    of subroutines, e.g. $self->VERSION_FIELD instead of VERSION_FIELD()
  * Bivio::Biz::Model->internal_initialize_local_fields generates
    hash_ref from array_refs for local fields in lists and forms.
  * Bivio::Test::Language::HTTP->verify_local_mail sleeps to allow
    sendmail to deliver the mail

  Revision 2.34  2004/09/23 20:27:41  dobbs
  * Bivio::Test::Language::HTTP->verify_local_email() can now check for
    multiple messages matching the given criteria

  Revision 2.33  2004/09/20 23:22:27  dobbs
  * removed ECCreditCardPayment.card_number in
    Bivio::Biz::Model::ECPaymentList
  * added Bivio::Test::Language::HTTP->clear_cookies(),
  * renamed Bivio::Test::Language::HTTP->generate_email() to
    generate_local_email()
  * Bivio::Test::Language::HTTP->verify_mail() now accepts compiled
    regular expressions, and also correctly matches recipient email address

  Revision 2.32  2004/09/17 23:27:06  moeller
  * added Bivio::Biz::Model->new_other(class) to dynamically create
    models within subclass code.
  * added Bivio::Test::LanguageHTTP->generate_email to return a
    randomized local email address.
  * added Bivio::Test::LanguageHTTP->verify_mail to read mail received.
  * added email_user and mail_tries configuration values for
    Bivio::Test::LanguageHTTP.

  Revision 2.31  2004/09/15 20:50:01  dobbs
  * Bivio::Mail::Common->send() can now accept a string
  * Bivio::Test::Language::HTTP->verify_form() now correctly submits
    button values

  Revision 2.30  2004/09/14 19:58:27  dobbs
  * Bivio::Biz::Model->map_iterate can now use unauth_iterate_start
  * Bivio::IO::Config->command_line_args returns the command line
    arguments, which were stripped from @ARGV
  * Bivio::Test::HTMLParser::Forms now ignores forms with duplicate
    labels that are identical.  Fixes a bug in testing multi-paged lists
  * Bivio::Test::HTMLParser::Tables->find_row now accepts a regular
    expression for column_value
  * Bivio::Test::Language::HTTP->find_table_row added
  * Bivio::Test::Util now passes command line arguments to piped_exec()

  Revision 2.29  2004/08/31 23:10:37  nagler
  * Bivio::Biz::FormModel->process correctly maps DB_CONSTRAINT
    exceptions on directly executed forms
  * Bivio::IO::Trace updated to support unit test
  * Bivio::Test::HTMLParser::Forms->get_by_field_names includes buttons
    in die message
  * Bivio::Test::Language::HTTP->verify_table dies if passed invalid column
  * Bivio::Test::Util lists failed tests before FAILED line;  Also,
    allows passing an explicit file name that is not .t or
    .btest--needed for the unit test.

  Revision 2.28  2004/08/24 18:42:24  nagler
  * Bivio::SQL::PropertySupport->unsafe_load and iterate_start support
    mapping undef to IS NULL for query values
  * Bivio::UI::HTML::Widget::Grid.style is a verbatim attribute for
    style values
  * Bivio::Test::Language::HTTP->verify_title is case sensitive

  Revision 2.27  2004/08/04 19:06:51  nagler
  * Bivio::Test::Language::HTTP->verify_title validates the title is
    what it is supposed to be.
  * Bivio::Type::PrimaryId->to/from_parts manipulates structured primary ids.
    set_file_volume_in_realm_id was removed.
  * Bivio::XML::DocBook->to_pdf converts XML to PDF via LaTeX

  Revision 2.26  2004/07/04 14:13:13  moeller
  * Bivio::Type::Number to_literal() no longer formats trailing .0*
  * Bivio::UI::Widget::MIMEEntity allows attaching files
    using the FileAttachment widget

  Revision 2.25  2004/07/04 14:10:51  moeller
  * Bivio::Auth::PermissionSet added includes() for permission testing
  * Bivio::Mail::Common added config reroute_address to route all mail
    to one address for testing, refactored methods

  Revision 2.24  2004/06/17 21:10:48  david
  * Bivio::UI::ViewLanguage
    Bivio::UI::ViewShortcutsBase
      Allows functions defined in ViewShortcuts files to call other vs_
      functions and Widget() constructors without $proto-> or Package->,
      just like in bview files.
  * Bivio::Util::SQL added upgrade_db function.  Subclasses should
    override internal_upgrade_db to implement upgrade functionality.

  Revision 2.23  2004/06/10 23:07:12  moeller
  * Bivio::IO::Trace fixed undefined _trace() if package filter is off

  Revision 2.22  2004/06/10 22:32:40  moeller
  * Bivio::Biz::Model::QuerySearchBaseForm
    Allow checkboxes to be defaulted to checked.
  * Bivio::Delegate::SimpleRealmName
    allow subclasses to parse realm name, added internal_is_realm_name()
  * Bivio::HTML
    escape_uri doesn't escape '/', because that's the way it works.
    The new URI::Escape escapes '/', and that breaks assumptions.
  * Bivio::IO::Trace
    Improved import/register,
    no longer need to call register() or use vars ('$_TRACE');
  * Bivio::SQL::Connection::Postgres
    now correctly parses Postgres 7.4.1 constraint violation error messages
  * Bivio::SQL::Support
    improved error messages
  * Bivio::Test::Language::HTTP
    set the "user agent" HTTP to the script name when sending requests.
    includes the script line number in the user-agent portion of the
      HTTP request.
    Added a reload_page() method.  Indended to be used after
      a deviance test to clear errors so that conformance
      tests can be resumed
  * Bivio::Test::Language
    Change to output to deviance output
  * Bivio::Type::ECCreditCardExpYear
    now determines credit card date window dynamically
  * Bivio::Type::Number
    now uses Math::BigInt because this is used by FixedPrecision but not imported
  * Bivio::UI::Task
    calls RealmName->from_literal() to see if uri is in a realm
  * Bivio::UNIVERSAL
    added package_version

  Revision 2.21  2004/04/28 18:11:18  david
    * Bivio::Agent::Request now lets you specify a link anchor in the
      various format functions.  The format functions now also accept a
      hash of arguments.
    * Bivio::Biz::Model::QuerySearchBaseForm now does a better job of
      not putting form button values on queries.
    * Bivio::Delegate::Cookie takes over the job of PersistentCookie and
      adds the following features:
      - cookies can now be temporary - they won't get stored on the
        client's disk
      - temporary cookies can time-out on inactivity. This forces the
        user to login again after a certain time has passed.
    * Bivio::Delegate::PersistentCookie now derives from Cookie
      and is deprecated.
    * Bivio::IO::File->write returns its first arguement.
    * Bivio::UI::Widget::MIMEEntity now does a better job of setting
      mime_type and mime_encoding.
    * Bivio::UI::Widget calls put_and_initialize before rendering a
      widget if the widget has no parent.

  Revision 2.20  2004/04/16 03:42:28  nagler
  * Bivio::ShellUtil->main will return the result as a string_ref if
    called from an array context and there is output.  This change
    facilitates unit testing of ShellUtil subclasses.
  * Bivio::ShellUtil->run_daemon can be configured to limit the run-time
    of children.  The configuration parameters daemon_sleep_after_reap,
    daemon_max_child_run_seconds, and daemon_max_child_term_seconds have
    been added to facilitate this feature.
  * Added Bivio::BConf default config for Bivio::Util::HTTPLog to
    ignore 'Facade::setup_request:.*: unknown facade uri'.
  * Bivio::XML::DocBook->to_html converts sect1/title to h2 and
    sect2/title to h4

  Revision 2.19  2004/04/08 20:20:39  nagler
  * Bivio::UI::Task->parse_uri uses $r->hostname if available and if the
    facade isn't explicitly set with /*<facade>
  * Bivio::HTML::Scraper sets last_uri to the redirected uri
  * Bivio::UI::Text no longer uses @x[] form (deprecated in perl 5.8)

  Revision 2.18  2004/04/06 23:17:24  moeller
  * Bivio::Collection::Attributes allow get_if_exists_else_put to put
    any value, not just call a computed code_ref
  * Bivio::Type::DateTime gettimeofday uses Time::HiRes to avoid
    syscall.ph problem
  * Bivio::UI::Mail::Widget::Message doesn't render empty to or cc
    attributes
  * Bivio::Util::Release added http_realm/user/password for retrieving
    files

  Revision 2.17  2004/03/25 03:17:49  moeller
  * Bivio::Agent::HTTP::Form ignores Content-Length in content, only
    included by HTTP::Request requests
  * Bivio::Test::HTMLParser::Forms allows a select widget to have an
    empty option
  * Bivio::Test fixed problems with custom expect/actual matches
  * Bivio::Util::Release pwd needs to be carried through by _do_in_tmp

  Revision 2.16  2004/03/23 20:22:00  nagler
  * Bivio::ShellUtil->lock_action does not test hostname if it doesn't
    exist in pid file
  * Bivio::Util::LinuxConfig->ifcfg_static no longer requires a gateway
  * Bivio::Util::Release->install_tar chdirs out of the tmp dir before
    deleting it
  * Bivio::SQL::Connection::Postgres handles yet another left join case

  Revision 2.15  2004/03/12 21:48:49  nagler
  * Bivio::Delegate::PersistentCookie upcases tag after reading it from config
  * Bivio::SQL::Connection::Postgres converts left join with table aliases
  * Bivio::ShellUtil->lock_action adds host to pid file so works on network
    file systems.  Also catches $SIG{TERM} and deletes lock before rethrowing
    so it works nicely with run_daemon.
  * Bivio::Type->compare/is_equal/compare_defined is self-consistent.
    Subclasses implement compare_defined, and all undef values handled
    by Bivio::Type::compare.  is_equal calls compare.
    Bivio::Type->compare_defined uses cmp for comparisons so now compare
    is defined for all types.
  * Bivio::Type::Password->is_equal/compare defines undef values as
    always not equal for security reasons.  A successful encryption is
    the only way to compare equal.

  Revision 2.14  2004/03/11 00:21:33  nagler
  * Bivio::SQL::Connection::Oracle uses all_cons_columns and
    all_ind_columns instead of user_cons_columns and user_ind_columns.
    This allows the database user to be different from the owner.

  Revision 2.13  2004/03/09 21:31:34  nagler
  * Bivio::Biz::ExpandableListFormModel saves itself on request instead
    of just rows.  Allows all fields to be saved across server_redirect
    for ADD_rows.
  * Bivio::Biz::FormModel->validate is passed the form_button which was
    pressed.

  Revision 2.12  2004/03/02 13:31:02  nagler
  * Bivio::Agent::Task->handle_die cleanly emulates server_redirect
    when modifying exception state.
  * Bivio::Biz::FormModel->get_context_from_request was not checking
    context state correctly in minor case

  Revision 2.11  2004/02/26 23:42:54  nagler
  * Bivio::Biz::Model::ForbiddenForm checks executing task for
    require_explicit_su attribute.  If true, it will not automatically
    logout substituted users or substitute to new users
  * Bivio::Util::Release had some minor bugs in new functions

  Revision 2.10  2004/02/25 23:15:24  nagler
  * Removed Bivio::UI::WidgetValueSource change from previous release.
    It was not backwards compatible.
  * Bivio::Biz::ListModel->map_rows calls reset cursor
  * Bivio::UI::Facade->get_local_file_root returns local_file_root
  * Bivio::Util::Release->install_tar is the install compliment to build_tar

  Revision 2.9  2004/02/24 11:52:38  nagler
  * Login redirects are handled by Model.ForbiddenForm. Two new default
    tasks were added to Bivio::Delegate::SimpleTaskId, which need to be
    added to any facades that want automatic login redirects on
    forbidden.  Here's an example of what you need.

      $t->group(DEFAULT_ERROR_REDIRECT_FORBIDDEN => undef);
      $t->group(FORBIDDEN => undef);

    The DEFAULT_ERROR_REDIRECT_FORBIDDEN task calculates what to do
    when a forbidden exception is thrown.  The logic automatically
    logs out substituted users, and logs super users in to a different
    auth_realm.  This makes access simpler for administrators.  If
    you override Model.AdmSubstituteUserForm, you may not want these
    tasks on your system.  This change involved small changes to the
    Dispatcher, Task, and Request packages.  As a side effect,
    form_context is now saved when an exception is thrown that reaches
    Bivio::Agent::Task.
  * Bivio::UI::WidgetValueSource->get_widget_value now unwraps widget
    values until no more array_refs are returned.  There's a
    recursion limit of 10 to avoid infinite loops.  This may break your
    code.  Bivio::UI::Widget->unsafe_render_value no longer does the
    unwrapping.
  * Bivio::IO::Config->merge_list and merge_dir support Bivio::BConf.
    You can now have a bconf.d in a subdirectory of any *.bconf file,
    and Bivio::BConf will find it.  Bivio::BConf->dev calls merge_dir
    implicitly.  Bivio::BConf->merge_dir might be deprecated at
    some point.
  * Bivio::IO::Config->bconf_file returns the absolute name of the
    *.bconf used by the current process.  This is available to the
    *.bconf file and all files in bconf.d during config read.
  * Bivio::Biz::FormContext is now a Bivio::Collection::Attributes.
    This allowed more code to be pulled out of Bivio::Biz::FormModel.
  * Bivio::IO::Ref->nested_differences now returns the element by
    element differences when two arrays are of different lengths.
  * PetShop has a guest user as well as demo.  Used to test
    FORBIDDEN redirects.
  * Bivio::Type::DateTime->now_as_year returns the year of now,
    which is useful for copyrights and such.
  * Bivio::Type->is_equal calls compare() if $proto can compare.
    Otherwise defaults to a simple string compare.
  * Bivio::UI::LocalFileType->DDL added for completeness and to
    enable build_tar to be clean.
  * Bivio::Util::Release->build_tar supports building standard
    MakeMaker tar.gz distributions from a well structured bivio
    project.
  * Bivio::Util::Release.projects is new config of the form:
      projects => [
  	[Bivio => b => 'bivio Software, Inc.'],
      ],
  * Bivio::Util::Release->list_projects_el prints a list of projects
    from the new config parameter.
  * Bivio::Util::Release->list works on ordinary directories.
  * Bivio::Util::Release defaults more config params, and Bivio::BConf
    configures the rest to reasonable defaults.  This allows easier
    testing.

  Revision 2.8  2004/02/22 07:01:09  david
  Bivio::SQL::ListSupport - Can generate the GROUP BY clause in SQL
  based on the metadata in ListModel.
  Bivio::Type::Array->from_literal returns undef if the value passed in
  is not defined.

  Revision 2.7  2004/02/20 17:36:31  moeller
  * fixed bugs in Bivio::UI::Mail::Widget::Message recipient handling

  Revision 2.6  2004/02/19 22:24:40  david
  Bivio::Agent::Request removed unecessary widget handling.
  Bivio::Biz::Action::ECCreditCardProcessor now warns on errors while
  downloading the current transaction batch instead of skipping them
  completely.
  Bivio::Mail::Address->parse_list_strict parses a list of simple email
  addresses.
  Bivio::Type::Array now supports from_literal.
  Bivio::UI::HTML::Widget::MailTo->new now accepts an attributes
  hash_ref.
  Bivio::UI::Mail::Widget::Message no longer requires the recipients
  attribute to filled. If no recipients are specified, the attribute is
  filled with the contents of to and cc.

  Revision 2.5  2004/02/13 23:43:42  david
  * Bivio::Biz::Model::QuerySearchBaseForm->internal_pre_execute loads
  the default value of any fields that were not present on the form
  submission.
  * Bivio::Biz::Model::QuerySearchBaseForm->load_default_value is a
  convenience method that loads the default value into the given field.
  * Bivio::Test::Language::HTTP->verify_options verifies that a select
  field has a given set of options.
  * Bivio::Test::Language::HTTP->verify_table tests to see if given
  table has a certain set of rows.
  * Bivio::Test::Language::HTTP->verify_uri can now take a regular expression.

  Revision 2.4  2004/01/31 04:45:35  nagler
  * Bivio::SQL::Connection::Postgres handles SELECT.*AS with outer
    (left) joins
  * Bivio::SQL::Support improved some die messages
  * Bivio::PetShop::Test::PetShop->add_to_cart fixed single item case

  Revision 2.3  2004/01/29 17:55:43  david
  * Bivio::Biz::FormModel->get_stay_on_page
    Returns state of internal_stay_on_page.
  * Bivio::Biz::Model::QuerySearchBaseForm
    Now differentiates between unspecified and undefined
    values. Unspecified values are given the field's default
    value. Undefined values are not modified.
  * Bivio::Test::HTMLParser::Links
    Links are stored as attributes indexed by their labels.
  * Bivio::Test::Language::HTTP->verify_link
    Verifies that the href of the given link matches the pattern.
  * Bivio::Type and subclasses
    Undefined values now compare as equal.
  * Bivio::Type::DateTime->delta_days
    Returns the floating point difference between two DateTimes

  Revision 2.2  2004/01/17 13:00:00  nagler
  * Bivio::Test::Language->test_setup prints die msgs correctly
  * Bivio::Test::Util->nightly sets PERLLIB correctly
  * Bivio::UI::HTML::Widget::Page->render uses unsafe_render_attr on
    body's html_tag_attrs

  Revision 2.1  2004/01/09 01:20:04  nagler
  * Bivio::IO::Ref->nested_differences produces a recursive diff of two
    data structures with contextual clues.
  * Bivio::IO::Ref->to_string acepts an indent parameter which it passes
    to Data::Dumper::Maxdepth, default is 1 (as it was before).
  * Bivio::Test::Language::HTTP->verify_uri validates a uri is what it
    should be.
  * Bivio::Test::Request->initialize_fully correctly gets the current
    request if any
  * Bivio::Test::Util->nightly corrected to set PERLLIB
  * Bivio::Test->unit uses nested_differences to show delta between
    actual and expected.
  * Bivio::Type::FileName->from_literal calls SUPER to do text processing
  * Bivio::Type::String->compare treats undef same as '' (SQL like)
  * Bivio::Type::Enum->compare assumes undef and undef are equal, which
    is how SQL treats NULL in an order by

  Revision 2.0  2003/12/22 20:18:24  nagler
  Societas move

  Revision 1.89  2003/12/10 19:01:58  moeller
  * uses shorter argument format for sendmail calls in Bivio::Mail::Common
    and Bivio::Mail::Message
  * 'b-test nightly' will expunge old test directories

  Revision 1.88  2003/11/21 17:24:09  moeller
  * Bivio::Test::Util->nightly now gets latest tests from CVS and runs
    all acceptance tests

  Revision 1.87  2003/11/19 23:29:34  david
    * Bivio::Biz::Model::QuerySearchBaseForm provides generic ability to
      redirect post data as URL query data. Default values for form/query
      data can be specified as an attribute of the field definition.

  Revision 1.86  2003/11/04 19:20:10  nagler
  * Bivio::Agent::HTTP::Dispatcher wraps BSD::Resource calls in an eval
    Makes portable to cygwin/win3
  * Fixed some bad $VERSION values, which caused failures on Perl 5.8
  * Bivio::ShellUtil.daemon_child_priority removed.  This feature wasn't
    in use (afawk), and it caused portability problems.
  * Bivio::Test::Request->get_instance was broken in previous release
  * Bivio::Util::RealmAdmin->invalidate_password refactored
  * Bivio::Util::RealmAdmin->invalidate_email added
  * Bivio::Type::DateTime->gettimeofday fixed for portability to cygwin

  Revision 1.85  2003/10/27 19:33:56  nagler
  * Bivio::ShellUtil->run_daemon logs more
  * Bivio::SQL::FormSupport.default_value holds a default value for a
    field.  Eventually to be used by FormModel->execute_empty.
  * Bivio::IO::Ref->to_string allows you to set max_depth
  * Bivio::Test::Language::HTTP->submit_from_table allows you to submit
    from multi-button forms in tables
  * Bivio::UI::ViewLanguage modified to allow views to compile view code
    within executing views.

  Revision 1.84  2003/10/16 23:03:52  moeller
  * updated PetShop acceptance tests to look inside table cells
  * ShellUtil - reap children in start loop
  * Bivio::Test::Language::HTTP now handles file fields
  * added YesNo widget

  Revision 1.83  2003/10/16 02:15:53  nagler
  * Bivio::ShellUtil->run_daemon runs a series of commands in
    subprocesses with configured params such as daemon_max_children
    and daemon_sleep_after_start
  * Bivio::Util::SQL->vacuum_db_continuously runs postgres vacuumdb as
    as daemon process
  * Bivio::IO::ClassLoader no longer prints stack traces
  * Bivio::Test::Language::HTTP->verify_form validates form field values
  * Bivio::Test::Request->get_instance allows current to be cleared
  * Bivio::UI::HTML::Widget::YesNo creates Yes/No fields for a value

  Revision 1.82  2003/10/03 23:08:47  nagler
  * Bivio::SQL::ListQuery adds other_query_keys to the formatted query
  * Bivio::Test::HTMLParser::Forms handles textarea and checkboxes in
    tables without column headers correctly
  * Bivio::Test::Language::HTTP fills in defaults for checkboxes correctly

  Revision 1.81  2003/10/01 18:04:49  moeller
  * AdmMailBulletin now has TEST_MODE which only send the bulletin to support
  * AdmMailBulletin allows subclasses to change the message per email
  * removed DateInterval BEGINNING_OF_YEAR, END_OF_IRS_TAX_SEASON, and
    THREE_MONTHS. Added SIX_MONTHS.
  * Added DateTimeMode FULL_MONTH
  * LinuxConfig allow any program

  Revision 1.80  2003/09/25 15:29:24  nagler
  * Bivio::Biz::ListModel->load_page returns self
  * Bivio::Biz::Model::UserCreateForm->parse_display_names splits a
    display_name into first, middle, and last
  * Bivio::Delegate::SimpleAuthSupport and Bivio::Delegate::SimplePermission
    modified to support SUPER_USER_TRANSIENT permission
  * Bivio::IO::Alert->format_args was not handling object as_string
    correctly. Empty strings resulted in returning $object as a string.
  * Bivio::PetShop added support for tests of SUPER_USER_TRANSIENT
  * Bivio::Test::HTMLParser::Tables creates Bivio::Test::HTMLParser::Tables::Cell
    instances for each cell, and it parses Links for each cell making it
    easier to click on a table cell's value.  This change will result in
    exceptions in tests, and you need to use $cell->get('text') to get
    the data.  String conversion was overloaded to ease the upgrade
    process.
  * Bivio::Test::HTMLParser::Tables->do_rows adds a _row_index value to
    each row.  find_rows returns a row with the found index.
  * Bivio::Test::Language:HTTP->follow_link_in_table allows you to
    call a link in a table by value.
  * Bivio::Test::Request->initialize_fully calls setup_all_facades, not
    setup_facade
  * Bivio::UI::Facade->get_all_classes returns an array_ref of all
    simple package names for the facades.
  * Bivio::UI::Facade->setup_request($req) is new signature that allows
    you to setup a facade instance directly.
  * Bivio::UI::Facade->get_instance() returns the default facade
    (making get_default redundant).

  Revision 1.79  2003/09/23 20:31:01  nagler
  * Bivio::Biz::ListModel->map_rows is similar to map_iterate, but
    operates on a loaded ListModel.
  * Bivio::Biz::Model->iterate_map has been renamed to map_iterate
  * Bivio::UI::HTML::Widget::ListActions was not inserting a comma
    between list items.
  * b-realm-admin invalidate_password (Bivio::Util::RealAdmin) invalidates the
    auth_user's password.
  * Removed assertion in b-realm-admin reset_password for realm

  Revision 1.78  2003/09/09 17:52:19  nagler
  * Bivio::UI::HTML::Widget::ListActions->new accepts an array_ref for values
    and labels are wrapped as a String if not already a Widget
  * Bivio::Biz::ListModel.other_query_keys allows models to specify
    keys to be included in ListQuery instance attributes
  * Bivio::Biz::Model->iterate_map lets you iterate over a model and
    apply a function which returns an array_ref (similar to map).
  * Bivio::Biz::PropertyModel->execute_unauth_load_this supports
    model loading from tasks without "auth_id".

  Revision 1.77  2003/09/02 19:36:20  nagler
  * Bivio::SQL::Connection->CAN_LIMIT_AND_OFFSET identifies a connnection
    implementation as supporting LIMIT and OFFSET.  Postgres supports
    this SQL feature, and it makes ListModels perform better
  * Bivio::SQL::ListSupport.want_only_one_order_by allows a ListModel
    query to be limited to one ORDER BY value, which in certain cases
    with Postgres, improves performance.  Use warily, because it does
    change the semantics
  * Bivio::SQL::Connection->get_instance replaces create().  create()
    cached instances, so it has been deprecated.
  * files/ddl/bOP*.sql has been updated to include e-commerce support and
    address and phone tablesN
  * Bivio::Test::Language->test_deviance accepts a regular expression
    that must match the Bivio::Die->as_string value, or the deviance
    test fails.
  * Bivio::Type::Date->compare removed

  Revision 1.76  2003/08/19 18:39:19  david
  * Added Bivio::Type::Date->compare to compare two DateTimes only with
    respect to their dates.

  Revision 1.75  2003/08/14 21:11:51  moeller
  * added Model.Lock->execute_general to allow locking the whole database
  * SimpleWidgetFactory now renders links conditional on the task
    being executable by the current user

  Revision 1.74  2003/08/11 21:36:43  moeller
  All form fields are printed on error, except secure fields.
  Added REALM_DATA LocalFileType.
  Added b-realm-admin reset_password.

  Revision 1.73  2003/07/22 22:32:11  moeller
  b-sendmail now receives domain
  mozilla considered a modern browser
  FormField fixup

  Revision 1.72  2003/07/10 21:16:59  nagler
  * Bivio::UI::HTML::Widget::Select quotes option values (handles empty
    string case)
  * Bivio::Agent::Request->internal_server_redirect handles
    ListQuery.attr format for queries

  Revision 1.71  2003/07/09 23:18:43  nagler
  * Bivio::UI::HTML::Widget::SelectSearch encapsulates selecting a
    search value from a list.
  * Bivio::Biz::Model->get_qualified gets "Model.field" or "field"
    from current model.  Useful if you aren't sure if the field is
    coming from a ListModel or PropertyModel

  Revision 1.70  2003/07/02 21:34:50  nagler
  * Added b-realm-role back into release after it was accidently deleted.
  * Bivio::UI::HTML::Widget::Table.source_name can be a widget value
    which is evaluated in context of $source.  This allows tables
    within tables to be relative to the ListModel fields of their
    parents.
  * Bivio::Biz::FormModel->get_button_sumbitted as it is redundant
  * Bivio::Biz::ListModel.want_select_distinct is a new attribute that
    allows SELECT DISTINCT queries for ListModels.
  * Bivio::UI::HTML::Widget::FormButton accepts positional arguments, e.g.
    FormButton('ok_button');

  Revision 1.69  2003/06/25 23:50:33  nagler
  * Bivio::IO::Log reads/writes (compressed) log files
  * Bivio::Biz::Action::ECCreditCardProcessor uses Bivio::Ext::LWPUserAgent
  * Bivio::Ext::LWPUserAgent supports a configurable timeout
  * Bivio::IO::File->read/write/append allows glob_refs and IO::File
    objects to be passed. Also refactored to share much more code.
  * Bivio::SQL::Connection::Postgres handles multiple table/column left joins
  * Bivio::SQL::ListSupport.from allows you to override the generated
    FROM clause.  Use sparingly.
  * Bivio::Test::HTMLParser had a variety of bug fixes and refactorings
  * Bivio::Test::HTMLParser::Tables->do_rows accepts a closure to iterate
    all rows.  Also find_row() for finding a specific row.
  * Bivio::Test::Language::HTTP->do_table_rows is shortcut for above
  * Bivio::Test::Language::HTTP->get_uri returns the uri for current page
  * Bivio::Test::Language::HTTP->home_page accepts a facade_uri argument
  * Bivio::Test::Language prints script name and line number on errors
  * Bivio::UI::Mail::Widget::Message.log_file uses Bivio::IO::Log to
    write a log of a message.
  * Bivio::UI::Widget->unsafe_render_value will convert a reference to
    a string
  * Bivio::Util::Release supports rpm proxy like LWP ($ENV{http_proxy})
  * Bivio::UI::Widget::Director.control can be a nested widget value
    (uses render_attr)

  Revision 1.68  2003/06/10 23:39:29  nagler
  * Bivio::Collection::Attributes->ancestral_get uses "exists" instead
    of "defined".  Was impossible to undef an attribute before.

  Revision 1.67  2003/06/09 23:33:24  nagler
  * Bivio::UI::HTML::Widget::Link supports undefined hrefs, which print
    nothing.  You can say Link('label', 0, {name => 'hello'}) to create
    an anchor called hello.  'hello' may be any widget value or widget.
  * Fixed bug in ListModel iterator with converter

  Revision 1.66  2003/06/06 22:28:04  nagler
  * Bivio::UI::Text::Widget::CSV renders comma separated version views

  Revision 1.65  2003/06/06 22:17:39  nagler
  * b-sendmail-http allows recipient to contain domain name
  * Bivio::Biz::ListModel->iterate_next was not including auth_id and
    parent_id fields
  * Bivio::Test::Request->setup_all_facades allows testing of different facades
  * Bivio::UI::HTML::Widget::JavaScript->render was adding spurious newlines
    which would create unexpected spaces

  Revision 1.64  2003/05/30 22:48:56  nagler
  * MAJOR INCOMPATIBLE CHANGE: Bivio::UI::Facade defines http_host and
    mail_host.  Formerly, Bivio::UI::Text controlled these values.  Use
    vs_mail_host(); in views to get mail_host (was vs_text('mail_host')).
    *::BConf needs to define http_suffix and mail_host for
    Bivio::UI::Facade.  See Bivio::PetShop::BConf for an example.
  * Bivio::Biz::Model::MailReceiveDispatchForm sets the facade based on
    the incoming mail host (if available).
  * Bivio::UI::Facade->setup_request accepts a domain name.  Expects
    that a domain component matches one facade's uri or uses default
    facade.  For example, petshop.bivio.biz matches uri "petshop".
  * Bivio::Util::LinuxConfig->add_sendmail_http_agent should be rerun
    (b-linux-config add_sendmail_http_agent your-host:80/bla/%s) to
    update your sendmail.cf to allow facade matching.  The changes
    to sendmail.cf are significant but minimal.

  Revision 1.63  2003/05/13 23:06:44  nagler
  * Bivio::UI::HTML::Widget::AmountCell.want_parens attribute added
  * Bivio::UI::Mail::Widget::Message.want_aol_munge attribute added and
    added support for Bivio::UI::Widget::MIMEEntity
  * Bivio::UI::Widget::MIMEEntity constructs MIME 1.0 entities from a
    list of widgets

  Revision 1.62  2003/05/08 21:48:22  moeller
  added explicit length checking on posted form data
  don't set cookie domain unless $_CFG->{domain}
  allow SimpleWidgetFactory to be subclassed
  added warnings when from_literal() is called in scalar context
  Checkbox now has an event_handler

  Revision 1.61  2003/04/24 03:04:56  moeller
  PersistentCookie uses domain from facade first, config second

  Revision 1.60  2003/04/23 22:42:20  moeller
  added warning if Type->from_literal() called in scalar context
  allow facades URIs with '.'

  Revision 1.59  2003/04/15 23:20:39  moeller
  readonly text fields are 'disabled' again

  Revision 1.58  2003/04/14 11:32:58  nagler
  * Bivio::Util::LinuxConfig->ifcfg_static fixed /etc/hosts creation
  * Bivio::ShellUtil->lock_action fixed deprecated lock (wasn't passing
    lock name).

  Revision 1.57  2003/04/10 23:11:44  moeller
  added ECSecureSourceProcessor credit card processor

  Revision 1.56  2003/04/05 13:12:00  nagler
  * Bivio::Agent::HTTP::Reply removed custom error returns for perl
    5.6.* and up.  Also removed hardwired hostname (bivio.com)
  * Bivio::UI::HTML::Widget::Text.is_read_only maps to html 'readonly' attribute
  * Bivio::Util::LinuxConfig->ifcfg_static configures static IP addrs
  * Bivio::Util::LinuxConfig->resolv_conf writes resolv.conf

  Revision 1.55  2003/04/01 17:35:06  nagler
  * Bivio::BConf added more standard ignored errors
  * Model.UserCreateForm will not create email if Email.email is
    Bivio::Type::Email->IGNORE_PREFIX
  * Bivio::Biz::Model->new accepts a name as first argument, e.g.
    Bivio::Biz::Model->new('RealmOwner'), and will use
    unsafe_get_request for instance's request.  Best to call as
    $self->new('RealmOwner').
  * Bivio::SQL::ListSupport allows primary_key to be local field,
    but you can't call load_this on the model.
  * Bivio::UI::HTML::Widget::Checkbox allows '' as label and
    won't output any string or extra newline.
  * Bivio::Util::SQL->run_command appends commit or rollback to
    SQL command before executing (depends on -noexecute value).

  Revision 1.54  2003/03/28 12:24:47  nagler
  * Bivio::HTML::Scraper->unescape_html replaces ISO-8859-1 non-breaking spaces
    (\240) with ordinary spaces (\40).
  * Bivio::BConf->merge_http_log ignores more errors unless count reached.

  Revision 1.53  2003/03/26 19:28:02  moeller
  UserCreateForm is now flexible with display_name

  Revision 1.52  2003/03/25 00:45:30  nagler
  * Bivio::Util::HTTPLog.ignore_unless_count added experimentally to
    control matching of messages which are sometimes interesting.
  * Bivio::Util::LinuxConfig deletes the backup file before writing.
  * Bivio::BConf added more http_log entries

  Revision 1.51  2003/03/24 23:11:15  moeller
  changed lost password query arg from 'p' to 'x'

  Revision 1.50  2003/03/24 01:21:10  nagler
  * Bivio::SQL::Connection::None is the default database connection

  Revision 1.49  2003/03/24 00:51:41  nagler
  * Bivio::BConf->merge_class_loader and merge_http_log ease
    configuration by merging arrays of values with defaults.
  * Bivio::IO::Config->merge prefixes arrays in values if parameter
    (merge_arrays) is passed.

  Revision 1.48  2003/03/23 13:37:19  nagler
  * Bivio::UI::HTML::Widget::Hidden allows you to add hidden fields.

  Revision 1.47  2003/03/23 13:35:44  nagler
  * Bivio::Util::HTTPLog (b-http-log) allows you to monitor Apache logs
    for repeated errors and crticial errors
  * Bivio::ShellUtil->lock_action supports locking closures with
    checking for process aliveness.  Old usage (locking by subprocess)
    is deprecated.

  Revision 1.46  2003/03/21 13:39:54  nagler
  * Bivio::SQL::ListSupport allows internal_pre_load to return a where
    clause which includes the FROM.  Allows for complex Postgres LEFT JOIN
    statements.

  Revision 1.45  2003/03/20 00:12:57  nagler
  * Bivio::IO::Alert.max_element_count configures number of hash/array
    elements displayed in formatted messages.n
  * Bivio::SQL::Connection forces commit or rollback for Postgres
    connections even if no DML is executed.  Postgres requires rollback
    in the event of DQL errors.
  * Bivio::ShellUtil->lock_action accepts a closure.  Deprecated form
    would use a subprocess, which isn't practical in web servers.
  * Bivio::Util::LinuxConfig->serial_console accepts the speed to configure
  * Bivio::Util::LinuxConfig->rename_rpmnew accepts a list of directories
  * Fixes to Bivio::Util::SQL and Bivio::Biz::Model::UserPasswordForm

  Revision 1.44  2003/03/14 23:17:10  moeller
  added Bivio::Biz::Model::UserPasswordForm

  Revision 1.43  2003/03/14 00:44:15  nagler
  * Bivio::Type::Number uses Math::FixedPrecision.  If you are using Red
    Hat 7.2, you need to install newer Math::BigInt package.
  * Bivio::IO::Alert shows more elements of arrays and hashes

  Revision 1.42  2003/02/26 19:38:15  nagler
  * Bivio::Util::SQL->import_db revised to work with Postgres 7.3 and
    reinitializes sequences properly.
  * Bivio::Util::Release->install execs rpm with all packages so that
    RPM handles dependencies.
  * Fixed Bivio::Util::LinuxConfig->append_lines, wasn't converting $perms
  * Bivio::Type::Month was missing the merry month of May
  * Bivio::Test::Language->test_conformance added
  * Bivio::SQL::Connection->ping_connection added
  * Bivio::SQL::Connection::Postgres handle 'server closed the
    connection unexpectedly' error

  Revision 1.41  2003/02/13 13:36:19  nagler
  * Bivio::BConf sets TestLanguage map to Bivio::Test::Language by default
  * Bivio::Biz::ListFormModel->execute_ok passes $button to execute_ok_*
  * Bivio::Biz::ListModel calls Bivio::Type->get_instance('PageSize') instead
    of hardwiring Bivio::Type::PageSize
  * Bivio::Test::HTMLParser::Forms.error_color is configurable
  * Bivio::UI::HTML::Widget::MathHandlerBase manipulates fields with commas
  * Bivio::XML::DocBook upgraded to match book example and added real xrefs

  Revision 1.40  2003/01/29 16:44:05  nagler
  * Bivio::SQL::Connection::Postgres supports BYTEA (BLOB) types
  * Bivio::Test::Language::HTTP->get_content returns current response content
  * Bivio::UI::HTML::Widget::String render text dynamically, always
  * Bivio::UI::LocalFileType->CACHE added
  * Bivio::Util::LinuxConfig->append_lines adds lines to any file,
    creating if necessary

  Revision 1.39  2003/01/20 23:29:26  nagler
  * Bivio::UI::HTML::Widget::ScriptOnly added
  * Bivio::Type::Secret escapes magic
  * Bivio::Biz::Model::UserCreateForm: deleted warning

  Revision 1.38  2003/01/20 20:58:30  nagler
  * Bivio::Biz::Model::UserCreateForm defaults email (ignore) and password (invalid)
  * Bivio::SQL::ListSupport.select_value lets you override value in SQL
    select statement.   Handy for creating min/max fields or subqueries.
  * Bivio::Test::Request->setup_http preserves query/path_info if supplied.
  * Bivio::UI::HTML::Widget::DateTime formats font dynamically (like String)
  * Bivio::UI::HTML::Widget::FormButton.label allows override default label
  * Bivio::UI::HTML::Widget::FormField.form_field_label can be set explicitly
  * Bivio::UI::HTML::Widget::JavaScript->has_been_rendered returns true
    if widget has been rendered in this request.
  * Bivio::UI::HTML::Widget::JavaScript->escape_string escapes contents
    of a single quoted JS string
  * Bivio::UI::HTML::Widget::Link.event_handler added
  * Bivio::UI::HTML::Widget::Table.column_want_error_widget allows
    override of default value (based on form field type)
  * Bivio::UI::HTML::Widget::Text.is_read_only allows override of
    is_field_editable().
  * Bivio::DocBook::XML various formatting and functional programming changes

  Revision 1.37  2003/01/07 12:59:40  nagler
  * Improved workflow of PetShop check out
  * Cleaned up some of the view implementations in PetShop
  * Bivio::IO::File->rm_rf added
  * Bivio::PetShop::Test::PetShop expanded tests
  * Bivio::Test::HTMLParser::Forms defaults values for <select> and
  * <radio>
  * Bivio::Test::Language::HTTP->visit_uri replaces goto_uri
  * Bivio::Test::Language::HTTP->follow_link replaces goto_link
  * Bivio::Test::Language::HTTP->submit_form defaults values from parsed
  * form
  * Bivio::Test::Language->test_deviance added
  * Bivio::Test::Language log files are written to subdirectory
  * Bivio::Type::DateInterval->THREE_MONTHS added
  * Bivio::Type::ECCreditCardExpYear starts at 2003
  * Bivio::UI::HTML::ViewShortcuts->vs_escape_html added
  * Bivio::UI::HTML::Widget::Grid.id attribute added
  * Bivio::UI::Task->format_uri defaults to realmless_uri if realm not
    supplied, but is required

  Revision 1.36  2002/12/21 05:29:11  nagler
  * b-sendmail-http strips +.* off names before passing to local delivery agent
  * Bivio::Biz::ExpandableListFormModel adds more context on
    server_redirect (works with forms with query strings and path_info)
  * Bivio::Biz::Model::MailReceiveDispatchForm->parse_recipient strips
    +.* from name
  * Bivio::Biz::Model::UserLoginForm->substitute_user redirects to su_task
    if exists or ADM_SUBSTITUTE_USER if not
  * Bivio::Biz::Util::ListModel->csv (b-list-model csv) iterates list
    if can_iterate, so can handle lists larger than MAX_SIZE
  * Bivio::Util::LinuxConfig->disable_service ignores errors
  * Bivio::Util::Release file exclude test ignores errors when no files

  Revision 1.35  2002/12/16 22:20:30  nagler
  * Bivio::Biz::ExpandableListFormModel->ROW_INCREMENT overridable
  * Bivio::Biz::FormModel->internal_catch_field_constraint_error added
  * Bivio::Biz::ListFormModel->execute_end can return a Task transition
  * Bivio::Test::Request->get/put_form added
  * Bivio::Type::DateTime->date_from_parts_or_die added
  * Bivio::UI::DateTimeMode->FULL_MONTH_AND_YEAR_UC and widget support added
  * Bivio::UI::HTML::Widget::FormField wraps label in String widget
  * Bivio::Util::LinuxConfig->add_user checks uid correctly

  Revision 1.34  2002/12/10 04:49:50  nagler
  * AdmSubstituteUserForm clears query before redirect

  Revision 1.33  2002/12/06 23:47:09  nagler
  * Bivio::UI::Mail::Widget::Message allows you to set arbitrary headers
  * Bivio::UI::PDF::* solidifying, but still experimental
  * Bivio::UI::HTML::FormErrors supports _mail_to links
  * Bivio::Test::Request->execute_task captures mail and sets JobBase sentinel
  * Bivio::Test::Request->capture_mail provides messages committed in a ShellUtil
  * Bivio::Biz::Action::JobBase->set_sentinel added (supports b-test task)
  * Bivio::UI::Facade->is_fully_initialized bug fix

  Revision 1.32  2002/12/01 22:16:29  nagler
  * Bivio::Biz::Action isa Bivio::Collection::Attributes
  * Bivio::IO::Alert.max_arg_depth is config parameter (was hardwired to 3)
  * Bivio::ShellUtil uses Bivio::Test::Request for cleaner exec environment
  * Bivio::Test::Request->execute_task allows task testing
  * b-test task allows you to call above from command line
  * Bivio::Test.create_object renamed from compute_object
  * Bivio::Test.want_scalar forces scalar context for method invocation
  * Bivio::Test accepts a Bivio::DieCode in no param case, e.g.
       my_method => Bivio::DieCode->DIE
  * Bivio::UI::PDF provides basic PDF support (requires http://www.pdflib.com)

  Revision 1.31  2002/11/20 03:42:55  nagler
  * Bivio::UI::Facade->is_fully_initialized added.
  * Infrastructure modules (Task* and PropertySupport) added documentation
  * Bivio::IO::ClassLoader->unsafe_simple_require imports silently
  * Bivio::Mail::Address->parse handles invalid RFC822 impls
  * Bivio::PetShop::Agent::TaskId->DEFAULT_ERROR_REDIRECT_MISSING_COOKIES added
  * Bivio::Test.create_object renamed from compute_object
  * Bivio::Test.class_name adds a create_object for the class
  * Bivio::Test.check_return can return a Regexp (better code sharing, too)

  Revision 1.30  2002/11/08 22:36:52  nagler
  * Bivio::Biz::Model::MailReceiveDispatchForm supports alternative
    authentication methods
  * Bivio::Agent::Task/Id has better documentation
  * Bivio::SQL::Connection error handling improved
  * Bivio::Test allows subroutine for object (compute_object)
  * Bivio::UI::HTML::Widget::Radio allows dynamic labels and positional
    arguments

  Revision 1.29  2002/10/31 00:32:44  nagler
  * Bivio::Biz::Model::MailReceiveDispatchForm no longer accepts Reply-To:
  * Bivio::UI::ViewLanguage improved error messages

  Revision 1.28  2002/10/28 00:57:25  nagler
  * Bivio::Biz::Action::JobBase allows easy job scheduling
  * Bivio::Biz::Action::ECPaymentProcessAll uses JobBase
  * Bivio::Type::Location delegates to Bivio::Delegate::SimpleLocation
  * Bivio::IO::Alert no longer import MIME::Parser.  use
    Bivio::Ext::MIMEParser to avoid warnings (on older perls)
  * Bivio::ShellUtil->lock_action allows global (file) locks on commands/actions
  * Bivio::UI::HTML::Widget::Table.column_bgcolor sets color on column

  Revision 1.27  2002/10/25 03:01:33  nagler
  * Bivio::Auth::Realm->is_default_id added
  * Bivio::Biz::Action::LocalFilePlain->execute_favicon added
  * Bivio::Delegate::SimpleTaskId->FAVICON_ICO added
  * Bivio::Ext::DBI changed die to warning on connection errors
  * Bivio::SQL::Connection->execute changed catch back to eval

  Revision 1.26  2002/10/23 22:48:20  nagler
  * Bivio::Biz::Model::MailReceiveDispatchForm.parse_recipient parses x-x.realm correctly
  * Bivio::Biz::Model::UserLoginForm::_assert_login/realm check for invalid password
  * Bivio::Ext::DBI prints better error messages when bad config
  * Bivio::Math::EMA->value returns value of EMA at any time
  * Bivio::Test::HTMLParser::Forms and Bivio::Test::Language::HTTP minor bugs

  Revision 1.25  2002/10/18 05:17:56  nagler
  * Bivio::UI::HTML::Format::Printf added

  Revision 1.24  2002/10/18 03:27:00  nagler
  * Bivio::Biz::Action::MailReceiveStatus missed last release

  Revision 1.23  2002/10/18 03:23:11  nagler
  * Bivio::Biz::Model::MailReceiveDispatchForm missed last release

  Revision 1.22  2002/10/18 03:14:38  nagler
  * bOP-sequences CACHEs 1, because Postgres caches on client
    side and sequences were growing by 10 every server restart.
  * account.bview includes a better disclaimer
  * Bivio::Biz::Model::UserLoginForm accepts name, email, or realm_id for
    login field.  Executed directly (from another class), it accepts
    "login" or "realm_owner".
  * Bivio::Agent::HTTP::Request removed Bivio::Auth::Support.  Handled
    by Cookie now.
  * Bivio::Agent::Job::Request sets redirect state, but doesn't throw
    exception when ignore_redirects is true.  ignore_redirects can be
    turned on and off.
  * Bivio::Agent::Request->set_user no longer uses dont_set_role parameter.
    Handled from context in request.
  * Regularized support for substitute/super users.  See Bivio::Agent::Request
    and Bivio::Biz::Model::AdmSubstituteUserForm.
  * Bivio::Agent::Task->execute checks return value of executables
    for TaskId or Task attribute which is a TaskId.  Calls
    client_redirect to that task_id.
  * Bivio::Agent::Task->new accepts want_* and require_* as arbitrary
    boolean attributes and *_task as TaskId attributes.  Allows TaskId
    table to contain all state transitions.
  * Bivio::Biz::Action::ClientRedirect simplified due to Task->execute change.
  * Bivio::Biz::Action::ECCreditCardProcessor escapes card_zip in
    command string.
  * Bivio::Biz::ListModel->iterate_start stores the iterator with the
    Model instance, so you no longer have to pass it in.  All iterate_*
    routines are backwards compatible with old style calling syntax.
  * Bivio::Biz::Model::MailReceiveBaseForm->execute_empty dies if
    called.
  * Bivio::Biz::Model->internal_initialize can return an as_string_fields
    attribute, which allows you to customize debug (as_string) output.
  * Bivio::Biz::PropertyModel->create_from_literals converts literals
    using types for the model.  Makes it convient when calling with
    the command line parameters.
  * Bivio::ShellUtil->convert_literal added.
  * Bivio::Biz::PropertyModel->unauth_load_parent_from_request added.
  * Bivio::Biz::Util::RealmRole->un/make_super_user added.
  * Bivio::Collection::Attributes->internal_put returns self.
  * Bivio::Delegate::NoCookie->assert_is_ok added.
  * Bivio::Delegate::PersistentCookie has more robust error checking
  * Bivio::Delegate::SimpleTypeError added OFFLINE_USER and CONFIRM_PASSWORD
    and DOMAIN_NAME
  * Bivio::Ext::LWPUserAgent->new accepts want_redirects.
  * Bivio::IO::Ref->to_scalar_ref added
  * Bivio::Biz::Model::MailReceiveDispatchForm added along with
    Bivio::Biz::Action::MailReceiveStatus.  See Bivio::PetShop::Agent::TaskId
    for usage.
  * PetShop has demo user.
  * Bivio::SQL::Connection::Postgres has better SQL parsing/conversions.
  * Bivio::ShellUtil is more testable.
  * Bivio::Test::Case->actual_return added.
  * Bivio::Test::Language::HTTP->get_html_parser added.
  * Bivio::Test::Request support http, facades, etc.
  * Bivio::Test->unit prints number of tests passed (sharing code
    with Bivio::Util::Test).
  * Bivio::Test.check_die is now Bivio::Test->check_die_code
  * Bivio::Test.method_is_autoloaded avoids "can" check
  * Bivio::Test.compute_object allows dynamic object creation from params
  * Bivio::Type::String tests string length
  * Bivio::Type::Enum->execute accepts a put_durable boolean param
  * Bivio::Type::UserAgent->execute accepts a put_durable option
    (true by default)
  * Bivio::UI::HTML::Widget::String->render support truly dynamic
    fonts (can be widget values).
  * Bivio::UI::View->execute accepts a string_ref (used for testing)
  * Bivio::Util::LinuxConfig->add_sendmail_http_agent added
  * Bivio::Util::SQL->ddl_files accepts base names (see
    Bivio::PetShop::Util
  * Bivio::Test::Reply added

  Revision 1.21  2002/09/11 03:33:23  nagler
  * Bivio::Test::Language::HTTP->home_page_uri returns configured URI
  * Bivio::Test had major API change to simplify anonymous
    compute_params and check_return.  Still needs documentation.
  * Bivio::Test::Case holds state of unit test, which allows cleaner
    check_return and compute_params.
  * Bivio::Agent::Request->set_realm accepts "undef" to mean GENERAL realm
  * Fixed formatting of some Pet Shop views
  * Bivio::Biz::Action::ECCreditCardProcessor sends card_zip for AVS
  * Bivio::Biz::ListModel won't check for Request's auth_id if List
    doesn't have one.
  * Bivio::Biz::Model::Email->execute_load_home loads HOME email
  * Bivio::Ext::LWPUserAgent doesn't let LWP::UserAgent redirect
    automatically.  LWP::UserAgent API change causes certain redirects
    to not show up unless redirect_ok() returns false.
  * Bivio::Ext::LWPUserAgent turns on LWP::Debug if tracing on
  * Bivio::IO::Ref->nested_equals compares structures (moved from Bivio::Test)
  * Bivio::IO::Ref->to_short_string gives brief summary of structure
  * Bivio::PetShop::Action::UserLogout works around a Postgres bug
    when a row is added and deleted in same transaction.
  * Fix to Pet Shop cart management when no cookies.  Used to create
    carts always, even if cookies not turned on.
  * Added paging to Pet Shop
  * Bivio::PetShop::Model::UserAccountForm now can be directly executed
  * Bivio::Type::Secret supports de/encrypt_http_base64, which
    uses Bivio::MIME::Base64 to encode HTTP-safe values.
  * Bivio::UI::Font allows style attributes
  * Bivio::UI::HTML::Widget::AmountCell.pad_left attribute added
  * Bivio::UI::HTML::Widget::ClearDot->new supports attributes
  * Bivio::UI::HTML::Widget::DateField.handler is dynamically rendered
  * Bivio::UI::HTML::Widget::Grid.{background,hide_empty_cells,height} added
  * Bivio::UI::HTML::Widget::Page.background is dynamically rendered
  * Bivio::UI::HTML::Widget::Select.handler is dynamically rendered
  * Bivio::UI::HTML::Widget::Style.other_styles added
  * Bivio::UI::HTML::Widget::Table.{row_bgcolor,id} added
  * Bivio::UI::HTML::Widget::Text.handler is dynamically rendered
  * Bivio::UI::HTML::Widget::Title->new accepts value as first arg
  * Bivio::UI::Icon->format_html_attribute returns icon name in HTML attr

  Revision 1.20  2002/07/26 21:58:48  nagler
  * Bivio::Delegate::PersistentCookie needs to use $r

  Revision 1.19  2002/07/26 17:53:29  nagler
  * Fixed remote_ip computation in Bivio::Agent::Request when req via proxy
  * Bivio::BConf->dev/merge_overrides receives host, user, http_port
  * Bivio::BConf->merge_dir read /etc/bconf.d/*.bconf for config
  * Bivio::Delegate::PersistentCookie doesn't send cookie if in another domain
  * --Bivio::IO::Config.trace=1 will produce a config dump at program start
  * Bivio::IO::Config->introduce_values now calls handle_config
  * Bivio::IO::File->chmod & chown_by_name added
  * Bivio::ShellUtil->group_args added
  * Bivio::Test::Language::HTTP->debug_print added; fixed a few bugs
  * Bivio::Test allows custom result_ok on individual test cases
  * Bivio::UI::HTML::Widget::DateTime supports FULL_MONTH_DAY_AND_YEAR_UC
  * Bivio::UI::HTML::ViewShortcuts->vs_blank_cell accepts count for spaces
  * Bivio::Util::Release: added _b_release_files() to spec files
  * Bivio::Util::Release->list_installed allows you to grep custom built pkgs
  * Bivio::Util::SQL->export/import_db added (Postgres only)
  * Bivio::XML::Docbook supports literallayout

  Revision 1.18  2002/06/27 17:43:34  nagler
  * Bivio-bOP.spec makes html publicly readable
  * Bivio::Agent::Request set_user/set_realm return their args
  * Bivio::Test::Language::HTTP supports HTTP acceptance testing
  * Bivio::BConf include Bivio::Test::Language::HTTP
  * Bivio::PetShop::Test::PetShop uses Bivio::Test::Language::HTTP
  * Bivio::Test::HTMLParser::Forms/Links now work
  * Bivio::Test::Language added logging
  * Bivio::Test cases accept a code_ref for expected which does compare

  Revision 1.17  2002/06/22 22:32:54  nagler
  * PetShop facade not "is_production"

  Revision 1.16  2002/06/14 23:53:15  nagler
  * Bivio::Test::HTMLParser::Forms->get_by_field_name added.
  * Bivio::Test::HTTP::Page supports redirects correctly
  * Bivio::Test::Util (b-test) works around bug in File::Find
  * Bivio::UI::HTML::Widget::Grid bgcolor and cell_bgcolor can be widget
    values.
  * Bivio::UI::Icon supports PNG.
  * Bivio::Ext::LWPUserAgent added (missing in last release)

  Revision 1.15  2002/06/07 23:13:36  nagler
  * EC (e-commerce) classes added which supports authorize.net
  * Bivio::BConf sharing config improved.
  * Bivio::Collection::Attributes->get_nested now recurses into Attributes
  * Bivio::Delegate::SimplePermission has ADMIN_WRITE and ADMIN_READ
  * Bivio::Util::SQL (b-sql) supports subclassing (better sharing)
  * Bivio::Test::Util (b-test) searches for unit tests recursively
  * Bivio::Test::Language fully implemented (no petshop examples)
  * Bivio::UI::HTML::Widget::Link renders TaskId values dynamically
  * Bivio::UI::HTML::Widget::Table renders headings in <th> (helps with testing)
  * Bivio::UNIVERSAL->inheritance_ancestor_list returns classes ancestors
  * Bivio::ShellUtil supports subclassing of utilities
  * Bivio::UI::HTML::Widget::FormField uses FormFieldLabel instead of String
  * Misc bug fixes

  Revision 1.14  2002/05/08 14:54:14  nagler
  * Added Bivio::Util::Backup (b-backup) which supports configured rsync mirroring
  * Added an include option to Bivio::Util::Release (b-release)
  * Minor bugs fixed

  Revision 1.13  2002/05/03 18:54:56  nagler
  * Some files didn't get updated in 1.12.

  Revision 1.12  2002/05/03 18:05:06  nagler
  * Fixed Bivio-bOP.spec (once again :-)
  * Fixed login and add to cart problems
  * Improved README demo instructions and added two more FAQs
  * Bivio::Util::Release more flexible and added support for perl

  Revision 1.11  2002/04/30 18:18:29  nagler
  * Runs better on Win32 (changes to Bivio::IO::File,
    Bivio::Type::DateTime, and Bivio::Agent::Dispatcher)
  * Mail is now a txn_resource in Bivio::Agent::Task
  * Bivio::Biz::ListModel->internal_load allows empty query
  * Bivio::Biz::Model->merge_initialize_info supports PropertyModel
  * Bivio::UI::HTML::Widget enhancements (Grid, MailTo, Page, Radio,
    RadioGrid, Select, Table)
  * Bivio::Util::Release->build can be run as any user, %{cvs} quieter
  * Bivio::XML::DocBook->count_words added and to_html enhanced.

  Revision 1.10  2002/04/01 23:40:50  nagler
  * Dynamically generated RPM spec file's version

  Revision 1.9  2002/04/01 22:53:22  nagler
  * Added RPM specfile: Bivio-bOP.spec
  * Some bug fixes

  Revision 1.8  2002/02/21 00:54:42  nagler
  * Bivio::Biz::ListModel->internal_post_load_row now returns a boolean,
    which allows lists to delete rows on iteration and loads.
  * Bivio::ShellUtil->piped_exec_remote uses ssh to execute remote calls
    like piped_exec
  * Added Bivio:::SQL::Connection->get_dbi_config
  * Fixed installation bugs (thanks Bob Sidebotham <bob@organic-connect.com>)

  Revision 1.7  2002/01/23 04:54:23  nagler
  * License Change: We changed the license to LGPL.
  * Changed instance data to array_ref from hash_ref for efficiency and
    more type safety (See Bivio::UNIVERSAL)
  * Added support for SQL "IN ()" for PropertyModel iterators
    and load queries.  Bivio::Type->to_sql_param_list is called by
    Bivio::SQL::PropertySupport if the query value is an array_ref.
  * Bug fixes.

  Revision 1.6  2001/12/27 18:49:52  nagler
  Moved Model.UserLoginForm, Action.UserLogout, Delegate.PersistentCookie from
  PetShop.
  Bug fixes.

  Revision 1.5  2001/12/12 03:27:46  nagler
  Added more packages (Types and HTMLWidgets)
  Various bug fixes

  Revision 1.4  2001/11/20 21:38:32  nagler
  Renamed bivio.net -> bivio.biz
  Added Bivio::bOP as source of version number
  Bug fixes and enhancements which we'll try to keep better track of.


=head1 COPYRIGHT

Copyright (c) 2001-2011 bivio Software, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
