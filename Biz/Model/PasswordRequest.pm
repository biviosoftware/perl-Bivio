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


=head1 CONSTANTS

=cut

=for html <a name="EXPIRE_DAYS"></a>

=head2 EXPIRE_DAYS : int

Number of days for expiry.

=cut

sub EXPIRE_DAYS {
    return 7;
}

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Biz::Model::RealmOwner;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_QUERY_FIELD) = 'x';

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hashref values)

Sets I<authorization_code> and I<creation_date_time>.

=cut

sub create {
    my($self, $values) = @_;
    $values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless defined($values->{creation_date_time});
    $values->{authorization_code} =
	    Bivio::Type::AuthorizationCode->random_value()
			unless defined($values->{authorization_code});
    return $self->SUPER::create($values);
}

=for html <a name="execute_load_from_query"></a>

=head2 execute_load_from_query(Bivio::Agent::Request req) : boolean

Loads model based on realm_id and authorization_code in the query.

=cut

sub execute_load_from_query {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    my($q) = $req->unsafe_get('query');
    $self->throw_die('NOT_FOUND', {message => 'no query'}) unless $q;

    # Parse query
    my($lq) = Bivio::SQL::ListQuery->unauth_new({%$q},
	    $self, $self->internal_get_sql_support);
    my($id, $actual) = $lq->unsafe_get('this', $_QUERY_FIELD);

    # User hacked the query?
    $self->throw_die(Bivio::DieCode::CORRUPT_QUERY(),
	    'missing or incorrect this') unless $id && $id->[0];
    my($realm_id) = $id->[0];
    $self->unauth_load_or_die(realm_id => $realm_id);
    _trace('actual=', $actual,
	    '; expected=', $self->get('authorization_code')) if $_TRACE;
    # Show not found; eliminates info that might allow "fishing"
    $self->throw_die(Bivio::DieCode::NOT_FOUND(),
	    {actual => $actual, expected => $self->get('authorization_code'),
		message => 'auth_code field mismatch'})
	    unless $actual eq $self->get('authorization_code');

    # Now load realm, because we know $self is valid
    my($realm) = Bivio::Biz::Model::RealmOwner->new($req)
	    ->unauth_load_or_die(realm_id => $id->[0]);
    $req->put(target_realm_owner => $realm);
    return 0;
}

=for html <a name="format_query_with_auth_code"></a>

=head2 format_query_with_auth_code() : string

Formats the query string with I<authorization_code>

=cut

sub format_query_with_auth_code {
    my($self) = @_;
    return $self->SUPER::format_query_for_this().'&'.$_QUERY_FIELD.'='
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
	    authorization_code => ['AuthorizationCode', 'NOT_NULL'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
	},
	auth_id => 'realm_id',
    };
}

=for html <a name="update"></a>

=head2 update(hash_ref values) : self

Sets I<creation_date_time> if not set, then calls super.

=cut

sub update {
    my($self, $values) = @_;
    $values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless defined($values->{creation_date_time});
    return $self->SUPER::update($values);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
