# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::File;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

my($_F) = b_use('IO.File');
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    root => $_C->REQUIRED,
    backup_root => $_C->REQUIRED,
});

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    $_CFG->{backup_root} ||= $_CFG->{root} . '/bkp';
    return;
}

sub absolute_path {
    my(undef, $base) = @_;
    return $base
        if $base =~ /^\Q$_CFG->{root}/;
    return File::Spec->catfile($_CFG->{root}, $base);
}

sub absolute_path_for_backup {
    my(undef, $base) = @_;
    return File::Spec->catfile($_CFG->{backup_root}, $base);
}

sub delete {
    my($proto, $base) = @_;
    unlink($proto->absolute_path($base));
    return;
}

sub destroy_db {
    my($proto) = @_;
    $_F->rm_children($_CFG->{root});
    return;
}

sub unsafe_read {
    my($proto, $base) = @_;
    my($f) = $proto->absolute_path($base);
    # The -e allows us to catch file permission errors of which there should
    # be none.  unsafe means "exists" in this case
    return -e $f ? $_F->read($f) : undef;
}

sub write {
    my($proto, $base, $content) = @_;
    my($f) = $proto->absolute_path($base);
    $_F->mkdir_parent_only($f, 0770);
    $_F->write($f, $content);
    return $f;
}

1;
