# Copyright (c) 2002-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Util::LinuxConfig;
my($_tmp) = "$ENV{PWD}/LinuxConfig2.tmp/";
CORE::system("rm -rf $_tmp; mkdir $_tmp;");

Bivio::Util::LinuxConfig->mock_dns({
    'gw1.example.com'  => '192.168.0.33',
    'gw2.example.com'  => '192.168.0.62',
    'one.example.com' => '192.168.0.34',
    'two.example.com' => '192.168.0.35',
    'ns1.example.com'  => '192.168.0.60',
    'ns2.example.com'  => '192.168.0.61',
    'gw1.private.example.com' => '192.168.1.65',
    'three.private.example.com' => '192.168.1.66',
    'ns1.private.example.com' => '192.168.1.90',
    'ns2.private.example.com' => '192.168.1.91',
});

Bivio::Test->unit([
    'Bivio::Util::LinuxConfig' => [
	_assert_network_configured_for => [
	    ['unknown.example.com'] => Bivio::DieCode->NOT_FOUND,
	    ['one.example.com'] => Bivio::DieCode->CONFIG_ERROR,
	],
	handle_config => [
	    [{
		root_prefix => $_tmp,
		hostname => 'one.example.com',
		networks => {
		    '192.168.0.32' => {
			mask => 27,
			gateway => 'gw1.example.com',
		    },
		},
	    }] => sub {
		my($case, $actual) = @_;
		my($expect) = [{
		    map(('192.168.0.'.(32+$_) => {
			network => '192.168.0.32',
			mask => 27,
			gateway => 'gw1.example.com',
		    }), 0..30),
		}];
		$case->actual_return([
		    $case->get('object')->_get_networks_config,
		]);
		return $expect;
	    },
	],
	_assert_network_configured_for => [
	    ['one.example.com'] => undef,
	],
	_assert_dns_configured_for => [
	    ['one.example.com'] => Bivio::DieCode->CONFIG_ERROR,
	],
	handle_config => [
	    [{
		root_prefix => $_tmp,
		hostname => 'one.example.com',
		networks => {
		    '192.168.0.32' => {
			mask => 27,
			gateway => 'gw1.example.com',
			dns => [qw(ns1.example.com ns2.example.com)],
			static_routes => {
			    '192.168.1.64' => 'gw2.example.com',
			},
		    },
		    '192.168.1.64' => {
			mask => 27,
			gateway => 'gw1.private.example.com',
			dns => [qw(ns1.private.example.com
				   ns2.private.example.com)],
		    },
		},
	    }] => undef,
	],
	_assert_dns_configured_for => [
	    ['one.example.com'] => undef,
	],
	_file_hosts => [
	    ['one.example.com'] =>
		['etc/hosts', \(<<'EOF')],
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: Bivio::Util::LinuxConfig
################################################################
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1		localhost.localdomain localhost
192.168.0.34	one.example.com
EOF
	    ['one.example.com', 'two.example.com'] =>
		['etc/hosts', \(<<'EOF')],
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: Bivio::Util::LinuxConfig
################################################################
# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1		localhost.localdomain localhost
192.168.0.34	one.example.com
192.168.0.35	two.example.com
EOF
	],
	_file_resolv_conf => [
	    ['one.example.com'] => ['etc/resolv.conf', \(<<'EOF')],
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: Bivio::Util::LinuxConfig
################################################################
search example.com
domain example.com
nameserver 192.168.0.60
nameserver 192.168.0.61
EOF
	],
	_file_network => [
	    [qw(one.example.com)] =>
		['etc/sysconfig/network', \(<<'EOF')],
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: Bivio::Util::LinuxConfig
################################################################
NETWORKING=yes
HOSTNAME=one.example.com
EOF
	],
	_bits2netmask => [
	    [24] => '255.255.255.0',
	    [25] => '255.255.255.128',
	    [26] => '255.255.255.192',
	    [27] => '255.255.255.224',
	    [28] => '255.255.255.240',
	    [29] => '255.255.255.248',
	    [30] => '255.255.255.252',
	],
	_assert_netmask_and_gateway_for => [
	    ['one.example.com'] => ['255.255.255.224', '192.168.0.33'],
	],
	_file_ifcfg => [
	    [qw(eth0 one.example.com)] =>
		['etc/sysconfig/network-scripts/ifcfg_eth0', \(<<'EOF')],
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: Bivio::Util::LinuxConfig
################################################################
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.0.34
NETMASK=255.255.255.224
GATEWAY=192.168.0.33
EOF
	    [qw(eth0:1 two.example.com)] =>
		['etc/sysconfig/network-scripts/ifcfg_eth0:1', \(<<'EOF')],
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: Bivio::Util::LinuxConfig
################################################################
DEVICE=eth0:1
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.0.35
NETMASK=255.255.255.224
GATEWAY=192.168.0.33
EOF
	],
	_file_static_routes => [
	    ['eth0 three.private.example.com'] => [],
	    ['eth0 one.example.com', 'eth0:1 two.example.com'] =>
		['etc/sysconfig/static_routes', \(<<'EOF')],
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: Bivio::Util::LinuxConfig
################################################################
eth0 net 192.168.1.64 netmask 255.255.255.224 gw 192.168.0.62
EOF
	    ['eth0 one.example.com', 'eth1 three.private.example.com'] =>
		['etc/sysconfig/static_routes', \(<<'EOF')],
################################################################
# Automatically Generated File; LOCAL CHANGES WILL BE LOST!
# By: Bivio::Util::LinuxConfig
################################################################
eth0 net 192.168.1.64 netmask 255.255.255.224 gw 192.168.0.62
EOF
	],
	generate_network => [
	    ['bogusargs'] => Bivio::DieCode->DIE,
	    ['eth0', 'one.example.com'] => Bivio::DieCode->DIE,
	    ['eth0 one.example.com', 'eth0:1 two.example.com'] => sub {
		my($case) = @_;
		my($o) = $case->get('object');
		my($expect) = [map(
		    [$_tmp . $_->[0], $_->[1]],
		    [$o->_file_hosts('one.example.com', 'two.example.com')],
		    [$o->_file_resolv_conf(qw(one.example.com))],
		    [$o->_file_network(qw(one.example.com))],
		    [$o->_file_ifcfg(qw(eth0 one.example.com))],
		    [$o->_file_ifcfg(qw(eth0:1 two.example.com))],
		    [$o->_file_static_routes('eth0 one.example.com')],
		)];
		$case->actual_return([
		    map([$_->[0], Bivio::IO::File->read($_->[0])],  @$expect),
		]);
		return $expect;
	    },
	],
    ],
]);
