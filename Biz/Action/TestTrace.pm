# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::TestTrace;
use strict;
use Bivio::Base 'Biz.Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PN) = __PACKAGE__->use('Type.PerlName');
my($_T) = __PACKAGE__->use('IO.Trace');
my($_A) = __PACKAGE__->use('IO.Alert');

sub execute {
    my($proto, $req) = @_;
    if (my $n = $_PN->unsafe_from_path_info($req)) {
	$_T->set_named_filters($n);
	$_A->info($n);
    }
    else {
	$_T->set_filters;
	$_A->info('<off>');
    }
    return 0;
}

1;
