# Copyright (c) 2002-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Tables;
use strict;
use Bivio::Base 'Bivio::Test::HTMLParser';
use Bivio::IO::Trace;
use Bivio::Test::HTMLParser::Tables::Cell;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
__PACKAGE__->register(['Cleaner']);

sub do_rows {
    my($self, $table_name, $do_rows_callback) = @_;
    # Iterates over the rows over I<table_name>, calling
    # L<do_rows_callback|"do_rows_callback"> for each row.
    #
    # The special field C<_row_index> is set to the value of the index of that row.
    my($index) = -1;

    my($t) = _assert_table($self, $table_name);
    foreach my $row (@{$t->{rows}}) {
	my($i) = -1;
	$index++;
        last unless $do_rows_callback->(
	    {
		_row_index => $index,
		map({
                    my($value) = $row->[++$i];
                    defined($value)
                        ? ($_->get('text') => $value)
                        : ();
                } @{$t->{headings}}),
	    },
	    $index,
	);
    }
    return;
}

sub find_row {
    my($self) = shift;
    # Return the hash_ref of the the row where the value in I<column_name>
    # matches I<column_value>.  Dies if row not found.
    #
    # If I<table_name> not supplied, calls L<get_by_headings|"get_by_headings"> with
    # I<column_name> for table.
    my($table_name) = shift
	if @_ > 2;
    my($column_name, $column_value) = @_;
    $table_name = $self->get_by_headings(
	defined($table_name) ? $table_name : $column_name,
    )->{headings}->[0]->get('text')
	if !defined($table_name) || ref($table_name);
    my($found_row);
    $column_name = _assert_column($self, $table_name, $column_name);
    my($misses) = [];
    $self->do_rows($table_name,
	sub {
	    my($row) = @_;
            # not all rows have all columns defined
            return 1 unless exists($row->{$column_name});
	    my($t) = $row->{$column_name}->get('text');
	    push(@$misses, $t);
	    $found_row = $row
		if _eq($column_value, $t);
	    return $found_row ? 0 : 1;
	});
    Bivio::Die->die(
	$column_value, ': not found in column "', $column_name,
	'" values: ', $misses,
    ) unless $found_row;
    return wantarray ? ($found_row, $column_name) : $found_row;
}

sub get_by_headings {
    my($self, @name) = @_;
    # Returns the table data by finding by I<name>(s) in heading fields.
    my($found);
    my($tables) = $self->get_shallow_copy;
 TABLE: while (my($table, $values) = each(%$tables)) {
	foreach my $n (@name) {
	    next TABLE
		unless grep(_eq($n, $_->get('text')), @{$values->{headings}});
	}
	Bivio::Die->die(\@name, ': too many tables matched headings')
	    if $found;
	$found = $values;
    }
    return $found || Bivio::Die->die(\@name, ': no table matches named headings');
}

sub html_parser_end {
    my($self, $tag) = (shift, @_);
    # Dispatch to the _end_XXX routines.
    my($fields) = $self->[$_IDI];
    $fields->{links}->html_parser_end(@_)
	if $fields->{links};
    _call_op('end', $tag, $self);
    return;
}

sub html_parser_start {
    my($self, $tag, $attr) = (shift, @_);
    # Calls _fixup_attr then dispatches to the _start_XXX routines.
    my($fields) = $self->[$_IDI];
    $fields->{links}->html_parser_start(@_)
	if $fields->{links};
    return if _call_op('start', $tag, $self, $attr);
    return _start_input($self, $attr)
	if $attr->{type};
    return;
}

sub html_parser_text {
    my($self, $text) = (shift, @_);
    # Parses the tables.  Called internally.
    my($fields) = $self->[$_IDI];
    $fields->{links}->html_parser_text(@_)
	if $fields->{links};
    return unless $fields->{in_data_table};
    $fields->{text} .= $text;
    return;
}

sub new {
    my($proto, $parser) = @_;
    # Parses cleaned html for forms.
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {};
    return $self;
}

sub _assert_column {
    my($self, $table_name, $column_name) = @_;
    my($table) = _assert_table($self, $table_name);
    my(@match) = grep(_eq($column_name, $_->get('text')), @{$table->{headings}});
    Bivio::Die->die($column_name, ': column name not found')
        unless @match;
    Bivio::Die->die(\@match, ': too many columns found for ', $column_name)
#TODO: There's an odd test case which requires this $column_name condition
        if $column_name && @match > 1;
    return $match[0]->get('text');
}

sub _assert_table {
    my($self, $table_name) = @_;
    Bivio::Die->die($table_name, ': table not found; tables=', $self->get_keys)
        unless $self->unsafe_get($table_name);
    return $self->get($table_name);
}

sub _call_op {
    my($prefix, $tag, @arg) = @_;
    # Calls _$prefix_$tag if it is defined.
    my($op) = \&{"_$prefix" . "_$tag"};
    return 0
	unless defined(&$op);
    $op->(@arg);
    return 1;
}

