# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Widget;
Bivio::Test::Widget->unit(
    'Bivio::UI::HTML::Widget::Script',
    undef,
    sub {
	my($case, $actual) = @_;
	# Clear state internal to Script widget each time the
	# [] empty case occurs.
	Bivio::Agent::Request->get_current->delete(
	    'Bivio::UI::HTML::Widget::Script')
	     unless $case->get('object')->unsafe_get('value');
	return $actual;
    },
    [
	[] => '',
	no_such_script => Bivio::DieCode->DIE,
	[] => '',
	page_print => '',
	[] => <<'EOF',
<script language="JavaScript">
<!--
function page_print_onload(){window.print()}
window.onload=function(){
page_print_onload();
}
// --></script>
EOF
	page_print => '',
	first_focus => '',
	[] => qr/\npage_print_onload\(\);\nfirst_focus_onload\(\);/,
    ],
);
