# Copyright (c) 2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::WidgetFactory;
use strict;
use Bivio::Base 'Bivio::Delegator';

# C<Bivio::UI::HTML::WidgetFactory> creates widgets for model fields.
#
# wf_class : string []
#
# Name of the widget class to use.  Overrides dynamic lookups.
#
# wf_list_link : hash_ref []
#
# Must contain a I<query> attribute which is a
# L<Bivio::Biz::QueryType|Bivio::Biz::QueryType> and
# the widget will be wrapped in a link whose I<href> is
# a call to
# L<Bivio::Biz::ListModel::format_uri|Bivio::Biz::ListModel/"format_uri">
# with I<wf_list_link> as the query type.
#
# If I<task> is specified, it will be passed as a second argument to
# I<format_uri>.
#
# If I<uri> is specified, it will be passed as a second argument to
# I<format_uri>.
#
# The rest of the attributes are passed to the link directly, e.g. control.
# I<control_off_value> is set to be the widget (i.e. the name).
#
# wf_want_display : boolean []
#
# If true, the field will be rendered as a display only widget.
#
# wf_want_select : boolean []
#
# If true, will force a widget to a be a select, if it can.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

1;
