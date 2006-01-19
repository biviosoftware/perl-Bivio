# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EmailAliasList;
use strict;
use base 'Bivio::Biz::ListModel';
use Digest::MD5 ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	primary_key => [{
	    name => 'primary_key',
	    type => 'Name',
	    constraint => 'NOT_NULL',
	}],
	order_by => [
	    'EmailAlias.incoming',
	    'EmailAlias.outgoing',
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{primary_key} = Digest::MD5::md5_base64(
	$row->{'EmailAlias.incoming'} . $row->{'EmailAlias.outgoing'});
    return 1;
}

1;
