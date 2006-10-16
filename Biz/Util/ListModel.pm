# Copyright (c) 2000,2001 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Util::ListModel;
use strict;
$Bivio::Biz::Util::ListModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Util::ListModel::VERSION;

=head1 NAME

Bivio::Biz::Util::ListModel - manipulate list models

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Util::ListModel;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Biz::Util::ListModel::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Biz::Util::ListModel> provides utilities to manipulate
ListModels generically.

=cut

=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:

    usage: b-list-model [options] command [args...]
    commands:
	   csv model [query [columns]]

=cut

sub USAGE {
    return <<'EOF';
usage: b-list-model [options] command [args...]
commands:
	csv model [query [columns]]
EOF
}

#=IMPORTS
use Bivio::Biz::Action;
use Bivio::IO::Trace;
use Bivio::Util::CSV;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="csv"></a>

=head2 csv(string model, string query, string columns) : string_ref

=head2 static csv(Bivio::Biz::ListModel models, string query, string columns) : string_ref

Generate CSV from list model.  If I<models> is a list, only the last
one is written.  The others are just loaded.

=cut

sub csv {
    my($self, $models, $query, $columns) = @_;
    $self->initialize_ui;
    $self->usage('too few arguments') unless int(@_) >= 2;

#TODO: Remove this ugly hack
    Bivio::Die->eval(sub {
	Bivio::Biz::Action->get_instance('PublicRealm')
	    ->execute_simple($self->get_request);
    });

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
    my($cols) = $columns ?
	    [
		map {
		    {
			name => $_,
			type => $model->get_field_info($_, 'type'),
		    }
		} (split(/[,\s]+/, $columns))
	    ]
	    : [
		sort {
		    $a->{name} cmp $b->{name};
		} values(%{$model->get_info('columns')})
	    ];
    my($res) = join(',', map {$_->{name}} @$cols)."\n";
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

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000,2001 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
