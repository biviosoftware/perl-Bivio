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
