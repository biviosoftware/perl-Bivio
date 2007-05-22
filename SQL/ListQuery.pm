# Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::SQL::ListQuery;
use strict;
$Bivio::SQL::ListQuery::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::SQL::ListQuery::VERSION;

=head1 NAME

Bivio::SQL::ListQuery - internal representation of an SQL query

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::SQL::ListQuery;
    Bivio::SQL::ListQuery->new($query, $support);

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::SQL::ListQuery::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::SQL::ListQuery> describes a query for a
L<Bivio::Biz::ListModel|Bivio::Biz::ListModel>.  The query
inputs come from the request, but all values are defaulted if
the request query is empty.

L<Bivio::Biz::ListModel::execute|Bivio::Biz::ListModel/"execute"> creates a
C<ListQuery>.

=head1 ATTRIBUTES

All attributes exist, but may be undef.
Use L<get|"get"> to ensure there are no spelling errors in your code.

=over 4

=item auth_id : Bivio::Type::PrimaryId

The auth_id extracted from the request.

=item count : int

Number of lines on a page.  Not passed in the query, set by the
caller of L<new|"new">.

=item begin_date : Bivio::Type::Date

If supplied, then is the last date to return (inclusive).  Allows you to
specify an explicit date range.

You can pass C<begin_date> in the query string and it will be parsed as a date.

You cannot pass I<begin_date> and I<interval>.

=item date : Bivio::Type::Date

Arbitrary date used to load the ListModel.  Bivio::Type::DateTime
and a Bivio::Type::Date are both acceptable.

You can pass C<date>, C<end_date>, or C<report_date> in the query string and it
will be parsed as a date.

Will be set to DateTime-E<gt>local_end_of_today if C<undef>
and support has I<want_date> set.

=item has_next : boolean

If there are unreturned items as a result of this query, is true.
This value may be invalid until the query is executed by
L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>.
Initialized to false.

=item has_prev : boolean

Are there items prior to this query?
This value may be invalid until the query is executed by
L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>.
Initialized to false.

=item interval : Bivio::Type::DateInterval

A L<Bivio::Type::DateInterval|Bivio::Type::DateInterval>.  Does not default.
You can pass C<interval> in the query string and it will be parsed
as an interval.

Accepts a ref or tries to convert unsafe_from_any.  Is left at C<undef>,
if not set.

You cannot pass I<begin_date> and I<interval>.

=item list_support : Bivio::SQL::ListSupport

Support instance used to create this query.

=item next : array_ref

primary key of previous item.

=item next_page : int

page number of previous page.

=item order_by : array_ref

List of fields to order_by as supplied by the user and filled in
from model's order_by names.  Even indexed elements are the name
and odd elements are true if ascending and false if descending.
It is an array_ref to preserve the order specified by the user.

You can pass C<order_by> in the query string and it will be parsed, if
C<o> is not set.

=item page_count : int

Total number of pages that can be returned by this the query.  Only set if
I<want_page_count> is true.

=item page_number : int

Page number on which I<this> is on or the page we are viewing.
Incoming is ignored if I<this>, because is set by
L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>.
Page numbers are one-based.

You can pass C<page_number> in the query string and it will be parsed, if
C<n> is not set.

=item parent_id : string

Primary id of parent list.  It is used to further qualify a
list of lists.

You can pass C<parent_id> in the query string and it will be parsed, if
C<p> is not set.

=item prev : array_ref

primary key of next item.

=item prev_page : int

page number of next page.

=item row_count : int

Total number of rows that can be returned by this the query.  Only set if
I<want_page_count> is true.

=item search : string

An arbitrary search string.  The only parsing done by this module
is to trim blanks and set to undef if zero length.

You can pass C<search> in the query string and it will be parsed
if the single character attribute doesn't exist.

=item this : array_ref

The primary key values for this item.  The query should be to
find this primary key.  There should only be one row returned.

You can pass C<this> in the query string and it will be parsed, if
C<t> is not set.

