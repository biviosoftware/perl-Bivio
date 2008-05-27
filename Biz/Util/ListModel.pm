# Copyright (c) 2000-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Util::ListModel;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::Biz::Action;
use Bivio::IO::Trace;
use Bivio::Util::CSV;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);

sub USAGE {
    return <<'EOF';
usage: b-list-model [options] command [args...]
commands:
	csv model [query [columns]]
EOF
}

sub csv {
    my($self, $models, $query, $columns) = @_;
    # Generate CSV from list model.  If I<models> is a list, only the last
    # one is written.  The others are just loaded.
    $self->initialize_ui;
    $self->usage('too few arguments') unless int(@_) >= 2;
#TODO: Remove this ugly hack
    my($pr) = Bivio::IO::ClassLoader->unsafe_map_require('Action.PublicRealm');
    $pr->get_instance->execute_simple($self->req)
	if $pr;
    my($model) = $models;
    my($iterating) = {};
    my($method) = 'next_row';
    unless (ref($model)) {
	foreach my $model_name (split(/[,\s]+/, $models)) {
	    $model = Bivio::Biz::Model->new($self->get_request, $model_name);
	    die(ref($model), ': is not a ListModel')
		unless $model->isa('Bivio::Biz::ListModel');
	    my($m) = 'load_all';
	    if ($models =~ /(,|^)$model_name$/ && $model->can_iterate) {
		$method = 'iterate_next_and_load';
		$m = 'iterate_start';
	    }
	    $model->$m(Bivio::Agent::HTTP::Query->parse($query || ''));
	}
    }
    my($cols) = $columns ? [
	map(+{
	    name => $_,
	    type => $model->get_field_info($_, 'type'),
	}, split(/[,\s]+/, $columns)),
    ] : [
	sort({
	    $a->{name} cmp $b->{name};
	} values(%{$model->get_info('columns')})),
    ];
    my($res) = join(',', map($_->{name}, @$cols)) . "\n";
    $model->reset_cursor
	if $method eq 'next_row';
    while ($model->$method()) {
        $res .= ${Bivio::Util::CSV->to_csv_text([
            map($_->{type}->to_string($model->get($_->{name})), @$cols),
        ])};
    }
    $model->iterate_end
	if $method eq 'iterate_next_and_load';

    $res .= <<"EOF";

Notes:
Date: @{[Bivio::Type::DateTime->now_as_string]}
Command: @{[$self->command_line]}
EOF
    if ($model->can('get_load_notes')) {
	my($notes) = $model->get_load_notes() || '';
	$res .= $notes;
    }
    $self->put(result_name => $model->simple_package_name.'.csv',
	    result_type => 'application/x-unknown-content-type-Excel.CSV');
    return \$res;
}

1;
