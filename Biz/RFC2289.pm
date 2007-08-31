# Copyright (c) 2007 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::OTP::RFC2289;
use strict;
our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
use base 'Bivio::Collection::Attributes';

# C<Bivio::OTP::RFC2289>
# Implements RFC2289.  See http://faqs.org/rfcs/rfc2289.html

#=IMPORTS
use Digest::MD5;

#=VARIABLES
my($_DICTIONARY) = do 'Bivio/OTP/rfc2289-dictionary.PL';
my($_REVERSE) = _build_reverse(do 'Bivio/OTP/rfc2289-dictionary.PL');

=head1 METHODS

=cut

sub canonical_hex {
    # Return uppercase hex otp from user input
    my($proto, $input) = @_;
    return undef
	unless $input;
    my($otp) = $proto->from_six_word_format($input);
    return $otp
	if $otp;
    $otp = uc(join('', split(/\s+/, $input)));
    return $otp
	if $otp =~ /^[0-9A-F]{16}$/;
    return undef;
}

sub checksum {
    # Return 2-bit checksum
    my(undef, $hex_otp) = @_;
    my($sum) = 0;
    foreach my $bin (
        unpack('A2'x32, unpack('B64', pack('H16', $hex_otp)))
    ) {
	$sum += unpack('n', pack('B16', '0'x14 . $bin));
    }
    return qw(0 4 8 C)[$sum % 4];
}

sub compute {
    # Return a One Time Password
    my(undef, $passwd, $seed, $count) = @_;
    return undef
	unless $count >= 0;
    return uc(unpack('H*', _compute(lc($seed) . $passwd, $count))),
}

sub from_six_word_format {
    my($proto, $sw_otp) = @_;
    return undef
	unless $sw_otp;
    my($words) = [grep($_, split(/\s+/, $sw_otp))];
    return undef
	unless @$words == 6;
    my($bits) = join('', map({$_REVERSE->{uc($_)} || 'X'} @$words));
    return undef
	if $bits =~ /X/;
    my($otp) = uc(unpack('H17', pack('B66', $bits)));
    return undef
	unless chop($otp) eq $proto->checksum($otp);
    return $otp;
}

sub to_six_word_format {
    my(undef, $otp) = @_;
    return join(' ', map({$_DICTIONARY->[$_]} _split11(_checksum($otp))));
}

sub verify {
    my($proto, $hex_otp, $hex_last_otp) = @_;
    return 1
	if uc(unpack('H*', _compute(unpack('A*', pack('H16', $hex_otp)), 0)))
	    eq $hex_last_otp;
    return 0;
}

#=PRIVATE SUBROUTINES

sub _build_reverse {
    my($count) = 0;
    return {
        map({($_ => substr(unpack('B32', pack('N', $count++)), -11))}
	    @{shift(@_)}),
    };
}

sub _checksum {
    # Append checksum to otp
    my($otp) = @_;
    return $otp . __PACKAGE__->checksum($otp);
}

sub _compute {
    # Recursively compute otp
    no warnings "recursion";
    my($text, $count) = @_;
    return _fold(Digest::MD5::md5($text))
	if $count == 0;
    return _fold(Digest::MD5::md5(_compute($text, --$count)));
}

sub _fold {
    # Fold 128-bit digest to 64-bits
    my($digest) = @_;
    return substr($digest, 0, 8) ^ substr($digest, 8);
}

sub _split11 {
    # Split otp + checksum into 6 11-bit words
    my($otp) = @_;
    return (map({unpack('N', pack('B32', '0'x21 . $_))}
        unpack('A11'x6, unpack('B*', pack('H*', $otp)))));
}

1;
