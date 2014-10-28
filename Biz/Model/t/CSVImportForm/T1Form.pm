# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::t::CSVImportForm::T1Form;
use strict;
use Bivio::Base 'Bivio::Biz::Model::t::CSVImportForm::TForm';


sub COLUMNS {
    return [
	[qw(name RealmOwner.name)],
	[qw(ID RealmOwner.realm_id NONE User.user_id)],
	[qw(other Line)],
	[qw(gender Gender)],
	[qw(login UserLoginForm.login NONE)],
	[qw(pass UserLoginForm.RealmOwner.password NONE)],
    ];
}

1;
