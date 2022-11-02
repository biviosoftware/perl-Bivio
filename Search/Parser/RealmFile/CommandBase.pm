# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::CommandBase;
use strict;
use Bivio::Base 'SearchParser.RealmFile';

my($_SU) = b_use('Bivio.ShellUtil');
my($_D) = b_use('Bivio.Die');
my($_S) = b_use('Type.String');

sub CONTENT_TYPE_LIST {
    return '';
}

sub handle_realm_file_new_text {
    my($proto, $parseable) = @_;
    my($path) = $parseable->get_os_path;
    my($title) = $proto->internal_get_title($parseable);
    return $proto->new({
        type => $proto->CONTENT_TYPE_LIST,
        defined($title) && length($title) ? (title => $title) : (),
        text => $_S->canonicalize_charset(
            \$proto->internal_get_text($parseable)),
    });
}

sub internal_get_text {
    my($proto, $parseable) = @_;
    return undef;
}

sub internal_get_title {
    my($proto, $parseable) = @_;
    return undef;
}

sub internal_run_parser {
    my($proto, $cmd, $parseable, $error_pattern) = @_;
    my($out);
    my($path) = $parseable->get_os_path;
    b_die($cmd, ': missing <path>')
        unless $cmd =~ s/<path>/$path/g;
    my($die) = $_D->catch_quietly(sub {$out = $_SU->piped_exec($cmd)});
    if ($die || !defined($out) || ($error_pattern && $$out =~ $error_pattern)) {
        b_warn($cmd, ': ', $die ? $die->get('attrs') : ($out || 'no output'));
        return '';
    }
    return $$out;
}

1;
