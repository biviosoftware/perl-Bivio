# Copyright (c) 2001-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::SourceCode;
use strict;
use Bivio::Base 'Bivio::UI::Widget';
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Config;
use Bivio::UI::Facade;
use Bivio::UI::LocalFileType;
use File::Find ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IGNORE_POD) = {
    '=for' => 1,
    '=over' => 1,
    '=back' => 1,
    '=cut' => 1,
};

my($_FILES) = {};
my($_SOURCE_DIR);
Bivio::IO::Config->register({
    source_dir => Bivio::IO::Config->REQUIRED,
});

sub handle_config {
    my(undef, $cfg) = @_;
    $_SOURCE_DIR = $cfg->{source_dir};
    $_SOURCE_DIR =~ s,/+$,,;
    _find_files();
    return;
}

sub initialize {
    return;
}

sub is_source_module {
    my($proto, $name) = @_;
    return $_FILES->{$name} ? 1 : 0;
}

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
	$file = Bivio::UI::Facade->get_local_file_name(
		Bivio::UI::LocalFileType->VIEW, $file, $req);
    }
    else {
	$file =~ s,::,/,g;
	$file = $_SOURCE_DIR.'/'.$file.'.pm';
    }

    Bivio::Die->throw(Bivio::DieCode::NOT_FOUND())
		unless -e $file;

#TODO: Don't hardwire path or allow override
    my($lines) = [`cat $file | /usr/local/bin/perl2html -c -s`];
    _reformat_pod($self, $lines);
    _add_links($self, $lines, $package);

    $$buffer .= join('', @$lines);
    return;
}

sub render_source_link {
    my($proto, $req, $source, $name, $buffer) = @_;
#TODO: use $req to determine the URI?
    $$buffer .= '<a href="/src?s='.$source.'">'.$name.'</a>';
    return;
}

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
		    if $_FILES->{$package} && $package ne $ignore_package
			    && ! _contains($matches, $package);
	}

	# iterate the matches, substituting in hrefs into the line
	foreach my $package (@$matches) {
	    unless ($line
		    =~ s,([^=>])($package),$1<a href="/$uri?s=$2">$2</a>,) {

		$line =~ s,($package),<a href="/$uri?s=$1">$1</a>,
			|| Bivio::Die->die('invalid package match: ',
				$package);
	    }
	}

	# add links to the view's parent
	if ($line =~ /view_parent\(.*?>.(\w+)/) {
	    my($view) = $1;
	    $line =~ s,($view),<a href="/$uri?s=View.$1">$1</a>,;
	}
    }
    return;
}

sub _contains {
    # (array_ref, string) : boolean
    # Returns true if the array contains the item.
    my($values, $item) = @_;

    foreach my $value (@$values) {
	return 1 if $value eq $item;
    }
    return 0;
}

sub _find_files {
    # () : hash_ref
    # Loads a map of browsable source file names.
    $_FILES = {};
    File::Find::find({
        # follow symbolic links to source
        follow => 1,
        follow_skip => 2,
	wanted => sub {
	    my($name) = $File::Find::name;
	    return
		unless $name =~ /\.pm$/;
	    $name =~ s,^\Q$_SOURCE_DIR\E/(.*)\.pm$,$1,;
	    $name =~ s,/,::,g;
	    $_FILES->{$name} = 1;
	    return;
	},
    },
	$_SOURCE_DIR,
    );
    return;
}

sub _reformat_pod {
    my($self, $lines) = @_;
    my($in_pod) = 0;
    foreach my $line (@$lines) {
	my($pod, $doc);
	if ($line =~ m,^(<font[^>]+>)?(=[chiobpfbe]\w+)\s?(.*?)(</font>)?$,) {
	    $in_pod = 1;
	    $pod = $2;
	    $doc = $3;
        }
	next unless $in_pod;

	if ($pod && $doc && $pod eq '=for' && $doc =~ s/^html\s//) {
	    $line =~ s/=for\shtml\s//;
	    next;
	}
	$line = _unescape_pod($line);

	unless ($pod) {
	    $line = '# '.$line;
	    next;
	}

	$line =~ s/$pod\s?//;

	if ($_IGNORE_POD->{$pod}) {
	    $line =~ s/$doc// if $doc;
	    $line =~ s/\n//;
	}
	else {
	    if ($doc) {
		$doc = _unescape_pod($doc);
		# the \Q calls quotemeta()
		$line =~ s,\Q$doc,<b>$doc</b>,;
	    }
	    $line = '# '.$line;
	}

	if ($pod eq '=cut') {
	    $in_pod = 0;
	}
    }
    return;
}

sub _unescape_pod {
    # (string) : string
    # Converts POD markup into HTML.
    my($line) = @_;

#TODO: the doc line isn't escaped
    $line =~ s,E<lt>,&lt;,g;
    $line =~ s,E<gt>,&gt;,g;
    $line =~ s,I<(.*?)>,<i>$1</i>,g;

    $line =~ s,E&lt;lt&gt;,&lt;,g;
    $line =~ s,E&lt;gt&gt;,&gt;,g;
    $line =~ s,C&lt;(.*?)&gt;,<code>$1</code>,g;
    $line =~ s,B&lt;(.*?)&gt;,<b>$1</b>,g;
    $line =~ s,I&lt;(.*?)&gt;,<i>$1</i>,g;

    # L<Bivio::Collection::Attributes>
    # L<Bivio::Agent::Dispatcher|Bivio::Agent::Dispatcher>.
    # L<Bivio::Util->gettimeofday|Bivio::Util/"gettimeofday">
    $line =~ s,L&lt;(.*?)\|.*?&gt;,$1,g;
    $line =~ s,L&lt;(.*?)&gt;,$1,g;

    return $line;
}

1;
