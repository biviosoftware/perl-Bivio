# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Ext::LWPUserAgent;
use strict;
$Bivio::Ext::LWPUserAgent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Ext::LWPUserAgent::VERSION;

=head1 NAME

Bivio::Ext::LWPUserAgent - extends LWP::UserAgent with bivio config

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

=cut

#=IMPORTS
use Bivio::IO::Config;

#=VARIABLES
my($_HTTP_PROXY);
Bivio::IO::Config->register({
    http_proxy => undef,
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(boolean always_redirect) : Bivio::Ext::LWPUserAgent

=head2 static new() : Bivio::Ext::LWPUserAgent

Calls SUPER::new and sets timeout and proxy. Optionally follow all
redirects. Normally only GETs are redirected.

=cut

sub new {
    my($self, $always_redirect) = LWP::UserAgent::new(@_);
    $self->{__PACKAGE__} = {
	always_redirect => $always_redirect ? 1 : 0,
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

=head2 redirect_ok(HTTP::Request request) : boolean

Always returns true. Overrides LWP::UserAgent redirect_ok() which
does not redirect POSTs.

=cut

sub redirect_ok {
    my($self, $request) = @_;
    my($fields) = $self->{__PACKAGE__};
    return $fields->{always_redirect}
	? 1
	: $self->SUPER::redirect_ok($request);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
