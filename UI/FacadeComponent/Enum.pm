# Copyright (c) 2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeComponent::Enum;
use strict;
use Bivio::Base 'FacadeComponent.Text';
b_use('IO.ClassLoaderAUTOLOAD');

my($_DESC_PREFIX) = '_desc';

sub make_facade_decl {
    my($proto, $items) = @_;
    my($map);
    my($enum);
    my($desc) = [];
    return ($proto->simple_package_name => [
        @{$proto->map_by_two(
            sub {
                my($k, $v) = @_;
                $map = $k;
                return ($map => $proto->map_by_two(
                    sub {
                        my($t, $list) = @_;
                        $enum = b_use($map, $t);
                        return (
                            $t => _list_to_tags($proto, $enum, $list, $desc),
                        );
                    },
                    $v,
                ));
            },
            $items,
        )},
        @$desc,
    ]);
}

sub unsafe_desc_from_enum {
    my($self, $enum, $which) = @_;
    return $self->unsafe_get_value(
        $enum->as_classloader_map_name,
        $enum->as_facade_text_tag,
        $which,
    );
}

sub unsafe_enum_from_desc {
    my($self, $class, $desc) = @_;
    _format_desc(\$desc);
    my($v);
    return $class->from_name($v)
        if $v = $self->unsafe_get_value(
            $_DESC_PREFIX, $class->as_classloader_map_name, $desc);
    return undef;
}

sub _enum_to_desc_tag {
    my($proto, $enum, $desc) = @_;
    _format_desc(\$desc);
    return $proto->join_tag(
        $_DESC_PREFIX, $enum->as_classloader_map_name, $desc);
}

sub _format_desc {
    my($desc) = @_;
    $$desc =~ s/\W/_/g;
    $$desc = uc($$desc);
    return;
}

sub _list_to_tags {
    my($proto, $enum, $list, $desc) = @_;
    return [map({
        my($name, $short_desc, $long_desc) = @$_;
        push(
            @$desc,
            [_enum_to_desc_tag($proto, $enum, $short_desc) => $name],
            $long_desc
                ? [_enum_to_desc_tag($proto, $enum, $long_desc) => $name]
                : (),
        );
        ($name => [
            short_desc => $short_desc,
            long_desc => defined($long_desc) ? $long_desc : $short_desc,
        ]);
    } @$list)];
}

1;
