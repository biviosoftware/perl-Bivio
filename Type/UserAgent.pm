# Copyright (c) 2000-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::UserAgent;
use strict;
use Bivio::Base 'Bivio::Type::Enum';

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
    BROWSER_ROBOT_OTHER => 13,
    BROWSER_ROBOT_SEARCH => 14,
    BROWSER_ANDROID_STOCK => 15,
    BROWSER_CHROME_PHONE => 16,
    BROWSER_CHROME_TABLET => 17,
    BROWSER_OPERA_MOBILE => 18,
    BROWSER_UC_BROWSER => 19,
    BROWSER_NOKIA => 20,
    BROWSER_BLACKBERRY_6_7 => 21,
    BROWSER_BB10 => 22,
    BROWSER_NETFRONT => 23,
    BROWSER_IPOD => 24,
    BROWSER_IEMOBILE => 25,
    BROWSER_MSIE_9 => 26,
    BROWSER_MSIE_10 => 27,
]);

sub execute {
    return shift->SUPER::execute(@_, @_ == 1 ? (1) : ());
}

sub from_header {
    my($proto, $ua) = @_;
    $ua ||= '';
    foreach my $t (
	['BROWSER_ROBOT_SEARCH', _is_search($proto, $ua)],
	['BROWSER_ROBOT_OTHER', _is_other($proto, $ua)],
	['BROWSER_IPHONE', $ua =~ /\biPhone\b/],
	['BROWSER_IPOD', $ua =~ /\biPod\b/],
	['BROWSER_CHROME_PHONE', $ua =~  /Android.*Chrome\/[.0-9]* Mobile/],
	['BROWSER_CHROME_TABLET', $ua =~  /Android.*Chrome\/[.0-9]* (?!Mobile)/],
	['BROWSER_OPERA_MOBILE', $ua =~ /\bOpera Mobi\b/],
	['BROWSER_UC_BROWSER', $ua =~ /\bUCBrowser\b/],
	['BROWSER_NOKIA', $ua =~ /\bNokia/],
	['BROWSER_BLACKBERRY_6_7', $ua =~ /\bBlackBerry\b/],
	['BROWSER_BB10', $ua =~ /\bBB10\b.*\bMobile\b/],
	['BROWSER_NETFRONT', $ua =~ /\bNetFront\b/],
	['BROWSER_IEMOBILE', $ua =~ /\bIEMobile\b/],
	['BROWSER_ANDROID_STOCK', $ua =~ /\bAndroid\b/],
    ) {
	return $proto->from_name($t->[0])
	    if $t->[1];
    }
    if ($ua =~ /\bMSIE (\d+)/) {
	my($v) = $1;
        return $proto->BROWSER_HTML3
            if $v < 5;
	$v = 10
	    if $v > 10;
        return $proto->from_name("BROWSER_MSIE_$v");
    }
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

sub is_actual_browser {
    my($self) = shift->self_from_req(@_);
    return $self->is_browser && !$self->is_robot ? 1 : 0;
}

sub is_browser {
    return shift->self_from_req(@_)->get_name =~ /^BROWSER/ ? 1 : 0;
}

sub is_continuous {
    return 0;
}

sub is_msie_6_or_before {
    return shift->equals_by_name(qw(
        BROWSER_MSIE_5
        BROWSER_MSIE_6
    ));
}

sub is_msie_8_or_before {
    return shift->equals_by_name(qw(
        BROWSER_MSIE_5
        BROWSER_MSIE_6
        BROWSER_MSIE_7
        BROWSER_MSIE_8
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
	BROWSER_MSIE_9
	BROWSER_MSIE_10
	BROWSER_ROBOT_OTHER
        BROWSER_ROBOT_SEARCH
    ));
}

sub is_mail_agent {
    return shift->self_from_req(@_)->eq_mail;
}

sub is_mobile_device {
    return shift->equals_by_name(qw(
	BROWSER_IPHONE
	BROWSER_ANDROID_STOCK
	BROWSER_CHROME_PHONE
	BROWSER_OPERA_MOBILE
	BROWSER_UC_BROWSER
	BROWSER_NOKIA
	BROWSER_BLACKBERRY_6_7
	BROWSER_BB10
	BROWSER_NETFRONT
	BROWSER_IPOD
	BROWSER_IEMOBILE
    ));
}

sub is_robot {
    return shift->self_from_req(@_)->get_name =~ /^BROWSER_ROBOT/ ? 1 : 0;
}

sub is_robot_search {
    return shift->self_from_req(@_)->eq_browser_robot_search;
}

sub is_robot_search_verified {
    # Very narrow set of search robots are approved here.  Clients can use
    # this for returning content they don't want out in the wild
    my(undef, $req) = @_;
    return 0
	unless shift->is_robot_search(@_);
    return 1
	if $req->is_test;
    return (
	b_use('Type.IPAddress')->unsafe_to_domain(
	    $req->ureq('client_addr') || return 0,
        ) || return 0,
    ) =~ m{
	\.(?:
        (?:gigablast|microsoft|googlebot|yahoo)\.com
	|msn\.net
	|baidu\.(?:com|jp)
        |yandex\.ru)
    $}ix ? 1 : 0;
}

sub _is_search {
    my(undef, $ua) = @_;
    return $ua =~ qr{
        adsbot-google
	|baidu.*spider
	|bingbot
	|ezooms.bot
	|gigabot
	|googlebot
	|msnbot
	|yahoo.*slurp
	|yahooseeker
	|yandex
        |mediapartners
        |teoma
    }ix ? 1 : 0;
}

sub _is_other {
    my(undef, $ua) = @_;
    return $ua =~ qr{
        (?:(?:ro)?bot|spider|crawler)(?:\.|/)
        |(?:/|:)(?:(?:ro)?bot|spider|crawler)
        |^davclnt$
	|http://
	|\w+\@\w+.com
        |^-$
        |docomo/
        |facebookexternalhit
        |gt::www/
        |htdig
        |ia_archiver
        |libcurl
        |libwww-perl
        |lwp-(?:request|trivial)
        |magent
        |slurp
        |tlsprober
        |wget
	|ultraseek
    }ix ? 1 : 0;
}

1;
