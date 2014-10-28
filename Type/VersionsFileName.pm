# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::VersionsFileName;
use strict;
use Bivio::Base 'Type.DocletFileName';


sub PRIVATE_FOLDER {
    return shift->VERSIONS_FOLDER;
}

1;
