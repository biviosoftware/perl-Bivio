# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::UserVisitorList;
use strict;
$Bivio::Biz::Model::UserVisitorList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::UserVisitorList - list of visitors bound to this user

=head1 SYNOPSIS

    use Bivio::Biz::Model::UserVisitorList;
    Bivio::Biz::Model::UserVisitorList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::UserVisitorList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::UserVisitorList> list of users associated with
a user.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="get_first_id"></a>

=head2 static get_first_id(Bivio::Agent::HTTP::Request req, string user_id) : string

Returns the visitor_id of the first entry or undef.

There may be multiple visitors for the same user if the user plays around
with her cookies.

=cut

sub get_first_id {
    my($proto, $req, $user_id) = @_;
    my($self) = $proto->new($req);
    $self->unauth_load_all({auth_id => $user_id});
    return $self->set_cursor(0) ? $self->get('Visitor.visitor_id') : undef;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<Internal use only.>

=cut

sub internal_initialize {
    return {
       version => 1,
       order_by => ['Visitor.visitor_id'],
       primary_key => ['Visitor.visitor_id'],
       auth_id => ['Visitor.user_id'],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
