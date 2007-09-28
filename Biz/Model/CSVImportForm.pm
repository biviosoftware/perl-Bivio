# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CSVImportForm;
use strict;
use Bivio::Base 'Bivio::Biz::FormModel';
use Bivio::Util::CSV;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# subclasses must define CSV_COLUMNS with the expected format:
#
#   my($_CSV);
#   sub CSV_COLUMNS {
#       return $_CSV ||= __PACKAGE__->internal_csv_columns([
#           <column name> => [<Type or Model.property>, <is required>],
#           ...
#       ]);
#   }
#
# subclasses should defined process_record(row, count) to do work

sub execute_ok {
    my($self) = @_;
    my($count) = 0;
    my($csv_info) = $self->CSV_COLUMNS;
    my($rows) = [];

    foreach my $row (@{_parse_rows($self)}) {
        $count++;

	# only need to check columns once
	if ($count == 1) {
	    _validate_columns($self, $row, $csv_info);
	    return if $self->in_error;
	}
	_validate_record($self, $row, $csv_info->{columns}, $count);
	push(@$rows, $row)
	    unless $self->in_error;
    }
    $self->internal_import_error(undef, 'No data was found in the file')
        unless $count;
    return if $self->in_error;
    $count = 0;

    foreach my $row (@$rows) {
	$count++;
	$self->process_record($row, $count);
	last if $self->in_error;
    }
    return;
}

sub internal_csv_columns {
    my($proto, $info) = @_;
    my($res) = {};

    for (my $i = 0; $i < @$info; $i += 2) {
	my($k, $v) = (@$info)[$i, $i + 1];
	$res->{columns}->{lc($k)} = $v;
	push(@{$res->{headings} ||= []}, $k);
	my($model, $field) = $v->[0] =~ /(\w+)\.(\w+)/;
	next unless $model;
	$v->[0] = Bivio::Biz::Model->get_instance($model)
	    ->get_field_type($field);
    }
    return $res;
}

sub internal_import_error {
    my($self, $row_count, $text) = @_;
    $self->internal_put_error(import_errors => 'NULL');
    $self->internal_put_field(import_errors =>
        $self->get('import_errors') . "\n"
	. (defined($row_count) ? ('Record ' . $row_count . ': ') : '')
	. $text);
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    {
		name => 'source',
		type => 'FileField',
		constraint => 'NOT_NULL',
	    },
	],
	other => [
	    {
		name => 'import_errors',
		type => 'String',
		constraint => 'NONE',
	    },
        ],
    });
}

sub internal_pre_execute {
    my($self, $method) = @_;
    $self->internal_put_field(import_errors => '');
    return;
}

sub _parse_rows {
    my($self) = @_;
    my($rows) = [];
    my($die) = Bivio::Die->catch(sub {
        $rows = Bivio::Util::CSV->parse_records(
	    $self->get('source')->{content});
    });
    $self->internal_import_error(undef, 'Invalid CSV file'
	. ($die->get('attrs')->{message}
	    ? (': ' . $die->get('attrs')->{message})
	    : ''))
        if $die;
    my($res) = [];

    foreach my $row (@$rows) {
        push(@$res, {
            map((_strip($_), $row->{$_}), keys(%$row)),
        });
    }
    return $res;
}

sub _strip {
    my($str) = @_;
    $str =~ s/^\s*(.*?)\s*$/lc($1)/e;
    return $str;
}

sub _validate_columns {
    my($self, $row, $csv_info) = @_;
    my(@columns) = keys(%{$csv_info->{columns}});
    $self->internal_import_error(undef,
	'Invalid CSV, expected columns: '
	. join(',', @{$csv_info->{headings}}))
	unless scalar(grep(exists($row->{$_}), @columns)) == scalar(@columns);
    return;
}

sub _validate_record {
    my($self, $row, $columns, $count) = @_;

    foreach my $name (keys(%$columns)) {
	my($type) = Bivio::Type->get_instance($columns->{$name}->[0]);
	my($v, $err);

	if ($type->isa('Bivio::Type::Enum')) {
	    $v = $type->unsafe_from_any($row->{$name});
	    $err = Bivio::TypeError->NOT_FOUND unless $v;
	}
	else {
	    ($v, $err) = $type->from_literal($row->{$name});
	}

	if ($err) {
	    $self->internal_import_error($count,
		$name . ': ' . $row->{$name} . ', ' . $err->get_short_desc)
	}
	# is the field required?
	elsif ($columns->{$name}->[1]) {
	    unless (defined($v) && length($v)) {
		$self->internal_import_error($count,
		    'Missing field value for ' . $name);
		next;
	    }
	}
	$row->{$name} = $v;
    }
    return;
}

1;