=item want_first_only : boolean (optional)

Set this to true if you want to get the first element and
set it as I<this>.  Used by
L<Bivio::SQL::ListModel::load|Bivio::SQL::ListModel/"load">.

=item want_only_one_order_by : boolean [0]

When preparing the C<ORDER BY> clause, only include the first order by column,
and ignore the rest.  This performance option is necessary for certain complex
queries with Postgres.  Don't use this unless you are really sure you need it.
I<want_only_one_order_by> does not affect I<order_by> of the query, but the
implementation of the ORDER BY clause in
L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>.

=item want_page_count : boolean (optional)

Set this to true if you want to count the number of pages.

=back

=cut


=head1 CONSTANTS

=cut

=for html <a name="FIRST_PAGE"></a>

=head2 FIRST_PAGE : int

Returns 1.

=cut

sub FIRST_PAGE {
    return 1;
}

=for html <a name="DEFAULT_MAX_COUNT"></a>

=head2 DEFAULT_MAX_COUNT : int

=cut

my($_COUNT_TYPE) = Bivio::Type->get_instance('Integer')->new(
    1, Bivio::Type->get_instance('PageSize')->get_max);
sub DEFAULT_MAX_COUNT {
    return $_COUNT_TYPE->get_max;
}

#=IMPORTS
use Bivio::Agent::HTTP::Query;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::HTML;
use Bivio::IO::Trace;
use Bivio::Type::Date;
use Bivio::Type::DateInterval;
use Bivio::Type::DateTime;
use Bivio::Type::Integer;
use Bivio::Type::PrimaryId;
use Bivio::Type;

#=VARIABLES
use vars ('$_TRACE');
use Bivio::Type::String;
Bivio::IO::Trace->register;
my(%_QUERY_TO_FIELDS) = (
    'b' => 'begin_date',
    'd' => 'date',
    'c' => 'count',
    'i' => 'interval',
    'n' => 'page_number',
    'o' => 'order_by',
    'p' => 'parent_id',
    's' => 'search',
    't' => 'this',
);
my(@_QUERY_FIELDS) = sort(values(%_QUERY_TO_FIELDS));
my(%_ATTR_TO_CHAR) = map {
    ($_QUERY_TO_FIELDS{$_}, $_);
} keys(%_QUERY_TO_FIELDS);
# Separates elements in a multivalued primary key.
# Tightly coupled with $Bivio::Biz::FormContext::_HASH_CHAR
my($_SEPARATOR) = "\177";
my($_SEPARATOR_AS_QUERY) = Bivio::Type::String->to_query("\177");

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref query, Bivio::SQL::Support support, ref die) : Bivio::SQL::ListQuery

Creates a new ListQuery.  I<auth_id> must be set in I<query> if required.

B<I<query> will be subsumed by this module.  Do not use it again.>

=cut

sub new {
    my($proto, $attrs, $support, $die) = @_;
    die('missing auth_id')
	if $support->get('auth_id') && !$attrs->{auth_id};
    foreach my $k (@_QUERY_FIELDS) {
	&{\&{'_parse_'.$k}}($attrs, $support, $die);
    }
    return _new($proto, $attrs, $support, $die);
}

=for html <a name="unauth_new"></a>

=head2 static unauth_new(hash_ref attrs, Bivio::Biz::Model model, Bivio::SQL::Support support) : Bivio::SQL::ListQuery

Creates a new ListQuery using the I<attrs> supplied.  No checking
is done on the values.  I<auth_id> may or may not be set.

B<I<attrs> will be subsumed by this module.  Do not use it again.>

=cut

sub unauth_new {
    my($proto, $attrs, $model, $support) = @_;
    # Rob said to set this for ordering anon list models, but it didn't work
#    $attrs->{order_by} ||= '';
    # Always set these
    foreach my $k (@_QUERY_FIELDS) {
	&{\&{'_parse_'.$k}}($attrs, $support, $model)
		unless exists($attrs->{$k});
    }
    return _new($proto, $attrs, $support, $model);
}

