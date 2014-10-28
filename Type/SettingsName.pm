# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::SettingsName;
use strict;
use Bivio::Base 'Type.DocletFileName';


sub PRIVATE_FOLDER {
    return shift->SETTINGS_FOLDER;
}

sub REGEX {
    return qr{(\w+\.csv)$};
}

sub SQL_LIKE_BASE {
    return '%.csv';
}

1;
