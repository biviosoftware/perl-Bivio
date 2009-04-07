# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::File;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register(my $_CFG = {
    root => Bivio::IO::Config->REQUIRED,
});
my($_F) = b_use('IO.File');

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub absolute_path {
    my(undef, $base) = @_;
    return File::Spec->catfile($_CFG->{root}, $base);
}

sub destroy_db {
    my($proto) = @_;
    $_F->rm_children($_CFG->{root});
    return;
}

sub write {
    my($proto, $base, $content) = @_;
    my($f) = $proto->absolute_path($base);
    $_F->mkdir_parent_only($f, 0770);
    $_F->write($f, $content);
    return $f;
}

1;
