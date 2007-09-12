# Copyright (c) 2000-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FileName;
use strict;
use Bivio::Base 'Type.FilePath';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ERROR {
    return Bivio::TypeError->FILE_NAME;
}

sub ILLEGAL_CHAR_REGEXP {
    return qr{^\.\.?$|[\\/:*?"<>|\0-\037\177]};
}

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless defined($v);
    $v =~ s{^/}{};
    return length($v) ? $v : (undef, undef);
}

sub get_width {
    return shift->get_component_width;
}

1;
