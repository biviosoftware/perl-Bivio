# Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Util::HTTPPing;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::Ext::LWPUserAgent;
use Bivio::IO::Config;
use Bivio::IO::File;
use Bivio::IO::Trace;
use HTTP::Headers ();
use HTTP::Request ();

# C<Bivio::Util::HTTPPing> pings a HTTP is running.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
Bivio::IO::Config->register(my $_CFG = {
    host_map => {},
    status_file => '/var/tmp/httpd.status',
    loadavg_file => '/proc/loadavg',
});

sub USAGE {
    # : string
    # Returns usage.
    return <<'EOF';
usage: b-http-ping [options] command [args...]
commands:
    page url ... -- request url(s)
    process_status -- check load avg
    db_status -- check for too many INSERT waiting
EOF
}

sub db_status {
    # (self) : undef
    # Checks for too many INSERT waiting.
    my($self) = @_;
    my $count = grep(/INSERT waiting/, `ps ax`);
    return $count ? "$count process(es) waiting on db insert\n" : ();
}

sub handle_config {
    # (proto, hash) : undef
    # host_map : hash_ref
    #
    # Name mapping for paged hosts.
    #
    # status_file : string [/var/tmp/httpd.status]
    #
    # Location of process_status cache.
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub page {
    # (self, array) : string_ref
    # Request I<pages> and report any problems.
    # Truncate data returned from the server at 512 bytes.
    my($self, @pages) = @_;
    $self->initialize_ui;
    my($user_agent) = Bivio::Ext::LWPUserAgent->new(1),
    my($status) = '';
    foreach my $page (@pages) {
        my($host) = $page =~ m!^\w+://([^:/]+)!;
        $host = $_CFG->{host_map}->{$host}
            if exists($_CFG->{host_map}->{$host});
        _trace('paging ', $host) if $_TRACE;
        my($reply) = $user_agent->request(HTTP::Request->new('GET', $page,
            HTTP::Headers->new(Host => $host)));
        next if $reply->is_success;
        $status .= 'PAGE: '.$page."\n".$reply->status_line."\n".
            substr($reply->as_string, 0, 512)."\n---\n";
    }
    return $status;
}

sub process_status {
    # (self) : string
    # Returns significant load average changes.
    my($new) = int(
	(split(' ', ${Bivio::IO::File->read($_CFG->{loadavg_file})}))[2]);
    my($old) = Bivio::Die->eval(sub {
        ${Bivio::IO::File->read($_CFG->{status_file}, $new)}
    }) || 0;
    my($res) = $new != $old && ($new > 3 || $old > 3) ? "Load average $new\n" : '';
    Bivio::IO::File->write($_CFG->{status_file}, $new);
    return $res;
}

1;
