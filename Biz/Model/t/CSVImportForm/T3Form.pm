# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::t::CSVImportForm::T3Form;
use strict;
use Bivio::Base 'Bivio::Biz::Model::t::CSVImportForm::TForm';


sub COLUMNS {
    return [
	[qw(name RealmOwner.name)],
	[qw(name RealmOwner.name)],
    ];
}

1;
