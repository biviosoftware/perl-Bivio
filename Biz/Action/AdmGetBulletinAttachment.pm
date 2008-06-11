# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::AdmGetBulletinAttachment;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = __PACKAGE__->use('MIME.Type');
my($_F) = __PACKAGE__->use('IO.File');

sub execute {
    my($proto, $req) = @_;
    my($reply) = $req->get('reply');
    my($file_index) = ($req->get('query') || {})->{file} || 0;
    $file_index =~ s/\D//g;
    my($file) = $req->get('Model.Bulletin')->get_attachment_file_names
        ->[$file_index];
    $reply->set_output_type($_T->from_extension($file));
    $reply->set_output($_F->read($file));
    return;
}

1;
