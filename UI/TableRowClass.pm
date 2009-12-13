# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::TableRowClass;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

# C<Bivio::UI::TableRowClass> controls rendering of widget table rows.
# This is used internally by
# L<Bivio::UI::HTML::Widget::Table|Bivio::UI::HTML::Widget::Table>.
#
#
# HEADING
#
# DATA
#
# FOOTER

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    HEADING => [1],
    DATA => [2],
    FOOTER => [3],
]);

1;
