# Copyright (c) 2023 bivio Software, Inc.  All rights reserved.
package Bivio::Type::NewPassword;
use strict;
use Bivio::Base 'Type.ConfirmPassword';

my($_F) = b_use('IO.File');
my($_TE) = b_use('Bivio.TypeError');

my($_WEAK_PASSWORDS);
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    weak_regex => undef,
    weak_corpus => undef,
});

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
        if !defined($v) || $e;
    return (undef, $_TE->WEAK_PASSWORD)
        if _is_weak($value);
    return $v;
}

sub get_min_width {
    return 8;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    unless ($_CFG->{weak_corpus}) {
        $_WEAK_PASSWORDS = {};
        return;
    }
    if (-f $_CFG->{weak_corpus}) {
        # TODO: Support bdb files; desirable for large corpuses.
        _parse_simple_weak_corpus($_CFG->{weak_corpus});
        return;
    }
    b_die('invalid weak_corpus=', $_CFG->{weak_corpus});
    # DOES NOT RETURN
}

sub _is_weak {
    my($clear_text) = @_;
    return 1
        if $_CFG->{weak_regex} && $clear_text =~ qr/$_CFG->{weak_regex}/i;
    return 1
        if $_WEAK_PASSWORDS->{lc(shift)};
    return 0;
}

sub _parse_simple_weak_corpus {
    my($path) = @_;
    $_WEAK_PASSWORDS = {};
    $_F->do_lines($path, sub {
        $_WEAK_PASSWORDS->{lc(shift)} = 1;
        return 1;
    });
    return;
}

1;
