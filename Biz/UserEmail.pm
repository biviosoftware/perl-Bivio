# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::UserEmail;
use strict;
$Bivio::Biz::UserEmail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::UserEmail - a user to email mapping model

=head1 SYNOPSIS

    use Bivio::Biz::UserEmail;
    Bivio::Biz::UserEmail->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::UserEmail::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::UserEmail>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Error;
use Bivio::Biz::FieldDescriptor;
use Bivio::Biz::FindParams;
use Bivio::Biz::SqlSupport;
use Bivio::Biz::User;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_PROPERTY_INFO) = {
    'user_' => ['Internal User ID',
	    Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    'email' => ['Email',
	    Bivio::Biz::FieldDescriptor->lookup('EMAIL', 255)]
    };

my($_SQL_SUPPORT) = Bivio::Biz::SqlSupport->new('user_email',
	keys(%$_PROPERTY_INFO));

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::UserEmail

Creates a new user-email mapping model.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::PropertyModel::new($proto, 'user_email',
	    $_PROPERTY_INFO);

    $self->{$_PACKAGE} = {};
    $_SQL_SUPPORT->initialize();

    return $self;
}

=head1 METHODS

=cut

=head2 create(hash new_values) : boolean

Creates a new model in the database with the specified value. After creation,
this instance has the same values.

=cut

sub create {
    my($self, $new_values) = @_;

    # clear the status from previous invocations
    $self->get_status()->clear();

    if ($new_values->{'email'} =~ /^(\w)+@(\w)+(.(\w)+)*$/) {

	$_SQL_SUPPORT->create($self, $self->internal_get_fields(),
		$new_values);
    }
    else {
	$self->get_status()->add_error(
		Bivio::Biz::Error->new('invalid email'));
    }
    return $self->get_status()->is_ok();
}

=for html <a name="delete"></a>

=head2 delete() : boolean

Deletes the current model from the database. Returns 1 if successful,
0 otherwise.

=cut

sub delete {
    my($self) = @_;

    return $_SQL_SUPPORT->delete($self, 'where user_=? and email=?',
	    $self->get('user_'), $self->get('email'));
}

=for html <a name="find"></a>

=head2 find(FindParams fp) : boolean

Finds the user given the specified search parameters. Valid find keys
are 'email'.

=cut

sub find {
    my($self, $fp) = @_;

    # clear the status from previous invocations
    $self->get_status()->clear();

    if ($fp->get('email')) {
	return $_SQL_SUPPORT->find($self, $self->internal_get_fields(),
		'where email=?', $fp->get('email'));
    }

    $self->get_status()->add_error(
	    Bivio::Biz::Error->new("Club not found"));
    return 0;
}

=for html <a name="get_action"></a>

=head2 get_action(string name) : Action

Returns the named action or undef if no action exists for that name.

=cut

sub get_action {
    return undef;
}

=for html <a name="get_heading"></a>

=head2 get_heading() : string

Returns a suitable heading.

=cut

sub get_heading {
    my($self) = @_;
    return 'User Email';
}
=for html <a name="get_title"></a>

=head2 get_title() : string

Returns a suitable title.

=cut

sub get_title {
    my($self) = @_;
    return 'User Email';
}

=for html <a name="get_user"></a>

=head2 get_user() : 

Returns the user model associated with this model.

=cut

sub get_user {
    my($self) = @_;

    my($user) = Bivio::Biz::User->new();
    $user->find(Bivio::Biz::FindParams->new({'id' => $self->get('user_')}));
    return $user;
}

=for html <a name="update"></a>

=head2 update(hash new_values) : boolean

Don't call this - there is nothing but key fields in this record. Use
delete() and create() to replace it.

=cut

sub update {

    die("UserEmail doesn't support update");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
