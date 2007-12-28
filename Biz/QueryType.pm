# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::QueryType;
use strict;
use Bivio::Base 'Type.Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    NEXT_DETAIL => [1, 'format_uri_for_next', 'detail_uri'],
    PREV_DETAIL => [2, 'format_uri_for_prev', 'detail_uri'],
    NEXT_LIST => [3, 'format_uri_for_next_page', 'list_uri'],
    PREV_LIST => [4, 'format_uri_for_prev_page', 'list_uri'],
    THIS_DETAIL => [5, 'format_uri_for_this', 'detail_uri'],
    THIS_LIST => [6, 'format_uri_for_this_page', 'list_uri'],
    THIS_CHILD_LIST => [7, 'format_uri_for_this_child', 'detail_uri'],
    THIS_PARENT => [8, 'format_uri_for_this_parent', 'parent_uri'],
    THIS_PATH => [9, 'format_uri_for_this_path', 'detail_uri'],
    THIS_PATH_NO_QUERY => [10, '', 'detail_uri'],
    NO_QUERY => [11, '', 'list_uri'],
    THIS_DETAIL_WITH_PATH => [12, 'format_uri_for_this', 'detail_uri'],
    ANY_LIST => [13, 'format_uri_for_any_list', 'list_uri'],
    THIS_AS_PARENT => [14, 'format_uri_for_this_as_parent', 'parent_uri'],
]);

sub get_method {
    return shift->get_short_desc;
}

sub get_uri_attr {
    return shift->get_long_desc;
}

1;
