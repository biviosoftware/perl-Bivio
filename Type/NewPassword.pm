# Copyright (c) 2023 bivio Software, Inc.  All rights reserved.
package Bivio::Type::NewPassword;
use strict;
use Bivio::Base 'Type.ConfirmPassword';

my($_F) = b_use('IO.File');
my($_TE) = b_use('Bivio.TypeError');

my($_WEAK_PASSWORDS) = {};
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    weak_regex => undef,
    weak_corpus_path => undef,
    in_weak_corpus => sub {
        # This implementation should only be used for a corpus of limited size. Larger corpuses
        # should be stored in an external database, with a new implementation that uses said
        # database.
        return $_WEAK_PASSWORDS->{shift(@_)} ? 1 : 0;
    },
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
    if ($_CFG->{weak_corpus_path} && -f $_CFG->{weak_corpus_path}) {
        $_F->do_lines($_CFG->{weak_corpus_path}, sub {
            $_WEAK_PASSWORDS->{shift(@_)} = 1;
            return 1;
        });
    }
    return;
}

sub _is_weak {
    my($clear_text) = @_;
    return 1
        if $_CFG->{weak_regex} && $clear_text =~ $_CFG->{weak_regex};
    return 1
        if $_CFG->{in_weak_corpus}($clear_text);
    return 0;
}

1;
