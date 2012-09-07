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
    BROWSER_ROBOT_OTHER => 13,
    BROWSER_ROBOT_SEARCH => 14,
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
    return $proto->BROWSER_ROBOT_SEARCH
	if _is_search($proto, $ua);
    return $proto->BROWSER_ROBOT_OTHER
	if _is_other($proto, $ua);
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
	BROWSER_ROBOT_OTHER
        BROWSER_ROBOT_SEARCH
    ));
}

sub is_mail_agent {
    return shift->self_from_req(@_)->eq_mail;
}

sub is_mobile_device {
    return shift->equals_by_name(qw(BROWSER_IPHONE));
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
