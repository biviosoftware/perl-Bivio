# Copyright (c) 1999,2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::Icon;
use strict;
$Bivio::UI::Icon::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Icon::VERSION;

=head1 NAME

Bivio::UI::Icon - returns widget image values

=head1 SYNOPSIS

    use Bivio::UI::Icon;

=cut

=head1 EXTENDS

L<Bivio::UI::WidgetValueSource>

=cut

use Bivio::UI::WidgetValueSource;
@Bivio::UI::Icon::ISA = ('Bivio::UI::WidgetValueSource');

=head1 DESCRIPTION

C<Bivio::UI::Icon> looks up icons by name.  They do not have
suffixes, i.e. you give the root name and they can only match
one file (root.jpg, root.gif, etc.).

Icons are dynamic.
Typically, you will supply their name to the I<src> attribute of
L<Bivio::UI::HTML::Widget::Image|Bivio::UI::HTML::Widget::Image>.
See also
L<Bivio::UI::HTML::Widget::ClearDot|Bivio::UI::HTML::Widget::ClearDot>.

There are several retrieval methods, but the main ones are
L<get_value|"get_value"> and L<format_html|"format_html">.

Bivio::UI::Icon is not a Facade component, but icons are facade-based.
Icons are found with
L<Bivio::UI::Facade::get_local_file_name|Bivio::UI::Facade/"get_local_file_name">
in the L<Bivio::UI::LocalFileType-E<gt>PLAIN|Bivio::UI::LocalFileType>

See L<handle_config|"handle_config"> for configuration values.

This class is initialized by L<Bivio::UI::Facade|Bivio::UI::Facade>.

=cut

#=IMPORTS
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::UI::Facade;
use Bivio::UI::LocalFileType;
use Image::Size ();
# Bivio::UI::Facade imports this class

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_URI) = '/i';
my($_CLEAR_DOT) = {
    uri => '/i/dot.gif',
    height => 1,
    width => 1,
};
my($_MISSING) = '/missing-image';
my($_FILE_SUFFIX_SEARCH_LIST) = ['.gif', '.jpg', '.jpeg'];
Bivio::IO::Config->register({
    uri => $_URI,
    missing_uri => $_MISSING,
    clear_dot_uri => $_CLEAR_DOT->{uri},
    file_suffix_search_list => $_FILE_SUFFIX_SEARCH_LIST,
});
# We keep a cache of all values if Facade.want_local_file_cache is true. In
# this case, we cache to avoid repeating not-found errors for each icon and for
# performance (avoids (N-1)xM file reads).
my(%_CACHE);

=head1 METHODS

=cut

=for html <a name="format_html"></a>

=head2 static format_html(string name, Bivio::Collection::Attributes req_or_facade) : string

Returns the image formated for an an C<IMG> tag, e.g.

     src="uri" width=W height=H

Value contains a I<leading space>.

=cut

sub format_html {
    return _find(@_)->{html};
}

=for html <a name="get_clear_dot"></a>

=head2 static get_clear_dot() : hash_ref

Please use L<Bivio::UI::HTML::Widget::ClearDot|Bivio::UI::HTML::Widget::ClearDot>.

Returns single pixel transparent gif.  Value should be treated as
read-only and is constant.

=cut

sub get_clear_dot {
    # Make a copy just in case
    return {%$_CLEAR_DOT};
}

=head2 static get_height(string name, Bivio::Collection::Attributes req_or_facade) : int

Returns the height of the icon.

=cut

sub get_height {
    return _find(@_)->{value}->{height};
}

=head2 static get_height_as_html(string name, Bivio::Collection::Attributes req_or_facade) : string

Returns the height of the icon in the form of an " height=N" attribute
to an HTML tag.

=cut

sub get_height_as_html {
    return ' height='._find(@_)->{value}->{height};
}

=for html <a name="get_value"></a>

=head2 static get_value(string name, Bivio::Collection::Attributes req_or_facade) : hash_ref

=head2 get_value(string name) : hash_ref

The return value should be treated as read-only.  The result contains
the following keys:

=over 4

=item height : int

The height of the image.

=item uri : string

The absolute uri (/i/...) of the image.

=item width : int

The width of the image.

=back

=cut

sub get_value {
    # Make a copy for safety reasons
    return {%{_find(@_)->{value}}};
}

