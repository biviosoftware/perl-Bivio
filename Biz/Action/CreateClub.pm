# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::CreateClub;
use strict;
$Bivio::Biz::Action::CreateClub::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::CreateClub - creates a new bivio club

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::CreateClub::ISA = qw(Bivio::Biz::Action);

=head1 DESCRIPTION

C<Bivio::Biz::Action::CreateClub> creates a club and its administrator.

=cut

#=IMPORTS
use Bivio::Biz::ClubUser;
use Bivio::Biz::Mail::Message;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Action::CreateClub

Creates an action for creating a bivio club.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::Biz::Action::new($proto, 'add', 'Create Club',
	   'Create a new club', '/i/new.gif');
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Club club, Request req) : boolean

Creates a new club record in the database using values specified in the
request.

=cut

sub execute {
    my($self, $club, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

#TODO: Need to create the messages directory
    eval {
	my($values) = &_create_field_map($club, $req);

	$values->{'bytes_in_use'} = 0;
	$values->{'bytes_max'} = 8 * 1024 * 1024;
	$club->create($values);

	if ($club->get_status()->is_ok()) {

	    # create the club's admin user
	    if ($req->get_arg('admin')) {
		my($club_user) = Bivio::Biz::ClubUser->new();
		$club_user->create({
		    'club_id' => $club->get('id'),
		    'user_id' => $req->get_arg('admin'),
		    'role' => 0,
		    'email_mode' => 1
		});

		# need to add errors to club, it is what is sent through
		# the system
		foreach (@{$club_user->get_status()->get_errors()}) {
		    $club->get_status()->add_error($_);
		}
	    }
	    my($bbmm) = Bivio::Biz::Mail::Message->new();
	    $bbmm->setup_club($club);
	}
    };

    # check for exceptions
    if ($@) {
	Bivio::SQL::Connection->rollback();
	die($@);
    }

    if ($club->get_status()->is_ok()) {
	Bivio::SQL::Connection->commit();
	return 1;
    }

    Bivio::SQL::Connection->rollback();
    die(join("\n", map {$_->get_message} @{$club->get_status->get_errors}));
}

#=PRIVATE METHODS

# _create_field_map(PropertyModel model, Request req) : hash
#
# Creates a hash of model fields which exist in the specified request.

sub _create_field_map {
    my($model, $req) = @_;

    my($result) = {};
    my($fields) = $model->get_field_names();

    foreach (@$fields) {
	$result->{$_} = $req->get_arg($_);
    }
    return $result;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
