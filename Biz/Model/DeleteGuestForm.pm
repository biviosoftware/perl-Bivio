# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::DeleteGuestForm;
use strict;
$Bivio::Biz::Model::DeleteGuestForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::DeleteGuestForm - delete a guest

=head1 SYNOPSIS

    use Bivio::Biz::Model::DeleteGuestForm;
    Bivio::Biz::Model::DeleteGuestForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::DeleteGuestForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::DeleteGuestForm> delete a guest

=cut

#=IMPORTS
use Bivio::Biz::Model::User;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute_input()

Deletes the selected guest from the current club.

=cut

sub execute_input {
    my($self) = @_;
    my($req) = $self->get_request;

    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $list->set_cursor(0);
    my($realm_user) = $list->get_model('RealmUser');
    $realm_user->cascade_delete();

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
