# Copyright (c) 2001-2005 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::bOP;
use strict;
$Bivio::bOP::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::bOP::VERSION;

=head1 NAME

Bivio::bOP - bivio OLTP Platform (bOP) overview and version

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::bOP;

=cut

use Bivio::UNIVERSAL;
@Bivio::bOP::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<bOP> is a multi-dimensional, application framework.  At the highest level,
bOP provides support for web-delivered applications based on a
Model-View-Controller (MVC) architecture.  At the lowest level, bOP provides a
cohesive infrastructure for any Perl application.

We'll be writing more here later.  Please visit
http://www.bivio.biz for more info.

=cut

#=IMPORTS

#=VARIABLES

=head1 CHANGES

  $Log$
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
  	[Bivio => b => 'bivio Software Artisans, Inc.'],
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


=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

$Id$

=head1 VERSION

$Id$

=cut

1;
