# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::bOP;
use strict;
$Bivio::bOP::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::bOP::VERSION;

=head1 NAME

Bivio::bOP - bivio OLTP Platform (bOP) overview and version (1.05)

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

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 COPYRIGHT

$Id$

=head1 VERSION

$Id$

=cut

1;
