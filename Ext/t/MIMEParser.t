# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test;
use Bivio::Ext::MIMEParser;
Bivio::Test->unit([
    'Bivio::Ext::MIMEParser' => [
	parse_data => [
	    [[<DATA>]] => sub {
		my($case, $return) = @_;
		return $return->[0]->head->get('to') eq "NAGLER\@BIVIO.COM\n";
	    },
        ],
    ],
]);
__DATA__
Return-Path: <L8375419203.50841.2@service.emailfactory.com>
Received: from bivio.com (ic.bivio.com [216.87.82.67])
	by s2.bivio.com (8.11.6/8.11.6) with ESMTP id g8HLhNv07338
	for <nagler@mail.bivio.com>; Tue, 17 Sep 2002 15:43:23 -0600
Received: from sonja.emailfactory.com (sonja.emailfactory.com [66.28.35.27])
	by bivio.com (8.9.3/8.9.3) with ESMTP id PAA06251
	for <NAGLER@BIVIO.COM>; Tue, 17 Sep 2002 15:43:22 -0600
Received: from sonja.emailfactory.com (mail@localhost)
	by sonja.emailfactory.com (8.9.3/8.9.3) with SMTP id NBW06109
	for <NAGLER@BIVIO.COM>; Tue, 17 Sep 2002 13:43:18 -0400
Message-Id: <200209171743.NBW06109@sonja.emailfactory.com>
Errors-To: L8375419203.50841.2@service.emailfactory.com
Reply-To: L8375419203.50841.1@service.emailfactory.com
Status:   
From: "ISPworld" <xspgear@emailfactory.net>
To: NAGLER@BIVIO.COM
Subject: xSP Gear -- Securing Your Web Server
Date: Tue, 17 Sep 2002 13:43:18 -0400

************************************************

ISPworld.com's
ISPworld Weekly xSP GEAR Newsletter
September 17, 2002

************************************************


_______________________Sponsored by Sprint____________________________

Combine the science of success with the science of FREE. Help your 
business leverage the full power of the Internet with Sprint Dedicated 
Internet Access Services - the right formulations and configurations for 
top speed and reliability. Plus, get a free Cisco 2620 Router - 
including installation and configuration - to boot! 
http://www.sprintbiz.com/speed374
______________________________________________________________________



**********************************

>From the Labs


Dialing for Dollars
By Jim Thompson
ISP World


Looking for a new revenue source? Why not call up some new profits. 
InnoMedia's MTA 3308 IP Phone is specifically targeted at broadband 
service providers who want to deliver new revenue-generating telephony 
services. 


http://www.ispworld.com/isp/newsletter/gear/labs_091702.htm


**********************************

Gear of the Week


A Place for Your Stuff
By Jim Thompson
ISP World


A wise man once said, you can never be too rich, too thin or have too 
much storage. No matter how much hard drive space you have or think you 
have, it never seems to be enough. It's kind of like socks ? you have a 
drawer full, but you can't get the right combination for a match (what 
does happen to those extra socks?). Other World Computing (OWC) can find 
your missing socks, and they can put a dent in your storage problems 
with a 120-GB portable hard drive that not only connects via FireWire 
and USB, but is quite and fast as well.


http://www.ispworld.com/isp/newsletter/gear/gotw_091702.htm


**********************************

Tools of the Trade

 
Securing Your Web Server
By Jim ThompsonISP World


For the hacker, a Web server is like a Big Mac to a man on a diet - it's 
such a visible and tempting target that it's irresistible. Any security 
professional will tell you that securing a Web sever is not only 
difficult but usually results in performance degradation. But don't give 
up. PentaSafe Security Technologies, Inc. claims their new VigilEnt 
Security Agent for Web Servers 3.0 can keep your Sun Microsystems 
iPlanet, Apache and Microsoft IIS Web servers safe without a drop in 
performance.


http://www.ispworld.com/isp/newsletter/gear/tools_091702.htm


*************************************************
Classified

COVAD-The high-speed Internet experts for business 

The leading national DSL provider for business. Satisfaction guaranteed. 
1-800-GO-COVAD / http://www.covad.com. GET free set-up/equipment. Click 
here http://altfarm.mediaplex.com/ad/ck/1194-8500-5474-2 for more 
information



Visit the Redesigned Microsoft Resource Center

If you're a Service Provider, this new online resource provides you with 

the software, support, and resources necessary to run your business more 

efficiently. Take advantage of technical and business resources, white 
papers, How-to Articles, the Microsoft Knowledge Base, licensing and 
certification programs, bulletin boards and much more! Just click on the 

Microsoft Resource Center link on the ISPworld home page! 
http://www.ispworld.com/msrc.htm



ENHANCE Your LISTINGS in the ISP Directory & in the Print Version of the 
Directory of Service Providers 

Be the first provider listed in your relevant area code(s). Enhanced 
listings will be bold, and will also appear online at ISPworld's "Find 
an ISP" directory. Premium positioning in each area code is available on 
a first come first serve basis, so act fast to make sure you get the 
first listing! To purchase your enhanced listing, contact Dave Rodriguez 
at 203/559-2805 or drodriguez@penton.com. 
http://www.ispworld.com/ASP/Search/ISPSearchPage.asp



NATIONAL ISPs

Premium positioning--with or without an accompanying display ad--is 
available to National ISPs for that portion of the Directory of Internet 
Service Providers. Enhanced listings in this section will also include 
additional verbiage written by you about your services. Again, these 
positions will be placed on a first come first serve basis, so don't 
wait. The first one to act will get the first listing in this section of 
ISPs operating nationally. To reserve your premium positioning and/or 
ad, contact Dave Rodriguez at 203/559-2805 or drodriguez@penton.com



LOOKING FOR ISPworld or Boardwatch REPRINTS?

ISPworld now offers reprints of ISPworld and Boardwatch Magazine 
articles. Reprints are ideal marketing tools for press kits, sales 
presentations and trade shows.

To request a reprint, contact Maureen Manzi at mmanzi@penton.com

*********************************

For information on advertising in e-mail newsletters or other creative 
advertising opportunities with ISPworld, please contact David Rodriguez 
at drodriguez@penton.com.

Please send feedback and comments about this e-newsletter to: 
khawe@penton.com

**********************************



----------------------------------------------------------------------------
----------------------------------------------------------------------------
To UNSUBSCRIBE from this mailing list:

Reply to this message with the word 'unsubscribe' as the subject

 OR

To UNSUBSCRIBE from this mailing list, go to:

http://ispworld.emailfactory.com/handler.cfm?idAddress=L8375419203.50841
----------------------------------------------------------------------------
----------------------------------------------------------------------------
<br><img src='http://emailfactory.com/counter.cfm?LMID=50841'><br>
