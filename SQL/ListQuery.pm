# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::SQL::ListQuery;
use strict;
$Bivio::SQL::ListQuery::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::SQL::ListQuery - internal representation of an SQL query

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

=item next : array_ref

=item next : int

primary key or page name of next item or page, respectively.

=item order_by : array_ref

List of fields to order_by as supplied by the user and filled in
from model's order_by names.  Even indexed elements are the name
and odd elements are true if ascending and false if descending.
It is an array_ref to preserve the order specified by the user.

=item page_number : int

Page number on which I<this> is on or the page we are viewing.
Incoming is ignored if I<this>, because is set by
L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>.

=item parent_id : string

Primary id of parent list.  It is used to further qualify a
list of lists.

=item next : array_ref

=item next : int

primary key or page name of previous item or page, respectively.

=item search : string

An arbitrary search string.  The only parsing done by this module
is to trim blanks and set to undef if zero length.

=item this : array_ref

The primary key values for this item.  The query should be to
find this primary key.  There should only be one row returned.

=back

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Type::DateTime;
use Bivio::Type::Integer;
use Bivio::Type::PrimaryId;
use Bivio::Util;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my(%_QUERY_TO_FIELDS) = (
    'n' => 'page_number',
    'o' => 'order_by',
    'p' => 'parent_id',
    's' => 'search',
    't' => 'this',
    'v' => 'version',
);
# Always check version first
my(@_QUERY) = ('version', grep($_ ne 'version',
	sort(values(%_QUERY_TO_FIELDS))));

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref query, Bivio::SQL::Support support, ref die) : Bivio::SQL::ListQuery

Creates a new Support.  I<auth_id> and I<count> must be set in
I<query>.  I<count> is the default page size to use.

B<I<query> will be subsumed by this module.  Do not use it again.>

=cut

sub new {
    my($proto, $attrs, $support, $die) = @_;
    Carp::croak('missing count') unless $attrs->{count};
    Carp::croak('missing auth_id')
		if $support->get('auth_id') && !$attrs->{auth_id};
    my($k);
#TODO: There may be junk in the query.  Probably should "clean" it?
#      Doesn't really matter as ALL the attributes are set explicitly.
    foreach $k (@_QUERY) {
	&{\&{'_parse_'.$k}}($attrs, $support, $die);
    }
    # Reset attrs that are set by Support
    @{$attrs}{'has_prev','has_next', 'prev', 'next'} = (0, 0, undef, undef);
    my($self) = &Bivio::Collection::Attributes::new($proto, $attrs);
    return $self;
}

=head1 METHODS

=cut

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
    $attrs{page_number} = $attrs{next};
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
    $attrs{page_number} = $attrs{prev};
    return _format_uri(\%attrs, $support);
}

=for html <a name="format_uri_for_this"></a>

=head2 static format_uri_for_this(Bivio::SQL::Support support, hash_ref this_row) : string

Generates the query string (URL-encoded) for the primary key
of I<this_row> using the current query parameters.

May be called statically iwc the version is pulled from support.

=cut

