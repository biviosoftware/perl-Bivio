# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Icon;

use strict;

my($_HOME) = '/i/';
my($_SUFFIX) = '.gif';

BEGIN {
    use Bivio::Util;
    &Bivio::Util::compile_attribute_accessors([qw(width height uri)],
					      'no_set');
}

sub lookup ($$$) {
    my($proto, $name, $br) = @_;
    # Always is found
    return &Bivio::Data::lookup($_HOME . $name . $_SUFFIX, $proto,
				     $br, &Bivio::Data::GIF_INFO);
}

sub init ($$$) {
    my($proto, $self, $br) = @_;
    bless($self, ref($proto) || $proto);
    $self->{img} = qq{<img src="$self->{uri}" height=$self->{height}}
	. " width=$self->{width} border=0";
    return $self;
}

sub img ($$$) {
    my($self, $alt, $options) = @_;
    my($res) = $self->{img};
    defined($alt) && ($res .= ' alt="' . $alt . '"');
    defined($options) && ($res .= ' ' . $options);
    return $res . '>';
}

1;
__END__

=head1 NAME

Bivio::Icon - Icon cache

=head1 SYNOPSIS

    use Bivio::Icon;

=head1 DESCRIPTION

=head1 AUTHOR

Rob Nagler <nagler@bivio.com>

=head1 SEE ALSO

=cut