=for html <a name="clone"></a>

=head2 clone() : Bivio::SQL::ListQuery

=cut

sub clone {
    my($self) = @_;
    return $self->SUPER::new($self->get_shallow_copy);
}

=head1 METHODS

=cut

=for html <a name="clean_raw"></a>

=head2 clean_raw(hash_ref query, Bivio::SQL::ListSupport support) : hash_ref

Removes any raw query keys that aren't part of the "valid" set.  If
the model has I<other_query_keys>, these will not be removed.
Used by
L<Bivio::Biz::ListModel::parse_query_from_request|Bivio::Biz::ListModel/"parse_query_from_request">.

Returns I<query>.

=cut

sub clean_raw {
    my(undef, $query, $support) = @_;
    Bivio::IO::Alert->warn_deprecated('must pass ListSupport')
	unless $support;
    my($oqk) = $support && $support->unsafe_get('other_query_keys');
    foreach my $k (keys(%$query)) {
	delete($query->{$k})
	    unless $_QUERY_TO_FIELDS{$k}
		|| $_ATTR_TO_CHAR{$k}
		|| $oqk && grep($k eq $_, @$oqk);
    }
    return $query;
}

=for html <a name="format_uri"></a>

=head2 format_uri(Bivio::SQL::Support support, hash_ref new_attrs) : string

Lets you override any I<new_attrs>, useful for other_query_keys at this time.
I<new_attrs> defaults to empty.

=cut

sub format_uri {
    my($self, $support, $new_attrs) = @_;
    return _format_uri({
	%{$self->internal_get},
	%{$new_attrs || {}},
    }, $support);
}

=for html <a name="format_uri_for_any_list"></a>

=head2 format_uri_for_any_list(Bivio::SQL::Support support, hash_ref new_attrs) : string

Returns the query without a this or page_number with overrides in
I<new_attrs>.

=cut

sub format_uri_for_any_list {
    my($self, $support, $new_attrs) = @_;
    my(%attrs) = %{$self->internal_get};
    $attrs{this} = undef;
    $attrs{page_number} = undef;
    while ($new_attrs and my($k, $v) = each(%$new_attrs)) {
	$attrs{$k} = $v;
    }
    return _format_uri(\%attrs, $support);
}

=for html <a name="format_uri_for_next"></a>

=head2 format_uri_for_next(Bivio::SQL::Support support) : string

Generates the query string (URL-encoded) for I<next> this.

=cut

sub format_uri_for_next {
    my($self, $support) = @_;
    my(%attrs) = %{$self->internal_get()};
    $attrs{this} = $attrs{next};
    $attrs{page_number} = undef;
    return _format_uri(\%attrs, $support);
}

=for html <a name="format_uri_for_next_page"></a>

=head2 format_uri_for_next_page(Bivio::SQL::Support support) : string

Generates the query string (URL-encoded) for next page.

=cut

sub format_uri_for_next_page {
    my($self, $support) = @_;
    my(%attrs) = %{$self->internal_get()};
    $attrs{this} = undef;
    $attrs{page_number} = $attrs{next_page};
    return _format_uri(\%attrs, $support);
}

=for html <a name="format_uri_for_prev"></a>

=head2 format_uri_for_prev(Bivio::SQL::Support support) : string

Generates the query string (URL-encoded) for I<prev> this.

=cut

sub format_uri_for_prev {
    my($self, $support) = @_;
    my(%attrs) = %{$self->internal_get()};
    $attrs{this} = $attrs{prev};
    $attrs{page_number} = undef;
    return _format_uri(\%attrs, $support);
}

=for html <a name="format_uri_for_prev_page"></a>

=head2 format_uri_for_prev_page(Bivio::SQL::Support support) : string

Generates the query string (URL-encoded) for prev page.

=cut

