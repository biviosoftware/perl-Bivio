# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ConfirmUploadForm;
use strict;
$Bivio::Biz::Model::ConfirmUploadForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ConfirmUploadForm - confirms club transaction deletion

=head1 SYNOPSIS

    use Bivio::Biz::Model::ConfirmUploadForm;
    Bivio::Biz::Model::ConfirmUploadForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::ConfirmUploadForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ConfirmUploadForm> confirms club transaction deletion

=cut

#=IMPORTS
use Bivio::Biz::Model::Club;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Checks that club transactions exist. If not redirects to the next form.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;

    # redirects to the next task if there are no club transactions
    my($club) = Bivio::Biz::Model::Club->new($req);
    $club->load(club_id => $req->get('auth_id'));
    $req->server_redirect($req->get('task')->get('next'))
	    unless ($club->has_transactions);

    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()

Deletes all existing transactions/instruments/shadow members.

=cut

sub execute_input {
    my($self) = @_;
    my($req) = $self->get_request();

    # delete all the club's instruments, valuations, and transactions
    my($club) = Bivio::Biz::Model::Club->new($req);
    $club->load(club_id => $req->get('auth_id'));
    $club->delete_instruments_and_transactions;

    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
