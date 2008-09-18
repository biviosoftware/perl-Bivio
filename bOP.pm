# Copyright (c) 2001-2008 bivio Software, Inc.  All Rights reserved.
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

Copyright (c) 2001-2006 bivio Software, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
