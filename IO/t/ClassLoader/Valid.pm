# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::t::ClassLoader::Valid;
use strict;
use base 'Bivio::UNIVERSAL';

my($_IMPORTERS) = [];

sub get_importers {
    return $_IMPORTERS;
}

sub handle_class_loader_require {
    my($proto, $importer) = @_;
    push(@$_IMPORTERS, $importer);
    return;
}

1;