sub format_uri_for_this {
    my($self, $support, $this_row) = @_;
    my(%attrs) = ref($self) ? %{$self->internal_get()} :
	    (version => $support->get('version'));
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
#TODO: Probably need a check that this is really a primary id
#TODO: Version in query is incorrect here.  Should be for child...
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

=head2 format_uri_for_this_page(Bivio::SQL::Support support) : string

Generates the query string (URL-encoded) for this page.

=cut

sub format_uri_for_this_page {
    my($self, $support) = @_;
    my(%attrs) = %{$self->internal_get()};
    $attrs{this} = undef;
    $attrs{page_number} = $attrs{page_number};
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
    my(@res) = ('v' => $attrs->{version});
#TODO: Should this be here?
#    push(@res, 'p' => Bivio::Type::PrimaryId->to_literal($attrs->{parent_id}))
#	    if $attrs->{parent_id};
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

=for html <a name="get_search_as_html"></a>

=head2 get_search_as_html() : string

Return the escaped search string if any.

=cut

sub get_search_as_html {
    my($self) = @_;
    my($search) = $self->get('search');
    return defined($search) ? Bivio::Util::escape_html($search) : '';
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

#=PRIVATE METHODS

# _die(Bivio::Type::Enum code, string message, string value)
#
# Calls Bivio::Die::die with appropriate params
#
sub _die {
    my($die, $code, $msg, $value) = @_;
    $die ||= 'Bivio::Die';
    $die->die($code, {entity => $value,
	class => 'Bivio::SQL::ListQuery', message => $msg}, caller);
}

# _format_uri(hash_ref attrs, Bivio::SQL::Support support) : string
#
# Formats the uri for the configuration parameters specified.
#
sub _format_uri {
    my($attrs, $support) = @_;
    my($res) = 'v='.$attrs->{version};
    my($columns) = $support->get('columns');

    # this?
    $res .= '&t='._format_uri_primary_key($attrs->{this}, $support)
	    if $attrs->{this};

    # parent_id?
    $res .= '&p='.Bivio::Type::PrimaryId->to_uri($attrs->{parent_id})
	    if $attrs->{parent_id};

    # page_number?
    $res .= '&n='.Bivio::Type::Integer->to_uri($attrs->{page_number})
	    if defined($attrs->{page_number});

    # order_by
    if ($attrs->{order_by}) {
	my($ob) = $attrs->{order_by};
	$res .= '&o=';
	for (my($i) = 0; $i < int(@$ob); $i += 2) {
	    $res .= $columns->{$ob->[$i]}->{order_by_index}
		    . ($ob->[$i+1] ? 'a' : 'd');
	}
    }

    # search
    $res .= '&s='.Bivio::Util::escape_uri($attrs->{search})
	    if defined($attrs->{search});
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
	$res .= $pk_cols->[$i]->{type}->to_uri(
		$is_array ? $pk->[$i] : $pk->{$pk_cols->[$i]->{name}})."\177";
    }
    chop($res);
    return $res;
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
    my($value) = $attrs->{o} || '';
    my($res) = $attrs->{order_by} = [];
    my($order_by, $columns) = $support->unsafe_get(
	    'order_by_names', 'columns');
    return unless $order_by;
    while (length($value)) {
	_die($die, Bivio::DieCode::CORRUPT_QUERY(), 'invalid order_by',
		$attrs->{o}) unless $value =~ s/^(\d+)([ad])//;
	my($index, $dir) = ($1, $2);
	_die($die, Bivio::DieCode::CORRUPT_QUERY(), 'unknown order_by column',
		$index) unless $order_by->[$index];
	push(@$res, $order_by->[$index], $dir eq 'a');
    }
    # Add in order_by values not explicitly listed.
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

    # Returns undef if no page number
    $attrs->{page_number} = Bivio::Type::Integer->from_literal($attrs->{'n'});

    # Set page_number to 0 by default
    $attrs->{page_number} = 0
	    unless defined($attrs->{page_number})
		    && $attrs->{page_number} >= 0;
    return;
}

# _parse_parent_id(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# The 'this' value's parent_id.  If not set, will be undef
#
sub _parse_parent_id {
    my($attrs, $support, $die) = @_;

    # Returns undef if no parent_id
    $attrs->{parent_id} = Bivio::Type::PrimaryId->from_literal($attrs->{'p'});

    # If the parent id is set and we aren't expecting it, will be ignored
    return if $attrs->{parent_id};

    # Otherwise, are we expecting a parent id?
    _die($die, Bivio::DieCode::CORRUPT_QUERY(), 'missing parent_id',
	    'parent_id') if $support->unsafe_get('parent_id');
    return;
}

# _parse_pk(hash_ref attrs, Bivio::SQL::Support support, ref die, string tag, string name)
#
# Parse the primary key.  The \177 is a special character
# that is unlikely to appear in primary keys.
#
sub _parse_pk {
    my($attrs, $support, $die, $tag, $name) = @_;
    my($value) = $attrs->{$tag};
    $attrs->{$name} = undef, return unless defined($value);
    my($res) = $attrs->{$name} = [];
    my(@pk) = split(/\177/, $value);
    foreach my $t (@{$support->get('primary_key_types')}) {
#TODO: Need to check for correct number of \177 values
	my($literal) = shift(@pk);
	my($v) = $t->from_literal($literal);
	_die($die, Bivio::DieCode::CORRUPT_QUERY(),
		"invalid $name", $attrs->{$tag}) unless defined($v);
	push(@$res, $v);
    }
    return;
}

# _parse_search(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# Parse the search string.  Make sure it doesn't have blanks.
#
sub _parse_search {
    my($attrs, $support, $die) = @_;
    my($value) = $attrs->{'s'};
    if (defined($value)) {
	$value =~ s/^\s+|\s+$//g;
	$attrs->{search} = $value, return if length($value);
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

# _parse_version(hash_ref attrs, Bivio::SQL::Support support, ref die)
#
# The version must either be undef or match the model.  If it doesn't
# match the model, throw a version exception.
#
sub _parse_version {
    my($attrs, $support, $die) = @_;
    my($value) = $attrs->{v};
    $attrs->{version} = $support->get('version');
    return unless defined($value);
    return if $attrs->{version} == $value;
    _die($die, Bivio::DieCode::VERSION_MISMATCH(), 'invalid version', $value);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
