# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::UserEmail;
use strict;
$Bivio::Biz::PropertyModel::UserEmail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::UserEmail - a user to email mapping model

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::UserEmail;
    Bivio::Biz::PropertyModel::UserEmail->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::UserEmail::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::UserEmail>

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::PropertyModel::User;
use Bivio::SQL::Support;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_user"></a>

=head2 get_user() : Bivio::Biz::PropertyModel::User

Returns the user model associated with this model.

=cut

sub get_user {
    my($self) = @_;
    my($user) = Bivio::Biz::PropertyModel::User->new($self->get_request);
    $user->unauth_load('user_id' => $self->get('user_id'))
	    || die('integrity constraint failed: missing user');
    return $user;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : (array_ref, Bivio::SQL::Support)

=cut

sub internal_initialize {
    my($property_info) = {
	'user_id' => ['Internal User ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'email' => ['Email',
		Bivio::Biz::FieldDescriptor->lookup('EMAIL', 255)]
    };
    return [$property_info,
	    Bivio::SQL::Support->new('user_email_t', keys(%$property_info)),
	    ['user_id', 'email']];

}

=for html <a name="update"></a>

=head2 update(hash new_values) : boolean

Don't call this - there is nothing but key fields in this record. Use
delete() and create() to replace it.

=cut

sub update {
    die('not supported');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
