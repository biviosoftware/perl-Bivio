# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::QueryType;
use strict;
use Bivio::Base 'Type.Enum';

my($_MAP) = _init();

sub can_take_path_info {
    my($self) = @_;
    return $self->get_name =~ /^(?:NEXT|PREV|THIS)_(?:DETAIL|LIST)$/ ? 1 : 0;
}

sub get_method {
    return $_MAP->{shift->get_name}->{method};
}

sub get_uri_attr {
    return $_MAP->{shift->get_name}->{uri_attr};
}

sub _init {
    my($map) = {};
    __PACKAGE__->compile([map(
        {
            $map->{$_->[0]} = {
                method => $_->[2],
                uri_attr => $_->[3],
            };
            ($_->[0], $_->[1]);
        }
        [NEXT_DETAIL => 1, 'format_uri_for_next', 'detail_uri'],
        [PREV_DETAIL => 2, 'format_uri_for_prev', 'detail_uri'],
        [NEXT_LIST => 3, 'format_uri_for_next_page', 'list_uri'],
        [PREV_LIST => 4, 'format_uri_for_prev_page', 'list_uri'],
        [THIS_DETAIL => 5, 'format_uri_for_this', 'detail_uri'],
        [THIS_LIST => 6, 'format_uri_for_this_page', 'list_uri'],
        [THIS_CHILD_LIST => 7, 'format_uri_for_this_child', 'detail_uri'],
        [THIS_PARENT => 8, 'format_uri_for_this_parent', 'parent_uri'],
        [THIS_PATH => 9, 'format_uri_for_this_path', 'detail_uri'],
        [THIS_PATH_NO_QUERY => 10, '', 'detail_uri'],
        [NO_QUERY => 11, '', 'list_uri'],
        [THIS_DETAIL_WITH_PATH => 12, 'format_uri_for_this', 'detail_uri'],
        [ANY_LIST => 13, 'format_uri_for_any_list', 'list_uri'],
        [THIS_AS_PARENT => 14, 'format_uri_for_this_as_parent', 'parent_uri'],
    )]);
    return $map;
}

1;
