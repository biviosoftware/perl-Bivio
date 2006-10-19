# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::StringArray;
use strict;
use base 'Bivio::Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub compare_defined {
    my($proto, $left, $right) = @_;
    $left = _clean_copy($left);
    $right = _clean_copy($right);
    foreach my $i (0 .. ($#$left < $#$right ? $#$left : $#$right)) {
	my($x) = $left->[$i] cmp $right->[$i];
	return $x
	    if $x;
    }
    return @$left <=> @$right;
}

sub from_literal {
    my($proto, $value) = @_;
    return (undef, undef)
	unless defined($value);
    $value =~ s/^\s+|\s+$//g
	if defined($value);
    return (undef, undef)
	unless length($value);
    my($sep) = $value =~ /$;/ ? $; : ',';
    return [split(/\s*$sep\s*/, $value)];
}

sub from_sql_column {
    my(undef, $param) = @_;
    return defined($param) ? _clean_copy([split(/$;/, $param)]) : undef;
}

sub get_width {
    return 4000;
}

sub to_literal {
    my(undef, $value) = @_;
    return join(', ', @{_clean_copy($value, ',') || []});
}

sub to_sql_param {
    my(undef, $param_value) = @_;
    return join($;, @{_clean_copy($param_value) || return undef});
}

sub to_string {
    my(undef, $value) = @_;
    # Different than to_literal so we can print arrays during debugging
    return '[' . join(',', @{_clean_copy($value) || []}) . ']';
}

sub _clean_copy {
    my($value, $sep) = @_;
    $sep ||= "$;";
    return undef
	unless defined($value);
    my($copy) = [map({
	$_ =~ s/^\s+|\s+$//gs
	    if defined($_);
	defined($_) && length($_) ? $_ : '';
    } @$value)];
    pop(@$copy)
	while @$copy && !length($copy->[$#$copy]);
    Bivio::Die->die($copy, ": separator ($sep) in element")
        if grep(/$sep/, @$copy);
    return @$copy ? $copy : undef;
}

1;
