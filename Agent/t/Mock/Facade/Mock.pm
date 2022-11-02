# Copyright (c) 2000-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::t::Mock::Facade::Mock;
use strict;
use Bivio::Base 'UI.Facade';

my($_SELF) = __PACKAGE__->new({
    clone => undef,
    is_production => 1,
    uri => 'task',
    # So local files are found
    local_file_prefix => 'petshop',
    Color => [],
    Constant => [
        [site_realm_id => 1],
        [require_secure => 0],
    ],
    Font => {
        initialize => sub {
            my($fc) = @_;
            $fc->group(default => [
                'family=verdana,arial,helvetica,sans-serif',
                'size=small',
            ]);
            return;
        }
    },
    Text => {
        initialize => sub {
            my($t) = @_;
            return;
        },
    },
    Task => {
        initialize => sub {
            my($t) = @_;
            $t->group(SITE_ROOT => ['/*']);
            foreach my $n (qw(
                CLUB_HOME
                MY_CLUB_SITE
                MY_SITE
                REDIRECT_TEST_1
                REDIRECT_TEST_2
                REDIRECT_TEST_3
                REDIRECT_TEST_4
                REDIRECT_TEST_5
                REDIRECT_TEST_6
                USER_HOME
                LOGIN
            )) {
                $t->group($n => undef);
            }
            return;
        },
    },
    HTML => {
        initialize => sub {
            return;
        },
    },
});

1;
