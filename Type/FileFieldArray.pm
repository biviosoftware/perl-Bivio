# Copyright (c) 2026 Bivio Software, Inc.  All Rights Reserved.
package Bivio::Type::FileFieldArray;
use strict;
use Bivio::Base 'Type.FileField';

# Values are array_refs of FileField hash_refs. Empty files are kept so the
# form can report each by name; validate them with FileField->from_literal.

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    my($res) = [];
    foreach my $v (ref($value) eq 'ARRAY' ? @$value : $value) {
        unless (ref($v) eq 'HASH') {
            my(undef, $err) = $proto->SUPER::from_literal($v);
            return (undef, $err)
                if $err;
            next;
        }
        return (undef, $v->{error})
            if $v->{error};
        push(@$res, $v)
            if length($v->{filename}) || length(${$v->{content}});
    }
    return int(@$res) ? $res : (undef, undef);
}

1;
