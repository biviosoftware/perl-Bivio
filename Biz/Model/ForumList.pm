# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ForumList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_EM) = Bivio::Type->get_instance('ForumEmailMode');

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	primary_key => [['Forum.forum_id', 'RealmOwner.realm_id']],
	order_by => [
	    {
		name => 'RealmOwner.name',
		type => 'ForumName',
	    },
	    'RealmOwner.display_name',
	],
	other => [
	    'Forum.want_reply_to',
	    map(+{
		name => $_,
		type => 'Boolean',
		constraint => 'NONE',
	    }, $_EM->OPTIONAL_MODES),
	],
	auth_id => ['Forum.parent_realm_id'],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    my($req) = $self->get_request;
    my($a) = $req->get('auth_id');
    $req->set_realm($row->{'RealmOwner.name'});
    my($cats) = Bivio::IO::ClassLoader
	->simple_require('Bivio::Biz::Util::RealmRole')
	    ->list_enabled_categories();
    foreach my $pc ($_EM->OPTIONAL_MODES) {
	$row->{$pc} = grep($_ eq $pc, @$cats) ? 1 : 0;
    }
    $req->set_realm($a);
    return 1;
}

1;
