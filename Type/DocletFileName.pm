# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DocletFileName;
use strict;
use base 'Bivio::Type::FileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub BLOG_FOLDER {
    return '/Blog';
}

sub MAIL_FOLDER {
    return '/Mail';
}

sub PATH_REGEX {
    return shift->REGEX;
}

sub PUBLIC_FOLDER {
    my($proto) = @_;
    return $proto->join($proto->PUBLIC_FOLDER_ROOT, $proto->PRIVATE_FOLDER);
}

sub PUBLIC_FOLDER_ROOT {
    return '/Public';
}

sub WIKI_FOLDER {
    return '/Wiki';
}

sub is_absolute {
    my($proto, $value) = @_;
    return $value =~ m{^@{[$proto->join(
        '(?:' . join('|', map($proto->to_absolute(undef, $_), 0, 1)) . ')',
	$proto->PATH_REGEX,
    )]}$}isx ? 1 : 0;
}

sub is_valid {
    my($proto, $value) = @_;
    return defined($value) && $value =~ qr{^@{[$proto->REGEX]}$} ? 1 : 0;
}

sub to_absolute {
    my($proto, $value, $is_public) = @_;
    return $proto->join(
	$is_public ? $proto->PUBLIC_FOLDER : $proto->PRIVATE_FOLDER,
	$value,
    );
}

sub to_sql_like_path {
    my($proto, $is_public) = @_;
    return lc($proto->to_absolute('_' x $proto->get_width, $is_public));
}

1;
