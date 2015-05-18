# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::NamedConf;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

my($_D) = b_use('Bivio.Die');
my($_F) = b_use('IO.File');
my($_ZONE_DIR) = 'var/named';
my($_ROOT_FILE) = 'named.root';
my($_DT) = b_use('Type.DateTime');
my($_CIDRN) = b_use('Type.CIDRNotation');

sub USAGE {
    return <<'EOF';
usage: bivio NamedConf [options] command [args..]
commands
  generate -- create /var/named and /etc/named.conf from input in pwd
  root_file -- get named.root from internic.net
EOF
}

sub generate {
    my($self) = @_;
    # http://zytrax.com/books/dns/
#TODO: Shoudl we use named-checkzone and named-checkconf on all files(?); doesn't do much
    my($cfg) = $_D->eval_or_die(${$self->read_input});
    _local_cfg($cfg);
    $_F->mkdir_p('etc');
    $_F->mkdir_p($_ZONE_DIR);
    _write({
	'etc/named.conf' => _conf($self, $cfg),
	$_ROOT_FILE => $self->root_file,
	_zones($self, $cfg),
    });
    return;
}

sub root_file {
    my($self) = @_;
    return ${b_use('Ext.LWPUserAgent')
	->bivio_http_get('http://www.internic.net/zones/named.root')};
}

sub _dot {
    my($name, $origin) = @_;
    return $name
	if $name =~ /[\.\@]$/;
    $name = "$name.$origin"
	if $origin;
    $name .= '.'
	unless $name =~ /\.$/;
    return $name;
}

sub _local_cfg {
    my($cfg) = @_;
    my($common) = {
	expiry => '1D',
	hostmaster => 'hostmaster.local.',
	servers => ['local.'],
	minimum => '1D',
	mx => undef,
	refresh => '1D',
	retry => '1D',
	spf1 => undef,
	dkim1 => undef,
	ttl => '1D',
    };
    my($net) = '127.0.0.0/31';
    $cfg->{nets}->{'0.0.127'} = {
	%$common,
	cidr => $net,
    };
    $cfg->{zones}->{local} = {
	%$common,
	ipv4 => {
	    $net => {
		1 => [
		    ['@', {
			mx => undef,
			spf1 => undef,
			dkim1 => undef,
			ptr => 1,
		    }],
		],
	    },
	},
    };
    return;
}

sub _conf {
    my($self, $cfg) = @_;
    my($other_logging) = <<'EOF';
  category cname { null; };
  category response-checks { null; };
EOF
    $other_logging = "\n"
	if ($self->do_backticks('/usr/sbin/named -v') =~ /(\d+\.\d+)/)[0] > 9.4;
    return <<"EOF" . _conf_zones($cfg);
options {
  directory "/$_ZONE_DIR";
  allow-transfer { none; };
  query-source address * port 53;
  recursion no;
  version "n/a";
};
logging {
  category lame-servers { null; };$other_logging};
zone "." in {
  type hint;
  file "$_ROOT_FILE";
};
EOF
    return;
}

sub _conf_zones {
    my($cfg) = @_;
    return join(
	'',
	map(<<"EOF",
zone "$_" in {
  type master;
  file "$_";
};
EOF
	    map("$_.in-addr.arpa", sort(keys(%{$cfg->{nets}}))),
	    sort(keys(%{$cfg->{zones}})),
	),
    );
}

sub _net {
    my($zone, $cfg, $common, $ptr_map) = @_;
    my($zone_dot) = _dot($zone = "$zone.in-addr.arpa");
    $cfg = {%$common, ref($cfg) ? %$cfg : (cidr => $cfg)};
    return (
	$zone,
	_newlines(
	    _zone_header($zone_dot, $cfg),
	    _net_ptr($zone_dot, $cfg, $ptr_map),
	),
    );
}

sub _net_ptr {
    my($zone, $cfg, $ptr_map) = @_;
    my($im) = $ptr_map->{$cfg->{cidr}};
    my($cidr_obj) = $_CIDRN->from_literal_or_die($cfg->{cidr});
    my($ptr) = $ptr_map->{$cfg->{cidr}};
    return @{
	$cidr_obj->map_host_addresses(sub {
		my($full) = @_;
		my($num) = $cidr_obj->address_to_host_num($full);
		my($yes) = $ptr->{$full}->{yes} || [];
		my($no) = $ptr->{$full}->{no} || [];
		return ()
		    unless @$yes || @$no;
		$yes = $no
		    if !@$yes && @$no == 1;
		b_die($no, ': no PTR records for ', $full)
		    if !@$yes && @$no;
		b_die($yes, ': too many PTR records for ', $full)
		    unless @$yes <= 1;
		return "$num IN PTR $yes->[0]";
	})
    };
}

sub _newlines {
    return join("\n", @_) . "\n";
}

sub _serial {
    my($self, $cfg) = @_;
    my($server) = $cfg->{servers}->[0];
    foreach my $line ($self->do_backticks([qw(dig soa), $server, '@' . $server])) {
        next
            if $line =~ /^;/;
        return $1 + 1
            if $line =~ /^\S+\s+\d+\s+IN\s+SOA\s+\S+\.\s+\S+\.\s+(\d{1,10})\s+\d/;
    }
    b_die($server, ': could not find SOA');
}

sub _write {
    my($files) = @_;
    while (my($name, $content) = each(%$files)) {
	$_F->write(
	    $name =~ m{/} ? $name : "$_ZONE_DIR/$name",
	    $content,
	);
    }
    return;
}

