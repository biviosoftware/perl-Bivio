# Copyright (c) 2007-2012 bivio Software, Inc.	All Rights Reserved.
# $Id$
package Bivio::Delegate::TaskId;
use strict;
use Bivio::Base 'Bivio.Delegate';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_INFO_RE) = qr{^info_(.*)};
my($_INCLUDED) = {};
my($_PS) = b_use('Auth.PermissionSet');
my($_C) = b_use('IO.Config');
my($_A) = b_use('IO.Alert');
my($_TC) = b_use('Agent.TaskComponents');

sub bunit_validate_all {
    # Sanity check to make sure the the list of info_ methods don't collide
    my($proto) = @_;
    my($seen) = {};
    foreach my $c (@{$proto->standard_components}) {
	foreach my $t (@{_component_info($proto, $c) || []}) {
	    my($n) = $t->[0];
	    Bivio::Die->die($c, ' and ', $seen->{$n}, ': both define ', $n)
	        if $seen->{$n};
	    $seen->{$n} = $c;
	}
    }
    return;
}

sub canonicalize_task_info {
    my($proto, $info) = @_;
    my($canonicalize) = sub {
	my($cfg) = @_;
	if (ref($cfg) eq 'HASH') {
	    if ($cfg->{permissions}) {
		$_A->warn_deprecated(
		    $cfg->{name},
		    ': permissions deprecated, use permission_set',
		);
		$cfg->{permission_set} = delete($cfg->{permissions});
	    }
	    return $cfg;
	}
	if (ref($cfg) eq 'ARRAY') {
	    return {
		name => shift(@$cfg),
		int => shift(@$cfg),
		realm_type => shift(@$cfg),
		permission_set => shift(@$cfg),
		items => [grep(!/=/, @$cfg)],
		map(split(/=/, $_, 2), grep(/=/, @$cfg)),
	    };
	}
	b_die($cfg, ': invalid config format');
        # DOES NOT RETURN
    };
    my($seen) = {};
    my($validate) = sub {
	my($cfg) = @_;
	b_die($cfg, 'name: missing from: ', $cfg)
	    unless $cfg->{name};
	b_die($cfg->{name}, ': duplicate name')
	    if $seen->{$cfg->{name}}++;
	return $cfg;
    };
    return [map($validate->($canonicalize->($_)), @$info)];
}

sub get_delegate_info {
    return shift->merge_task_info('base');
}

sub included_components {
    return [sort _sort keys(%$_INCLUDED)];
}

sub is_component_included {
    my(undef, $component) = @_;
    return $_INCLUDED->{$component} || 0;
}

sub merge_task_info {
    my($proto, @info) = @_;
    my($merge) = sub {
	my($info) = @_;
	my($map) = {};
	foreach my $cfg (@$info) {
	    $map->{$cfg->{name}} = {
		%{$map->{$cfg->{name}} || {}},
		%$cfg,
	    };
	}
	return [sort(
	    {$a->{int} <=> $b->{int}}
	    values(%$map),
	)];
    };
    my($info) = sub {
	my($component) = @_;
	return $component
	    if ref($component);
	return []
	    unless my $tasks = _component_info($proto, $component);
	$_INCLUDED->{$component} = 1;
	return $tasks;
    };
    return $merge->([
	map(@{$proto->canonicalize_task_info($info->($_))}, @info),
    ]);
}

sub standard_components {
    return [sort
        _sort
	grep(
	    $_ ne 'otp'
		&& $_C->if_version(10, 1, sub {$_ ne 'task_log'}),
	    @{$_TC->grep_methods($_INFO_RE)},
	),
    ];
}

sub _component_info {
    my($proto, $component) = @_;
    my($m) = "info_$component";
    b_die($component, ': no such info_* component')
        unless $_TC->can($m);
    return $_TC->$m();
}

sub _sort {
    return $a eq $b ? 0
	: $a eq 'base' ? -1
	: $b eq 'base' ? +1
	: $a cmp $b;
}

1;
