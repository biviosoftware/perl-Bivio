# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Ext::NetFTPServer::RootHandle;
use strict;
use base 'Bivio::Ext::NetFTPServer::DirHandle';
use Bivio::Biz::ListModel;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub get {
    my($self, $filename) = @_;
    my($path) = '/' . $filename;
    return undef
	unless $self->{ftps}->get_realm_file($path);
    return Bivio::Ext::NetFTPServer::DirHandle->new($self->{ftps}, $path);
}

sub parent {
    my($self) = @_;
    return $self;
}

sub list_status {
    my($self, $wildcard) = @_;

    if ($wildcard) {
	$wildcard = $self->{ftps}->wildcard_to_regex($wildcard);
    }
    return Bivio::Biz::ListModel->new_anonymous({
	primary_key => ['Forum.forum_id'],
	other => [
	    [qw(Forum.forum_id RealmOwner.realm_id)],
	],
	order_by => ['RealmOwner.name'],
    })->map_iterate(sub {
        my($list) = @_;
	my($name) = $list->get('RealmOwner.name');
	return () if $wildcard && $name !~ /$wildcard/;
	my($handle) = Bivio::Ext::NetFTPServer::DirHandle->new(
	    $self->{ftps}, '/' . $name);
	# status will be empty if there is no Public folder
	my(@status) = $handle->status;
	return scalar(@status)
	    ? [$name, $handle, [@status]]
	    : ();
    });
}

1;