=head2 static get_width(string name, Bivio::Collection::Attributes req_or_facade) : int

Returns the width of the icon.

=cut

sub get_width {
    return _find(@_)->{value}->{width};
}

=head2 static get_width_as_html(string name, Bivio::Collection::Attributes req_or_facade) : string

Returns the width of the icon in the form of an " width=N" attribute
to an HTML tag.

=cut

sub get_width_as_html {
    return ' width='._find(@_)->{value}->{width};
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item clear_dot_uri : string [/i/dot.gif]

URI of single pixel transparent gif.
See L<get_clear_dot|"get_clear_dot">.

=item file_suffix_search_list : array_ref [['.gif', '.jpg', '.jpeg']]

Ordered list of file suffices to search for when trying to find an icon.
Two icons cannot share the same base name, e.g. only one of
my_icon.gif and my_icon.jpg will be found when looking for I<my_icon>.

=item missing_uri : string [/missing-image]

URI to be used when an icon could not be found.

=item uri : string [/i]

URI prefix for icons.  The uniquely short name allows for simple
configuration of URI-based front-end icon serving.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_URI = $cfg->{uri};
    Bivio::IO::Alert->warn("$_URI: is not absolute") unless $_URI =~ m!^/!;
    $_URI =~ s!([^/])$!$1/!;
    $_MISSING = $cfg->{missing_uri};
    $_CLEAR_DOT->{uri} = $cfg->{clear_dot_uri};
    $_FILE_SUFFIX_SEARCH_LIST = [map {
	/^\w+$/ ? '.'.$_ : /^\.\w+$/ ? $_
		: Bivio::Die->die($_,
			': bad file_suffix_search_list value (not a word)');
    } @{$cfg->{file_suffix_search_list}}];
    return;
}

=for html <a name="initialize_by_facade"></a>

=head2 static initialize_by_facade(Bivio::UI::Facade facade)

Initializes all views in a facade, if caching turned on.

=cut

sub initialize_by_facade {
    my($proto, $facade) = @_;
    my($d) = $facade->get_local_file_name(
	    Bivio::UI::LocalFileType->PLAIN, $_URI);
    Bivio::Die->die($d, ": $!")
		unless opendir(IN, $d);
    foreach my $file (grep(/[^\.].*\.\w+$/, readdir(IN))) {
	# Only look up files which match search prefixes
	next unless $file =~ s/(\.\w+)$//
		&& grep($1 eq $_, @$_FILE_SUFFIX_SEARCH_LIST);
	_find($proto, $file, $facade);
    }
    return;
}

#=PRIVATE METHODS

# _find(proto, string name, Bivio::Collection::Attributes req_or_facade) : hash_ref
#
# Returns the value hash_ref
#
sub _find {
    my($proto, $name, $req_or_facade) = @_;
    my($facade) = Bivio::UI::Facade->get_from_request_or_self($req_or_facade);

    # NOTE: We cache without the suffix.
    my($file_name) = $facade->get_local_file_name(
	    Bivio::UI::LocalFileType->PLAIN, $_URI.$name);

    # Is it in the cache?
    my($cache) = $facade->get('want_local_file_cache');
    return $_CACHE{$file_name} if $cache && $_CACHE{$file_name};

    my($w, $h, $err);
    foreach my $suffix (@$_FILE_SUFFIX_SEARCH_LIST) {
	# Try to read the file
	my($f) = $file_name.$suffix;
	next unless -r $f;

	($w, $h, $err) = Image::Size::imgsize($f);
	next unless defined($w);

	# Valid image.  Save values.
	my($u) = $_URI.$name.$suffix;
	my($value) = {
	    value => {
		uri => $u,
		width => $w,
		height => $h,
	    },
	    html => qq! src="$u" width=$w height=$h!,
	};
	$_CACHE{$file_name} = $value if $cache;
	return $value;
    }

    # Some type of error
    Bivio::IO::Alert->warn(
	    $facade, '.Icon.', $name,
	    ($err ? (': Image::Size error: ', $err) : ': not found'));

    my($value) = {
	value => {
	    uri => $_MISSING,
	    width => 1,
	    height => 1,
	},
	html => qq! src="$_MISSING" width=1 height=1!,
    };

    # We cache misses to avoid lots of noise
    $_CACHE{$file_name} = $value if $cache;
    return $value;
}

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
