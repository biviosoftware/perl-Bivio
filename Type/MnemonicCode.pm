# Copyright (c) 2025 bivio, Inc.  All rights reserved.
package Bivio::Type::MnemonicCode;
use strict;
use Bivio::Base 'Type.SecretLine';

my($_F) = b_use('IO.File');
my($_MCA) = b_use('Type.MnemonicCodeArray');

my($_WORDS);
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    # TODO: probably don't want this long-term
    is_enabled => 0,
    word_list => undef,
    word_sample_size => 6,
    word_separator => '-',
});

sub from_literal {
    my($proto, $value) = @_;
    return _canonicalize($value);
}

sub generate_code {
    my($proto) = @_;
    b_die('recovery codes not enabled')
        unless $_CFG->{is_enabled};
    my($w) = {};
    for (1..$_CFG->{word_sample_size}) {
        my($i) = int(rand(int(@$_WORDS)));
        redo
            if defined($w->{$i});
        $w->{$i} = int(keys(%$w));
    }
    # TODO: Should this be a StringArray?
    return join(
        $_CFG->{word_separator},
        map($_WORDS->[$_], sort({$w->{$a} <=> $w->{$b}} keys(%$w))),
    );
}

sub generate_new_codes {
    my($proto, $count) = @_;
    b_die('new code count required')
        unless $count;
    my($res) = $_MCA->new;
    $res = $res->append($proto->generate_code)
        for 1..$count;
    return $res;
}

sub get_word_separator {
    return $_CFG->{word_separator};
}

sub handle_config {
    my($proto, $cfg) = @_;
    $_CFG = $cfg;
    return
        unless $_CFG->{is_enabled};
    if ($_CFG->{word_list} && -f $_CFG->{word_list}) {
        _init_word_list($proto, $_CFG->{word_list});
    }
    b_die('invalid word_list')
        unless int(@$_WORDS) >= ($_C->is_test ? 3 : 1000);
    b_die('invalid word_sample_size')
        unless $_CFG->{word_sample_size} >= ($_C->is_test ? 2 : 5);
    b_die('sanity error')
        unless int(@$_WORDS) > $_CFG->{word_sample_size};
    return;
}

# Not sure if should use
sub is_otp {
    return 1;
}

sub is_password {
    # return 0;
    return 1;
}

sub is_secure_data {
    # return 0;
    return 1;
}

sub _canonicalize {
    my($value) = @_;
    $value = lc($value);
    $value = join($_CFG->{word_separator}, split(/[^a-z]+/, $value));
    return $value;
}

sub _init_word_list {
    my($proto, $path) = @_;
    my($max_length) = 0;
    $_F->do_lines($path, sub {
        my($line) = @_;
        $max_length = length($line)
            unless $max_length >= length($line);
        push(@$_WORDS, lc($line));
        return 1;
    });
    b_die('longest code exceeds type width')
        if (($max_length + length($_CFG->{word_separator})) * $_CFG->{word_sample_size}) - 1 > $proto->get_width;
    return;
}

1;
