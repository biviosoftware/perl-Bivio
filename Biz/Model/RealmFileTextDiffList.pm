# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmFileTextDiffList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = b_use('Type.FilePath');

sub get_compare_file {
    my($self) = @_;
    return _get_file($self, 'compare');
}

sub get_compare_name {
    my($self) = @_;
    return $_FP->get_tail($self->get_compare_file->get('path'));
}

sub get_versionless_name {
    my($self) = @_;
    return $_FP->get_versionless_tail($self->get_selected_file->get('path'));
}

sub get_selected_file {
    my($self) = @_;
    return _get_file($self, 'selected');
}

sub get_selected_name {
    my($self) = @_;
    return $_FP->get_tail($self->get_selected_file->get('path'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
	    map(+{
		name => $_,
		type => 'String',
		constraint => 'NONE',
	    }, qw(line_info same top bottom)),
	],
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($left) = ${$self->get_compare_file->get_content};
    my($right) = ${$self->get_selected_file->get_content};
    my($rows) = [];
    if ($self->use('Algorithm::Diff')) {
	my($diff) = Algorithm::Diff->new(
	    map([split(/(?<=\n)/, $_)], $left , $right),
	);
	$diff->Base(1);
	while ($diff->Next) {
	    my($top, $bot) = map({
		my($s) = ($_ ? '+' : '-');
		join('', map($diff->Same ? $_ : "$s $_", $diff->Items($_ + 1)));
	    } 0, 1);
	    push(@$rows, {
		line_info => $diff->Same ? '' : _line_info($diff),
		same => $diff->Same ? $top : '',
		top => $diff->Same ? '' : $top,
		bottom => $diff->Same ? '' : $bot,
	    });
	}
    }
    return [@$rows];
}

sub _get_file {
    my($self, $name) = @_;
    return $self->new_other('RealmFile')->load({
	realm_file_id => $self->req('query')->{$name},
    });
}

sub _line_info {
    my($diff) = shift;
    return sprintf(
	"%s",
	$diff->Items(2)
	    ? sprintf('%d,%dd%d', $diff->Get(qw(Min1 Max1 Max2)))
		: $diff->Items(1) ? (
		    sprintf('%d,%dc%d,%d',
			    $diff->Get(qw(Min1 Max1 Min2 Max2))),
		    my($sep) = "--",
		)[0] : sprintf('%da%d,%d',
			       $diff->Get(qw(Max1 Min2 Max2))),
    );
}

1;
