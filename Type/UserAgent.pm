# Copyright (c) 2000-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::UserAgent;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->compile([
    UNKNOWN => 0,
    MAIL => 2,
    JOB => 3,
    BROWSER_HTML3 => 4,
    BROWSER_HTML4 => 5,
    BROWSER_MSIE_5 => 6,
    BROWSER_MSIE_6 => 7,
    BROWSER_FIREFOX_1 => 8,
    BROWSER_MOZILLA_1 => 9,
    BROWSER_MSIE_7 => 10,
    BROWSER_MSIE_8 => 11,
    BROWSER_IPHONE => 12,
    BROWSER_ROBOT => 13,
]);

sub execute {
    return shift->SUPER::execute(@_, @_ == 1 ? (1) : ());
}

sub from_header {
    my($proto, $ua) = @_;
    $ua ||= '';
    if ($ua =~ /\bMSIE (\d+)/) {
	my($v) = $1;
        return $proto->BROWSER_HTML3
            if $v < 5;
	$v = 8
	    if $v > 8;
        return $proto->from_name("BROWSER_MSIE_$v");
    }
    return $proto->BROWSER_ROBOT
	if _is_robot($proto, $ua);
    return $proto->BROWSER_IPHONE
	if $ua =~ /\biPhone\b/;
    if ($ua =~ /Mozilla\/(\d+)/) {
        return $proto->BROWSER_HTML3
            if $1 < 5;
	return $proto->BROWSER_FIREFOX_1
	    if $ua =~ /Firefox\/1\./;
	return $proto->BROWSER_MOZILLA_1
	    if $ua =~ /Gecko\/(\d\d\d\d)/ && $1 <= 2006;
        return $proto->BROWSER_HTML4
    }
    return $proto->MAIL
	if $ua =~ /b-sendmail/i;
    return $proto->BROWSER_HTML3;
}

sub has_over_caching_bug {
    return shift->get_name =~ /^BROWSER_MSIE/ ? 1 : 0;
}

sub has_table_layout_bug {
    return shift->equals_by_name(qw(BROWSER_MOZILLA_1 BROWSER_FIREFOX_1));
}

sub is_browser {
    my($self, $req) = @_;
    $self = $req->get(ref($self) || $self)
	if $req;
    return $self->get_name =~ /^BROWSER/ ? 1 : 0;
}

sub is_continuous {
    return 0;
}

sub is_msie_6_or_before {
    shift->equals_by_name(qw(
        BROWSER_MSIE_5
        BROWSER_MSIE_6
    ));
}

sub is_css_compatible {
    return shift->equals_by_name(qw(
	BROWSER_FIREFOX_1
	BROWSER_HTML4
	BROWSER_IPHONE
	BROWSER_MOZILLA_1
	BROWSER_MSIE_5
	BROWSER_MSIE_6
	BROWSER_MSIE_7
	BROWSER_MSIE_8
	BROWSER_ROBOT
    ));
}

sub is_mobile_device {
    return shift->equals_by_name(qw(BROWSER_IPHONE));
}

sub _is_robot {
    my(undef, $ua) = @_;
    return $ua =~ qr{
        googlebot
        |mediapartners
        |adsbot
        |slurp
        |yahooseeker
        |msnbot
        |teoma
        |yandex
        |bingbot
        |(?:(?:ro)?bot|spider|crawler)(?:\.|/)
        |(?:/|:)(?:(?:ro)?bot|spider|crawler)
        |^davclnt$
        |docomo/
        |gt::www/
	|tlsprober
        |libwww-perl
        |lwp-(?:request|trivial)
	|libcurl
	|wget
	|htdig
        |magent
    }ix ? 1 : 0;
}

1;
