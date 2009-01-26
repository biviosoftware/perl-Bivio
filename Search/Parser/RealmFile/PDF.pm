# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::PDF;
use strict;
use Bivio::Base 'SearchParser.RealmFile';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SU) = b_use('Bivio.ShellUtil');
my($_D) = b_use('Bivio.Die');

sub CONTENT_TYPE_LIST {
    return 'application/pdf';
}

sub handle_realm_file_new_text {
    my($proto, $parseable) = @_;
    my($path) = $parseable->get_os_path;
    return
	unless my $info = _run($parseable, "pdfinfo $path");
    my($title) = $info =~ /^Title:\s*(.*)/im ? $1 : undef;
    $title = ''
	unless defined($title);
    return
	unless my $text = _run($parseable, "pdftotext $path -");
    $text =~ s/^\s*\n$//mg;
    return $proto->new({
	type => 'application/pdf',
	length($title) ? (title => $title) : (),
	text => \$text,
    });
}

sub _run {
    my($parseable, $cmd) = @_;
    my($out);
    my($die) = $_D->catch_quietly(sub {$out = $_SU->piped_exec("$cmd 2>&1")});
    return b_warn($cmd, ': ', $die || $out || 'no output')
	if $die || !$out || $$out =~ /^Error:.*Error:/s;
    return $$out;
}

1;
