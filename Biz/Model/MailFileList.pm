# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MailFileList;
use strict;
$Bivio::Biz::Model::MailFileList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MailFileList - files associated with a mail message

=head1 SYNOPSIS

    use Bivio::Biz::Model::MailFileList;
    Bivio::Biz::Model::MailFileList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::MailFileList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MailFileList> is the list of files associated with
a mail message.  It is an in-order list, i.e. it expands all attachments
in the order they appear in the file.

=cut

#=IMPORTS
use Bivio::Type::FileVolume;
use Bivio::Biz::Model::File;

#=VARIABLES
my($_CACHE_VOLUME) = Bivio::Type::FileVolume->MAIL_CACHE;

=head1 METHODS

=cut

=for html <a name="get_mime_content_type"></a>

=head2 get_mime_content_type() : string

Returns the mime file name.
See
L<Bivio::Biz::Model::File::get_mime_content_type|Bivio::Biz::Model::File/"get_mime_content_type">.

=cut

sub get_mime_content_type {
    my($self) = @_;
    return Bivio::Biz::Model::File->get_mime_content_type($self, 'File.', @_);
}

=for html <a name="get_mime_filename"></a>

=head2 get_mime_filename() : string

Returns the mime file name.
See
L<Bivio::Biz::Model::File::get_mime_filename|Bivio::Biz::Model::File/"get_mime_filename">.

=cut

sub get_mime_filename {
    my($self) = @_;
    return Bivio::Biz::Model::File->get_mime_filename($self, 'File.', @_);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

All local fields.

=cut

sub internal_initialize {
    return {
	version => 1,
	# We don't order by name_sort, because the attachment names may
	# be case sensitive
	order_by => ['File.name'],

	# The primary key is special for retrieving attachments.  When
	# writing, we don't know the file_id until it is written.
	primary_key => [qw(File.directory_id File.name)],

	auth_id => [qw(File.realm_id)],
	other => [
            'File.is_directory',
	    'File.directory_id',
	    'File.bytes',
	    'File.aux_info',
	    # Dynamically generated in internal_load.  Doesn't contain
	    # leading '/'.
	    {
		name => 'path_info',
		type => 'String',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

=for html <a name="internal_load"></a>

=head2 internal_load(array_ref rows, Bivio::SQL::ListQuery query)

Set path_info for each row.

=cut

sub internal_load {
    my($self, $rows, $query) = @_;
    shift;
    $self->SUPER::internal_load(@_);

    # just iterate over rows and assign get_mime_filename to path_info
    $self->reset_cursor;
    while ($self->next_row) {
	my($properties) = $self->internal_get();
	$properties->{path_info} = $self->get_mime_filename();
    }
    $self->reset_cursor;
    return;
}

=for html <a name="internal_pre_load"></a>

=head2 internal_pre_load(Bivio::SQL::ListQuery query, Bivio::SQL::ListSupport support, array_ref params) : string

Returns the WHERE and CONNECT BY clause and associated I<params>.

=cut

sub internal_pre_load {
    my($self, $query, $support, $params) = @_;
    my($req) = $self->get_request;

    # This is the first file in the tree of mail attachments.  It may
    # be the only file.
    push(@$params, $req->get('auth_id'),
	    $req->get('Bivio::Biz::Model::Mail')->get('cache_id'));
    return "file_id in
        (SELECT DISTINCT file_id
            FROM file_t
            WHERE realm_id = ?
            AND volume = $_CACHE_VOLUME
            START WITH file_id = ?
            CONNECT BY directory_id = PRIOR file_id)";
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
