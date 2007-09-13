# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::WikiText;
use strict;
use Bivio::Base 'Type.Text64K';
use Bivio::Mail::RFC822;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CAMEL_CASE) = qr{((?-i:[A-Z][A-Z0-9]*[a-z][a-z0-9]*[A-Z][A-za-z0-9]*))};
my($_EMAIL) = qr{@{[Bivio::Mail::RFC822->ATOM_ONLY_ADDR]}}o;
my($_DOMAIN) = qr{(@{[
    'www\.'
    . Bivio::Mail::RFC822->DOMAIN
    . '\.(?:'
    . join('|', qw(
	ar
	fm
	ma
        ms
	pl
	pm
	sh
    ))
    . ')|'
    . Bivio::Mail::RFC822->DOMAIN
    . '\.(?:'
    . join('|', qw(
	aero
	biz
	cat
	com
	coop
	edu
	gov
	info
	int
	jobs
	mil
	mobi
	museum
	name
	net
	org
	pro
	travel
	asia
	post
	tel
	geo
	ac
	ad
	ae
	af
	ag
	ai
	al
	am
	an
	ao
	aq
	as
	at
	au
	aw
	az
	ax
	ba
	bb
	bd
	be
	bf
	bg
	bh
	bi
	bj
	bm
	bn
	bo
	br
	bs
	bt
	bv
	bw
	by
	bz
	ca
	cd
	cf
	cg
	ch
	ci
	ck
	cl
	cm
	cn
	co
	cr
	cs
	cu
	cv
	cx
	cy
	cz
	de
	dj
	dk
	dm
	do
	dz
	ec
	ee
	eg
	eh
	er
	es
	et
	eu
	fi
	fj
	fk
	fo
	fr
	ga
	gb
	gd
	ge
	gf
	gg
	gh
	gi
	gl
	gm
	gn
	gp
	gq
	gr
	gs
	gt
	gu
	gw
	gy
	hk
	hm
	hn
	hr
	ht
	hu
	id
	ie
	il
	im
	in
	io
	iq
	ir
	is
	it
	je
	jm
	jo
	jp
	ke
	kg
	kh
	ki
	km
	kn
	kp
	kr
	kw
	ky
	kz
	la
	lb
	lc
	li
	lk
	lr
	ls
	lt
	lu
	lv
	ly
	mc
	md
	mg
	mh
	mk
	ml
	mm
	mn
	mo
	mp
	mq
	mr
	mt
	mu
	mv
	mw
	mx
	my
	mz
	na
	nc
	ne
	nf
	ng
	ni
	nl
	no
	np
	nr
	nu
	nz
	om
	pa
	pe
	pf
	pg
	ph
	pk
	pn
	pr
	ps
	pt
	pw
	py
	qa
	re
	ro
	ru
	rw
	sa
	sb
	sc
	sd
	se
	sg
	si
	sj
	sk
	sl
	sm
	sn
	so
	sr
	st
	sv
	sy
	sz
	tc
	td
	tf
	tg
	th
	tj
	tk
	tl
	tm
	tn
	to
	tp
	tr
	tt
	tv
	tw
	tz
	ua
	ug
	uk
	um
	us
	uy
	uz
	va
	vc
	ve
	vg
	vi
	vn
	vu
	wf
	ws
	ye
	yt
	yu
	za
	zm
	zw
    )) . ')'
]})}x;
my($_PHRASE) = _hash([qw(
    a
    abbr
    acronym
    cite
    code
    del
    dfn
    em
    ins
    kbd
    q
    samp
    small
    span
    strong
    sub
    sup
    var
)], []);
my($_EMPTY) = _hash([qw(br hr img)], []);
my($_BLOCK) = _hash([qw(
    blockquote
    center
    div
    h1
    h2
    h3
    h4
    h5
    h6
    p
    li
    dt
    dd
    dl
    ol
    ul
    table
    tr
    td
    th
    tbody
    tfoot
    thead
    colgroup
    col
    caption
    pre
)], [keys(%$_PHRASE), qw(p h1 h2 h3 h4 h5 h6)]);
foreach my $x (
    map([$_ => qw(tbody thead tfoot td tr th col colgroup)],
	qw(table tbody thead tfoot colgroup)),
    [col => qw(col)],
    [tr => qw(tr td th)],
    [td => qw(td th)],
    [th => qw(td th)],
    map([$_ => qw(dt dd)], qw(dl dt dd)),
    map([$_ => qw(li)], qw(ul ol li)),
) {
    my($t) = shift(@$x);
    foreach my $y (@$x) {
	$_BLOCK->{$t}->{$y} = 1;
    }
}
# These elements nest
foreach my $t (qw(table dl ul ol div)) {
    delete($_BLOCK->{$t}->{$t});
}
my($_TAGS) = {%$_EMPTY, %$_BLOCK, %$_PHRASE};
my($_CLOSE_ALL) = {map(($_ => 1), keys(%$_TAGS))};
my($_IMG) = qr{.*\.(?:jpg|gif|jpeg|png|jpe)};
my($_HREF) = qr{^(\W*(?:\w+://\w.+|/\w.+|$_IMG|$_EMAIL|$_DOMAIN|$_CAMEL_CASE)\W*$)};
Bivio::IO::Config->register(my $_CFG = {
    deprecated_auto_link_mode => 0,
});
my($_MY_TAGS) = {};
Bivio::IO::ClassLoader->map_require_all('WikiText');

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub register_tag {
    my($self, $tag, $class) = @_;
    $tag = lc($tag);
    Bivio::Die->die($tag, ': invalid tag format: ', $class)
        unless $tag =~ /^[a-z][-\w]+$/ && $tag =~ /-/;
    Bivio::Die->die($class, ': does not implement render_html')
	unless $class->can('render_html');
    Bivio::Die->die(
	$tag, ': already registered by ', $_MY_TAGS->{$tag},
	' cannot register to: ', $class,
    ) if $_MY_TAGS->{$tag}
        && $_MY_TAGS->{$tag}->simple_package_name
	ne $class->simple_package_name;
    # Super class will register first so we always override
    $_MY_TAGS->{$tag} = $class;
    return;
}

sub render_html {
    my($self, $args) = @_;
    unless (ref($args) eq 'HASH') {
	my(undef, $value, $name, $req, $task_id, $no_auto_links) = @_;
	Bivio::IO::Alert->warn_deprecated('pass a hash, not positional');
	$args = {
	    value => ref($value) ? $$value : $value,
	    name => $name,
	    req => $req,
	    task_id => $task_id,
	    no_auto_links => $no_auto_links,
	};
    }
    $args->{no_auto_links} ||= !$_CFG->{deprecated_auto_link_mode};
    $args->{task_id} ||= $args->{req}->get('task_id');
    $args->{realm_id} ||= $args->{req}->get('auth_id');
    $args->{is_public} = 1
	unless defined($args->{is_public});
    $args->{prefix_word_mode} = $args->{no_auto_links}
	|| $args->{value} =~ /\^/s ? 1 : 0;
    my($state) = {
	%$args,
	args => $args,
	lines => [split(/\r?\n/, $args->{value})],
	line_num => 0,
	tags => [],
	attrs => [],
	html => '',
    };
    while (defined(my $line = _next_line($state))) {
	$state->{html} .= $line =~ s/^\@// ? _fmt_tag($line, $state)
	    : _fmt_line($line, $state);
    }
    _close_tags($_CLOSE_ALL, $state);
    return $state->{html};
}

sub _abs_href {
    my($uri, $state) = @_;
    $uri =~ s/^(?=javascript:)/no-wiki-/;
    return $uri =~ m{[/:]} ? Bivio::UI::Task->format_uri({
	uri => $uri,
    }) : $state->{req}->format_uri({
	task_id => $state->{task_id},
	query => undef,
	path_info => $uri,
    });
}

sub _close_top {
    my($tag, $state) = @_;
    if (($state->{tags}->[0] || '') eq $tag) {
	$state->{html} .= '</' . shift(@{$state->{tags}}) . '>';
	shift(@{$state->{attrs}});
#TODO: This "class="prose"" is a pain
	$state->{html} =~ s{<p(?: class="prose")?></p>$}{}s
	    if $tag eq 'p';
    }
    return '';
}

sub _close_tags {
    my($to_close, $state, $attrs) = @_;
    $to_close = $_TAGS->{$to_close}
	unless ref($to_close);
    my($tags) = $state->{tags};
    while (@$tags && $to_close->{$tags->[0]}) {
	$$attrs = $state->{attrs}->[0]
	    if $attrs;
	_close_top($tags->[0], $state);
    }
    return '';
}

sub _fmt_err {
    my($line, $err, $state) = @_;
    $state->{req}->warn(
	$state->{name}, ', line ', $state->{line_num}, ': ',
	$err, ' data="', $line, '"');
    return '';
}

sub _fmt_href {
    my($tok, $state) = @_;
    return $tok
	if ($state->{tags}->[0] || '') eq 'a';
    my($notwiki) = '\=';
    if ($tok =~ s{(^\W*)$notwiki(\S+)$notwiki(\W*$)}{
	"$1" . join(' ', split(/$notwiki/, $2)) . "$3"
    }e) {
	return $tok;
    }
    $tok = Bivio::HTML->unescape($tok);
    unless ($state->{prefix_word_mode} ? $tok =~ s{^\^}{}o && $tok !~ /^\^/
	    : $tok =~ $_HREF) {
	$tok = shift(@_);
	$tok =~ s{^\^}{}o;
	return $tok;
    }
    # Any &'s were turned into &amp;
    # The trailing punctuation can't be everything, because http://a//? is a
    # legitimate URI.
    my($s, $m, $e) = $tok =~ m#(^[^\w/]*)(.+?)([\)\]\}\>\.,:;"'`~!\|]*$)#;
    return Bivio::HTML->escape($s)
	. ($m =~ $_IMG
	? qq{<img src="}
	  . Bivio::HTML->escape_attr_value(_abs_href($m, $state))
	  . qq{" />}
	: ( '<a href="'
	    . Bivio::HTML->escape_attr_value(
		_abs_href(
		    $m =~ qr{^$_EMAIL$}o ? "mailto:$m"
		    : $m =~ qr{^$_DOMAIN$}o ? "http://$m"
		    : $m,
		    $state,
	        )
	    ) . '">'
	    . Bivio::HTML->escape($m)
	    . '</a>'
        )) . Bivio::HTML->escape($e);
}

sub _fmt_line {
    my($line, $state) = @_;
    $line =~ s{^\s+|\s+$}{}sg;
    if (!length($line) || $line =~ s{^--+$}{<hr /><br />\n}) {
	my($attrs);
	_close_tags('p', $state, \$attrs);
	$state->{html} .= $line;
	return defined($attrs) ? _start_tag('p', $attrs, $state) : '';
    }
    my($nl) = $line =~ s/\@$// ? '' : "\n";
    _start_p($state);
    $line = Bivio::HTML->escape($line);
    $line =~ s{(\S+)}{_fmt_token($1, $state)}eg;
    return $line . $nl;
}

sub _fmt_pre {
    my($line, $state) = @_;
    my($tag) = $state->{tags}->[0];
    my($res) = '';
    if (length($line)) {
	$state->{html} .= Bivio::HTML->escape($line);
	$res = "\n";
    }
    else {
	$state->{html} .= "\n" . Bivio::HTML->escape($line) . "\n"
	    while defined($line = _next_line($state))
		&& $line !~ m{^\@/$tag\s*$};
    }
    _close_top($tag, $state);
    return $res;
}

sub _fmt_tag {
    my($line, $state) = @_;
    return "\n"
	if $line =~ /^\s*$/;
    return "$1"
	if $line =~ /^(\&\w+\;|\&\#\d+\;)/;
    return ''
	if $line =~ /^\!/;
    return _fmt_line($line, $state)
	if $line =~ /^@/;
#TODO: Special tags need some distinctive identifier.  ins-page does
#      does not collide with the space of HTML tags.  This is hardwired
#      because only one, generalize when needed.
    return _fmt_err($line, 'invalid syntax', $state)
        unless $line =~ s{^(/?)([-\w]+)(?:\.([-\w]+))?(?=\s|$)}{};
    my($close) = $1;
    my($tag) = lc($2);
    my($class) = $3;
    return _fmt_err($close . $tag . $line, 'unknown tag', $state)
	unless $_MY_TAGS->{$tag} || $_TAGS->{$tag};
    _close_tags($tag, $state);
    return _close_top($tag, $state)
	if $close;
    my($attrs) = defined($class) && length($class) ? {class => $class} : {};
    while ($line =~ s/^\s+(?:(?:(\w+)=)([^"\s]+)|(?:(\w+)=)"([^\"]+)")//) {
	$attrs->{lc($1 ? $1 : $3)} = defined($2) ? $2 : $4;
    }
    $line =~ s/^\s+|\s+$//g;
    my($nl) = $line =~ s/\@$// ? '' : "\n";
    if ($_MY_TAGS->{$tag}) {
	my($res);
	my($die) = Bivio::Die->catch(sub {
            $res = $_MY_TAGS->{$tag}->render_html({
		%{$state->{args}},
		value => $line,
		tag => $tag,
		attrs => $attrs,
	    });
	    return;
        });
	return _fmt_err($line, $die->as_string, $state)
	    if $die;
	return $res . $nl;
    }
    my($attrs_string) = '';
    foreach my $k (sort(keys(%$attrs))) {
	$attrs_string .= ' ' . lc($k) . '="'
	    . Bivio::HTML->escape_attr_value(
		$k =~ /^(?:src|href)$/ ? _abs_href($attrs->{$k}, $state)
	        : $attrs->{$k}
	    ) . '"';
    }
    return "<$tag$attrs_string />$nl"
	if $_EMPTY->{$tag};
    _start_p($state)
	if $_PHRASE->{$tag};
    $state->{html} .= _start_tag($tag, $attrs_string, $state);
    return _fmt_pre($line, $state)
	if $tag =~ /^(?:pre|code)$/;
    if (length($line)) {
 	$state->{html} .= _fmt_line($line, $state);
	chomp($state->{html});
	_close_top($tag, $state);
	$state->{html} .= $nl;
    }
    $state->{html} .= _start_tag('p', '', $state)
	if $tag =~ /^(?:td|th|li|dd|dt|blockquote|center)$/;
    return '';
}

sub _fmt_token {
    my($tok, $state) = @_;
    my($hit) = 0;
    foreach my $x (
	[qw(\* strong)],
	[qw(\_ em)],
    ) {
	my($c, $h) = @$x;
	$tok =~ s{(^\W*)$c(\S+)$c(\W*$)}{
	    "$1<$h>" . join(' ', split(/$c/, _fmt_href($2, $state))) . "</$h>$3"
	}e && $hit++;
    }
    return $hit ? $tok : _fmt_href($tok, $state);
}

sub _hash {
    my($a, $b) = @_;
    return {map(($_ => +{map(($_ => 1), @$b, $_)}), @$a)};
}

sub _ins_page {
    my($line, $state) = @_;
#TODO: Could generalize to any URI.  For now, just local.
    return _fmt_err($line, 'invalid URI, must begin with a /', $state)
	unless $line =~ s{^/+}{/};
    my($res);
    my($die) = Bivio::Die->catch(sub {
        # Missing leading /', just put in my
        (my $uri = $line) =~ s{(?<=^/)my(?=/)}{
	    $state->{req}->get_nested(qw(auth_realm owner name))
	}sex;
	$res = Bivio::IO::ClassLoader->simple_require(
	    'Bivio::Agent::Embed::Dispatcher'
	)->call_task($state->{req}, $state->{req}->format_uri({
	    uri => $uri,
	    no_context => 1,
	    query => undef,
	    path_info => undef,
	}));
	return;
    });
    return _fmt_err($line, $die->as_string, $state)
	if $die;
    return $$res;
}

sub _next_line {
    my($state) = @_;
    $state->{line_num}++;
    return shift(@{$state->{lines}});
}

sub _start_p {
    my($state) = @_;
    $state->{html} .= _start_tag('p', ' class="prose"', $state)
	unless $state->{tags}->[0];
    return '';
}

sub _start_tag {
    my($tag, $attrs, $state) = @_;
    unshift(@{$state->{tags}}, $tag);
    unshift(@{$state->{attrs}}, $attrs);
    return "<$tag$attrs>";
}

1;
