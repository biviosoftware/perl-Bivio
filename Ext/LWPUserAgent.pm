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

=head2 static new() : Bivio::Ext::LWPUserAgent

Calls SUPER::new and sets timeout and proxy.

=cut

sub new {
    my($self) = LWP::UserAgent::new(@_);
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

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
