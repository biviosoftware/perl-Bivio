# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Util::ListModel;
use strict;
$Bivio::Biz::Util::ListModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Util::ListModel::VERSION;

=head1 NAME

Bivio::Biz::Util::ListModel - manipulate a list model

=head1 SYNOPSIS

    use Bivio::Biz::Util::ListModel;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Biz::Util::ListModel::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Biz::Util::ListModel> implements utilities that use
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
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

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
    $self->usage('too few arguments') unless int(@_) >= 2;
    my($model) = $models;
    unless (ref($model)) {
	foreach my $model_name (split(/[,\s]+/, $models)) {
	    $model = Bivio::Biz::Model->new($self->get_request, $model_name);
	    die(ref($model), ': is not a ListModel')
		    unless $model->isa('Bivio::Biz::ListModel');
	    $model->load_all(Bivio::Agent::HTTP::Query->parse($query || ''));
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
    $model->reset_cursor;
    while ($model->next_row) {
	foreach my $c (@$cols) {
	    my($cell) = $c->{type}->to_string($model->get($c->{name}));
	    _quote_cell(\$cell);
	    $res .= $cell.',';
	}
	chop($res);
	$res .= "\n";
    }

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

# _quote_cell(string_ref cell)
#
# Quotes the cell, if need be.
#
sub _quote_cell {
    my($cell) = @_;
    return unless $$cell =~ /,/s;
    $$cell =~ s/"/""/sg;
    $$cell =~ s/^|$/"/sg;
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
