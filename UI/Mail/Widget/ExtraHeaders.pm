# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Mail::Widget::ExtraHeaders;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    my($values) = $self->get('values');
    while (my($k, $v) = each(%$values)) {
	$self->initialize_value($k, $v);
    }
    return;
}

sub internal_new_args {
    shift;
    return {
	values => {@_},
    };
}

sub mail_headers {
    my($self, $req) = @_;
    my($values) = $self->get('values');
    return [
	map({
	    my($v) = $self->render_simple_value($values->{$_}, $req);
	    length($v) ? [$_ => $v] : ();
	} sort {lc($a) cmp lc($b)} keys(%$values)),
    ];
}

sub render {
    my($self, $source, $buffer) = @_;
    # for testing only
    $$buffer .= join(
	'',
	map("$_->[0]: $_->[1]\n", @{$self->mail_headers($source)}));
    return;
}

1;
