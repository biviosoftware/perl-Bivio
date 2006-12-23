# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$

# introspection helpers for bOP

package Bivio::Util::Class;
use strict;
use base 'Bivio::ShellUtil';
use Bivio::UI::Facade;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-class [options] command [args..]
commands
  super package -- return the list of superclasses for given package
  task key -- return the TaskId from the given string based on Facade.Text map
EOF
}

sub super {
    my($self, $package) = @_;
    return $self->model($package)->inheritance_ancestor_list;
}

sub task {
    my($self, $text) = @_;
    my($req) = $self->get_request;
    $req->initialize_fully;
    #TODO: BAD PROGRAMMER!  No hacking the internal data structures!
    my($map) = $req->get_nested(qw(Bivio::UI::Facade Text))->[1]->{map};
    return [map(@{$map->{$_}->{names}},
		grep({
		    defined($map->{$_})
			&& lc($map->{$_}->{value}) eq lc($text)
		} keys(%$map)))];
}

1;