sub _zones {
    my($self, $cfg) = @_;
    $cfg->{serial} = _serial($self, $cfg);
    my($z) = delete($cfg->{zones});
    my($n) = delete($cfg->{nets});
    my($ptr_map) = {};
    return (
	map(
	    _zone($_, $z->{$_}, $cfg, $ptr_map),
	    sort(keys(%$z)),
	),
	map(
	    _net($_, $n->{$_}, $cfg, $ptr_map),
	    sort(keys(%$n)),
	),
    );
}

sub _zone {
    my($zone, $cfg, $common, $ptr_map) = @_;
    $cfg = {%$common, %$cfg};
    my($zone_dot) = _dot($zone);
    return (
	$zone,
	_newlines(
	    _zone_header($zone_dot, $cfg),
	    sort(
		_zone_a($zone_dot, $cfg, $ptr_map),
		_zone_cname($zone_dot, $cfg, $ptr_map),
		_zone_txt($zone_dot, $cfg, $ptr_map),
		_zone_mx($zone_dot, $cfg, $ptr_map),
		_zone_spf1($zone_dot, $cfg, $ptr_map),
		_zone_dkim1($zone_dot, $cfg, $ptr_map),
	    ),
	),
    );
}

sub _zone_a {
    my($zone, $cfg, $ptr_map) = @_;
    return _zone_ipv4_map(
	@_,
	sub {
	    my($host, $host_cfg, $ip, $cidr) = @_;
	    push(
		@{($ptr_map->{$cidr}->{$ip} ||= {})
		    ->{$host_cfg->{ptr} ? 'yes' : 'no'}
		    ||= []},
		_dot($host, $zone),
	    );
	    return join(
		' ',
		$host,
		'IN A',
		$ip,
	    ),
	},
    );
}

sub _zone_cname {
    return _zone_literal('cname', @_);
}

sub _zone_dkim1 {
    return _zone_ipv4_map(
	@_,
	sub {
	    my($host, $host_cfg, $ip) = @_;
	    return
		unless my $dkim = $host_cfg->{dkim1};
	    return join(
		' ',
		$dkim->{host},
		'IN TXT',
		'"v=DKIM1\\; k=rsa\\; p=' . $dkim->{p} . '\\;"',
	    );
	},
    );
}

sub _zone_header {
    my($zone, $cfg) = @_;
    return (
	'$TTL ' . $cfg->{ttl},
	'$ORIGIN ' . $zone,
	'@ IN SOA ' . join(
	    ' ',
	    _dot($cfg->{servers}->[0], $zone),
	    _dot($cfg->{hostmaster}, $zone),
	    '(',
	    @{$cfg}{qw(serial refresh retry expiry minimum)},
	    ')',
	),
	map('@ IN NS ' . _dot($_, $zone), @{$cfg->{servers}}),
    );
}

sub _zone_ipv4_map {
    my($zone, $cfg, $ptr_map, $op) = @_;
    my($ipv4) = $cfg->{ipv4};
    return map(
	{
	    my($cidr, $net_cfg) = ($_, $ipv4->{$_});
	    my($cidr_obj) = $_CIDRN->from_literal_or_die($cidr);
	    @{$cidr_obj->map_host_addresses(
		sub {
		    my($ip) = @_;
		    my($num) = $cidr_obj->address_to_host_num($ip);
		    return
			unless $net_cfg->{$num};
		    my($hosts) = $net_cfg->{$num};
		    $hosts = [$hosts]
			unless ref($hosts);
		    my($not_first_host) = 0;
		    return map(
			{
			    $op->(@$_, $ip, $cidr);
			}
			sort(
			    {$a->[0] cmp $b->[0]}
			    map(
				{
				    $_ = (ref($_) ? $_ : [$_]);
				    $_->[1] = {
					%$cfg,
					%{$_->[1] || {}},
				    };
				    $_->[1]->{ptr} = 1
					if $_->[0] =~ s/^\@(?=[\w\@])//;
				    $_->[0] = $zone
					if $_->[0] eq '@';
				    $_;
				}
				@$hosts,
			    ),
			),
		    );
		},
	    )};
	}
	sort(keys(%$ipv4)),
    );
}

sub _zone_literal {
    my($which, $zone, $cfg) = @_;
    my($values) = $cfg->{$which} || [];
    $values = [map([$_ => $values->{$_}], sort(keys(%$values)))]
        if ref($values) eq 'HASH';
    $which = uc($which);
    return map(
	"$_->[0] IN $which $_->[1]",
	@$values,
    );
}

sub _zone_mx {
    my($zone, $cfg) = @_;
    return _zone_ipv4_map(
	@_,
	sub {
	    my($host, $host_cfg, $ip) = @_;
	    $host_cfg->{mx} = $host
		unless exists($host_cfg->{mx});
	    return
		unless $host_cfg->{mx};
	    return map(
		{
		    my($mx_host, $mx_pref) = ref($_) ? @$_ : $_;
		    $mx_pref = $host_cfg->{mx_pref}
			unless defined($mx_pref);
		    join(
			' ',
			$host,
			'IN MX',
			$mx_pref || 10,
			$mx_host,
		    );
		}
		ref($host_cfg->{mx}) ? @{$host_cfg->{mx}} : $host_cfg->{mx},
	    ),
	},
    );
    return;
}

sub _zone_spf1 {
    my($zone, $cfg) = @_;
    return _zone_ipv4_map(
	@_,
	sub {
	    my($host, $host_cfg, $ip) = @_;
	    return
		unless my $spf1 = $host_cfg->{spf1};
	    $spf1 =~ s/\+/$cfg->{spf1}/;
	    return join(
		' ',
		$host,
		'IN TXT',
		'"v=spf1 a mx',
		$spf1,
		'-all"',
	    );
	},
    );
}

sub _zone_txt {
    return _zone_literal('txt', @_);
}

1;
