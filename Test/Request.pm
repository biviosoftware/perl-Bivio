# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Request;
use strict;
$Bivio::Test::Request::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Request::VERSION;

=head1 NAME

Bivio::Test::Request - manages requests for tests

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Request;

=cut

=head1 EXTENDS

L<Bivio::Agent::Job::Request>

=cut

use Bivio::Agent::Job::Request;
@Bivio::Test::Request::ISA = ('Bivio::Agent::Job::Request');

=head1 DESCRIPTION

C<Bivio::Test::Request> manages requests for tests.  Simply importing creates a
new request running in general realm.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Auth::Realm::General;
use Bivio::Type::DateTime;

#=VARIABLES
my($_SELF);

=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::Test::Request

Returns an instance of self.

=cut

sub get_instance {
    my($proto) = @_;
    if ($_SELF) {
	Bivio::Die->die($_SELF, ': self not current request ',
	    $_SELF->get_current)
	    unless $_SELF->get_current == $_SELF;
    }
    else {
	$_SELF = $proto->new({
	    auth_id => undef,
	    auth_user_id => undef,
	    task_id => Bivio::Agent::TaskId->SHELL_UTIL,
	    timezone => Bivio::Type::DateTime->timezone,
	});
	$_SELF->set_realm(Bivio::Auth::Realm::General->get_instance);
    }
    return $_SELF;
}

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
