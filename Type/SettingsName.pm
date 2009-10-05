# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::SettingsName;
use strict;
use Bivio::Base 'Type.DocletFileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub PRIVATE_FOLDER {
    return shift->SETTINGS_FOLDER;
}

sub REGEX {
    return qr{(\w+\.csv)$};
}

1;
