# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::SourceCode;
use strict;
$Bivio::UI::HTML::Widget::SourceCode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::SourceCode::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::SourceCode - source code HTML pretty printer

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::SourceCode;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::SourceCode::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::SourceCode> renders source code as HTML.

=head1 ATTRIBUTES

=over 4

=item uri : string []

The uri to use when rendering related package links.

=back

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::IO::Config;
use File::Find ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_SOURCE_DIR);
Bivio::IO::Config->register({
    source_dir => Bivio::IO::Config->REQUIRED,
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::SourceCode

Creates a new SourceCode renderer.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Calls L<Bivio::UI::Widget::execute_with_content_type|Bivio::UI::Widget/"execute_with_content_type">
as text/html.

=cut

sub execute {
    my($self, $req) = @_;
    return $self->execute_with_content_type($req, 'text/html');
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item source_dir> : string (required)

The directory to search for source code.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_SOURCE_DIR = $cfg->{source_dir};
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = @_;
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the source code using perl2html, then adding links.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($package) = $source->get_request->get('query')->{'s'};
    return unless $package;

    my($file) = $package;
    $file =~ s,::,/,g;
    $file = $_SOURCE_DIR.'/'.$file.'.pm';
    Bivio::Die->die($file, ' not found') unless -e $file;

    my($lines) = [`cat $file | perl2html -c`];
#TODO: reformat POD
    _add_links($self, $lines, _find_files($self, $package));

    $$buffer .= join('', @$lines);
    return;
}

#=PRIVATE METHODS

# _add_links(self, array_ref lines, hash_ref files)
#
# Adds href links to related package files.
#
sub _add_links {
    my($self, $lines, $files) = @_;
    my($uri) = $self->get('uri');

    foreach my $line (@$lines) {
	my($matches) = [];

	# gather up the package names on the line
	while ($line =~ /(\w+::[\w:]+)/g) {
	    my($package) = $1;

	    # try removing a constant reference
	    unless ($files->{$package}) {
		$package =~ s/::[A-Z_]+$//;
	    }

	    push(@$matches, $package)
		    if $files->{$package};
	}

	# iterate the matches, substituting in hrefs into the line
	foreach my $package (@$matches) {
	    $line =~ s,($package),<a href="/$uri?s=$1">$1</a>,
		    || Bivio::Die->die('invalid package match: ', $package);
	}
    }
    return;
}

# _find_files(self, string ignore_package) : hash_ref
#
# Returns a map of source file names, searching the specified directory.
#
sub _find_files {
    my($self, $ignore_package) = @_;

    my($files) = {};
    File::Find::find(
	    sub {
		my($name) = $File::Find::name;
		return unless $name =~ /\.pm$/;

		# turn the file name into a package name
		$name =~ s,^$_SOURCE_DIR/(.*)\.pm$,$1,;
		$name =~ s,/,::,g;

		$files->{$name} = 1
			unless $name eq $ignore_package;
	    },
	    $_SOURCE_DIR);
    return $files;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
