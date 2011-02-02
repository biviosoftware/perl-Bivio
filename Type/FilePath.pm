# Copyright (c) 2005-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::FilePath;
use strict;
use Bivio::Base 'Type.Line';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub ABSOLUTE_REGEX {
    return qr{^/};
}

sub ILLEGAL_CHAR_REGEXP {
    return qr{(?:^|/)\.\.?$|[\\\:*?"<>\|\0-\037\177]};
}

sub BLOG_FOLDER {
    return '/Blog';
}

sub ERROR {
    return Bivio::TypeError->FILE_PATH;
}

sub IMAGE_FOLDER {
    return '/Image';
}

sub MAIL_FOLDER {
    return '/Mail';
}

sub PATH_REGEX {
    return shift->REGEX;
}

sub PRIVATE_FOLDER {
    return '';
}

sub PUBLIC_FOLDER {
    my($proto) = @_;
    return $proto->join($proto->PUBLIC_FOLDER_ROOT, $proto->PRIVATE_FOLDER);
}

sub PUBLIC_FOLDER_ROOT {
    return '/Public';
}

sub REGEX {
    return qr{(.+)};
}

sub SETTINGS_FOLDER {
    return '/Settings';
}

sub VERSION_REGEX {
    return qr{;\d+(\.\d+)?};
}

sub VERSIONS_FOLDER {
    return '/Archived';
}

sub WIKI_DATA_FOLDER {
    return '/WikiData';
}

sub WIKI_FOLDER {
    return '/Wiki';
}

sub add_trailing_slash {
    my(undef, $path) = @_;
    return $path =~ m,/$, ? $path : $path.'/';
}

sub delete_suffix {
    my(undef, $value) = @_;
    return $value && $value =~ m{(.+)\.[^\.]+$} ? $1 : $value;
}

sub from_literal {
    my($proto, $value) = @_;
    my($v, $e) = $proto->SUPER::from_literal($value);
    return ($v, $e)
	unless defined($v);
    $v =~ s{^\s+|\s+$}{}g;
    return (undef, undef)
	unless length($v);
    return (undef, $proto->ERROR)
	if $v =~ $proto->ILLEGAL_CHAR_REGEXP;
    $v =~ s{(?=^[^/])|/+}{/}g;
    $v =~ s{(?<=[^/])/$}{};
    return $v;
}

sub from_public {
    my($proto, $path) = @_;
    return '/'
	unless defined($path);
    my($v) = $proto->VERSIONS_FOLDER;
    my($p) = $proto->PUBLIC_FOLDER_ROOT;
    $path =~ s{^((?:\Q$v\E)?)\Q$p\E(/|$)}{$1$2}i;
    return length($path) ? $path : '/';
}

sub get_base {
    my($proto, $value) = @_;
    $value = $proto->get_tail($value);
    return $value
	if $value =~ /^\.+[^\.]*$/;
    $value =~ s/\.[^\.]+$//;
    return $value;
}

sub get_clean_base {
    my($proto, $value) = @_;
    return _clean($proto, $proto->get_base($value));
}

sub get_clean_tail {
    my($proto, $value) = @_;
    return _clean($proto, $proto->get_tail($value));
}

sub get_component_width {
    return shift->SUPER::get_width;
}

sub get_suffix {
    my($proto, $value) = @_;
    return $value && $value =~ m{[^\./\\:]\.([^\./\\:]+)$} ? $1 : '';
}

sub get_tail {
    my(undef, $value) = @_;
    return ''
	unless defined($value);
    $value =~ s{[:\/\\]+$}{};
    $value =~ s{.*[:\/\\]}{};
    return $value;
}

sub get_versionless_tail {
    my($proto, $value) = @_;
    $value = $proto->get_tail($value);
    $value =~ s{@{[$proto->VERSION_REGEX]}}{};
    return $value;
}

sub get_width {
    return 500;
}

sub join {
    my($proto, @parts) = @_;
    (my $res = join('/', map(defined($_) && length($_) ? $_ : (), @parts)))
	 =~ s{//+}{/}sg;
    return $res;
}

sub is_absolute {
    my($proto, $value) = @_;
    return defined($value) && $value =~ $proto->ABSOLUTE_REGEX ? 1 : 0;
}

sub is_public {
    my($proto, $value) = @_;
    return ($value || '') =~ m{^\Q@{[$proto->PUBLIC_FOLDER]}\E(?:/|$)}i ? 1 : 0;
}

sub to_absolute {
    my($proto, $value, $is_public) = @_;
    return $proto->join(
	$value && $value =~ $proto->VERSION_REGEX
	    ? $proto->VERSIONS_FOLDER : '',
	$is_public ? $proto->PUBLIC_FOLDER : $proto->PRIVATE_FOLDER,
	$value,
    );
}

sub to_public {
    my($proto, $path) = @_;
    my($p) = $proto->PUBLIC_FOLDER_ROOT;
    my($v) = $proto->VERSIONS_FOLDER;
    return $p
	unless defined($path);
    if ($path =~ /^\Q$v\E/) {
	$path =~ s{^\Q$v\E}{$v$p}i;
    }
    else {
	$path = $proto->join($p, $path);
	$path =~ s{^\Q$p$p\E(/|$)}{$p$1}i;
    }
    return $path;
}

sub _clean {
    my($proto, $value) = @_;
    $value =~ s/^\W+|\W+$//g;
    $value =~ s/[^\w\.]+/-/g;
    my($n) = $proto->get_component_width - 6;
    return length($value) > $n ? substr($value, 0, $n)
	: length($value) ? $value : undef;
}

1;
