# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AdmGetBulletinAttachment;
use strict;
$Bivio::Biz::Action::AdmGetBulletinAttachment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::AdmGetBulletinAttachment::VERSION;

=head1 NAME

Bivio::Biz::Action::AdmGetBulletinAttachment - download a bulletin attachment

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::AdmGetBulletinAttachment;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::AdmGetBulletinAttachment::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::AdmGetBulletinAttachment>

=cut

#=IMPORTS
use Bivio::IO::File;
use Bivio::MIME::Type;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req)

Sets the reply to the bulletin attachment.

=cut

sub execute {
    my($proto, $req) = @_;
    my($reply) = $req->get('reply');
    my($file_index) = ($req->get('query') || {})->{file} || 0;
    $file_index =~ s/\D//g;
    my($file) = $req->get('Model.Bulletin')->get_attachment_file_names
        ->[$file_index];
    $reply->set_output_type(Bivio::MIME::Type->from_extension($file));
    $reply->set_output(Bivio::IO::File->read($file));
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
