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
use Bivio::DieCode;
use Bivio::IO::Config;
use Bivio::UI::Facade;
use Bivio::UI::LocalFileType;
use File::Find ();

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_FILES) = {};
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
    _find_files();
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

=for html <a name="is_source_module"></a>

=head2 static is_source_module(string name) : boolean

Returns true if the name identifies a browsable source module.

=cut

sub is_source_module {
    my($proto, $name) = @_;
    return $_FILES->{$name} ? 1 : 0;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the source code using perl2html, then adding links.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    Bivio::Die->throw(Bivio::DieCode::NOT_FOUND())
		unless $req->get('query') && $req->get('query')->{'s'};
    my($package) = $req->get('query')->{'s'};

    my($file) = $package;
    if ($file =~ /^View\./) {
	$file =~ s/^View\.//;
	$file .= '.bview';
#TODO: probably don't want the views directly browsable
	$file = Bivio::UI::Facade->get_local_file_name(
		Bivio::UI::LocalFileType->VIEW, $file, $req);
    }
    else {
	$file =~ s,::,/,g;
	$file = $_SOURCE_DIR.'/'.$file.'.pm';
    }

    Bivio::Die->throw(Bivio::DieCode::NOT_FOUND())
		unless -e $file;

    my($lines) = [`cat $file | perl2html -c`];
#TODO: reformat POD
    _add_links($self, $lines, $package);

    $$buffer .= join('', @$lines);
    return;
}

=for html <a name="render_source_link"></a>

=head2 static render_source_link(Bivio::Agent::Request req, string source, string name, string_ref buffer)

Draws the source link onto the buffer.

=cut

sub render_source_link {
    my($proto, $req, $source, $name, $buffer) = @_;
#TODO: use $req to determine the URI?
    $$buffer .= '<a href="/src?s='.$source.'">'.$name.'</a>';
    return;
}

#=PRIVATE METHODS

# _add_links(self, array_ref lines, string ignore_package)
#
# Adds href links to related package files.
#
sub _add_links {
    my($self, $lines, $ignore_package) = @_;
    my($uri) = $self->get('uri');

    foreach my $line (@$lines) {
	my($matches) = [];

	# gather up the package names on the line
	while ($line =~ /(\w+::[\w:]+)/g) {
	    my($package) = $1;

	    # try removing a constant reference
	    unless ($_FILES->{$package}) {
		$package =~ s/::[A-Z_]+$//;
	    }

	    push(@$matches, $package)
		    if $_FILES->{$package} && $package ne $ignore_package;
	}

	# iterate the matches, substituting in hrefs into the line
	foreach my $package (@$matches) {
	    $line =~ s,($package),<a href="/$uri?s=$1">$1</a>,
		    || Bivio::Die->die('invalid package match: ', $package);
	}
    }
    return;
}

# _find_files() : hash_ref
#
# Loads a map of browsable source file names.
#
sub _find_files {

    File::Find::find(
	    sub {
		my($name) = $File::Find::name;
		return unless $name =~ /\.pm$/;

		# turn the file name into a package name
		$name =~ s,^$_SOURCE_DIR/(.*)\.pm$,$1,;
		$name =~ s,/,::,g;

		$_FILES->{$name} = 1;
	    },
	    $_SOURCE_DIR);
    return;
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
