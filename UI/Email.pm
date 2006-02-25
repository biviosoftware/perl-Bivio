# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Email;
use strict;
use base 'Bivio::UI::FacadeComponent';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize_by_facade {
    return shift->new(@_);
}

sub format {
    my($self, $local_part_or_email, $req_or_facade) = @_;
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
