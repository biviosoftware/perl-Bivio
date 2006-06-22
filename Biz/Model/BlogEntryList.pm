# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BlogEntryList;
use strict;
use base 'Bivio::Biz::Model::RealmFileList';
my($_BN) = Bivio::Type->get_instance('BlogName');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute_load_entry_or_page {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    my($query) = $self->parse_query_from_request();
    $query->put(path_info => '/Blog');
    my($name) = $req->unsafe_get('path_info');
    if ($name) {
	$query->put(entry => $_BN->absolute_path($name));
	$self->load_all($query);
    }
    else {
	$self->load_page($query);
    }
    return 0;
}

sub get_content {
    my($self) = @_;
    return ${$self->get_model('RealmFile')->get_content()};
}

sub internal_initialize {
    my($self) = @_;
    my($conf) = $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	other => [
	    [qw(RealmFile.user_id RealmOwner.realm_id)],
	    'RealmOwner.display_name',
	    {
	        name => 'title',
	        type => 'String',
	    }
	],
    });

    # realm_file_id is a proxy for creation_date_time
    $conf->{order_by} = ['RealmFile.realm_file_id'];

    return $conf;
}

sub internal_post_load_row {
    my($self, $row) = @_;
    ($row->{title}) = $row->{'RealmFile.path'} =~ m{.+/(.+)$};
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($req) = $self->get_request();
    shift->SUPER::internal_prepare_statement(@_);
    $stmt->where(['RealmFile.path', [$query->get('entry')]])
	if $query->unsafe_get('entry');
    return;
}

1;
