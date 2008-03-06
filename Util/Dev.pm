# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Dev;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-dev [options] command [args..]
commands
  project_aliases -- generate aliases for project Util commands
EOF
}

sub project_aliases {
    my($self) = @_;
    return join('', map({
	my($root, $prefix) = @$_;
	sort(map({
	    my($n) = $_ =~ m{([^/]+)$};
	    $n =~ /^[-\w]+$/s && ! -x (`which $n` =~ /^([^\n]+)/)[0]
		? "alias '$n=env BCONF=$ENV{HOME}/bconf/$prefix.bconf perl -w $_'\n"
		: ();
	} glob("$ENV{HOME}/src/perl/$root/Util/$prefix-*"))),
    } @{$self->new_other('Release')->list_projects}))
}

1;