sub format_uri_for_prev_page {
    my($self, $support) = @_;
    my(%attrs) = %{$self->internal_get()};
    $attrs{this} = undef;
    $attrs{page_number} = $attrs{prev_page};
    return _format_uri(\%attrs, $support);
}

=for html <a name="format_uri_for_this"></a>

=head2 static format_uri_for_this(Bivio::SQL::Support support, hash_ref this_row) : string

Generates the query string (URL-encoded) for the primary key
of I<this_row> using the current query parameters.

=cut

sub format_uri_for_this {
    my($self, $support, $this_row) = @_;
    my(%attrs) = ref($self) ? %{$self->internal_get()} : ();
    $attrs{this} = $this_row;
    $attrs{page_number} = undef;
    return _format_uri(\%attrs, $support);
}

=for html <a name="format_uri_for_this_child"></a>

=head2 format_uri_for_this_child(Bivio::SQL::Support support, hash_ref this_row) : string

Generates the query string (URL-encoded) for the primary key
of I<this_row> as the parent_id.  There is no page number.

=cut

sub format_uri_for_this_child {
    my($self, $support, $this_row) = @_;
    my(%attrs) = %{$self->internal_get()};
    $attrs{parent_id} = $this_row->{$support->get('primary_key_names')->[0]};
    $attrs{this} = undef;
    $attrs{page_number} = undef;
    # At this point, we lose context.  The query is "owned" relative to
    # the child, so the order by goes away
    $attrs{order_by} = undef;
    $attrs{search} = undef;
    return _format_uri(\%attrs, $support);
}

=for html <a name="format_uri_for_this_page"></a>

=head2 format_uri_for_this_page(Bivio::SQL::Support support, hash_ref new_attrs) : string

Generates the query string (URL-encoded) for this page.
I<new_attrs> can be passed in to extend or override existing attributes.

=cut

sub format_uri_for_this_page {
    my($self, $support, $new_attrs) = @_;
    my(%attrs) = (%{$self->internal_get()}, %$new_attrs);
    $attrs{this} = undef;
    return _format_uri(\%attrs, $support);
}

=for html <a name="format_uri_for_this_as_parent"></a>

=head2 static format_uri_for_this_as_parent(Bivio::SQL::Support sql_support) : string

Generates the query string (URL-encoded) for this query's I<this> as
a parent query (p=)

=cut

sub format_uri_for_this_as_parent {
    my($self, $support, $this_row) = @_;
    my($res) = $self->format_uri_for_this($support, $this_row);
#TODO: Wow is this a hack!
    $res =~ s/\bt=/p=/;
    return $res;
}

=for html <a name="format_uri_for_this_parent"></a>

=head2 format_uri_for_this_parent(Bivio::SQL::Support sql_support) : string

Generates the query string (URL-encoded) for this query's parent as
this.

=cut

sub format_uri_for_this_parent {
    my($self, $support) = @_;
    my($attrs) = $self->internal_get();

#TODO: Need to know which detail_model this is bound
    # Format explicitly, because breaks all the rules
    die('no parent_id associated with query') unless $attrs->{parent_id};
    my($res) = 't='.$attrs->{parent_id};

    # We don't know ordering, because this is the parent list
    return $res;
}

=for html <a name="format_uri_for_this_path"></a>

=head2 static format_uri_for_this_path(Bivio::SQL::Support support, hash_ref this_row) : string

Generates the query string (URL-encoded) for this detail, but doesn't
include "this".

May be called statically iwc the version is pulled from support.

=cut

sub format_uri_for_this_path {
    my($self, $support, $this_row) = @_;
    my(%attrs) = ref($self) ? %{$self->internal_get()} : ();
    $attrs{this} = undef;
    $attrs{page_number} = undef;
    return _format_uri(\%attrs, $support);
}

=for html <a name="get_hidden_field_values"></a>

=head2 get_hidden_field_values(Bivio::SQL::Support sql_support) : array_ref

