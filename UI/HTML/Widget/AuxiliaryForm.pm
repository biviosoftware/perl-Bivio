# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::AuxiliaryForm;
use strict;
use Bivio::Base 'HTMLWidget.Form';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub control_off_render {
    my($self, $source) = @_;
    $self->get('form_class')->new($source->req)->process;
    return shift->SUPER::control_on_render(@_);
}

sub initialize {
    my($self) = @_;
    return shift->call_super_before(\@_, sub {
	my($self) = @_;
	$self->put_unless_exists(control => sub {
	    return ['->ureq', $self->get('form_class')];
	});
	return;
    });
}

1;
