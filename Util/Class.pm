# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Class;
use strict;
use base 'Bivio::ShellUtil';
use Bivio::UI::Facade;
use Bivio::Agent::TaskId;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub USAGE {
    return <<'EOF';
usage: b-class [options] command [args..]
commands
  info class -- return information about the class
  qualified_name class -- return fully qualified name for class
  super package -- return the list of superclasses for given package
EOF
}

sub info {
    my($self, $class) = @_;
    return
	unless my $pkg = Bivio::IO::ClassLoader->unsafe_map_require($class);
    my($file) = "$pkg.pm";
    $file =~ s{::}{/}g;
    no strict 'refs';
    return ${\${$pkg . '::VERSION'}} . ' ' . $INC{$file};
}

sub qualified_name {
    my($self, $name) = @_;
    return $self->use($name);
}

sub super {
    my($self, $package) = @_;
    return $self->use($package)->inheritance_ancestors;
}

1;
