# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Icon;
use strict;
$Bivio::UI::Icon::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Icon - returns widget image values

=head1 SYNOPSIS

    use Bivio::UI::Icon;
    Bivio::UI::Icon->get_widget_value($name);

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::Icon::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::UI::Icon> looks up icons by name.  Currently, the name is
the root name of the file.  The C<.gif> is added on as well as
the (configured) directory name.  The icon's size is read and
a tuple (uri, size, width, is_constant) is returned as a
C<hash_ref> from L<get_widget_value|"get_widget_value">.

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;
use GD ();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_DIR);
my($_URI);
my($_MISSING);
my(%_CACHE) = ();
Bivio::IO::Config->register({
    'uri' => Bivio::IO::Config->REQUIRED,
    'directory' => Bivio::IO::Config->REQUIRED,
    'not_found_uri' => '/not_found',
});

=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 get_widget_value(string name) : hash_ref

=head2 get_widget_value(string name, string formatter, ...) : any

Returns the tuple (uri, width, height, is_constant).  I<height> and I<width>
can only be returned for gif images.  I<is_constant> will always be true.

If a formatter is specified, the formatter will be called with the value
and the rest of the arguments.

Note: caller must not modify result as it is cached.

=cut

sub get_widget_value {
    shift;
    my($name) = shift;
    # We cache both misses and hits.  But with misses, we only output
    # an error message once and keep on trying to read the file.
    return $_CACHE{$name} if $_CACHE{$name} && $_CACHE{$name} != $_MISSING;
    my($file) = $_DIR . $name . '.gif';
    # Use only one handle to avoid leaks
    my($fh) = \*Bivio::UI::Icon::IN;
    my($res);
    unless (open($fh, $file)) {
	# Don't be too noisy, because we retry misses.
	warn("$file: unable to open: $!") unless $_CACHE{$name};
	$res = $_MISSING;
    }
    else {
	my($gif) =  GD::Image->newFromGif($fh);
	$res = {uri => $_URI . $name . '.gif', is_constant => 1};
	if (defined($gif)) {
	    ($res->{width}, $res->{height}) = $gif->getBounds;
	}
	else {
	    warn("$file: unable to determine size");
	}
	close($fh);
    }
    $_CACHE{$name} = $res;
    return @_ ? shift(@_)->get_widget_value($res, @_) : $res;
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item directory : string (required)

Directory in which icons reside.

=item uri : string (required)

URI prefix for icons.

=item missing_uri : string [/missing-image]

URI to be used when an icon could not be found.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_URI = $cfg->{uri};
    warn("$_URI: is not absolute") unless $_URI =~ m!^/!;
    $_URI =~ s!([^/])$!$1/!;
    $_DIR = $cfg->{directory};
    warn("$_DIR: not a directory") unless -d $_DIR;
    $_DIR =~ s!([^/])$!$1/!;
    $_MISSING = {
	uri => $cfg->{missing_uri},
	is_constant => 1,
    };
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
