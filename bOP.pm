# Copyright (c) 2001-2002 bivio Software Artisans, Inc.  All Rights reserved.
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

Copyright (c) 2001-2002 bivio Software Artisans, Inc.  All Rights reserved.

=head1 COPYRIGHT

$Id$

=head1 VERSION

$Id$

=cut

1;
