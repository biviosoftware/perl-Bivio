# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Email;
use strict;
$Bivio::Biz::Model::Email::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Email - interface to email_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::Email;
    Bivio::Biz::Model::Email->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::AbstractLocation>

=cut

use Bivio::Biz::Model::AbstractLocation;
@Bivio::Biz::Model::Email::ISA = qw(Bivio::Biz::Model::AbstractLocation);

=head1 DESCRIPTION

C<Bivio::Biz::Model::Email> is the create, read, update,
and delete interface to the C<email_t> table.

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Cookie;
use Bivio::SQL::Constraint;
use Bivio::Type::Email;
use Bivio::Type::Location;
use Bivio::Type::PrimaryId;

#=VARIABLES
my($_COOKIE_USER_FIELD) = Bivio::Agent::HTTP::Cookie->USER_FIELD();

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<want_bulletin> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{want_bulletin} = 1
	    unless defined($values->{want_bulletin});
    return $self->SUPER::create($values);
}

=for html <a name="get_email_from_cookie"></a>

=head2 static get_email_from_cookie(Bivio::Agent::Request req) : string

Returns the email of the user in the cookie.
Returns undef if realm can't be loaded or email address is invalid.

=cut

sub get_email_from_cookie {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    return undef unless $self->unauth_load(
	    realm_id => $req->get('cookie')->unsafe_get($_COOKIE_USER_FIELD));
    return $self->is_ignore ? undef : $self->get('email');
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 2,
	table_name => 'email_t',
	columns => {
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
            location => ['Location', 'PRIMARY_KEY'],
            email => ['Email', 'NOT_NULL_UNIQUE'],
	    want_bulletin => ['Boolean', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
    };
}

=for html <a name="is_ignore"></a>

=head2 is_ignore() : boolean

=head2 static is_ignore(Bivio::Biz::ListModel list_model, string model_prefix) : boolean

Calls L<Bivio::Type::Email::is_ignore|Bivio::Type::Email/"is_ignore">
on the email address.

=cut

sub is_ignore {
    my($self, $list_model, $model_prefix) = @_;
    my($p) = $model_prefix || '';
    my($m) = $list_model || $self;
    return Bivio::Type::Email->is_ignore($m->get($p.'email'));
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
