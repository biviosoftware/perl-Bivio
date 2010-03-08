# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Auth::Role;
use strict;
use Bivio::Base 'Type.EnumDelegator';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = b_use('Type.Array');
__PACKAGE__->compile;
my($_CACHE) = b_use('Collection.Attributes')->new;

sub get_category_role_group {
    my($proto, $which) = @_;
    return $_CACHE->get_if_exists_else_put($which => sub {
	return $which eq 'all' ? [$proto->get_non_zero_list]
	    : $_A->sort_unique([_group($proto, $which)]);
    });
}

sub get_overlap_count {
    return int(shift->get_non_zero_list / 2);
}

sub in_category_role_group {
    my($self, $which) = @_;
    return grep(
	$self->equals($_),
	@{$self->get_category_role_group($which)},
    ) ? 1 : 0;
}

sub is_continuous {
    return 0;
}

sub _group {
    my($proto, @which) = @_;
    return map(
	$_ =~ /[\-\+]/
	    ? _group_math($proto, $_)
	    : $_ =~ /^[a-z]/
	    ? _group($proto, @{_group_lookup($proto, $_)})
	    : $proto->from_any($_),
	@which,
    );
}

sub _group_lookup {
    my($proto, $which) = @_;
    return $proto->internal_category_role_group_map->{$which}
	|| b_die($which, ': unknown category group');
}

sub _group_math {
    my($proto, $math) = @_;
    my($res) = [];
    foreach my $op (split(/(?=[\-\+])/, $math)) {
	my($sign, $group) = $op =~ /^([\-\+]?)(.+)/;
	$sign ||= '+';
	$group = $proto->get_category_role_group($group);
	if ($sign eq '+') {
	    push(@$res, @$group);
	    next;
	}
	@$res = grep({
	    my($r) = $_;
	    !grep($r->equals($_), @$group);
	} @$res);
    }
    return @$res;
}

1;
