# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::PasswordRequest;
use strict;
$Bivio::Biz::Model::PasswordRequest::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::PasswordRequest::VERSION;

=head1 NAME

Bivio::Biz::Model::PasswordRequest - interface to password_request_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::PasswordRequest;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::PasswordRequest::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::PasswordRequest> is the create interface to the
C<password_request_t> table.  Can also format queries.

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmOwner;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_QUERY_FIELD) = 'x';

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hashref values)

Sets I<realm_id>, I<authorization_code>, and I<creation_date_time>.

=cut

sub create {
    my($self, $values) = @_;
    my($req) = $self->get_request();

    # return if entry exists for realm_id
    return $self if $self->unsafe_load(realm_id => $values->{realm_id});
    $values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless defined($values->{creation_date_time});
    $values->{authorization_code} = Bivio::Type::AuthorizationCode->
	    random_value() unless defined($values->{authorization_code});
    $values->{realm_id} =  $values->{realm_id};
    return $self->SUPER::create($values);
}

=for html <a name="execute_load_from_query"></a>

=head2 execute_load_from_query(Bivio::Agent::Request req)

Loads model based on realm_id and authorization_code in the uri.

=cut

sub execute_load_from_query {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);

    # get the query string...should die if not found
    my($query) = $req->get('query');
    my($auth_code) = $query->{$_QUERY_FIELD};

    # load realm, set target realm owner
    my($realm) = Bivio::Biz::Model::RealmOwner->new($req);
#TODO Where does 't' come from...would like not to hard code it here
    $realm->unauth_load_or_die(realm_id => $query->{t});
    $req->put(target_realm_owner => $realm);

    # load password request, give error if auth_code is bad
    $self->throw_die(Bivio::DieCode::NOT_FOUND(),
	    'password request for query realm_id not found in db')
	    unless ($self->unauth_load(realm_id => $query->{t}));
    # Give error page if auth code doesn't match query...could make diff page
    $self->throw_die(Bivio::DieCode::NOT_FOUND(),
	    'authorization code in query does not match db')
	    unless ($self->get('authorization_code')
		    == $query->{$_QUERY_FIELD});

    return;
}

=for html <a name="format_query_with_auth_code"></a>

=head2 format_query_with_auth_code() : string

Formats the query string with I<authorization_code>

=cut

sub format_query_with_auth_code {
    my($self) = @_;
    return $self->SUPER::format_query().'&'.$_QUERY_FIELD.'='
	    .$self->get('authorization_code');
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'password_request_t',
	columns => {
	    realm_id => ['PrimaryId', 'PRIMARY_KEY'],
	    authorization_code => ['Bivio::Type::AuthorizationCode',
		'NOT_NULL'],
	    creation_date_time => ['Bivio::Type::DateTime', 'NOT_NULL'],
	},
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
