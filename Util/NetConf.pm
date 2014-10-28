# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::NetConf;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_DIE) = b_use('Bivio.Die');
my($_CIDRN) = b_use('Type.CIDRNotation');
my($_IPA) = b_use('Type.IPAddress');
my($_F) = b_use('IO.File');

sub generate {
    sub GENERATE {[[qw(?conf Hash), sub {$_DIE->eval_or_die(shift->read_input)}]]}
    my($self, $bp) = shift->parameters(\@_);
    $self->put(
	LinuxConfig => $self->new_other('LinuxConfig'),
	net_conf => _parse_net_conf(
	    $bp->{conf}->{net} || b_die($bp->{conf}, ': no {net}')),
	domains => [],
    );
    my($devices) = $bp->{conf}->{host}->{devices}
	|| b_die($bp->{conf}, ': no conf->{host}->{devices}');
    # Order matters: Hostname is always first network sorted alpha (eth0)
    foreach my $device (sort(keys(%$devices))) {
	_generate_ifcfg($self, $device, $devices->{$device});
    }
    _generate_network($self);
    _generate_resolv_conf($self);
    _generate_hosts($self);
    return;
}

sub _generate_hosts {
    my($self) = @_;
    return _write(
	$self,
	'etc/hosts',
	join(
	    '',
	    map(
		"$_->[0]\t$_->[1]\n",
		['127.0.0.1', 'localhost.localdomain localhost'],
		@{$self->get('domains')},
	    ),
	),
    );
}

sub _generate_ifcfg {
    my($self, $device, $domain) = @_;
    my($ip) = $_IPA->from_domain($domain);
    my($c) = $self->get('net_conf')->{$ip};
    push(@{$self->get('domains')}, [$ip, $domain]);
    $self->put_unless_exists(nameservers => $c->{dns});
    return _write($self, "etc/sysconfig/network-scripts/ifcfg-$device", <<"EOF");
DEVICE=$device
ONBOOT=yes
BOOTPROTO=none
IPADDR=$ip
NETMASK=$c->{net_mask}@{[$c->{gateway} ? "\nGATEWAY=$c->{gateway}" : '']}
EOF
}

sub _generate_network {
    my($self) = @_;
    return _write($self, 'etc/sysconfig/network', <<"EOF");
HOSTNAME=@{[$self->get('domains')->[0]->[1]]}
NETWORKING=yes
NETWORKING_IPV6=yes
EOF
}

sub _generate_resolv_conf {
    my($self) = @_;
    my($d) = $self->get('net_conf')->{search_domain}
	|| b_die('no search domain in net_conf');
    return _write(
	$self,
	'etc/resolv.conf',
	join(
	    '',
	    "search $d\n",
	    "domain $d\n",
	    map(
		'nameserver ' . $_IPA->from_domain($_) . "\n",
		@{$self->get('nameservers')},
	    ),
	    '',
	),
    );
}

sub _parse_net_conf {
    my($net_conf) = @_;
    return {map(
	{
	    my($x) = $_;
	    if ($x->{cidr}) {
		$x = {%$x};
		my($c) = $_CIDRN->from_literal_or_die($x->{cidr});
		$x->{net_mask} = $c->get_net_mask;
		$x->{gateway} = $c->assert_host_address(
		    $_IPA->from_domain($x->{gateway}),
		) if $x->{gateway};
		$x->{cidr} = $c;
	        $x = {@{$c->map_host_addresses(sub {shift(@_) => $x})}};
	    }
	    %$x;
	}
	values(%$net_conf),
    )};
}

sub _write {
    my($self, $file, $data) = @_;
    $_F->mkdir_parent_only($file);
    $self->get('LinuxConfig')->replace_file(
	$file,
	'root',
	'root',
	0444,
	<<'EOF' . $data,
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: Bivio::Util::NetConf
################################################################
EOF
    );
}

1;
