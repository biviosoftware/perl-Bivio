#!perl -w
# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
#
use strict;
use Bivio::Test;
use Bivio::TypeError;
use Bivio::Type::UserAgent;

Bivio::Test->unit([
    'Bivio::Type::UserAgent' => [
        from_header => [
            ['Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050511 Firefox/1.0.4']
                => [Bivio::Type::UserAgent->BROWSER_FIREFOX_1],
            ['Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)']
                => [Bivio::Type::UserAgent->BROWSER_MSIE_6],
            ['Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050511']
                => [Bivio::Type::UserAgent->BROWSER_MOZILLA_1],
            ['Mozilla/4.0 (compatible; MSIE 5.0; Windows 98)']
                => [Bivio::Type::UserAgent->BROWSER_MSIE_5],
            ['Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; en) Opera 8.01']
                => [Bivio::Type::UserAgent->BROWSER_MSIE_6],
            ['Mozilla/4.0 (compatible; MSIE 6.0; AOL 6.0; Windows 98)']
                => [Bivio::Type::UserAgent->BROWSER_MSIE_6],
            ['b-sendmail-http'] => [Bivio::Type::UserAgent->MAIL],
            ['libwww-perl/5.65'] => [Bivio::Type::UserAgent->BROWSER_HTML3],
            ['msnbot/1.0 (+http://search.msn.com/msnbot.htm)']
                => [Bivio::Type::UserAgent->BROWSER_HTML3],
            ['Googlebot/2.1 (+http://www.google.com/bot.html)']
                => [Bivio::Type::UserAgent->BROWSER_HTML3],
            ['Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en) AppleWebKit/312.1 (KHTML, like Gecko) Safari/312']
                => [Bivio::Type::UserAgent->BROWSER_HTML4],
            ['Mozilla/3.01 [fr]C-SYMPA  (Win95; I)']
                => [Bivio::Type::UserAgent->BROWSER_HTML3],
            ['Mozilla/4.0 (compatible; MSIE 4.01; AOL 5.0; Mac_PPC)']
                => [Bivio::Type::UserAgent->BROWSER_HTML3],
            [''] => [Bivio::Type::UserAgent->BROWSER_HTML3],
            [undef] => [Bivio::Type::UserAgent->BROWSER_HTML3],
            ['Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0; .NET CLR 2.0.50215; SL Commerce Client v1.0; Tablet PC 2.0; Media Center PC 3.1; Media Center PC $(runtime.Emerald_version))'] => [Bivio::Type::UserAgent->BROWSER_MSIE_7],
            ['Mozilla/4.0 (compatible; MSIE 25.0; Windows 2098)']
                => [Bivio::Type::UserAgent->BROWSER_HTML3],
        ],
    ],
    Bivio::Type::UserAgent->MAIL => [
        has_over_caching_bug => 0,
        has_table_layout_bug => 0,
        is_browser => 0,
        is_css_compatible => 0,
    ],
    Bivio::Type::UserAgent->BROWSER_HTML3 => [
        has_over_caching_bug => 0,
        has_table_layout_bug => 0,
        is_browser => 1,
        is_css_compatible => 0,
    ],
    Bivio::Type::UserAgent->BROWSER_HTML4 => [
        has_over_caching_bug => 0,
        has_table_layout_bug => 0,
        is_browser => 1,
        is_css_compatible => 1,
    ],
    Bivio::Type::UserAgent->BROWSER_MSIE_5 => [
        has_over_caching_bug => 1,
        has_table_layout_bug => 0,
        is_browser => 1,
        is_css_compatible => 1,
    ],
    Bivio::Type::UserAgent->BROWSER_MSIE_6 => [
        has_over_caching_bug => 1,
        has_table_layout_bug => 0,
        is_browser => 1,
        is_css_compatible => 1,
    ],
    Bivio::Type::UserAgent->BROWSER_MSIE_7 => [
        has_over_caching_bug => 1,
        has_table_layout_bug => 0,
        is_browser => 1,
        is_css_compatible => 1,
    ],
    Bivio::Type::UserAgent->BROWSER_FIREFOX_1 => [
        has_over_caching_bug => 0,
        has_table_layout_bug => 1,
        is_browser => 1,
        is_css_compatible => 1,
    ],
    Bivio::Type::UserAgent->BROWSER_MOZILLA_1 => [
        has_over_caching_bug => 0,
        has_table_layout_bug => 1,
        is_browser => 1,
        is_css_compatible => 1,
    ],
]);
