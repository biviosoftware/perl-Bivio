# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::t::CSVImportForm::T2Form;
use strict;
use Bivio::Base 'Bivio::Biz::Model::t::CSVImportForm::TForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CSV_COLUMNS {
    return shift->internal_csv_columns([
	name => [qw(RealmOwner.name 1)],
	id => [qw(RealmOwner.realm_id)],
	other => [qw(Line 0)],
    ]);
}

1;
