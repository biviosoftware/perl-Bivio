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

All attributes are always defined, but may be undef.
Use L<get|"get"> to ensure there are no spelling errors in your code.

=over 4

=item auth_id : Bivio::Type::PrimaryId

The auth_id extracted from the request.

=item begin : hash_ref

Column names are keys.  The value limits the query to all rows
whose named column is B<greater> than or equal to
the value of this attribute.

=item end : hash_ref

Column names are keys.  The value limits the query to all rows
whose named column is B<less> than or equal to
the value of this attribute.

=item has_next : boolean

If there are unreturned items as a result of this query, is true.
This value may be invalid until the query is executed by
L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>.

=item has_prev : boolean

Are there items prior to this query?
This value may be invalid until the query is executed by
L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>.

=item is_forward : boolean

The query generates a list in the "forward" order, i.e. it is for
next page or next item.  If the query is not C<is_forward>, then
the cutoff value will be the C<end> of the first C<order_by>.

=item order_by : array_ref

List of fields to order_by as supplied by the user and filled in
from model's order_by names.  Even indexed elements are the name
and odd elements are true if ascending and false if descending.
It is an array_ref to preserve the order specified by the user.

=item just_prior : array_ref

The primary key values for the previous element in the list relative to
I<is_forward>.  In combination with I<begin> and I<end> entries, this attribute
is used to ensure the result set begins at the place just after the prior
query.

=item this : array_ref

The primary key values for this item.  The query should be to
find this primary key.  There should only be one row returned.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::Util;

#=VARIABLES
my(%_QUERY_TO_FIELDS) = (
    'a' => 'action',
    'b' => 'begin',
    'e' => 'end',
    'j' => 'just_prior',
    'o' => 'order_by',
    't' => 'this',
    'v' => 'version',
);
my(@_QUERY) = grep($_ ne 'version', sort(values(%_QUERY_TO_FIELDS)));
my($_PK_RS) = "\0177";

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref query, Bivio::SQL::ListSupport support) : Bivio::SQL::ListQuery

Creates a new ListSupport.  I<auth_id> and I<count> must be set in
I<query>.  I<count> is the default page size to use if the action is
not next_item or prev_item.

B<I<query> will be subsumed by this module.  Do not use it again.>

=cut

