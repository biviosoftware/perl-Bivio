# Copyright (c) 1999-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Address;
use strict;
use Bivio::Base 'Model.LocationBase';


sub execute_load_home {
    my($proto, $req) = @_;
    $proto->new($req)->load({
	location => Bivio::Type::Location->HOME,
    });
    return 0;
}

sub format {
    my($self, $model, $model_prefix) = shift->internal_get_target(@_);
    my($m, $p) = ($model, $model_prefix);
    my($sep) = ', ';
    my($csz) = undef;
    foreach my $n ($m->unsafe_get($p.'city', $p.'state', $p.'zip')) {
	$csz .= $n.$sep if defined($n);
	$sep = '  ';
    }
    chop($csz), chop($csz) if defined($csz);
    my($res) = '';
    my(@f) = $m->unsafe_get($p.'street1', $p.'street2', $p.'country');
    splice(@f, 2, 0, $csz);
    foreach my $n (@f) {
	$res .= $n."\n" if defined($n);
    }
    chop($res);
    return $res;
}

sub internal_initialize {
    return {
	version => 1,
	table_name => 'address_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    location => ['Location', 'PRIMARY_KEY'],
	    street1 => ['Line', 'NONE'],
	    street2 => ['Line', 'NONE'],
	    city => ['Name', 'NONE'],
	    state => ['Name', 'NONE'],
	    zip => ['Name', 'NONE'],
	    country => ['Country', 'NONE'],
        },
	auth_id => 'realm_id',
    };
}

1;
