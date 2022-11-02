# Copyright (c) 2006-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::DocletFileName;
use strict;
use Bivio::Base 'Type.FilePath';


sub ABSOLUTE_REGEX {
    my($proto) = @_;
    return qr{^@{[$proto->join(
        '(?:' . join('|', map($proto->to_absolute(undef, $_), 0, 1)) . ')',
        $proto->PATH_REGEX,
    )]}$}is;
}

sub SQL_LIKE_BASE {
    return '%';
}

sub from_absolute {
    my($proto, $path) = @_;
    b_die($path, ': not an absolute path')
        unless my(@x) = ($path || '') =~ m{@{[$proto->ABSOLUTE_REGEX]}};
    return join('', @x);
}

sub from_literal {
    my($proto, $value) = @_;
    return (undef, undef)
        unless defined($value) && length($value);
    $value = $proto->from_literal_stripper($value);
    return (undef, $proto->ERROR)
        unless length($value);
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
        unless defined($v);
    $v =~ s{^/}{};
    return $v =~ m{^@{[$proto->REGEX]}$}s ? $v : (undef, $proto->ERROR);
}

sub from_literal_stripper {
    return $_[1];
}

sub is_ignored_value {
    my($proto, $value) = @_;
    return defined($value) && $value =~ qr{(?:^|/)\.|(?:\.bak|\~)$}si ? 1 : 0;
}

sub is_valid {
    my($proto, $value) = @_;
    return defined($value) && $value =~ qr{^@{[$proto->REGEX]}$} ? 1 : 0;
}

sub public_path_info {
    my($proto, $value) = @_;
    return $value
        unless $value;
    $value =~ s{^\Q@{[$proto->PUBLIC_FOLDER_ROOT]}\E}{}i;
    return $value;
}

sub to_sql_like_path {
    my($proto, $is_public) = @_;
    return lc($proto->to_absolute($proto->SQL_LIKE_BASE, $is_public));
}

sub uri_hash_for_realm_and_path {
    my($self, $realm_name, $realm_file_path) = @_;
    return {
        task_id => b_use('UI.Facade')
            ->get_from_source($self->req)
            ->is_site_realm_name($realm_name)
                ? 'SITE_WIKI_VIEW'
                : 'FORUM_WIKI_VIEW',
        realm => $realm_name,
        query => undef,
        path_info => $self->from_absolute($realm_file_path),
    };
}

1;