Emulate L<Bivio::Biz::FormModel::get_hidden_field_values|Bivio::Biz::FormModel/"get_hidden_field_values">

Used in search and chooser forms.  The conversion to html is done by caller.

=cut

sub get_hidden_field_values {
    my($self, $support) = @_;
    my($attrs) = $self->internal_get();
    my($columns) = $support->get('columns');
    my($ob) = $attrs->{order_by};
    # Since this is a search, there is no page_number or this, but
    # there may be need to be a parent_id.
    my(@res) = ();
    if ($ob) {
	my($o);
	for (my($i) = 0; $i < int(@$ob); $i += 2) {
	    $o .= $columns->{$ob->[$i]}->{order_by_index}
		    . ($ob->[$i+1] ? 'a' : 'd');
	}
	push(@res, 'o' => $o);
    }
    return \@res;
}

=for html <a name="get_sort_order_for_type"></a>

=head2 static get_sort_order_for_type(Bivio::Type type) : boolean

Returns the default sort order for the type.

=cut

sub get_sort_order_for_type {
    my(undef, $type) = @_;
    # Dates and Primary ids are reverse sorted by default.  PrimaryIds
    # are used in entry/transaction lists to allow predictive ordering of
    # entries entered at the same time (a transaction is composed of several
    # entries).
    return (UNIVERSAL::isa($type, 'Bivio::Type::DateTime')
	    || UNIVERSAL::isa($type, 'Bivio::Type::PrimaryId'))
		    ? 0 : 1,
}

=for html <a name="initialize_support"></a>

=head2 static initialize_support(Bivio::SQL::Support support)

Should only be called by L<Bivio::SQL::Support|Bivio::SQL::Support>.

Sets up the default order_by on the I<support>.

=cut

sub initialize_support {
    my($proto, $support) = @_;

    return unless $support->unsafe_get('order_by');

    # This requires intimate knowledge of format_uri and parse_order_by
    my($attrs) = {};
    # Always fills in defaults
    _parse_order_by($attrs, $support, 'Bivio::Die');

    # format_uri needs default_order_by_query to be set
    $support->put(default_order_by_query => '');
    $support->put(default_order_by_query => _format_uri($attrs, $support));
    return;
}

=for html <a name="set_request_this"></a>

=head2 static set_request_this(Bivio::Agent::Request req, string this_id)

Set I<this_id> on I<req>'s query.  I<this_id> must be
L<Bivio::Type::PrimaryId|Bivio::Type::PrimaryId>.

=cut

sub set_request_this {
    my(undef, $req, $this_id) = @_;
    die('this_id must be a PrimaryId')
	    if defined($this_id) && $this_id !~ /^\d+$/;
    my($query) = $req->get('query') || {};
    $query->{t} = Bivio::Type::PrimaryId->to_literal($this_id);
    $req->put(query => $query);
    return;
}

=for html <a name="to_char"></a>

=head2 static to_char(string attr_name) : string

Returns the character for the specified field.  This value is a
constant.

=cut

sub to_char {
    my(undef, $attr_name) = @_;
    die($attr_name, ': unknown query attribute')
	    unless defined($_ATTR_TO_CHAR{$attr_name});
    return $_ATTR_TO_CHAR{$attr_name};
}

#=PRIVATE METHODS

# _die(Bivio::Type::Enum code, string message, string value)
#
# _die(Bivio::Type::Enum code, hash_ref attrs, string value)
#
# Calls Bivio::Die::die with appropriate params
#
sub _die {
    my($die, $code, $attrs, $value) = @_;
    $attrs = {message => $attrs} unless ref($attrs);
    $attrs->{class} =  'Bivio::SQL::ListQuery';
    $attrs->{entity} = $value;
    $die ||= 'Bivio::Die';
    $die->throw_die($code, $attrs, caller);
}

