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

L<Bivio::UI::FacadeComponent>

=cut

use Bivio::UI::FacadeComponent;
@Bivio::UI::Icon::ISA = ('Bivio::UI::FacadeComponent');

=head1 DESCRIPTION

C<Bivio::UI::Icon> looks up icons by name.  They do not have
suffixes, i.e. you give the root name and they can only match
one file (root.jpg, root.gif, etc.).

Icons are dynamic.
Typically, you will supply their name to the I<src> attribute of
L<Bivio::UI::HTML::Widget::Image|Bivio::UI::HTML::Widget::Image>.
See also
L<Bivio::UI::HTML::Widget::ClearDot|Bivio::UI::HTML::Widget::ClearDot>.

There are two retrieval methods:  L<get_value|"get_value"> and
L<format_html|"format_html">.

There is no Facade configuration.  All images are stored in the
root icon directory or sub-directories identified by the
Facade I<uri>.

=cut

=head1 CONSTANTS

=cut

=for html <a name="UNDEF_CONFIG"></a>

=head2 UNDEF_CONFIG : array_ref

Returns config for missing-image.

=cut

sub UNDEF_CONFIG {
    return '';
}

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;
use Bivio::IO::Alert;
use Bivio::IO::Config;
use Bivio::IO::Trace;
use Bivio::UI::Facade;
use Image::Size ();

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_DIR);
my($_URI);
my($_CLEAR_DOT) = {
    uri => '/i/dot.gif',
    height => 1,
    width => 1,
};
my($_MISSING) = '/missing-image';
Bivio::IO::Config->register({
    'uri' => Bivio::IO::Config->REQUIRED,
    'directory' => Bivio::IO::Config->REQUIRED,
    'missing_uri' => $_MISSING,
    'clear_dot_uri' => $_CLEAR_DOT->{uri},
});
# We keep a cache of all values, because FacadeComponent's don't share
# information--avoids bugs when there are dependencies.  In this case,
# we cache to avoid repeating not-found errors for each icon and for
# performance (avoids (N-1)xM file reads).
my(%_CACHE);

=head1 METHODS

=cut

=for html <a name="format_html"></a>

=head2 static format_html(string name, Bivio::Collection::Attributes req_or_facade) : string

=head2 format_html(string name) : string

Returns the image formated for an an C<IMG> tag, e.g.

     src="uri" width=W height=H

Value contains a I<leading space>.

=cut

sub format_html {
    return shift->internal_get_value(@_)->{html};
}

=for html <a name="get_clear_dot"></a>

=head2 get_clear_dot() : hash_ref

Please use
L<Bivio::UI::HTML::Widget::vs_clear_dot|Bivio::UI::Widget/vs_"clear_dot">
or
L<Bivio::UI::HTML::Widget::vs_clear_dot_as_html|Bivio::UI::Widget/vs_"clear_dot_as_html">
to get a clear dot of arbitrary width/height.

Returns single pixel transparent gif.  Value must be treated as
read-only and is constant.

=cut

sub get_clear_dot {
    return $_CLEAR_DOT;
}

=head2 static get_height(string name, Bivio::Collection::Attributes req_or_facade) : int

=head2 get_height(string name) : int

Returns the height of the icon.

=cut

sub get_height {
    return shift->internal_get_value(@_)->{value}->{height};
}

=head2 static get_height_as_html(string name, Bivio::Collection::Attributes req_or_facade) : string

=head2 get_height_as_html(string name) : string

Returns the height of the icon in the form of an " height=N" attribute
to an HTML tag.

=cut

sub get_height_as_html {
    return ' height='.shift->internal_get_value(@_)->{value}->{height};
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
    return shift->internal_get_value(@_)->{value};
}

=head2 static get_width(string name, Bivio::Collection::Attributes req_or_facade) : int

=head2 get_width(string name) : int

Returns the width of the icon.

=cut

sub get_width {
    return shift->internal_get_value(@_)->{value}->{width};
}

=head2 static get_width_as_html(string name, Bivio::Collection::Attributes req_or_facade) : string

=head2 get_width_as_html(string name) : string

