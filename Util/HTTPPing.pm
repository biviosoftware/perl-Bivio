# Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Util::HTTPPing;
use strict;
$Bivio::Util::HTTPPing::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::HTTPPing::VERSION;

=head1 NAME

Bivio::Util::HTTPPing - pings HTTP server is up

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Util::HTTPPing;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Util::HTTPPing::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Util::HTTPPing> pings a HTTP is running.

=cut

=head1 CONSTANTS

=cut

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns usage.

=cut

sub USAGE {
    return <<'EOF';
usage: b-http-ping [options] command [args...]
commands:
    page url ... -- request url(s)
    process_status -- check load avg
    db_status -- check for too many INSERT waiting
EOF
}

#=IMPORTS
use Bivio::Ext::LWPUserAgent;
use Bivio::IO::Config;
use Bivio::IO::File;
use Bivio::IO::Trace;
use HTTP::Headers ();
use HTTP::Request ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
Bivio::IO::Config->register(my $_CFG = {
    host_map => {},
    status_file => '/var/tmp/httpd.status',
    loadavg_file => '/proc/loadavg',
});

=head1 METHODS

=cut

=for html <a name="db_status"></a>

=head2 db_status()

Checks for too many INSERT waiting.

=cut

sub db_status {
    my($self) = @_;
    my $count = grep(/INSERT waiting/, `ps ax`);
    return $count ? "$count process(es) waiting on db insert\n" : ();
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item host_map : hash_ref

Name mapping for paged hosts.

=item status_file : string [/var/tmp/httpd.status]

Location of process_status cache.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

=for html <a name="page"></a>

=head2 page(array pages) : string_ref

Request I<pages> and report any problems.
Truncate data returned from the server at 512 bytes.

=cut

sub page {
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

=for html <a name="process_status"></a>

=head2 process_status() : string

Returns significant load average changes.

=cut

sub process_status {
    my($new) = int(
	(split(' ', ${Bivio::IO::File->read($_CFG->{loadavg_file})}))[2]);
    my($old) = Bivio::Die->eval(sub {
        ${Bivio::IO::File->read($_CFG->{status_file}, $new)}
    }) || 0;
    my($res) = $new != $old && ($new > 3 || $old > 3) ? "Load average $new\n" : '';
    Bivio::IO::File->write($_CFG->{status_file}, $new);
    return $res;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
