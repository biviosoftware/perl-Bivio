# Copyright (c) 1999 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Address;
use strict;
use Bivio::Base 'Bivio::Biz::Model::LocationBase';

# C<Bivio::Biz::Model::Address> is the create, read, update,
# and delete interface to the C<address_t> table.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_load_home {
    # (proto, Agent.Request) : boolean
    # Loads the home address for the current realm.
    my($proto, $req) = @_;
    $proto->new($req)->load({
	location => Bivio::Type::Location->HOME,
    });
    return 0;
}

sub format {
    # (self) : string
    # (proto, Biz.Model, string) : string
    # Returns the street1, street2, city, state, zip, and country as
    # a single string (with embedded newlines).
    #
    # In the second form, I<list_model> is used to get the values, not I<self>.
    # List Models can declare a method of the form:
    #
    #     sub format_address {
    # 	my($self) = shift;
    # 	Bivio::Biz::Model::Address->format($self, 'Address.');
    #     }
    #
    # Always returns a valid (defined) string, but may be zero length.
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
    # (self) : hash_ref
    # B<FOR INTERNAL USE ONLY>
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