# _format_uri(hash_ref attrs, Bivio::SQL::Support support) : string
#
# Formats the uri for the configuration parameters specified.
#
sub _format_uri {
    my($attrs, $support) = @_;
    my($res) = '';
    my($columns) = $support->get('columns');
    $res .= 't=' . _format_uri_primary_key($attrs->{this}, $support) . '&'
	if $attrs->{this};
    $res .= 'p=' . _get_parent_id_type($attrs, $support)->to_query(
	$attrs->{parent_id}) . '&'
	if $attrs->{parent_id};
    $res .= 'n=' . Bivio::Type::Integer->to_query($attrs->{page_number}) . '&'
	if defined($attrs->{page_number});
    if ($attrs->{order_by} && @{$attrs->{order_by}}) {
	my($ob) = $attrs->{order_by};
	my($s) = 'o=';
	for (my($i) = 0; $i < int(@$ob); $i += 2) {
	    $s .= $columns->{$ob->[$i]}->{order_by_index}
		    . ($ob->[$i+1] ? 'a' : 'd');
	}
	$res .= $s . '&'
	    if $s ne $support->get('default_order_by_query');
    }
    $res .= 's=' . Bivio::Type::String->to_query($attrs->{search}) . '&'
	if defined($attrs->{search});
    $res .= 'b=' . Bivio::Type::DateTime->to_query($attrs->{begin_date}) . '&'
	if defined($attrs->{begin_date});
    $res .= 'd=' . Bivio::Type::DateTime->to_query($attrs->{date}) . '&'
	if defined($attrs->{date});
    $res .= 'i=' . Bivio::Type::DateInterval->to_query($attrs->{interval}) . '&'
	if defined($attrs->{interval});
    foreach my $k (@{$support->unsafe_get('other_query_keys') || []}) {
	$res .= $k . "=" . Bivio::Type::String->to_query($attrs->{$k}) . '&'
	    if defined($attrs->{$k});
    }
    chop($res);
    return $res;
}

# _format_uri_primary_key(array_ref pk, Bivio::SQL::Support support) : string
# _format_uri_primary_key(hash_ref pk, Bivio::SQL::Support support) : string
#
# Returns primary key formatted for a uri.
#
sub _format_uri_primary_key {
    my($pk, $support) = @_;
    my($res) = '';
    my($pk_cols) = $support->get('primary_key');
    my($is_array) = ref($pk) eq 'ARRAY';
    # NOTE: Nice to agree with PropertyModel::format_query
    for (my($i) = 0; $i < int(@$pk_cols); $i++) {
	$res .= $_SEPARATOR_AS_QUERY if length($res);
	$res .= $pk_cols->[$i]->{type}->to_query(
		$is_array ? $pk->[$i] : $pk->{$pk_cols->[$i]->{name}});
    }
    return $res;
}

# _get_parent_id_type(hash_ref attrs, Bivio::SQL::Support support) : string
#
# Returns the type of the parent_id field.
#
sub _get_parent_id_type {
    my($attrs, $support) = @_;
    # use the list support first
    my($type) = $support->unsafe_get('parent_id_type');

    # try the first primary key type
    unless ($type) {
	my($primary_key) = $support->unsafe_get('primary_key');
	if ($primary_key && int(@$primary_key)) {
	    $type = $primary_key->[0]->{type};
	}
    }

    # default to PrimaryId
    return $type || 'Bivio::Type::PrimaryId';
}

# _new(any proto, hash_ref attrs, Bivio::SQL::Support, ref die) : Bivio::SQL::ListQuery
#
# Initializes default attrs and instantiates.
#
sub _new {
    my($proto, $attrs, $support, $die) = @_;
    # Reset attrs that are set by Support
    @{$attrs}{qw(has_prev has_next prev next prev_page next_page list_support)}
	   = (0, 0, undef, undef, undef, undef, $support);
    _die($die, Bivio::DieCode->CORRUPT_QUERY, {
	message => 'cannot have both interval and begin_date',
	begin_date => $attrs->{begin_date},
    },
	    $attrs->{interval}) if $attrs->{interval} && $attrs->{begin_date};
    return $proto->SUPER::new($attrs);
}

