# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$

package Bivio::NAICRegister;

use strict;
use Apache::Constants qw(OK);
use Bivio::Mail::Outgoing;



sub handler {
    my $r = shift;
    $r->content_type("text/html");
    $r->send_http_header;
    my(%args) = $r->args;
    my(@keys) = keys %args;
    my(@values) = values %args;
    if (%args){
	my($view) = $args{view};
	if($view eq('result')){
	    _render_result($r, \%args );
	}
    }
    else{
	_render_form($r);
    }
    $r->print("</BODY></HTML>");
    return OK;
}


sub _send_mail{
    my($arguments) = @_;
    my $s;
    my $outmail = Bivio::Mail::Outgoing->new( );
    $outmail->set_recipients([qw(nagler)]);

    $outmail->set_header("From", $arguments->{email});
    $outmail->set_header("To", 'nagler');
    $outmail->set_header("Cc", $arguments->{email});
    $s .= "\nThe following information was submitted by " . $arguments->{username};
    $s .= "\n\nName: \t" . $arguments->{username};
    $s .= "\nHome Phone:\t" . $arguments->{homephone};
    $s .= "\nWork Phone:\t" . $arguments->{workhone};
    $s .= "\nAddress:  \t" . $arguments->{address};
    $s .= " " . $arguments->{city};
    $s .= ", " . $arguments->{state};
    $s .= " " . $arguments->{zip};
    $s .= "\nEmail:\t" . $arguments->{email};
    $s .= "\nClass:\t" . $arguments->{class};
    $s .= "\nDate:\t" . $arguments->{date};
    $s .= "\nSection:\t" . $arguments->{section};
    $s .= "\nFee:\t" . $arguments->{fee};
    $s .= "\nInstructor:\t" . $arguments->{instructor};
    $outmail->set_body($s);
    $outmail->send( );
}


sub _render_result{
    my($output, $arguments) = @_;
    my(@keys) = keys %$arguments;
    my(@values) = values %$arguments;
    _send_mail($arguments);
    $output->print("<H2>NAIC Denver Chapter Registration Form</H2>\n");
    $output->print("The following information was submitted to the Denver Chapter:<P><P>");
    $output->print("<table width = 60%>\n");
    $output->print("<TR><TD width = 15%>Name: <TD>" . $arguments->{username});
    $output->print("<TR><TD>Home Phone: <TD> " . $arguments->{homephone});
    $output->print("<TR><TD>Work Phone: <TD> " . $arguments->{workhone});
    $output->print("<TR><TD>Address: <TD> " . $arguments->{address});
    $output->print("<TR><TD>City: <TD>" . $arguments->{city});
    $output->print("<TR><TD>State: <TD>" . $arguments->{state});
    $output->print("<TR><TD>Zip: <TD>" . $arguments->{zip});
    $output->print("<TR><TD>Email: <TD>" . $arguments->{email});
    $output->print("<TR><TD>Name of Class: <TD>" . $arguments->{class});
    $output->print("<TR><TD>Date: <TD>" . $arguments->{date});
    $output->print("<TR><TD>Section: <TD>" . $arguments->{section});
    $output->print("<TR><TD>Fee: <TD>" . $arguments->{fee});
    $output->print("<TR><TD>Instructor: <TD>" . $arguments->{instructor});
    $output->print("</TABLE>\n");
    $output->print("<CENTER>");
    $output->print("<P><B><a href=\"/denver/denver.html\">Return To Denver Chapter Home Page</a></B>");
    $output->print("</CENTER>");
}


sub _render_form{
    my($output) = @_;
    $output->print("<CENTER><H2>NAIC Denver Chapter Registration Form</H2>\n");
    $output->print("<FORM action = \"/naic-denver\">\n");
    $output->print("<INPUT type=hidden name=view value=\"result\">\n");
    $output->print("<TABLE width = 90%>\n");
    $output->print("<TR><TD>Name:</TD><TD colspan = 2><input type=text size=50 name=username>\n");
    $output->print("<TR><TD>Home Phone:</TD><TD><input type=text size=12 name=homephone>\n");
    $output->print("<TD>Work Phone:</TD><TD><input type=text size=12 name=workhone>\n");
    $output->print("<TR><TD>Address:</TD><TD colspan = 2><input type=text size=50 name=address>\n");
    $output->print("<TR><TD>City:</TD><TD><input type=text size=30 name=city>\n");
    $output->print("<TD>State:</TD><TD><input type=text size=30 name=state>\n");
    $output->print("<TR><TD>Zip:</TD><TD><input type=text size=12 name=zip>\n");
    $output->print("<TR><TD>Email:</TD><TD colspan = 2><input type=text size=50 name=email>\n");
    $output->print("<TR><TD>Name of Class:</TD><TD colspan = 2><input type=text size=50 name=class>\n");
    $output->print("<TR><TD>Date:</TD><TD colspan = 2><input type=text size=20 name=date>\n");
    $output->print("<TR><TD>Class Number:</TD><TD><input type=text size=20 name=classnumber>\n");
    $output->print("<TR><TD>Section:</TD><TD colspan = 2><input type=text size=20 name=section>\n");
    $output->print("<TR><TD>Fee:</TD><TD colspan = 2><input type=text size=20 name=fee>\n");
    $output->print("<TR><TD>Instructor:</TD><TD colspan = 2><input type=text size=50 name=instructor>\n");
    $output->print("<TR><TD colspan = 4><INPUT type=submit value=\"Submit\">\n");
    $output->print("</FORM>\n");
    $output->print("</TABLE>\n");
    $output->print("</CENTER>\n");
}




1;