Returns the width of the icon in the form of an " width=N" attribute
to an HTML tag.

=cut

sub get_width_as_html {
    return ' width='.shift->internal_get_value(@_)->{value}->{width};
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item clear_dot_uri : string [/i/dot.gif]

URI of single pixel transparent gif.
See L<get_clear_dot|"get_clear_dot">.

=item directory : string (required)

Directory in which icons reside.

=item missing_uri : string [/missing-image]

URI to be used when an icon could not be found.

=item uri : string (required)

URI prefix for icons.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_URI = $cfg->{uri};
    Bivio::IO::Alert->warn("$_URI: is not absolute") unless $_URI =~ m!^/!;
    $_URI =~ s!([^/])$!$1/!;
    $_DIR = $cfg->{directory};
    Bivio::IO::Alert->warn("$_DIR: not a directory") unless -d $_DIR;
    $_DIR =~ s!([^/])$!$1/!;
    $_MISSING = $cfg->{missing_uri};
    $_CLEAR_DOT->{uri} = $cfg->{clear_dot_uri};
    return;
}

=for html <a name="handle_register"></a>

=head2 static handle_register()

Registers with Facade.

=cut

sub handle_register {
    my($proto) = @_;
    Bivio::UI::Facade->register($proto);
    return;
}

=for html <a name="initialization_complete"></a>

=head2 initialization_complete()

Does the initialization from the Facade's URI.

=cut

sub initialization_complete {
    my($self) = @_;
    my(%map);

    # First find all the files by searching "root" directory then
    # facade sub directory.
    foreach my $subdir ('', $self->get_facade->get('uri')) {
	my($d) = $subdir ? $_DIR.'/'.$subdir : $_DIR;
	unless (opendir(IN, $d)) {
	    _trace($d, ": opendir($d): $! (OK to not be found)")
		    if $_TRACE;
	    next;
	}

	# Only look for names that have suffixes and avoid dot files.
	my($prefix) = $subdir ? $subdir.'/' : '';
	foreach my $file (grep(/[^\.].*\.\w+$/, readdir(IN))) {
	    my($name) = $file;
	    $name =~ s/\.\w+$//;
	    $map{$name} = $prefix.$file;
	}
    }
    close(IN);

    # Initialize each file.  If we can't get the image, print a
    # warning.  Only reinitialize those images with different config,
    # i.e. different file names.
    while (my($name, $file) = each(%map)) {
	my($v) = $self->internal_unsafe_get_value($name);
	unless (defined($v)) {
	    $self->group($name, $file);
	}
	elsif ($v->{config} ne $file) {
	    $self->regroup($name, $file);
	}
    }
    $self->SUPER::initialization_complete();
    return;
}

=for html <a name="internal_initialize_value"></a>

=head2 internal_initialize_value(hash_ref value)

Initializes the internal value from the configuration.

=cut

sub internal_initialize_value {
    my($self, $value) = @_;
    my($file) = $value->{config};

    my($f) = $_DIR.'/'.$file;
    if ($file ne UNDEF_CONFIG()) {

	# Is it in the cache?
	if ($_CACHE{$f}) {
	    my($cv) = $_CACHE{$f};
	    $value->{value} = $cv->{value};
	    $value->{html} = $cv->{html};
	    return;
	}

	# Try to read the file
	my($w, $h, $err) = Image::Size::imgsize($f);
	if (defined($w)) {
	    # Valid image.  Save values.
	    my($u) = $_URI.$file;
	    $value->{value} = {
		uri => $u,
		width => $w,
		height => $h,
	    };
	    $value->{html} = qq! src="$u" width=$w height=$h!;
	    $_CACHE{$f} = {%{$value}};
	    return;
	}

	# Let 'em know and then put undef in the table.
	$self->bad_value($value, 'Image::Size error: ', $err);
    }

    # Invalid or UNDEF_CONFIG
    $value->{value} = {
	uri => $_MISSING,
	width => 1,
	height => 1,
    };
    $value->{html} = qq! src="$_MISSING" width=1 height=1!;

    # We cache misses to avoid lots of noise
    $_CACHE{$f} = {%{$value}};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999,2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
