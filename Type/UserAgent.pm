# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::UserAgent;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
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
    BROWSER_MSIE_8 => [11],
]);

sub execute {
    # (self, Agent.Request, boolean) : boolean
    # Adds I<put_durable> to true if not supplied.
    return shift->SUPER::execute(@_, @_ == 1 ? (1) : ());
}

sub from_header {
    # (proto, string) : self
    # Figures out the type of user agent from the I<http_user_agent> string.
    # Always returns a valid browser.
    my($proto, $ua) = @_;
    $ua ||= '';

    # Internet Explorer
    if ($ua =~ /\bMSIE (\d+)/) {
        return $proto->BROWSER_HTML3
            if $1 < 5 || $1 > 8;
        return $proto->from_name('BROWSER_MSIE_' . $1);
    }

    # Mozilla or Firefox, or other Mozilla/x compatible browsers
    if ($ua =~ /Mozilla\/(\d+)/) {
        return $proto->BROWSER_HTML3
            if $1 < 5;
        return $proto->BROWSER_FIREFOX_1
            if $ua =~ /Firefox\/1\./;
        return $proto->BROWSER_MOZILLA_1
            if $ua =~ /Gecko\/(\d\d\d\d)/ && $1 <= 2006;
        return $proto->BROWSER_HTML4;
    }

    if ($ua =~ /b-sendmail/i) {
        return $proto->MAIL;
    }
    return $proto->BROWSER_HTML3;
}

sub has_over_caching_bug {
    # (self) : boolean
    # Returns true if the browser has over caching problems (MSIE).
    my($self) = @_;
    return $self->get_name =~ /^BROWSER_MSIE/ ? 1 : 0;
}

sub has_table_layout_bug {
    # (self) : boolean
    # Returns true if the browser needs help to properly layout a table.
    my($self) = @_;
    return $self->equals_by_name(qw(BROWSER_MOZILLA_1 BROWSER_FIREFOX_1));
}

sub is_browser {
    # (self) : boolean
    # (proto, Agent.Request) : boolean
    # Returns true if I<self> or this package on I<req> is a browser.
    my($self, $req) = @_;
    $self = $req->get(ref($self) || $self) if $req;
    return $self->get_name =~ /^BROWSER/ ? 1 : 0;
}

sub is_continuous {
    # (proto) : boolean
    # Numbers are not continuous.
    return 0;
}

sub is_css_compatible {
    # (self) : boolean
    # Returns true if the browser can handle css.
    my($self) = @_;
    return $self->equals_by_name(qw(BROWSER_HTML4 BROWSER_MSIE_5
        BROWSER_MSIE_6 BROWSER_MSIE_7 BROWSER_MSIE_8 BROWSER_FIREFOX_1
        BROWSER_MOZILLA_1));
}

1;
