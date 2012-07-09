# Copyright (c) 2006-2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Class;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CL) = b_use('IO.ClassLoader');

sub USAGE {
    return <<'EOF';
usage: b-class [options] command [args..]
commands
  info class -- return information about the class
  name class -- return fully qualified name for class
  super class -- return the list of superclasses for given package
EOF
}

sub u_info {
    my($self, $class) = @_;
    return
	unless $_CL->unsafe_map_require($class);
    my($pkg) = _load($class);
    my($file) = "$pkg.pm";
    $file =~ s{::}{/}g;
    no strict 'refs';
    return ${\${$pkg . '::VERSION'}} . ' ' . $INC{$file};
}

sub u_name {
    my($self, $class) = @_;
    return _load($class);
}

sub u_super {
    my($self, $class) = @_;
    return _load($class)->inheritance_ancestors;
}

sub _load {
    my($class) = @_;
    return $_CL->map_require($class)
	if $_CL->is_valid_map_class_name($class);
    return $_CL->simple_require($class);
}

1;
