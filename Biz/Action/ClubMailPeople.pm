# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ClubMailPeople;
use strict;
$Bivio::ClubMailPeople::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::ClubMailPeople - forward a mail message to club members AND guests

=head1 SYNOPSIS

    use Bivio::Biz::Action::ClubMailPeople;
    Bivio::Biz::Action::ClubMailPeople->execute($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::ClubMailPeople::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::ClubMailPeople> forwards a mail message
to club members AND guests.

TODO: Need to actually support "the guests".

=cut

#=IMPORTS
use Bivio::Mail::Message;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute(Agent::Request req) : 

Forwards an incoming message to members AND guests of a club.

=cut

sub execute {
    my($self, $req) = @_;
    my($realm_owner) = $req->get('auth_realm')->get('owner');
    my($msg) = $req->get('mail');

    my($club) = Bivio::Biz::Model::Club->new($req);
    $club->load(club_id => $realm_owner->get('realm_id'));

    my($emails) = $club->get_outgoing_emails;
    $req->die('NOT_FOUND', 'alls emails marked as invalid')
            unless $emails;
    $msg->add_recipients($emails);

    my($display_name) = $realm_owner->get('display_name');
    $msg->set_headers_for_list_send($realm_owner->get('name'),
            $display_name, 1, 1);
    # Include the club's URI in the header for convenience
    $msg->get_head->replace('Organization',
            $realm_owner->get_request->format_http(
                    Bivio::Agent::TaskId::CLUB_HOME(),
                    undef, Bivio::Auth::Realm->new($realm_owner)));
    $msg->enqueue_send;
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
