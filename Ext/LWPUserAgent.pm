# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Ext::LWPUserAgent;
use strict;
$Bivio::Ext::LWPUserAgent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Ext::LWPUserAgent::VERSION;

=head1 NAME

Bivio::Ext::LWPUserAgent - extends LWP::UserAgent with bivio config

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Ext::LWPUserAgent;

=cut

=head1 EXTENDS

L<LWP::UserAgent>

=cut

use LWP::UserAgent ();
@Bivio::Ext::LWPUserAgent::ISA = ('LWP::UserAgent');

=head1 DESCRIPTION

C<Bivio::Ext::LWPUserAgent> adds timeouts and proxy handling to LWP::UserAgent.

If you trace this module, also turns on tracing in LWP::Debug.  See
L<new|"new">.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::IO::Config;
use LWP::Debug ();

#=VARIABLES
use vars ('$_TRACE');
my($_PKG) = __PACKAGE__;
Bivio::IO::Trace->register;
my($_HTTP_PROXY);
Bivio::IO::Config->register({
    http_proxy => undef,
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(boolean want_redirects) : Bivio::Ext::LWPUserAgent

Calls SUPER::new and sets timeout and proxy.

If I<want_redirects> is true, L<redirect_ok|"redirect_ok"> will return true.

Turns on LWP::Debug if $_TRACE is true for this class.

=cut

sub new {
    my($proto, $want_redirects) = @_;
    my($self) = $proto->SUPER::new;
    my($fields) = $self->{$_PKG} = {
	want_redirects => $want_redirects ? 1 : 0,
    };
    # Relatively short timeout, so we don't get stuck in remote services.
    $self->timeout(60);
    # Use a proxy if configured
    if (defined($_HTTP_PROXY)) {
        $self->proxy(['http', 'https'], $_HTTP_PROXY);
    }
    elsif ($ENV{http_proxy}) {
        $self->proxy(['http', 'https'], $ENV{http_proxy});
    }
    LWP::Debug::level("+debug") if $_TRACE;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item http_proxy : string [undef]

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_HTTP_PROXY = $cfg->{http_proxy};
    return;
}

=for html <a name="redirect_ok"></a>

=head2 redirect_ok() : boolean

Always returns false.  Redirects need to be handled at higher level for cookies
and logging.

=cut

sub redirect_ok {
    return shift->{$_PKG}->{want_redirects};
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
