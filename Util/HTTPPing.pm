# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Util::HTTPPing;
use strict;
$Bivio::Util::HTTPPing::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Util::HTTPPing::VERSION;

=head1 NAME

Bivio::Util::HTTPPing - pings HTTP server is up

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

Returns:

    usage: b-http-ping [options] command [args...]
    commands:
	page url ... -- request url(s) and email problems

=cut

sub USAGE {
    return <<'EOF';
usage: b-http-ping [options] command [args...]
commands:
	page url ... -- request url(s) and email problems
EOF
}

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::Config;
use Bivio::Ext::LWPUserAgent;
use HTTP::Request ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_CFG) = {
    page => ['http://127.0.0.1/'],
    email => 'lichtin@mail.bivio.com',
};
Bivio::IO::Config->register($_CFG);

=head1 METHODS

=cut

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item email : string [root]

Where to send mail to.  ShellUtil -email flag overrides this value
if it is defined.

=item page: array []

Pages to be pinged.

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
    my($user_agent) = Bivio::Ext::LWPUserAgent->new;
    my($status) = '';
    foreach my $page (@pages) {
        my($reply) = $user_agent->request(HTTP::Request->new('GET', $page));
        next if $reply->is_success;
        $status .= 'PAGE: '.$page."\n".$reply->status_line."\n".
                substr($reply->as_string, 0, 512)."\n---\n";
    }
    return unless length($status);
    return \$status unless $_CFG->{email};
    $self->email_message($_CFG->{email}, 'http ping errors', $status);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
