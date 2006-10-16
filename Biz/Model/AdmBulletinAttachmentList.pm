# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmBulletinAttachmentList;
use strict;
$Bivio::Biz::Model::AdmBulletinAttachmentList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::AdmBulletinAttachmentList::VERSION;

=head1 NAME

Bivio::Biz::Model::AdmBulletinAttachmentList - attachments for current bulletin

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::AdmBulletinAttachmentList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::AdmBulletinAttachmentList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AdmBulletinAttachmentList>

=cut

#=IMPORTS
use Bivio::HTML;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="format_file_href"></a>

=head2 format_file_href() : string

Returns the href to download the current attachment.

=cut

sub format_file_href {
    my($self) = @_;
    my($req) = $self->get_request;
    return $req->format_stateless_uri('ADM_BULLETIN_ATTACHMENT')
        . '/' . Bivio::HTML->escape_uri($self->get('name'))
        . '?t=' . $req->get('Model.Bulletin')->get('bulletin_id')
        . '&file=' . $self->get_cursor;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
        version => 1,
        other => [
            {
                name => 'filename',
                type => 'String',
                constraint => 'NONE',
            },
            {
                name => 'name',
                type => 'String',
                constraint => 'NONE',
            },
        ],
    };
}

=for html <a name="internal_load_rows"></a>

=head2 internal_load_rows(Bivio::SQL::ListQuery query, string where, array_ref params, Bivio::SQL::ListSupport sql_support) : array_ref

Loads the attachment names for the current bulletin.

=cut

sub internal_load_rows {
    my($self, @args) = @_;
    my($result) =[];
    my($index) = 0;

    foreach my $file (@{$self->get_request->get('Model.Bulletin')
        ->get_attachment_file_names}) {

        my($name) = $file;
        $name =~ s/^.*\/\d+-\d+-//;
        push(@$result, {
            filename => $file,
            name => $name,
        });
    }
    return $result;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
