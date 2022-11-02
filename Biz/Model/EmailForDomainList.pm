# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EmailForDomainList;
use strict;
use Bivio::Base 'Biz.ListModel';


sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        can_iterate => 1,
        primary_key => [qw(Email.realm_id Email.location)],
        order_by => ['Email.email'],
        other_query_keys => ['b_domain_name'],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $stmt->where(
        $stmt->LIKE('Email.email', '%@' . $query->get('b_domain_name')));
    return shift->SUPER::internal_prepare_statement(@_);
}

1;
