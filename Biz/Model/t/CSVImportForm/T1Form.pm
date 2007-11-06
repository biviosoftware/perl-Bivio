# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::t::CSVImportForm::T1Form;
use strict;
use Bivio::Base 'Bivio::Biz::Model::t::CSVImportForm::TForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub COLUMNS {
    return [
	[qw(name RealmOwner.name)],
	[qw(id RealmOwner.realm_id NONE)],
	[qw(other Line)],
    ];
}

1;
