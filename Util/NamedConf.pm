# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::NamedConf;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
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
# use named-checkzone and named-checkconf on all files
    my($cfg) = $_D->eval_or_die(${$self->read_input});
    _local_cfg($cfg);
    $_F->mkdir_p('etc');
    $_F->mkdir_p($_ZONE_DIR);
    _write({
	'etc/named.conf' => _conf($cfg),
	$_ROOT_FILE => $self->root_file,
	_zones($cfg),
    });
    return;
}

sub root_file {
    my($self) = @_;
    my($response) = b_use('Ext.LWPUserAgent')
	->new(1)
	->request(
	    HTTP::Request->new(
		'GET',
		'http://www.internic.net/zones/named.root',
	    ),
	);
    b_die($response)
	unless $response->is_success;
    return $response->content;
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
		    }],
		],
	    },
	},
    };
    return;
}

sub _conf {
    my($cfg) = @_;
    return <<"EOF" . _conf_zones($cfg);
options {
  directory "/$_ZONE_DIR";
  allow-transfer { none; };
  query-source address * port 53;
  recursion no;
  version "n/a";
};
logging {
  category cname { null; };
  category lame-servers { null; };
  category response-checks { null; };
};
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
    my($zone, $cfg, $common, $ip_map) = @_;
    my($zone_dot) = _dot($zone = "$zone.in-addr.arpa");
    $cfg = {%$common, ref($cfg) ? %$cfg : (cidr => $cfg)};
    return (
	$zone,
	_newlines(
	    _zone_header($zone_dot, $cfg),
	    _net_ips($zone_dot, $cfg, $ip_map),
	),
    );
}

sub _net_ips {
    my($zone, $cfg, $ip_map) = @_;
    my($im) = $ip_map->{$cfg->{cidr}};
    my($cidr) = $cfg->{cidr};
    my($ips) = $ip_map->{$cidr};
    return @{
	$_CIDRN
	    ->from_literal_or_die($cidr)
	    ->map_host_addresses(sub {
		my($full) = @_;
#TODO: Should we make this work with other than Class C CIDRs?
		my($num) = $full =~ /(\d+)$/;
		map(
		    "$num IN PTR $_",
		    @{$ips->{$full} || []},
		);
	    })
    };
}

sub _newlines {
    return join("\n", @_) . "\n";
}

sub _serial {
    # Serial numbers must increase for every generation.  Instead of using the
    # manual process yyyymmdd<seq>, we use yyyy<year-seconds>.  However,
    # <year-seconds> could be 31622400, which is too large, so we divide by 33.
    # This means you can only do an update every 33 seconds to be sure the
    # number increases.  The number is truncated (not %d, which rounds)
    # so it doesn't "jump to the future".
    my($now) = $_DT->now;
    my($y) = $_DT->get_parts($now, 'year');
    return sprintf(
	'%04d%06d',
	$y,
	int(
	    $_DT->diff_seconds(
		$now,
		$_DT->from_parts(0, 0, 0, 1, 1, $y),
	    ) / 33,
	),
    );
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
    my($cfg) = @_;
    $cfg->{serial} = _serial();
    my($z) = delete($cfg->{zones});
    my($n) = delete($cfg->{nets});
    my($ip_map) = {};
    return (
	map(
	    _zone($_, $z->{$_}, $cfg, $ip_map),
	    sort(keys(%$z)),
	),
	map(
	    _net($_, $n->{$_}, $cfg, $ip_map),
	    sort(keys(%$n)),
	),
    );
}

sub _zone {
    my($zone, $cfg, $common, $ip_map) = @_;
    $cfg = {%$common, %$cfg};
    my($zone_dot) = _dot($zone);
    return (
	$zone,
	_newlines(
	    _zone_header($zone_dot, $cfg),
	    sort(
		_zone_a($zone_dot, $cfg, $ip_map),
		_zone_cname($zone_dot, $cfg, $ip_map),
		_zone_mx($zone_dot, $cfg, $ip_map),
		_zone_spf1($zone_dot, $cfg, $ip_map),
	    ),
	),
    );
}

sub _zone_a {
    my($zone, $cfg, $ip_map) = @_;
    return _zone_ipv4_map(
	@_,
	sub {
	    my($host, $host_cfg, $ip, $cidr) = @_;
	    push(
		@{$ip_map->{$cidr}->{$ip} ||= []},
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
    my($zone, $cfg) = @_;
    my($cname) = $cfg->{cname} || {};
    return map(
	"$_ IN CNAME $cname->{$_}",
	keys(%$cname),
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
    my($zone, $cfg, $ip_map, $op) = @_;
    my($ipv4) = $cfg->{ipv4};
    return map(
	{
	    my($cidr, $net_cfg) = ($_, $ipv4->{$_});
	    @{$_CIDRN->from_literal_or_die($_)
		->map_host_addresses(
		    sub {
			my($ip) = @_;
			my($num) = $ip =~ /\.(\d+)$/;
			return
			    unless $net_cfg->{$num};
			my($hosts) = $net_cfg->{$num};
			$hosts = [$hosts]
			    unless ref($hosts);
			return map(
			    {
				$op->(@$_, $ip, $cidr);
			    }
			    sort(
				{$a->[0] cmp $b->[0]}
				map(
				    {
					$_ = (ref($_) ? $_ : [$_]);
					$_->[0] = $zone
					    if $_->[0] eq '@';
					$_->[1] = {
					    %$cfg,
					    %{$_->[1] || {}},
					};
					$_;
				    }
				    @$hosts,
				),
			    ),
			);
		    },
		)
	    };
	}
	sort(keys(%$ipv4)),
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

1;