# _parse_begin_date(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# Parses the "begin_date" attribute.
#
sub _parse_begin_date {
    my($attrs, $support, $die) = @_;
    $attrs->{begin_date} = _parse_date_value(
	    $attrs->{b} || $attrs->{begin_date} || undef,
	    $support, $die, 0);
    return;
}

# _parse_count(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# Parse the count string.
#
sub _parse_count {
    my($attrs, $support, $die) = @_;
    my($c) = $_COUNT_TYPE->from_literal($attrs->{'c'} || $attrs->{'count'});
    $attrs->{count} = $c
	if defined($c);
    return;
}

# _parse_date(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# Parses the "date" attribute.
#
sub _parse_date {
    my($attrs, $support, $die) = @_;
    $attrs->{date} = _parse_date_value(
	    $attrs->{d} || $attrs->{date} || $attrs->{end_date}
	    || $attrs->{report_date} || undef,
	    $support, $die, $support->unsafe_get('want_date'));
    return;
}

# _parse_date_value(string literal, Bivio::SQL::Support support, ref die, boolean want_date) : string
#
# Parses the literal and returns a Type::Date. We handle both a literal
# DateTime (J SSSSS) and a Date (mm/dd/yyyy).  We also check for report_date
# and date passed in.  If the date is invalid, we set it to undef or now
# depending on whether support is passed in or not.
#
# Backwards compatibility issues: Default to Bivio::Type::DateTime for type.
#
sub _parse_date_value {
    my($literal, $support, $die, $want_date) = @_;
    my($type) = $support->unsafe_get('date');
    $type = $type ? $type->{type} : 'Bivio::Type::DateTime';
    return $want_date ? $type->get_default : undef
	unless $literal;
    my($value, $e) = $type->from_literal($literal);
    return $value if $value;
#TODO: can we get rid of this?
    # Try a date first, because that's the common case
    ($value, $e) = Bivio::Type::Date->from_literal($literal);
    return $value if $value;
    ($value, $e) = Bivio::Type::DateTime->from_literal($literal);
    _die($die, Bivio::DieCode::CORRUPT_QUERY(), {
	message => 'invalid date',
	type_error => $e,
    },
	$literal) unless $value;
    return $value;
}

# _parse_interval(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# Parses an interval as an unsafe_from_any or literal ref.
#
sub _parse_interval {
    my($attrs, $support, $die) = @_;
    my($literal) = $attrs->{i};
    $literal = $attrs->{interval} unless defined($literal);

    # Passed internally?
    if (ref($literal)) {
	# Already parsed, is a reference
	_die($die, Bivio::DieCode::CORRUPT_QUERY(), {
	    message => 'not a Bivio::Type::DateInterval',
	},
		$literal)
		unless UNIVERSAL::isa($literal, 'Bivio::Type::DateInterval');
	$attrs->{interval} = $literal;
	return;
    }

    # Empty?
    unless (defined($literal) && length($literal)) {
	$attrs->{interval} = undef;
	return;
    }

    # Parse
    my($value, $e) = Bivio::Type::DateInterval->unsafe_from_any($literal);
    _die($die, Bivio::DieCode::CORRUPT_QUERY(), {
	message => 'invalid interval',
	type_error => $e,
    },
	    $literal) unless $value;
    $attrs->{interval} = $value;
    return;
}

