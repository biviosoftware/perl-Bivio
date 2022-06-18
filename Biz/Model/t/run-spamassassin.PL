#!/usr/bin/perl -w
#
# Usage: perl -w run-spamassassin.PL MailReceiveDispatchForm3/*.in
#
use strict;
use warnings;
use Mail::SpamAssassin ();
# Needs to run outside bOP due to bugs in evals:
# https://rt.cpan.org/Public/Bug/Display.html?ForceShowHistory=1;ShowHeaders=1;id=130949
sub _read {
    my($file) = @_;
    open('IN', $file) || die;
    local($/);
    my $res = scalar(<IN>);
    close(IN) || die;
    return $res;
}

sub _write{
    my($file, $content) = @_;
    open('OUT', '> ' . $file) || die;
    print(OUT $content);
    close(OUT) || die;
}

for my $f (@ARGV) {
    my($m) = Mail::SpamAssassin->new;
    _write(
        $f,
        $m->check($m->parse(_read($f)))->rewrite_mail,
    );
}
