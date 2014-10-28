# Copyright (c) 1999-2012 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::TaskId;
use strict;
use Bivio::Base 'Type.EnumDelegator';

my($_JSON_SUFFIX) = '_JSON';
my($_JSON_RE) = qr{$_JSON_SUFFIX$}ois;
my($_INFO_RE) = qr{^info_(.*)};
my($_INCLUDED_COMPONENT) = {};
my($_PS) = b_use('Auth.PermissionSet');
my($_C) = b_use('IO.Config');
my($_A) = b_use('IO.Alert');
my($_CFG);
_compile(__PACKAGE__);

sub bunit_validate_all {
    # Sanity check to make sure the the list of info_ methods don't collide
    my($proto) = @_;
    my($seen) = {};
    foreach my $c (@{$proto->standard_components}) {
	foreach my $t (@{_component_info($proto, $c) || []}) {
	    my($n) = ref($t) eq 'ARRAY' ? $t->[0] : $t->{name};
	    Bivio::Die->die($c, ' and ', $seen->{$n}, ': both define ', $n)
	        if $seen->{$n};
	    $seen->{$n} = $c;
	}
    }
    return;
}

sub canonicalize_task_decl {
    my($proto, $cfg) = @_;
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
}

sub canonicalize_task_info {
    my($proto, $info) = @_;
    my($seen) = {};
    my($validate) = sub {
	my($cfg) = @_;
	b_die($cfg, 'name: missing from: ', $cfg)
	    unless $cfg->{name};
	b_die($cfg->{name}, ': duplicate name')
	    if $seen->{$cfg->{name}}++;
	return $cfg;
    };
    return [map($validate->($proto->canonicalize_task_decl($_)), @$info)];
}

sub get_cfg_list {
    return $_CFG;
}

sub if_task_is_json {
    my($self) = shift;
    return $self->if_then_else($self->get_name =~ $_JSON_RE || 0, @_);
}

sub included_components {
    return [sort _sort keys(%$_INCLUDED_COMPONENT)];
}

sub internal_json_decl {
    my($proto, $decl) = @_;
    $decl = $proto->canonicalize_task_decl($decl);
    b_die($decl->{name}, ": does not match $_JSON_RE")
	unless $decl->{name} =~ $_JSON_RE;
    # JSON tasks just return "OK" unless 
    push(@{$decl->{items}}, 'Action.JSONReply->http_ok');
    return $decl;
}

sub is_component_included {
    my(undef, $component) = @_;
    return $_INCLUDED_COMPONENT->{$component} || 0;
}

sub is_continuous {
    return 0;
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
	return [
	    {
		name => "_TASK_COMPONENT_$component",
		int => 0,
	    },
	    @$tasks,
	];
    };
    return $merge->([
	map(@{$proto->canonicalize_task_info($info->($_))}, @info),
    ]);
}

sub standard_components {
    my($proto) = @_;
    return [sort(
        _sort
	grep(
	    $_ ne 'otp'
		&& $_C->if_version(10, 1, sub {$_ ne 'task_log'}),
	    @{$proto->internal_delegate_package->grep_methods($_INFO_RE)},
	),
    )];
}

sub _compile {
    my($proto) = @_;
    return
	if $_CFG;
    $_CFG = [];
    foreach my $cfg (@{$proto->internal_delegate_package->get_delegate_info}) {
	if ($cfg->{name} =~ /_TASK_COMPONENT_(\w+)/) {
	    $_INCLUDED_COMPONENT->{lc($1)}++;
	}
	else {
	    push(@$_CFG, $cfg);
	}
    }
    $proto->compile([
	map(
	    (
		$_->{name},
		[$_->{int} || b_die($_, ': missing int')],
	    ),
	    @{$proto->get_cfg_list},
	)
    ]);
    return;
}

sub _component_info {
    my($proto, $component) = @_;
    my($method) = "info_$component";
    my($delegate) = $proto->internal_delegate_package;
    b_die($component, ': no such info_* component in ', $delegate)
        unless $delegate->can($method);
    return $delegate->$method;
}

sub _sort {
    return $a eq $b ? 0
	: $a eq 'base' ? -1
	: $b eq 'base' ? +1
	: $a cmp $b;
}

1;
