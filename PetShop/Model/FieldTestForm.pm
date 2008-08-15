# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::FieldTestForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->field_decl(visible => [
	    [qw(boolean Boolean)],
	    [qw(date Date)],
	    [qw(date_time DateTime)],
	    [qw(realm_name RealmName)],
	    [qw(line Line)],
	    [qw(text Text)],
	], undef, 'NONE'),
    });
}

1;
