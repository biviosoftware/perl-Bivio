# Copyright (c) 2000-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Ext::HTTPCookies;
use strict;
use base 'HTTP::Cookies';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = Bivio::UNIVERSAL->use('IO.File');
my($_D) = Bivio::UNIVERSAL->use('Bivio.Die');

sub clone {
    my($self) = @_;
    my($tmp) = $_F->temp_file;
    my($clone);
    my($die) = $_D->catch(
	sub {
	    $self->save($tmp);
	    delete($self->{file});
	    $clone = ref($self)->new(
		map(
		    ($_ => $self->{$_}),
		    grep($_ ne 'COOKIES', keys(%$self)),
		),
	    );
	    $clone->load($tmp);
	    delete($clone->{file});
	    return;
	},
    );
    unlink($tmp);
    $die->throw
	if $die;
    return $clone;
}

1;