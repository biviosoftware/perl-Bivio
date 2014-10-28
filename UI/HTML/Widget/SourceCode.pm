# Copyright (c) 2001-2010 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::SourceCode;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_HTML) = b_use('Bivio.HTML');
my($_C) = b_use('IO.Config');
my($_D) = b_use('Bivio.Die');
my($_CL) = b_use('IO.ClassLoader');
my($_F) = b_use('UI.Facade');
my($_SU) = b_use('Bivio.ShellUtil');
my($_IGNORE_POD) = {
    '=for' => 1,
    '=over' => 1,
    '=back' => 1,
    '=cut' => 1,
};
my($_CACHE);
$_C->register(my $_CFG = {
    source_dir => $_C->REQUIRED,
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
    my($package) = $req->unsafe_get('path_info')
	|| ($req->get('query') || {})->{'s'};
    $package =~ s{^/}{};
    $_D->throw('NOT_FOUND') if Bivio::Die->catch_quietly(sub {
        my($p) = $_CL->unsafe_map_require($package);
	$package = $p
	    if $p;
    });
    $_D->throw('NOT_FOUND')
	unless $package;
    $_D->throw('NOT_FOUND')
	 unless my $file = _file($package, $req);
#TODO: remove this and do it inline always
    my($lines) = [$_SU->do_backticks("/usr/local/bin/perl2html -c -s < '$file'")];
    _reformat_pod($self, $lines);
    _add_links($self, $lines, $package, $req);
    _add_method_anchors($self, $lines);
    $lines = join('', @$lines);
    $lines =~ s{<pre[^>]*}{<div class="b_literal"}ig;
    $lines =~ s{</pre>}{</div>}ig;
    DIV_b_source_code_title(String($package))
	->initialize_and_render($req, $buffer);
    $$buffer .= $lines;
    return;
}

sub render_source_link {
    my($proto, $req, $source, $name, $buffer, $method) = @_;
    Link(
	$name,
	URI({
	    task_id => 'SOURCE',
	    path_info => Bivio::UNIVERSAL->is_super_of($source)
	       ? $source->as_classloader_map_name : $source,
	    $method ? (anchor => $method) : (),
	}),
    )->initialize_and_render($req, $buffer);
    return;
}

sub _add_links {
    my($self, $lines, $ignore_package, $req) = @_;
    my($vars) = {};
    my($render) = sub {
	my($prefix, $map_name, $pkg, $var, $widget) = @_;
	my($name) = $map_name || $pkg || $var || $widget;
	if ($map_name) {
	    return $prefix . $map_name
		unless _require($pkg = $map_name);
	}
	elsif ($pkg) {
	    return $pkg
		unless _require($pkg);
	}
	elsif ($var) {
	    return $var
		unless $pkg = $vars->{$var};
	}
	else {
	    # We prefer XHTMLWidget over other widgets.  It's
	    # not easy to determine in which context a widget will
	    # be loaded.
	    foreach my $map (
		'XHTMLWidget',
		grep(/Widget/, @{$_CL->all_map_names}),
	    ) {
		last
		    if _require($pkg = "$map.$widget");
		$pkg = undef;
	    }
	    return $widget
	        unless $pkg;
	}
	my($b);
	$self->render_source_link($req, $pkg, $name, \$b);
	return ($prefix || '') . $b;
    };
    foreach my $line (@$lines) {
	$vars->{$1} = $2
	    if $line =~ m{my.*?\((\$_\w+)\).*use\(.*?'(\w+\.\w+)};
	$line =~ s{
	    (\b|'|")([A-Z]\w+\.[A-Z]\w+)
	    | ((?:[A-Z]\w+::)+[A-Z]\w+)
	    | (\$_[A-Z0-9]+\b)
            | (?<=[^:])(\b[A-Z]\w+)(?=\()
	}{$render->($1, $2, $3, $4, $5)}exg;
    }
    return;
}

sub _add_method_anchors {
    my($self, $lines) = @_;

    foreach my $line (@$lines) {
	$line =~ s{>(sub (\w+) <)}{><a name="$2"></a>$1};
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

sub _require {
    my($pkg) = @_;
    # avoid autoloading other modules and corrupting this one
    return ''
	if $pkg =~ /AUTOLOAD/;
    return $_D->eval(sub {$_CL->unsafe_map_require($pkg)});
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
