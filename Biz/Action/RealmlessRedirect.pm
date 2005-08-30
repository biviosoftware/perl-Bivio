# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::RealmlessRedirect;
use strict;
$Bivio::Biz::Action::RealmlessRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::RealmlessRedirect::VERSION;

=head1 NAME

Bivio::Biz::Action::RealmlessRedirect - redirect to task on auth_user

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::RealmlessRedirect;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::RealmlessRedirect::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::RealmlessRedirect>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean



Always returns false.

=cut

sub execute {
    my($proto, $req) = @_;
    my($us, $t) = $req->get(qw(user_state task));
    return $us->equals_by_name('JUST_VISITOR')
	? 'visitor_task'
	: $req->get('auth_user')
	? _set_realm($req, Bivio::Agent::Task->get_by_id($t->get('home_task')))
	|| 'unauth_task'
	: Bivio::Agent::TaskId->LOGIN;
}

#=PRIVATE SUBROUTINES

# _set_realm(Bivio::Agent::Request req, Bivio::Agent::TaskId t) : Bivio::Agent::TaskId
#
# Returns t if can set the realm for t.
#
sub _set_realm {
    my($req, $t) = @_;
    return unless my $l = Bivio::Biz::Model->new($req, 'UserRealmList')
	->unauth_load_all({auth_id => $req->get('auth_user_id')})
	->find_row_by_type($t->get('realm_type'));
    $req->set_realm($l->get('RealmUser.realm_id'));
    return $t->get('id');
}

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
