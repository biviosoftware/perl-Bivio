# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::AdmSubstituteUserForm;
use strict;
use Bivio::Base 'Model';

my($_A) = b_use('Mail.Address');

sub internal_post_parse_columns {
    my($self, $values) = @_;
#TODO: Coupled with View.UserAuth;  Need list_id_field on ComboBox
    if (
	($values->{login} || '') =~ /\@/
	and my $e = ($_A->parse($values->{login}))[0]
    ) {
	$values->{login} = $e;
    }
    return shift->SUPER::internal_post_parse_columns(@_);
}

sub internal_pre_execute {
    my($self) = @_;
    $self->new_other('AdmUserList')->load_all;
    return shift->SUPER::internal_pre_execute(@_);
}

1;
