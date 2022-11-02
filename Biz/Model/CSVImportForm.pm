# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CSVImportForm;
use strict;
use Bivio::Base 'Biz.FormModel';

my($_C) = b_use('SQL.Constraint');
my($_T) = b_use('Bivio::Type');
my($_FF) = b_use('Type.FileField');
my($_CONFIG) = {};
my($_A) = b_use('IO.Alert');
my($_F) = b_use('IO.File');

# subclasses must define COLUMNS with the expected format:
#
#   sub COLUMNS {
#        return [
#            [column_name => Type|Model.property, (optional: constraint)],
#           ...
#        ];
#   }
#
#   constraint defaults to value of Model.property.
#
# subclasses should defined process_record(row, count) to do work

sub CONTINUE_VALIDATION_ON_ERROR {
    return 0;
}

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
    return
        unless _validate_columns($self, $rows->[0], $columns);
    my($count) = 1;
    foreach my $row (@$rows) {
        _validate_record($self, $row, $columns, $count++);
        next
            if $self->CONTINUE_VALIDATION_ON_ERROR;
        return
            if $self->in_error;
    }
    return
        if $self->in_error;
    $count = 1;
    foreach my $row (@$rows) {
        $self->process_record($row, $count++);
        return
            if $self->in_error;
    }
    return;
}

sub internal_import_error {
    Bivio::IO::Alert->warn_deprecated('use internal_source_error()');
    return shift->internal_source_error(@_);
}

sub internal_source_error {
    my($self, $row_count, @args) = @_;
    my($ed) = $_A->format_args(
        defined($row_count) ? ('Record ', $row_count, ': ') : (),
        @args,
    );
    my($oed) = $self->get_field_error_detail('source');
    $self->internal_put_error_and_detail(
        source => 'SYNTAX_ERROR',
        ($oed || "\n") . $ed,
    );
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
    my(@res) = shift->SUPER::internal_pre_execute(@_);
    $self->internal_put_field(import_errors => '');
    return @res;
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
        $i && $i->{field} =~ /^$model\.(\w.*)/ ? ($1 => $row->{$_}) : ();
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
    my($seen) = {};
    return {map({
        my($name, $type, $constraint, $field) = @$_;
        Bivio::Die->die($name, ': duplicate name')
            if $seen->{$name}++;
        $name = lc($name);
        if (my($model, $property) = $type =~ /(\w+)\.(\w.*)/) {
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
        @{$self->COLUMNS},
    )};
}

sub _parse_rows {
    my($self) = @_;
    my($rows);
    my($die) = Bivio::Die->catch(sub {
        # write to temp file first - source->{content}
        # takes too long to read for large input...
        my($f) = $_F->temp_file($self->req);
        $_F->write($f, $self->get('source')->{content});
        $rows = b_use('ShellUtil.CSV')->parse($_F->read($f));
        return;
    });
    return $self->internal_source_error(
        undef,
        'Invalid CSV file',
        $die->get('attrs')->{message} ? (': ', $die->get('attrs')->{message}) : (),
    ) if $die;
    return $rows
        unless $rows && @$rows;
    my($headings) = [map({
        $_ =~ s/^\s*(.*?)\s*$/\L$1/s;
        $_;
    } @{shift(@$rows)})];
    return [map({
        my($row) = $_;
        grep(defined($_) && $_ =~ /\S/, @$row)
            ? {
                map(($_, shift(@$row)), @$headings),
            } : ();
    } @$rows)];
}

sub _validate_columns {
    my($self, $row, $columns) = @_;
    my($headings) = [keys(%$columns)];
    return grep(
        exists($row->{$_}) || $columns->{$_}->{constraint} eq $_C->NONE,
        @$headings) == @$headings
        ? 1
        : $self->internal_source_error(
            undef,
            'Missing column(s): ',
                [grep(!exists($row->{$_}), @$headings)],
        );
}

sub _validate_record {
    my($self, $row, $columns, $count) = @_;
    my($no_error) = 1;

    foreach my $name (keys(%$columns)) {
        my($type) = $columns->{$name}->{type};
        my($v, $err);
        if ($type->isa('Bivio::Type::Enum') && defined($row->{$name})) {
            $row->{$name} =~ s/^\s+|\s+$//g;
            if (length($row->{$name})) {
                $v = $type->unsafe_from_any($row->{$name});
                $err = Bivio::TypeError->SYNTAX_ERROR
                    unless $v;
            }
        }
        else {
            ($v, $err) = $type->from_literal($row->{$name});
        }
        if ($err) {
            $no_error = 0;
            $self->internal_source_error(
                $count,
                $name,
                ': ',
                defined($row->{$name}) && length($row->{$name})
                    ? ($row->{$name}, ', ')
                    : (),
                $err->get_long_desc,
            );
        }
        elsif (my $e = $columns->{$name}->{constraint}->check_value($type, $v)) {
            $no_error = 0;
            $self->internal_source_error(
                $count,
                $name,
                ': ',
                $e->get_long_desc,
            );
        }
        $row->{$name} = $v;
    }
    $self->validate_record($row, $count)
        if $no_error && $self->can('validate_record');
    return;
}

1;
