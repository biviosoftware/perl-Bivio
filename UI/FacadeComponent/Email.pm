# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeComponent::Email;
use strict;
use Bivio::Base 'UI.FacadeComponent';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub format {
    my($self, $local_part_or_email, $req_or_facade) = @_;
    unless ($req_or_facade || ref($self)) {
	IO_Alert()->warn_deprecated('must pass req or facade');
	$req_or_facade = b_use('Agent.Request')->get_current;
    }
    return shift->internal_get_self(pop(@_))->format(@_)
	unless ref($self);
    return $local_part_or_email =~ /\@/ ? $local_part_or_email
	: ($local_part_or_email
	. '@' . $self->get_facade->get_value('mail_host'));
}

sub internal_initialize_value {
    return;
}

1;