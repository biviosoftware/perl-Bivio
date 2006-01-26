# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
use strict;
use Bivio::Test::Widget;
Bivio::Test::Widget->unit(
    'Bivio::UI::HTML::Widget::Table',
    sub {
	my($req) = @_;
	$req->put(task_id => Bivio::Agent::TaskId->PRODUCTS);
	Bivio::Biz::Model->new($req, 'ProductList')->load_all({
	    parent_id => 'REPTILES',
	}) unless $req->unsafe_get('Model.ProductList');
	return;
    },
    [
	map({
	    my($left, $right) = ref($_) eq 'ARRAY' ? @$_ : $_;
	    $right ||= {%$left};
	    ([ProductList => ['Product.product_id', 'Product.name'], $left]
		 => ref($right) ? _t($right) : $right);
	}
	    {},
	    {cellpadding => 2},
	    {cellspacing => 3},
	    [{align => 'n'}, {align => 'center', valign => 'top'}],
	    [{expand => 1}, {width => '95%'}],
	    {width => '100%'},
	    {border => 1},
	    [{title => 'Reptiles'}, {title => qq{\n<tr><td colspan="2"><font face="arial,sans-serif"><b><br />Reptiles<br /></b></font></td>\n</tr>}}],
	    [{class => 'reptiles'}, _chomp(<<'EOF')],

<table class="reptiles">
<tr>
<th><a target="_top" href="/pub/products?p=REPTILES&n=1&o=1a"><font face="arial,sans-serif"><b>Product ID</b></font></a></th>
<th><a target="_top" href="/pub/products?p=REPTILES&n=1&o=0d"><font face="arial,sans-serif"><b>Product Name</b></font> <img alt="This column sorted in ascending order" border="0" src="/i/sort_down.gif" width="10" height="8" /></a></th>
</tr>
<tr bgcolor="#D5EEFF">
<td><font face="arial,sans-serif">RP-LI-02</font></td>
<td><font face="arial,sans-serif">Iguana</font></td>
</tr>
<tr bgcolor="#F0F9FF">
<td><font face="arial,sans-serif">RP-SN-01</font></td>
<td><font face="arial,sans-serif">Rattlesnake</font></td>
</tr>
</table>
EOF
	),
    ],
);

sub _chomp {
    my($x) = @_;
    chomp($x);
    return $x;
}

sub _t {
    my($exp) = @_;
    my($x) = _chomp(<<'EOF');

<table border="0" cellpadding="5" cellspacing="0" valign="NOP" width="NOP" align="left" class="NOP"> title=NOP
<tr>
<th valign="bottom" align="center" nowrap="1"><a target="_top" href="/pub/products?p=REPTILES&n=1&o=1a"><font face="arial,sans-serif"><b>Product ID</b></font></a></th>
<th valign="bottom" align="center" nowrap="1"><a target="_top" href="/pub/products?p=REPTILES&n=1&o=0d"><font face="arial,sans-serif"><b>Product Name</b></font> <img alt="This column sorted in ascending order" valign="bottom" border="0" src="/i/sort_down.gif" width="10" height="8" /></a></th>
</tr>
<tr><td colspan="2"><table width="100%" cellspacing="0" cellpadding="0" border="0">
<tr bgcolor="#000000"><td><img src="/i/dot.gif" border="0" width="1" height="1" /></td></tr></table></td>
</tr>
<tr bgcolor="#D5EEFF">
<td align="left"><font face="arial,sans-serif">RP-LI-02</font></td>
<td align="left"><font face="arial,sans-serif">Iguana</font></td>
</tr>
<tr bgcolor="#F0F9FF">
<td align="left"><font face="arial,sans-serif">RP-SN-01</font></td>
<td align="left"><font face="arial,sans-serif">Rattlesnake</font></td>
</tr>
</table>
EOF
    $exp ||= {};
    while (my($k, $v) = each(%$exp)) {
	$x =~ s/(?<=\b$k=)("?)[^"\s>]+("?)/$1$v$2/;
    }
    $x =~ s/ \w+="?NOP"?//g;
    $x =~ s/ title=//g;
    return $x;
}
