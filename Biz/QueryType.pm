# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::QueryType;
use strict;
$Bivio::Biz::QueryType::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::QueryType - enumerates types of URI queries parsed by

=head1 SYNOPSIS

    use Bivio::Biz::QueryType;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Biz::QueryType::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Biz::QueryType> is used by
L<Bivio::Biz::ListModel::format_uri|Bivio::Biz::ListModel/"format_uri">.

Map of types to methods in L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>.

=over 4

=item NEXT_DETAIL

C<format_uri_for_next>

=item PREV_DETAIL

C<format_uri_for_prev>

=item NEXT_LIST

C<format_uri_for_next_page>

=item PREV_LIST

C<format_uri_for_prev_page>

=item THIS_DETAIL

C<format_uri_for_this>

=item THIS_LIST

C<format_uri_for_this_page>

=item THIS_CHILD_LIST

C<format_uri_for_this_child>

=item THIS_PATH

Calls C<format_uri_for_this_path>.  The list must have a
I<path_info> attribute.

=item THIS_PATH_NO_QUERY

The list must have a I<path_info> attribute, but doesn't include
the query string.

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile(
    # Name, method, and which uri to default to.
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
);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