sub _delete_empty_rows {
    my($rows) = @_;
    # Deletes totally empty rows from the table.  They are probably separator
    # rows.
    for (my($i) = 0; $i < @$rows; $i++) {
	next if grep(defined($_) && length($_->get('text')), @{$rows->[$i]});
	_trace($rows->[$i]) if $_TRACE;
	splice(@$rows, $i--, 1)
    }
    return;
}

sub _end_table {
    my($self) = @_;
    # The only tables we track are "data" tables.
    my($fields) = $self->[$_IDI];
    return unless $fields->{in_data_table} && !--$fields->{in_data_table};
    # Delete totally empty rows (probably separators)
    _delete_empty_rows($fields->{table}->{rows});
 
   my($elements) = $self->get('elements');
    my($name) = $fields->{table}->{label} ||= '_anon#'
        . keys(%{$self->get('elements')});

    if ($elements->{$name}) {
        my($count) = 1;

        while ($elements->{$name . '#' . $count}) {
            $count++;
        }
        $name .= '#' . $count;
    }
    $elements->{$name} = $fields->{table};
    _trace($fields->{table}) if $_TRACE;
    delete($fields->{table});
    return;
}

sub _end_td {
    my($self) = @_;
    # Adds the text from column to current row
    my($fields) = $self->[$_IDI];
    return unless $fields->{table};
    _save_cell($self, $fields,
	$fields->{table}->{rows}->[$#{$fields->{table}->{rows}}]);
    return;
}

sub _end_th {
    my($self) = @_;
    # Ends the "th".  Saves the cell and id for table (if not already there).
    my($fields) = $self->[$_IDI];
    return unless $fields->{table};
    my($t) = _save_cell($self, $fields, $fields->{table}->{headings});
    $fields->{table}->{label} ||= $t;
    return;
}

sub _eq {
    my($expect, $actual) = @_;
    return ref($expect) ? $actual =~ $expect : $actual eq $expect;
}

sub _found_table {
    my($fields, $id) = @_;
    # Either at <table id=xxx> or at every <th>.  Returns true if
    # initializes table.
    unless ($fields->{in_data_table}) {
	$fields->{in_data_table}++;
	$fields->{table} = {
	    headings => [],
	    rows => [],
	    label => $id,
	};
    }
    elsif ($fields->{in_data_table} > 1) {
	die('nested data tables not supported');
    }
    return;
}

sub _in_data {
    my($fields) = @_;
    # Returns true if at data table level.
    return ($fields->{in_data_table} || 0) == 1 ? 1 : 0;
}

sub _links {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{links} ||= Bivio::Test::HTMLParser::Links->new->internal_put({
	cleaner => $self->get('cleaner'),
	elements => {},
    });
}

sub _save_cell {
    my($self, $fields, $row) = @_;
    # Checks colspan to see if needs filling.  Returns the found text,
    # if any.
    return
	unless $fields->{in_data_table} == 1;
    my($t) = $self->get('cleaner')->text(_text($fields));
    push(@$row, Bivio::Test::HTMLParser::Tables::Cell->new({
	text => $t,
	Links => _links($self)->internal_put(
	    _links($self)->get('elements'))->set_read_only,
    }));
    $fields->{links} = undef;
    _trace($t) if $_TRACE;
    push(@$row, undef)
	while --$fields->{colspan} > 0;
    return $t;
}

sub _start_input {
    my($self, $attr) = @_;
    # Saves "value" attribute.
    my($fields) = $self->[$_IDI];
    $fields->{text} .= $attr->{value} || '';
    return;
}

sub _start_table {
    my($self, $attr) = @_;
    # Increments in_data_table
    my($fields) = $self->[$_IDI];
    $fields->{in_data_table}++
	if $fields->{in_data_table};
    _found_table($fields, $attr->{id})
	if $attr->{id};
    return;
}

sub _start_td {
    my($self, $attr) = @_;
    # Starts a TD.
    my($fields) = $self->[$_IDI];
    # Don't separate cells in nested table
#TODO: Format like a table, e.g. </td> -> ' ', </tr> -> \n
    return unless _in_data($fields);
    $fields->{text} = '';
    $fields->{colspan} = $attr->{colspan} || 1;
    _links($self);
    return;
}

sub _start_th {
    my($self, $attrs) = @_;
    # Starts a TH and initializes {table} if necessary.
    my($fields) = $self->[$_IDI];
    _found_table($fields);
    return _start_td(@_);
}

sub _start_tr {
    my($self, $attr) = @_;
    # Only adds rows if rows has been initialized.
    my($fields) = $self->[$_IDI];
    return unless _in_data($fields);
    push(@{$fields->{table}->{rows}}, [])
	if $fields->{table}->{rows};
    return;
}

sub _text {
    my($fields) = @_;
    # Returns the cleaned text field or an empty string if not defined.
    my($res) = defined($fields->{text}) ? $fields->{text} : '';
    $fields->{text} = undef;
    return $res;
}

1;
