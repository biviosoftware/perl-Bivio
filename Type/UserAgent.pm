# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::UserAgent;
use strict;
$Bivio::Type::UserAgent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::UserAgent::VERSION;

=head1 NAME

Bivio::Type::UserAgent - defines type of the user agent for a request

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::UserAgent;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::UserAgent::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::UserAgent> defines the type of user agent requesting
information.

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [0],
    # Mail transfer agent
    MAIL => [2],
    # Background job
    JOB => [3],
    BROWSER_HTML3 => [4],
    BROWSER_HTML4 => [5],
    BROWSER_MSIE_5 => [6],
    BROWSER_MSIE_6 => [7],
    BROWSER_FIREFOX_1 => [8],
    BROWSER_MOZILLA_1 => [9],
    BROWSER_MSIE_7 => [10],
]);

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req, boolean put_durable) : boolean

Adds I<put_durable> to true if not supplied.

=cut

sub execute {
    return shift->SUPER::execute(@_, @_ == 1 ? (1) : ());
}

=for html <a name="from_header"></a>

=head2 static from_header(string http_user_agent) : self

Figures out the type of user agent from the I<http_user_agent> string.
Always returns a valid browser.

=cut

sub from_header {
    my($proto, $ua) = @_;
    $ua ||= '';

    # Internet Explorer
    if ($ua =~ /\bMSIE (\d+)/) {
        return $proto->BROWSER_HTML3
            if $1 < 5 || $1 > 7;
        return $proto->from_name('BROWSER_MSIE_' . $1);
    }

    # Mozilla or Firefox, or other Mozilla/x compatible browsers
    if ($ua =~ /Mozilla\/(\d+)/) {
        return $proto->BROWSER_HTML3
            if $1 < 5;
        return $proto->BROWSER_FIREFOX_1
            if $ua =~ /Firefox\/1\./;
        return $proto->BROWSER_MOZILLA_1
            if $ua =~ /\brv:1\./;
        return $proto->BROWSER_HTML4;
    }

    if ($ua =~ /b-sendmail/i) {
        return $proto->MAIL;
    }
    return $proto->BROWSER_HTML3;
}

=for html <a name="has_over_caching_bug"></a>

=head2 has_over_caching_bug() : boolean

Returns true if the browser has over caching problems (MSIE).

=cut

sub has_over_caching_bug {
    my($self) = @_;
    return $self->get_name =~ /^BROWSER_MSIE/ ? 1 : 0;
}

=for html <a name="has_table_layout_bug"></a>

=head2 has_table_layout_bug() : boolean

Returns true if the browser needs help to properly layout a table.

=cut

sub has_table_layout_bug {
    my($self) = @_;
    return $self->equals_by_name(qw(BROWSER_MOZILLA_1 BROWSER_FIREFOX_1));
}

=for html <a name="is_browser"></a>

=head2 is_browser() : boolean

=head2 static is_browser(Bivio::Agent::Request req) : boolean

Returns true if I<self> or this package on I<req> is a browser.

=cut

sub is_browser {
    my($self, $req) = @_;
    $self = $req->get(ref($self) || $self) if $req;
    return $self->get_name =~ /^BROWSER/ ? 1 : 0;
}

=for html <a name="is_continuous"></a>

=head2 static is_continuous() : boolean

Numbers are not continuous.

=cut

sub is_continuous {
    return 0;
}

=for html <a name="is_css_compatible"></a>

=head2 is_css_compatible() : boolean

Returns true if the browser can handle css.

=cut

sub is_css_compatible {
    my($self) = @_;
    return $self->equals_by_name(qw(BROWSER_HTML4 BROWSER_MSIE_5
        BROWSER_MSIE_6 BROWSER_MSIE_7 BROWSER_FIREFOX_1 BROWSER_MOZILLA_1));
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
