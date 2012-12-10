# Copyright (c) 2002-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::ResultViewer;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($root) = "$ENV{PERLLIB}/$ENV{BROOT}/Test/t";
my($log_dir_name) = $root . '/log';
my($index_page_name) = $log_dir_name . '/index.html';
my($our_name) = __PACKAGE__ =~ /::(\w+)$/;

sub USAGE {
    return <<'EOF';
View acceptance test output in browser

usage: b ResultViewer [options] command [args...]

commands:
    generate [test-name ...] -- (re)process results from one or more tests
                                Default is all tests

EOF
}

my($css) = <<'EOF';
<style type="text/css">
* {
    font-family:"Verdana", "Sans-serif";
}
.link {
    color: darkblue;
    font-size:13px;
}
.link:hover {
    color: cyan;
}
table {
    font-size:13px;
}
.headers {
    margin-top: 10px;
    font-weight: bold;
}
.res_nr {
   width: 70px;
}
.location {
   width: 65px;
}
.sts {
   width: 50px;
}
.unselected {
   background-color: none;
}
.selected {
   background-color: yellow;
}
</style>
EOF

my($javascript) = <<'EOF';
<script type="text/javascript">
<!--
function display(element, req, res) {
   if (selected != null) {
        selected.className = "unselected"; 
   }
   selected = element;
   selected.className = "selected"; 
   top.frames['req'].location.href = req;
   top.frames['res'].location.href = res;
   return 0;
}
var selected;
-->
</script>
EOF


my($frameset_html) = <<'EOF';
<frameset rows="140px,20%,45%">
<frame name="panel" src="panel.html">
<frame name="transactions" src="transactions.html">
<frameset cols="30%,70%">
<frame name="req"/>
<frame name="res"/>
</frameset> 
</frameset>
EOF


sub generate {
    my($self, @names) = (shift, @_);
    my($dir);
    opendir($dir, $log_dir_name) || return 'Cannot open directory: ' . $log_dir_name;
    my(@subdirs)= grep {/^[^.]/ && -d "$log_dir_name/$_"} readdir($dir);
    closedir($dir);
    if (int(@names)) {
	foreach my $name (@names) {
	   return 'no test results for ' . $name
	       unless grep({$name eq $_} @subdirs);
	}
    }
    else {
	@names = @subdirs;
    }
    my($rows) = "<tr><td>Test Name</td></tr>\n";
    foreach my $dir (sort(@subdirs)) {
	$rows .= "<tr><td><a href='$dir/$our_name/index.html'>$dir</a></td></tr>\n";
	my($err) = _generate_one($self, $dir) if grep({$dir eq $_} @names);	    
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

sub _generate_one {
    my($self, $dir) = @_;
    print "$dir\n";
    my($test_dir_name) = $root . '/log/' . $dir;
    my($gen_dir_name) = $test_dir_name . '/' . $our_name;
    mkdir($gen_dir_name) || return 'cannot create directory: ' . $gen_dir_name
	unless -e $gen_dir_name;
    my(@req_files) = glob($test_dir_name. '/http*.req');
    return "$test_dir_name contains no test results"  unless int(@req_files);
    _write_file($gen_dir_name . '/index.html', $frameset_html);
    _write_panel($gen_dir_name . '/panel.html', $dir);
    my($html);
    open($html, '>', $gen_dir_name . '/transactions.html') || return 'cannot open transactions file for: ' . $dir;
    _write_page_header($html, $dir); 
    foreach my $req_file (@req_files) {
	my($req_nr) = $req_file =~ /http-(\d+)/;
	my($res_nr) = sprintf('%05d', $req_nr + 1);
	my(@req_lines) = _read_file($req_file);
	my($location) = shift @req_lines;
	my($req_page_name) = 'request-' . $req_nr . '.txt';
	_write_file($gen_dir_name . '/' . $req_page_name, \@req_lines);
	$location =~ s/^.*?:\s*//;
	my($cmd) = @req_lines;
	my($base) = $cmd =~ qr{(http://.*?/)};
	my($res_file) = $req_file;
	$res_file =~ s/http-\d+.req/http-$res_nr.res/;
	my(@res_lines) = _read_file($res_file);
	my($sts) = $res_lines[0]  =~ /HTTP\/1.1 (\d+).*/;
	my($nr_empty);
        my(@headers) = map({$nr_empty++ if $_ eq "\n"; $nr_empty ? () : $_} @res_lines);
	my(@res_page) = @res_lines;
	splice(@res_page, 0, int(@headers) + 1);
	map({$_ =~ s/<head>/<head><base href="$base">/} @res_page)
	    if $base;
	my($extension) = $cmd =~ qr{http://.*?/.*?(\..*?)[$\?]};
	$extension ||= '.html';
	my($res_page_name) = 'response-' . $res_nr . '.html';
	_write_file($gen_dir_name . '/' . $res_page_name, \@res_page);
        _write_page_line($html, $location, int($req_nr), $req_page_name, int($res_nr), $res_page_name, $sts, $cmd);
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
$javascript
</head>
<body>
<table>
END
    return;
}

sub _write_page_line {
    my($fh, $location, $req_nr, $req_page_name, $res_nr, $res_page_name, $sts, $cmd) = @_;
    print $fh <<END;
<tr>
<td class="res_nr">
    <a class="link" href="#nonesuch" onclick='display(this.parentNode.parentNode, "$req_page_name", "$res_page_name");'>$req_nr/$res_nr</a>
</td>
<td class="location">$location</td>
<td class="sts">$sts</td>
<td class="cmd">$cmd</td>
</td>
</tr>
END
    return;
}

sub _write_panel {
    my($fn, $name) = @_;
    _write_file($fn, << "END");
<html>
<head>
$css
<title>$name</title>
</head>
<body>
<h3>Results for $name</h3>
<a href="../../index.html" target="_top">Back to test list</a>
<br/>
<table class="headers">
<tr>
  <td class="res_nr">Request Response Number</td>
  <td class="location">Test Line Number</td>
  <td class="sts">HTTP Status</td>
  <td class="cmd">Command</td>
</tr>
</table>
END
}

1;
