# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::FacadeComponent::Icon;
use strict;
use Bivio::Base 'UI.FacadeComponent';
use Image::Size ();
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_HTML) = b_use('Bivio.HTML');
my($_URI) = '/i';
my($_CLEAR_DOT) = {
    uri => '/i/dot.gif',
    height => 1,
    width => 1,
};
my($_FILE_SUFFIX_REGEXP);
my($_MISSING) = '/missing-image';
my($_FILE_SUFFIX_SEARCH_LIST) = ['.gif', '.jpg', '.jpeg', '.png'];
$_FILE_SUFFIX_REGEXP = qr{
    \.(?:@{[join('|', map(substr($_, 1), @$_FILE_SUFFIX_SEARCH_LIST))]})$
}ix;
Bivio::IO::Config->register({
    uri => $_URI,
    missing_uri => $_MISSING,
    clear_dot_uri => $_CLEAR_DOT->{uri},
    file_suffix_search_list => $_FILE_SUFFIX_SEARCH_LIST,
});
# We keep a cache of all values if Facade.want_local_file_cache is true. In
# this case, we cache to avoid repeating not-found errors for each icon and for
# performance (avoids (N-1)xM file reads).
my($_CACHE) = {};

sub FILE_SUFFIX_REGEXP {
    # : regexp_ref
    # Returns regular expression used for file suffixes
    return $_FILE_SUFFIX_REGEXP;
}

sub UNDEF_VALUE {
    return {
	file_name => $_MISSING,
	uri => $_MISSING,
	width => 1,
	height => 1,
	mtime => 0,
    };
}

sub format_css {
    my($proto, $name, $attr, $req) = @_;
    ($req, $attr) = ($attr, undef)
	if !$req && ref($attr);
    my($v) = _find($proto, $name, $req)->{value};
    $attr ||= 'uri';
    return $attr eq 'uri' ? 'url(' . $v->{uri} . ')'
	: defined($v->{$attr}) ? $v->{$attr}
        : $proto->die($v, $attr, ': no such attribute');
}

sub format_html {
    # (proto, string, Collection.Attributes) : string
    # Returns the image formated for an an C<IMG> tag, e.g.
    #
    #      src="uri" width="W" height="H"
    #
    # Value contains a I<leading space>.
    return _find(@_)->{html};
}

sub format_html_attribute {
    # (proto, string, string, Collection.Attributes) : string
    # Formats tag, e.g. background as in:
    #
    #      background="uri"
    #
    # Value contains a I<leading space>.
    my($proto, $name, $attribute, $req_or_facade) = @_;
    return qq{ $attribute=}
	. _html_attr(uri => $proto, $name, $req_or_facade);
}

sub get_clear_dot {
    # (proto) : hash_ref
    # Please use L<Bivio::UI::HTML::Widget::ClearDot|Bivio::UI::HTML::Widget::ClearDot>.
    #
    # Returns single pixel transparent gif.  Value should be treated as
    # read-only and is constant.
    # Make a copy just in case
    return {%$_CLEAR_DOT};
}

sub get_favicon_uri {
    my($proto, $req) = @_;
    my($uri) = FacadeComponent_Text()->get_value('favicon_uri', $req);
    return Type_CacheTagFilePath()->from_local_path(
	$req->req('UI.Facade')->get_local_plain_file_name($uri), $uri);
}

sub get_height {
    # (proto, string, Collection.Attributes) : int
    # Returns the height of the icon.
    return _find(@_)->{value}->{height};
}

sub get_height_as_html {
    # (proto, string, Collection.Attributes) : string
    # Returns the height of the icon in the form of an " height=N" attribute
    # to an HTML tag.
    return ' height=' . _html_attr(height => @_);
}

sub get_icon_dir {
    my($self) = @_;
    return _facade_name($self, '');
}

sub get_uri {
    return shift->internal_uri(@_);
}

sub get_value {
    # (proto, string, Collection.Attributes) : hash_ref
    # (self, string) : hash_ref
    # The return value should be treated as read-only.  The result contains
    # the following keys:
    #
    #
    # height : int
    #
    # The height of the image.
    #
    # uri : string
    #
    # The absolute uri (/i/...) of the image.
    #
    # width : int
    #
    # The width of the image.
    # Make a copy for safety reasons
    return {%{_find(@_)->{value}}};
}

