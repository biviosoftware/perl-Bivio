# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CSVImportForm;
use strict;
use Bivio::Base 'Bivio::Biz::FormModel';
use Bivio::Util::CSV;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_C) = __PACKAGE__->use('SQL.Constraint');
my($_T) = __PACKAGE__->use('Bivio::Type');
my($_FF) = __PACKAGE__->use('Type.FileField');
my($_CONFIG) = {};

# subclasses must define COLUMNS with the expected format:
#
#   sub COLUMNS {
#	return [
#	    [column_name => Type|Model.property, (optional: constraint)],
#           ...
#	];
#   }
#
#   constraint defaults to value of Model.property.
#
# DEPRECATED:
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

sub column_info {
    return _config(shift)->{shift(@_)};
}

sub execute_ok {
    my($self) = @_;
    my($columns) = _config($self);
    return
	unless my $rows = _parse_rows($self);
    return $self->internal_source_error(undef, 'No data rows found')
        unless @$rows;
    return unless _validate_columns($self, $rows->[0], $columns);
    my($count) = 1;
    foreach my $row (@$rows) {
	_validate_record($self, $row, $columns, $count++);
	return if $self->in_error;
    }
    $count = 1;
    foreach my $row (@$rows) {
	$self->process_record($row, $count++);
	return if $self->in_error;
    }
    return;
}

sub internal_csv_columns {
    Bivio::IO::Alert->warn_deprecated('define COLUMNS() with new syntax');
    my($proto, $info) = @_;
    return $proto->map_by_two(sub {
	my($k, $v) = @_;
	return [$k, $v->[0], $v->[1] ? 'NOT_NULL' : 'NONE'];
    });
}

sub internal_import_error {
    Bivio::IO::Alert->warn_deprecated('use internal_source_error()');
    return shift->internal_source_error(@_);
}

sub internal_source_error {
    my($self, $row_count, $text) = @_;
    my($ed) = (defined($row_count) ? ('Record ' . $row_count . ': ') : '')
	. $text;
    if ($self->can('CSV_COLUMNS')) {
	# DEPRECATED
	$self->internal_put_error(import_errors => 'NULL');
	$self->internal_put_field(
	    import_errors => $self->get('import_errors') . "\n$ed");
    }
    else {
	my($oed) = $self->get_field_error_detail('source');
	$self->internal_put_error_and_detail(
	    source => 'SYNTAX_ERROR',
	    ($oed ? "$oed\n" : '') . $ed,
	);
    }
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

sub process_content {
    my($self, $content) = @_;
    return $self->process({
	source => $_FF->from_string_ref($content || $self->req->get_content),
    });
}

sub record_to_model_properties {
    my($self, $row, $model) = @_;
    return {map({
	my($i) = $self->column_info($_);
	$i && $i->{field} =~ /^$model\.(\w+)$/ ? ($1 => $row->{$_}) : ();
    }
	keys(%$row),
    )};
}

sub _config {
    my($self) = @_;
    return $_CONFIG->{ref($self)} ||= _config_init($self);
}

sub _config_init {
    my($self) = @_;
    my($method) = $self->can('CSV_COLUMNS') ? 'CSV_COLUMNS' : 'COLUMNS';
    my($seen) = {};
    return {map({
	my($name, $type, $constraint, $field) = @$_;
	Bivio::Die->die($name, ': duplicate name')
	    if $seen->{$name}++;
	$name = lc($name);
	if (my($model, $property) = $type =~ /(\w+)\.(\w+)/) {
	    $field ||= $type;
	    $model = $self->get_instance($model);
	    $type = $model->get_field_type($property);
	    $constraint ||= $model->get_field_constraint($property);
	}
	else {
	    $constraint ||= 'NONE';
	    $type = $_T->get_instance($type);
	}
	($name => {
	    type => $type,
	    constraint => $_C->from_any($constraint),
	    field => $field || $name,
	});
    }
	@{$self->$method()},
    )};
}

sub _parse_rows {
    my($self) = @_;
    my($rows);
    my($die) = Bivio::Die->catch(sub {
        $rows = Bivio::Util::CSV->parse(
	    $self->get('source')->{content},
	);
	return;
    });
    return $self->internal_source_error(undef, 'Invalid CSV file'
	. ($die->get('attrs')->{message}
	    ? (': ' . $die->get('attrs')->{message}) : ''),
    ) if $die;
    return
	unless $rows;
    my($headings) = [map({
	$_ =~ s/^\s*(.*?)\s*$/\L$1/s;
	$_;
    } @{shift(@$rows)})];
    return [map({
	my($row) = $_;
	+{
	    map(($_, shift(@$row)), @$headings),
	};
    } @$rows)];
}

sub _validate_columns {
    my($self, $row, $columns) = @_;
    my($headings) = [keys(%$columns)];
    return grep(exists($row->{$_}), @$headings) == @$headings ? 1
	: $self->internal_source_error(
	    undef,
	    'Missing column(s): '
		. join(',', grep(!exists($row->{$_}), @$headings)),
	);
}

sub _validate_record {
    my($self, $row, $columns, $count) = @_;
    foreach my $name (keys(%$columns)) {
	my($type) = Bivio::Type->get_instance($columns->{$name}->{type});
	my($v, $err);
	if ($type->isa('Bivio::Type::Enum')) {
	    $v = $type->unsafe_from_any($row->{$name});
	    $err = Bivio::TypeError->NOT_FOUND unless $v;
	}
	else {
	    ($v, $err) = $type->from_literal($row->{$name});
	}
	if ($err) {
	    $self->internal_source_error($count,
		$name . ': ' . $row->{$name} . ', ' . $err->get_short_desc)
	}
	# is the field required?
	elsif (my $e = $columns->{$name}->{constraint}->check_value($v)) {
	    $self->internal_source_error(
		$count, "${name}: " . $e->get_long_desc);
	}
	$row->{$name} = $v;
    }
    return;
}

1;
