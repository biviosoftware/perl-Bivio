# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::PermissionSet;
use strict;
use Bivio::Base 'Type.EnumSet';
use Bivio::Auth::Permission;

# C<Bivio::Auth::PermissionSet> is the storage format for the
# task permissions.  Each element is a
# L<Bivio::Auth::Permission|Bivio::Auth::Permission>.
# A task may require more than one permission.
# See L<Bivio::Agent::Task|Bivio::Agent::Task> and
# L<Bivio::Auth::Realm|Bivio::Auth::Realm>
# for more details.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
__PACKAGE__->initialize();

sub clear {
    my($proto, $perm_set, @arg_bits) = @_;
    # Return a permission set with the specified bits cleared
    my(@bits) = map({ref($_)
        ? $_ : Bivio::Auth::Permission->from_literal($_)} @arg_bits);
    return ${Bivio::Type::EnumSet->clear(\$perm_set, @bits)};
}

sub get_enum_type {
    # Returns L<Bivio::Auth::Permission|Bivio::Auth::Permission>.
    return 'Bivio::Auth::Permission';
}

sub get_width {
    # Returns 15.  That's 120 permissions.
    return 15;
}

sub includes {
    my($proto, $perm_set, @perm_name) = @_;
    # Returns true if this permission set includes perm_name.

    foreach my $name (@perm_name) {
        return 1
            if $proto->is_set($perm_set, Bivio::Auth::Permission->$name());
    }
    return 0;
}

1;