sub get_width {
    # (proto, string, Collection.Attributes) : int
    # Returns the width of the icon.
    return _find(@_)->{value}->{width};
}

sub get_width_as_html {
    # (proto, string, Collection.Attributes) : string
    # Returns the width of the icon in the form of an " width=N" attribute
    # to an HTML tag.
    return ' width=' . _html_attr(width => @_);
}

sub handle_config {
    # (proto, hash) : undef
    # clear_dot_uri : string [/i/dot.gif]
    #
    # URI of single pixel transparent gif.
    # See L<get_clear_dot|"get_clear_dot">.
    #
    # file_suffix_search_list : array_ref [['.gif', '.jpg', '.jpeg', '.png']]
    #
    # Ordered list of file suffices to search for when trying to find an icon.
    # Two icons cannot share the same base name, e.g. only one of
    # my_icon.gif and my_icon.jpg will be found when looking for I<my_icon>.
    #
    # missing_uri : string [/missing-image]
    #
    # URI to be used when an icon could not be found.
    #
    # uri : string [/i]
    #
    # URI prefix for icons.  The uniquely short name allows for simple
    # configuration of URI-based front-end icon serving.
    my(undef, $cfg) = @_;
    $_URI = $cfg->{uri};
    Bivio::IO::Alert->warn("$_URI: is not absolute") unless $_URI =~ m!^/!;
    $_URI =~ s!([^/])$!$1/!;
    $_MISSING = $cfg->{missing_uri};
    $_CLEAR_DOT->{uri} = $cfg->{clear_dot_uri};
    $_FILE_SUFFIX_SEARCH_LIST = [map(
	$_ =~ /^\w+$/ ? ".$_"
	    : $_ =~ /^\.\w+$/
	    ? $_
	    : b_die($_, ': bad file_suffix_search_list value (not a word)'),
        @{$cfg->{file_suffix_search_list}},
    )];
    return;
}

sub internal_cache_key {
    return _facade_name(@_);
}

sub internal_file_name {
    my($name) =  _facade_name(@_);
    foreach my $suffix (@$_FILE_SUFFIX_SEARCH_LIST) {
	my($f) = $name . $suffix;
	return $f
	    if -r $f;
    }
    return undef;
}

sub internal_initialize_value {
    my($self, $value) = @_;
    my($v) = $value->{config};
    $value->{value} = defined($v)
	? b_die($value, ': configuration not allowed')
	: $self->UNDEF_VALUE;
    return;
}

sub internal_uri {
    my($file_name) = shift->internal_file_name(@_);
    $file_name = Type_CacheTagFilePath()->from_local_path($file_name);
    return $file_name =~ m{([^/]+)$} ? "$_URI$1" : $_MISSING;
}

sub _facade_name {
    my($self, $name) = @_;
    return $self->get_facade->get_local_plain_file_name("$_URI$name");
}

sub _find {
    # (proto, string, Collection.Attributes) : hash_ref
    # Returns the value hash_ref
    my($proto, $name, $req_or_facade) = @_;
    my($self) = $proto->internal_get_self($req_or_facade);
    my($facade) = $self->get_facade;
    my($key) = $self->internal_cache_key($name);
    my($cache) = $facade->get('want_local_file_cache');
    if ($cache &&= $_CACHE->{$key}) {
	return $cache
	    if (-M $cache->{file_name} || 0) == $cache->{mtime};
	delete($_CACHE->{$key});
	$cache = 1;
    }
    my($file) = $self->internal_file_name($name);
    my($w, $h, $err) = $file ? Image::Size::imgsize($file) : ();
    my($u);
    unless (defined($w)) {
	Bivio::IO::Alert->warn(
	    $facade, '.Icon.', $name,
	    ($err ? (': Image::Size error: ', $err) : ': not found'),
	);
	$w = $h = 1;
	$file = $_MISSING;
	$u = $_MISSING;
    }
    my($v) = {
	file_name => $file,
	uri => $u || $self->internal_uri($name),
	width => $w,
	height => $h,
	mtime => -M $file || 0,
    };
    my($value) = {
	value => $v,
	html => qq{ src="@{[$_HTML->escape_attr_value($v->{uri})]}" width="$w" height="$h"},
    };
    $_CACHE->{$key} = $value
	if $cache;
    return $value;
}

sub _html_attr {
    my($which) = shift;
    return '"' . $_HTML->escape_attr_value(_find(@_)->{value}->{$which}) . '"';
}

1;
