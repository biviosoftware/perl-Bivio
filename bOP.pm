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
