# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::ResultViewer;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);


my($root) = "$ENV{HOME}/src/perl/$ENV{BROOT}/Test/t";
my($log_dir_name) = $root . '/log';
my($index_page_name) = $log_dir_name . '/index.html';



sub USAGE {
    return <<'EOF';
View acceptance test output in browser

usage: b-result-viewer [options] command [args...]

commands:
    generate_all -- process all test results and create index page.
    generate [test-name ...] -- (re)process results from one or mores tests

EOF
}

my($css) = <<'EOF';
<style type="text/css">
* {
    font-family:"Verdana", "Sans-serif";
}
a {
    font-size:13px;
}
table {
    font-size:13px;
}
.headers {
    font-weight: bold; 
}
.res_nr {
   width: 40px;
}
.location {
   width: 40px;
}
.sts {
   width: 50px;
}
</style>
EOF

sub generate_all {
    my($self) = @_;
    my($dir);
    opendir($dir, $log_dir_name) || return 'Cannot open directory: ' . $log_dir_name;
    my(@subdirs)= grep {/^[^.]/ && -d "$log_dir_name/$_"} readdir($dir);
    closedir($dir);
    my($rows) = "<tr><td>Test Name</td></tr>\n";
    foreach my $dir (sort(@subdirs)) {
	$rows .= "<tr><td><a href='$dir/index.html'>$dir</a></td></tr>\n";
	my($err) = _generate_one($self, $dir);
	return $err if $err;
    }
    my $content =  <<EOF;
<html>
<head>
$css
<title>Test Results</title>
</head>
<body>
<h3>Test Results</h3>
<table>
$rows
</table>
</body>
</html>
EOF
    return _write_file($index_page_name, $content);
}

sub generate {
   my($self, @dirs) = (shift, @_);
   return "no test names specified" unless int(@dirs);
   foreach my $dir (@dirs) {
       my($err) = _generate_one($self, $dir);
       return $err if $err;
   }
   return;
}

sub _generate_one {
    my($self, $dir) = @_;
    my($qualified) = $root . '/log/' . $dir;
    my(@req_files) = glob($qualified. '/http*.req');
    return "$qualified contains no test results"  unless int(@req_files);
    my($html);
    open($html, '>', $qualified . '/index.html') || return 'cannot open index file for: ' . $dir;
    _write_page_header($html, $dir); 
    foreach my $req_file (@req_files) {
	my($req_nr) = $req_file =~ /http-(\d+)/;
	my($res_nr) = sprintf('%05d', $req_nr + 1);
	my($location, $cmd) = _read_file($req_file);
	$location =~ s/^.*?:\s*//;
	my($base) = $cmd =~ qr{(http://.*?/)};
	my($res_file) = $req_file;
	$res_file =~ s/http-\d+.req/http-$res_nr.res/;
	my(@lines) = _read_file($res_file);
	my($sts) = $lines[0]  =~ /HTTP\/1.1 (\d+).*/;
	my($nr_empty);
        my(@headers) = map({$nr_empty++ if $_ eq "\n"; $nr_empty ? () : $_} @lines);
	my(@page) = @lines;
	splice(@page, 0, int(@headers) + 1);
	map({$_ =~ s/<head>/<head><base href="$base">/} @page)
	    if $base;
	my($extension) = $cmd =~ qr{http://.*?/.*?(\..*?)[$\?]};
	$extension ||= '.html';
	my($page_file) = 'page-' . $res_nr . $extension;
	_write_file($qualified . '/' . $page_file, \@page);
        _write_page_line($html, $location, $res_nr, $sts, $page_file, $cmd);
    }
    _write_page_footer($html);
    close($html);
    return;
}

sub _read_file {
     my($fn) = @_;
     my($fh);
     open($fh, '<', $fn) || die('cannot open: ' . $fn);
     my(@lines) = <$fh>;
     close($fh);
     return @lines;
 }

sub _write_file {
     my($fn, $lines) = @_;
     my($fh);
     open($fh, '>', $fn) || return 'cannot open: ' . $fn;
     print $fh ref($lines) ? @$lines : $lines;
     close($fh);
     return;
 }

sub _write_page_footer {
    my($fh, $name) = @_;
    print $fh <<END;
</table>
</div>
<iframe name='frame' height='100%' width='100%'/>
</body>
</html>
END
    return;
}

sub _write_page_header {
    my($fh, $name) = @_;
    print $fh <<END;
<html>
<head>
$css
<title>$name</title>
</head>
<body>
<h3>Results for $name</h3>
<a href="../index.html">Back to test list</a>
<table class="headers">
<tr>
  <td class="res_nr">Resp Nr</td>
  <td class="location">Test Line Nr</td>
  <td class="sts">HTTP Status</td>
  <td class="cmd">Command</td>
</tr>
</table>
<hr/>
<div style='overflow:auto; height:300px;'>
<table>


END
    return;
}

sub _write_page_line {
    my($fh, $location, $res_nr, $sts, $href, $cmd) = @_;
    print $fh <<END;
<tr>
<td class="rsp_nr">
    <a href='$href' target='frame'>$res_nr</a>
</td>
<td class="location">$location</td>
<td class="sts">$sts</td>
<td class="cmd">$cmd</td>

</td>
</tr>
END
    return;
}

1;
