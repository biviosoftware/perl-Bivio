# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$

package Bivio::NAICRegister;

use strict;
use Apache::Constants qw(OK);
use Bivio::Mail::Outgoing;
use Bivio::Util;

my($_FORM) = <<'EOF';
<html><head><title>NAIC Denver Chapter Registration Form</title>
</head><body>
<CENTER>
<H2>NAIC Denver Chapter Registration Form</H2>
<FORM action="/denver-register" method=POST>
<TABLE width="1%">
<TR>
  <TD>Name:</TD><TD colspan=2><input type=text size=50 name=name></TD>
</TR><TR>
  <TD nowrap>Home Phone:</TD><TD><input type=text size=20 name=home_phone></TD>
  <TD nowrap align=right>Work Phone:&nbsp;&nbsp;<input type=text size=15 name=work_phone></TD>
</TR><TR>
  <TD>Address:</TD><TD colspan=2><input type=text size=50 name=address>
</TR><TR><TD>City:</TD><TD><input type=text size=20 name=city></TD>
  <TD nowrap align=right>State:&nbsp;&nbsp;<input type=text size=2 name=state>
  &nbsp;Zip:&nbsp;&nbsp;<input type=text size=12 name=zip></TD>
</TR><TR>
  <TD>Email:</TD><TD colspan=2><input type=text size=50 name=email>
</TR><TR>
  <TD nowrap>Name of Class:</TD><TD colspan=2><input type=text size=50 name=name_of_class></TD>
</TR><TR>
  <TD>Date:</TD><TD><input type=text size=20 name=date></TD>
  <TD nowrap align=right>Fee:&nbsp;&nbsp;<input type=text size=15 name=fee></TD>
</TR><TR>
  <TD nowrap>Class Number:</TD><TD><input type=text size=20 name=class_number></TD>
  <TD nowrap align=right>Section:&nbsp;&nbsp;<input type=text size=15 name=section></TD>
</TR><TR>
  <TD>Instructor:</TD><TD colspan=2><input type=text size=50 name=instructor></TD>
</TR><TR>
  <TD colspan=3 align=center><INPUT type=submit value="Submit">
</TR>
</FORM>
</TABLE>
</CENTER>
</body>
</html>
EOF
my(%_LABELS);
my(@_FIELDS);
foreach (split(/\n/, $_FORM)) {
    /([\w\s]+:).*name=(\w+)/ || next;
    $_LABELS{$2} = $1;
    push(@_FIELDS, $2);
    print STDERR "$1 $2\n";

}
my(%_NOT_REQUIRED_FIELDS) = (work_phone => 1);

sub handler {
    my $r = shift;
    $r->content_type("text/html");
    $r->send_http_header;
    if ($r->method_number == Apache::Constants::M_POST()) {
	my(%args) = $r->content;
        if (_check_fields(\%args)) {
	    _render_result($r, \%args);
	}
	else {
	    _render_form($r, \%args);
	}
    }
    else {
	_render_form($r);
    }
    return OK;
}


sub _send_mail{
    my($args) = @_;
    my $outmail = Bivio::Mail::Outgoing->new( );
    $outmail->set_recipients(['nagler', $args->{email}]);
    my($n) = $args->{name};
    $n =~ s/(["\\])/\\$1/g;
    $outmail->set_header('From', qq!"$n" <$args->{email}>!);
    $outmail->set_header('Subject', 'NAIC Registration');
    $outmail->set_header('To', 'nagler');
    $outmail->set_header('Cc', $args->{email});
    my($s) = "NAIC Denver Chapter Registration:\n\n";
    foreach (@_FIELDS) {
	$s .= sprintf('%-14s %s'."\n", $_LABELS{$_}, $args->{$_});
    }
    $outmail->set_body($s);
    $outmail->send( );
}


sub _render_result{
    my($output, $args) = @_;
    _send_mail($args);
    my($s) = <<'EOF';
<html><head><title>NAIC Denver Chapter Registration Complete</title>
</head><body>
<h2>NAIC Denver Chapter Registration Complete</h2>
The following information was submitted to the Denver Chapter:<P><P>
<table>
EOF
    foreach (@_FIELDS) {
	$s .= sprintf('<TR><TD>%s</TD><TD>%s</TD></TR>'."\n",
		$_LABELS{$_}, $args->{$_});
    }
    $s .= <<'EOF';
</TABLE>
<CENTER>
<P><B><a href="/denver.html">Return To Denver Chapter Home Page</a></B>
</CENTER>
</body>
</html>
EOF
    $output->print($s);
}

sub _render_form {
    my($output, $args) = @_;
    my($form) = $_FORM;
    if (defined($args)) {
	my($x) = '<p><font color=red><i>Please fill in required fields'
		.'</i></font></p>';
	$form =~ s/(<H2>.*<\/H2>)/$1$x/;
	foreach (@_FIELDS) {
	    if (length($args->{$_})) {
		my($v) = Bivio::Util::escape_html($args->{$_});
		$form =~ s/(name=$_)\b/$1 value="$v"/;
	    }
	    elsif (!$_NOT_REQUIRED_FIELDS{$_}) {
print STDERR "$_ $args->{$_}\n";
		my($x) = $_;
                $x =~ s/_/ /g;
		$form =~ s/\b($x:)/<font color=red><i>$1<\/i><\/font>/i;
	    }
	}
    }
    $output->print($form);
}

sub _check_fields {
    my($args) = @_;
    my($err) = 0;
    foreach (@_FIELDS) {
	if (defined($args->{$_})) {
	    $args->{$_} =~ s/^\s+|\s+$//g;
	}
	else {
	    $args->{$_} = '';
	}
    }
    foreach (@_FIELDS) {
	length($args->{$_}) && next;
	if ($_ =~ /phone$/) {
	    next if length($args->{work_phone}) || length($args->{home_phone});
	}
	$err++;
    }
    return !$err;
}

1;
