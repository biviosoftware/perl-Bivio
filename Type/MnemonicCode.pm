# Copyright (c) 2025 bivio, Inc.  All rights reserved.
package Bivio::Type::MnemonicCode;
use strict;
use Bivio::Base 'Type.SecretLine';

my($_F) = b_use('IO.File');
my($_MCA) = b_use('Type.MnemonicCodeArray');
my($_TE) = b_use('Bivio.TypeError');

my($_WORDS);
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    word_list => [qw(foo bar baz qux)],
    word_sample_size => 3,
    word_separator => '-',
});

sub from_literal {
    my(undef, $value) = @_;
    return _canonicalize($value);
}

sub generate_code {
    my($proto) = @_;
    my($w) = {};
    for (1..$_CFG->{word_sample_size}) {
        my($i) = int(rand(int(@$_WORDS)));
        redo
            if defined($w->{$i});
        $w->{$i} = int(keys(%$w));
    }
    return join(
        $_CFG->{word_separator},
        map($_WORDS->[$_], sort({$w->{$a} <=> $w->{$b}} keys(%$w))),
    );
}

sub generate_new_codes {
    my($proto, $count) = @_;
    b_die('new code count required')
        unless $count;
    my($codes) = [];
    for (1..$count) {
        push(@$codes, $proto->generate_code);
    }
    $codes = [sort(@$codes)],
    return $_MCA->new($codes);
}

sub get_word_separator {
    return $_CFG->{word_separator};
}

sub handle_config {
    my($proto, $cfg) = @_;
    $_CFG = $cfg;
    if ($_CFG->{word_list} && -f $_CFG->{word_list}) {
        _init_word_list($proto, $_CFG->{word_list});
    }
    elsif ($_C->is_test && ref($_CFG->{word_list}) eq 'ARRAY') {
        @$_WORDS = @{$_CFG->{word_list}};
    }
    else {
        b_die('word_list required');
        # DOES NOT RETURN
    }
    b_die('invalid word_list')
        unless int(@$_WORDS) >= ($_C->is_test ? 3 : 1000);
    b_die('invalid word_sample_size')
        unless $_CFG->{word_sample_size} >= ($_C->is_test ? 2 : 5)
        && int(@$_WORDS) > $_CFG->{word_sample_size};
    return;
}

sub is_secure_data {
    return 1;
}

sub _canonicalize {
    my($value) = @_;
    $value = lc($value);
    $value =~ s/^\s+|\s+$//g;
    return (undef, $_TE->SYNTAX_ERROR)
        unless $value =~ qr{^[a-z\s.,_/\\|-]+$};
    my(@words) = split(/[^a-z]+/, $value);
    return (undef, $_TE->TOO_FEW)
        unless int(@words) >= 2;
    $value = join($_CFG->{word_separator}, @words);
    return $value;
}

sub _init_word_list {
    my($proto, $path) = @_;
    @$_WORDS = ();
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
