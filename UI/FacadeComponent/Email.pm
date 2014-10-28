# Copyright (c) 2006-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeComponent::Email;
use strict;
use Bivio::Base 'UI.FacadeComponent';
b_use('IO.ClassLoaderAUTOLOAD');

my($_E) = Type_Email();
my($_R) = Agent_Request();

sub format {
    my($self, $local_part_or_email, $req) = @_;
    unless ($_R->is_blesser_of($req)) {
	IO_Alert()->warn_deprecated('must pass req');
	$req = $_R->get_current;
    }
    $self = $self->internal_get_self($req)
	unless ref($self);
    return $_E->format_email(
	$local_part_or_email,
	$self->get_facade->get_value('mail_host'),
	undef,
	undef,
	b_use('Agent.Request')->get_current,
    );
}

sub internal_initialize_value {
    return;
}

1;