# _parse_order_by(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# Creates a hash of order_by values.  The default is the order returned from
# the model.  The value is a list of numbers followed by letters ('a' or 'd'),
# e.g. 1a3d.
#
# The "order_by" attributes is defined as a array_ref (which can be turned
# into a hash) of column name followed by either true (ascending)
# or false (descending).
#
sub _parse_order_by {
    my($attrs, $support, $die) = @_;
    my($orig_value) = $attrs->{o} || $attrs->{order_by} || '';
    my($res) = $attrs->{order_by} = [];
    my($order_by, $columns) = $support->unsafe_get(
	    'order_by_names', 'columns');
    return unless $order_by;
    my($value) = $orig_value;
    while (length($value)) {
	_die($die, Bivio::DieCode::CORRUPT_QUERY(), 'invalid order_by',
		$orig_value) unless $value =~ s/^(\d+)([ad])//;
	my($index, $dir) = ($1, $2);
	_die($die, Bivio::DieCode::CORRUPT_QUERY(), 'unknown order_by column',
		$index) unless $order_by->[$index];
	push(@$res, $order_by->[$index], $dir eq 'a' ? 1 : 0);
    }

    # Add in default order_by values not explicitly listed.
    foreach my $ob (@$order_by) {
	push(@$res, $ob, $columns->{$ob}->{sort_order})
		unless grep($_ eq $ob, @$res);
    }
    return;
}

# _parse_page_number(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# If not set or invalid, will be set to zero.
#
sub _parse_page_number {
    my($attrs, $support, $die) = @_;

    # Returns undef if no page number.
    ($attrs->{page_number}) = Bivio::Type::Integer->from_literal(
	    $attrs->{'n'} || $attrs->{page_number});

    # Set page_number to 1 by default (if invalid)
    $attrs->{page_number} = FIRST_PAGE()
	    unless defined($attrs->{page_number})
		    && $attrs->{page_number} >= FIRST_PAGE();
    return;
}

# _parse_parent_id(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# The 'this' value's parent_id.  If not set, will be undef
#
sub _parse_parent_id {
    my($attrs, $support, $die) = @_;

    # Returns undef if no parent_id or bad parent id
    my($err);
    ($attrs->{parent_id}, $err)
	    = _get_parent_id_type($attrs, $support)->from_literal(
		    $attrs->{'p'} || $attrs->{parent_id});

    # If the parent id is set and we aren't expecting it, will be ignored
    return if $attrs->{parent_id};

    # Otherwise, are we expecting a parent id?
    _die($die, Bivio::DieCode::CORRUPT_QUERY(),
	    {message => 'bad or missing parent_id',
		type_error => $err},
	    'parent_id') if $support->unsafe_get('parent_id');
    return;
}

# _parse_pk(hash_ref attrs, Bivio::SQL::Support support, ref die, string tag, string name)
#
# Parse the primary key.  The $_SEPARATOR is a special character
# that is unlikely to appear in primary keys.
#
# Allows $tag or $name in the query.
#
sub _parse_pk {
    my($attrs, $support, $die, $tag, $name) = @_;
    my($value) = $attrs->{$tag} || $attrs->{$name};
    unless (defined($value)) {
	$attrs->{$name} = undef;
	return;
    }
    my($res) = $attrs->{$name} = [];
    my($pk)
	= [ref($value) eq 'ARRAY' ? @$value : split(/$_SEPARATOR/o, $value)];
    foreach my $t (@{$support->get('primary_key_types')}) {
#TODO: Need to check for correct number of $_SEPARATOR values
	my($literal) = shift(@$pk);
	my($v, $err) = $t->from_literal($literal);
	_die($die, Bivio::DieCode->CORRUPT_QUERY, {
	    message => "invalid $name",
	    error => $err,
	}, $literal) unless defined($v);
	push(@$res, $v);
    }
    return;
}

# _parse_search(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# Parse the search string.  Make sure it doesn't have blanks.  Allows
# "s" or "search" to be supplied.
#
sub _parse_search {
    my($attrs, $support, $die) = @_;
    my($value) = defined($attrs->{'s'}) ? $attrs->{'s'} : $attrs->{'search'};
    if (defined($value)) {
	$value =~ s/^\s+|\s+$//g;
	if (length($value)) {
	    $attrs->{search} = $value;
	    return;
	}
    }
    $attrs->{search} = undef;
    return;
}

# _parse_this(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# The this value's primary key.
#
sub _parse_this {
    _parse_pk(@_, 't', 'this');
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
