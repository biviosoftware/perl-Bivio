# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmLogoList;
use strict;
use Bivio::Base 'Bivio::Biz::ListModel';
use Image::Size ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PUBLIC) = Bivio::Type->get_instance('DocletFileName')->PUBLIC_FOLDER_ROOT;
my($_BASE) = $_PUBLIC . '/logo';

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 0,
        auth_id => ['RealmFile.realm_id', 'RealmOwner.realm_id'],
        primary_key => ['RealmFile.realm_file_id'],
	order_by => [qw(
	    RealmFile.modified_date_time
	)],
	other => [
	    'RealmFile.path',
	    'RealmOwner.name',
	    {
		name => 'uri',
		type => 'FilePath',
		constraint => 'NONE',
	    },
	    map(+{
		name => $_,
		type => 'Integer',
		constraint => 'NONE',
	    }, qw(height width)),
	],
	other_query_keys => ['path_info'],
    });
}

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    $stmt->where(
	$stmt->LIKE('RealmFile.path_lc', lc("$_BASE.%")),
	['RealmFile.is_public', [1]],
    );
    return shift->SUPER::internal_prepare_statement(@_);
}

sub is_ok_to_render {
    my($self) = @_;
    my($req) = $self->get_request;;
    my($re) = qr{
        $_BASE
        @{[$req->get_nested(qw(Bivio::UI::Facade Icon))->FILE_SUFFIX_REGEXP]}
    }ix;
    my($rf) = $self->new_other('RealmFile');
    return $self->do_rows(sub {
	my($p) = $self->get('RealmFile.path');
	return 1
	    unless $p =~ $re;
	my($w, $h, $err)
	    = Image::Size::imgsize($rf->get_content($self, 'RealmFile.'));
	# imgsize returns the file suffix when supplying the buffer in the place
	# of the err
	if ($err =~ /\s/) {
	    $req->warn($self->get('RealmFile.path'),
	        ': Image::Size::imgsize returned: ', $err);
	    return 1;
	}
	@{$self->internal_get}{qw(width height uri)} = (
	    $w,
	    $h,
	    $req->format_uri({
		task_id => Bivio::IO::Config->if_version(
		    3 => sub {'FORUM_FILE'},
		    sub {'FORUM_PUBLIC_FILE'},
		),
		realm => $self->get('RealmOwner.name'),
#TODO: Need to wrap this.  It's to loosely coupled
		path_info => substr($self->get('RealmFile.path'), length($_PUBLIC)),
		query => undef,
	    }),
	);
	return 0;
    })->has_cursor;
}

1;
