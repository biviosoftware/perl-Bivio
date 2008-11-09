# Copyright (c) 2001-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::SourceCode;
use strict;
use Bivio::Base 'UI.Widget';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_D) = b_use('Bivio.Die');
my($_F) = b_use('UI.Facade');
my($_IGNORE_POD) = {
    '=for' => 1,
    '=over' => 1,
    '=back' => 1,
    '=cut' => 1,
};
my($_CACHE);
Bivio::IO::Config->register(my $_CFG = {
    source_dir => Bivio::IO::Config->REQUIRED,
});

sub handle_config {
    my(undef, $cfg) = @_;
    ($_CFG->{source_dir} = $cfg->{source_dir}) =~ s,/+$,,;
    $_CACHE = undef;
    return;
}

sub initialize {
    return;
}

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    $_D->throw('NOT_FOUND')
	unless my $package = ($req->get('query') || {})->{'s'};
    $_D->throw('NOT_FOUND')
	 unless my $file = _file($package, $req);
    my($lines) = [`perl2html -c -s < '$file'`];
    _reformat_pod($self, $lines);
    _add_links($self, $lines, $package, $req);
    $$buffer .= join('', @$lines);
    return;
}

sub render_source_link {
    my($proto, $req, $source, $name, $buffer) = @_;
    $$buffer .= qq{<a href="/src?s=$source">$name</a>};
    return;
}

sub _add_links {
    my($self, $lines, $ignore_package, $req) = @_;
    my($uri) = $self->get('uri');
    foreach my $line (@$lines) {
	my($matches) = [];
	while ($line =~ /(\w+::[\w:]+)/g) {
	    my($package) = $1;
	    $package =~ s/::[A-Z_]+$//
		unless _file($package, $req);
	    push(@$matches, $package)
		if _file($package, $req)
		&& $package ne $ignore_package
		&& !_contains($matches, $package);
	}
	foreach my $package (@$matches) {
	    b_die('invalid package match: ', $package)
		unless $line =~
		    s{([^=>])(\Q$package\E)}{$1<a href="/$uri?s=$2">$2</a>}
		|| $line =~ s{(\Q$package\E)}{<a href="/$uri?s=$1">$1</a>};
	}
	if ($line =~ /view_parent\(.*?>.(\w+)/) {
	    my($view) = $1;
	    $line =~ s,(\Q$view\E),<a href="/$uri?s=View.$1">$1</a>,;
	}
    }
    return;
}

sub _contains {
    my($values, $item) = @_;
    return grep($item eq $_, @$values) ? 1 : 0;
}

sub _file {
    my($package, $req) = @_;
    return ($_CACHE ||= {})->{$package} ||= _file_find($package, $req);
}

sub _file_find {
    my($file, $req) = @_;
    if ($file =~ /^View\./) {
	$file =~ s/^View\.//;
	$file .= '.bview';
	$file = $_F->get_local_file_name('VIEW', $file, $req);
    }
    else {
	$file =~ s,::,/,g;
	$file = "$_CFG->{source_dir}/$file.pm";
    }
    return -f $file ? $file : undef;
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
	next
	    unless $in_pod;
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
    my($line) = @_;
    $line =~ s,E<lt>,&lt;,g;
    $line =~ s,E<gt>,&gt;,g;
    $line =~ s,I<(.*?)>,<i>$1</i>,g;
    $line =~ s,E&lt;lt&gt;,&lt;,g;
    $line =~ s,E&lt;gt&gt;,&gt;,g;
    $line =~ s,C&lt;(.*?)&gt;,<code>$1</code>,g;
    $line =~ s,B&lt;(.*?)&gt;,<b>$1</b>,g;
    $line =~ s,I&lt;(.*?)&gt;,<i>$1</i>,g;
    $line =~ s,L&lt;(.*?)\|.*?&gt;,$1,g;
    $line =~ s,L&lt;(.*?)&gt;,$1,g;
    return $line;
}

1;