sub new {
    my($proto, $attrs, $support) = @_;
    Carp::croak('invalid query arg')
		unless $attrs->{auth_id} && $attrs->{count};
    my($k);
    # Always check version first
    _parse_version($attrs, $support);
#TODO: There may be junk in the query.  Probably should "clean" it?
#      Doesn't really matter as ALL the attributes are set explicitly.
    foreach $k (@_QUERY) {
	&{\&{'_parse_'.$k}}($attrs, $support);
    }
    if ($attrs->{is_forward}) {
	$attrs->{has_prev} = $attrs->{just_prior} ? 1 : 0;
	$attrs->{has_next} = undef;
    }
    else {
	$attrs->{has_prev} = undef;
	$attrs->{has_next} = $attrs->{just_prior} ? 1 : 0;
    }
    my($self) = &Bivio::Collection::Attributes::new($proto, $attrs);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="format_uri_for_this"></a>

=head2 format_uri_for_this(array_ref primary_key, Bivio::SQL::ListSupport support) : string

Generates the query string (URL-encoded) for the primary key set as
C<this> using the current query parameters.

=cut

sub format_uri_for_this {
    my($self, $primary_key, $support) = @_;
    my(%attrs) = %{$self->internal_get()};
    $attrs{this} = $primary_key;
    delete($attrs{just_prior});
    return _format_uri(\%attrs, $support);
}

#=PRIVATE METHODS

# _die(Bivio::Type::Enum code, string message, string value)
#
# Calls Bivio::Die::die with appropriate params
#
sub _die {
    my($code, $msg, $value) = @_;
    Bivio::Die->die($code, {entity => $value,
	class => 'Bivio::SQL::ListQuery', message => $msg}, caller);
}

# _format_uri(hash_ref attrs, Bivio::SQL::ListSupport support) : string
#
# Formats the uri for the configuration parameters specified.
#
sub _format_uri {
    my($attrs, $support) = @_;
    my($res) = 'v'.$attrs->{version};
    my($columns) = $support->get('columns');

    # action: this or just_prior?
    my($pk);
    if ($pk = $attrs->{this}) {
	$res .= '&a=t&t=';
	$pk = $attrs->{this};
    }
    else {
	if ($attrs->{action}) {
	    $res .= '&a='.$attrs->{action};
	}
	if ($pk = $attrs->{just_prior}) {
	    $res .= '&j=';
	}
    }

    # primary key
    if ($pk) {
	my($pk_cols) = $support->get('primary_key');
	for (my($i) = 0; $i < int(@$pk); $i++) {
	    $res .= $pk_cols->[$i]->{type}->to_uri($pk->[$i]);
	}
    }

    # order_by
    if (@{$attrs->{order_by}}) {
	$res .= '&o=';
	my($ob) = $attrs->{order_by};
	for (my($i) = 0; $i < int(@$ob); $i += 2) {
	    $res .= $columns->{$ob->[$i]}->{order_by_index}
		    . ($ob->[$i+1] ? 'a' : 'd');
	}
    }

    # begin and end
    foreach my $limit ('begin', 'end') {
	next unless %{$attrs->{$limit}};
	my($limit_values) = $attrs->{$limit};
	my($prefix) = substr($limit, 0, 1);
	foreach my $k (keys(%$limit_values)) {
	    my($col) = $columns->{$k};
	    $res .= '&'.$prefix.$col->{order_by_index}.'='
		    .$col->{type}->to_uri($limit_values->{$k});
	}
    }
    return;
}

# _parse_action(hash_ref attrs, Bivio::SQL::ListSupport support)
#
# The action is either forward or back and the size.
#
sub _parse_action {
    my($attrs, $support) = @_;
    my($value) = $attrs->{a};
    if (defined($value)) {
	if ($value eq 'n' || $value eq 't') {
	    $attrs->{is_forward} = 1;
	    $attrs->{count} = 1;
	    return;
	}
	elsif ($value eq 'N') {
	    $attrs->{is_forward} = 1;
	    return;
	}
	elsif ($value eq 'p') {
	    $attrs->{is_forward} = 0;
	    $attrs->{count} = 1;
	    return;
	}
	elsif ($value eq 'P') {
	    $attrs->{is_forward} = 0;
	    return;
	}
	else {
	    _die(Bivio::DieCode::CORRUPT_QUERY(), 'invalid action', $value);
#TODO: Should we fall through to default?
	}
    }
    # Default
    $attrs->{is_forward} = 1;
    # Always get a page.  Can't be wrong to get too much.
    return;
}

# _parse_begin(hash_ref attrs, Bivio::SQL::ListSupport support)
#
# Limit the query to some begin value in the order_by.
#
sub _parse_begin {
    _parse_limit(@_, 'b', 'begin');
    return;
}

# _parse_end(hash_ref attrs, Bivio::SQL::ListSupport support)
#
# Limit the query to some end value in the order_by.
#
sub _parse_end {
    _parse_limit(@_, 'e', 'end');
    return;
}

# _parse_limit(hash_ref attrs, Bivio::SQL::ListSupport support, char tag, string name)
#
# The "limit" values are defined as follows:
#	tN=V
# Where "N" is the order_by, "t" is tag, and "V" is value.
#
# The converted value is set in a hash_ref of ($column, $value).
#
sub _parse_limit {
    my($attrs, $support, $tag, $name) = @_;
    my($order_by) = $support->get('order_by_names');
    my($res, $literal);
    my($i) = int(@$order_by);
    while (--$i >= 0) {
	next unless defined($literal = $attrs->{$tag.$i});
	my($c) = $order_by->[$i];
	my($v) = $support->get_column_type($c)->from_literal($literal);
	_die(Bivio::DieCode::CORRUPT_QUERY(), "invalid limit $c", $literal)
		unless defined($v);
	$res = {} unless $res;
	$res->{$c} = $v;
    }
    $attrs->{$name} = $res;
    return;
}

# _parse_order_by(hash_ref attrs, Bivio::SQL::ListSupport support)
#
# Creates a hash of order_by values.  The default is the order returned
# from the list model and sort ascending.  The value is a list of
# numbers followed by letters ('a' or 'd'), e.g. 1a3d.
#
# The "order_by" attributes is defined as a array_ref (which can be turned
# into a hash) of column name followed by either true (ascending)
# or false (descending).
#
sub _parse_order_by {
    my($attrs, $support) = @_;
    my($value) = $attrs->{o} || '';
    my($res) = $attrs->{order_by} = [];
    my($order_by) = $support->get('order_by_names');
    while (length($value)) {
	_die(Bivio::DieCode::CORRUPT_QUERY(), 'invalid order_by',
		$attrs->{o}) unless $value =~ s/^(\d+)([ad])//;
	my($index, $dir) = ($1, $2);
	_die(Bivio::DieCode::CORRUPT_QUERY(), 'unknown order_by column',
		$index) unless $order_by->[$index];
	push(@$res, $order_by->[$index], $dir eq 'a');
    }
    # Add in order_by values not explicitly listed.  The default
    # is ascending.
    foreach my $ob (@$order_by) {
	push(@$res, $ob, 1) unless grep($_ eq $ob, @$res);
    }
    return;
}

# _parse_just_prior(hash_ref attrs, Bivio::SQL::ListSupport support)
#
# The previous value's primary key.
#
sub _parse_just_prior {
    _parse_pk(@_, 'j', 'just_prior');
    return;
}

# _parse_pk(hash_ref attrs, Bivio::SQL::ListSupport support)
#
# The pkious value's primary keys.  The $_PK_RS is a special character
# that is unlikely to appear in strings.
#
sub _parse_pk {
    my($attrs, $support, $tag, $name) = @_;
    my($value) = $attrs->{$tag};
    $attrs->{$name} = undef, return unless defined($value);
    my($res) = $attrs->{$name} = [];
    foreach my $t (@{$support->get('primary_key_types')}) {
	_die(Bivio::DieCode::CORRUPT_QUERY(),
		"incomplete $name", $attrs->{$tag})
		unless $value =~ s/^([^$_PK_RS]+)$_PK_RS?//o;
	my($literal) = $1;
	my($v) = $t->from_literal($literal);
	_die(Bivio::DieCode::CORRUPT_QUERY(), "invalid $name", $attrs->{$tag})
		unless defined($v);
	push(@$res, $v);
    }
    return;
}

# _parse_this(hash_ref attrs, Bivio::SQL::ListSupport support)
#
# The this value's primary key.
#
sub _parse_this {
    _parse_pk(@_, 't', 'this');
    return;
}

# _parse_version(hash_ref attrs, Bivio::SQL::ListSupport support)
#
# The version must either be undef or match the model.  If it doesn't
# match the model, throw a version exception.
#
sub _parse_version {
    my($attrs, $support) = @_;
    my($value) = $attrs->{v};
    $attrs->{version} = $support->get('version');
    return unless defined($value);
    return if $attrs->{version} == $value;
    _die(Bivio::DieCode::VERSION_MISMATCH(), 'invalid version', $value);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
