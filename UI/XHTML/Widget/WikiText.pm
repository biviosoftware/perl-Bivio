# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText;
use strict;
use Bivio::Base 'XHTMLWidget.ControlBase';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_A) = b_use('IO.Alert');
my($_C) = b_use('IO.Config');
my($_CA) = b_use('Collection.Attributes');
my($_DT) = b_use('Type.DateTime');
my($_FCC) = b_use('FacadeComponent.Constant');
my($_I) = b_use('View.Inline');
my($_RF) = b_use('Action.RealmFile');
my($_RFC) = b_use('Mail.RFC822');
my($_T) = b_use('FacadeComponent.Task');
my($_TI) = b_use('Agent.TaskId');
my($_V) = b_use('UI.View');
my($_WDN) = b_use('Type.WikiDataName');
my($_WN) = b_use('Type.WikiName');
my($_WV);
my($_REALM_PLACEHOLDER) = b_use('Type.RealmName')->SPECIAL_PLACEHOLDER;
my($_CAMEL_CASE) = qr{((?-i:[A-Z][A-Z0-9]*[a-z][a-z0-9]*[A-Z][A-za-z0-9]*))};
my($_EMAIL) = qr{@{[$_RFC->ATOM_ONLY_ADDR]}}o;
my($_DOMAIN) = qr{(@{[
    'www\.'
    . $_RFC->DOMAIN
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
    . $_RFC->DOMAIN
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
my($_CHILDREN) = _init_children();
my($_EMPTY) = {map((@{$_CHILDREN->{$_}} ? () : ($_ => 1)), keys(%$_CHILDREN))};
my($_IMG) = qr{.*\.(?:jpg|gif|jpeg|png|jpe)};
my($_HREF) = qr{^(\W*(?:\w+://\w.+|/\w.+|$_IMG|$_EMAIL|$_DOMAIN|$_CAMEL_CASE)\W*$)};
my($_WIDGET_ATTRS) = [qw(value realm_id realm_name task_id)];
my($_MY_TAGS);
_require_my_tags(__PACKAGE__);
$_C->register(my $_CFG = {
    deprecated_auto_link_mode => 0,
});
my($_TT) = $_WN->TITLE_TAG =~ /(\w+)/;

sub NEW_ARGS {
    return [qw(value ?class)];
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->req;
    my($a) = {
	source => $source,
	req => $req,
	map(($_ => $self->render_simple_attr($_, $source)), @$_WIDGET_ATTRS),
    };
    if (my $cc = $self->unsafe_get('calling_context')) {
	$a->{line_num} = $cc->calling_context_get('line') - 1;
	$a->{path} = $cc->calling_context_get('file');
    }
    else {
	$a->{path} = $a->{value};
    }
    $$buffer .= $self->render_html($a);
    # Don't call SUPER; we don't want html_attrs
    return;
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub initialize {
    my($self) = @_;
    $self->map_invoke(unsafe_initialize_attr => $_WIDGET_ATTRS);
    return shift->SUPER::initialize(@_);
}

sub internal_format_uri {
    my($proto, $uri, $args) = @_;
    my($orig) = $uri;
    if ($uri =~ s/^\^//) {
	$uri = $uri =~ qr{^$_EMAIL$}o
	    ? "mailto:$uri"
	    : $uri =~ qr{^$_DOMAIN$}o
	    ? 'http://' . ($uri =~ /^[^\.]+\.\w+$/s ? 'www.' : '') . $uri
	    : $uri;
    }
    $uri =~ s/#([a-z][a-z0-9_:\.-]*)$//is;
    my($anchor) = $1 ? "#$1" : '';
    return _check_uri(
	$uri =~ m{^/+$_REALM_PLACEHOLDER(/.+)}os && $args->{realm_name}
	? $_T->format_uri({uri => "/$args->{realm_name}$1"}, $args->{req})
	: $uri =~ m{[/:]}
	? $_T->format_uri({uri => $uri}, $args->{req})
	: $uri =~ /\./ ? $_WDN->format_uri($uri, $args)
	: $args->{req}->format_uri({
	    task_id => $args->{task_id},
	    realm => $args->{realm_name},
	    query => undef,
	    path_info => $uri,
	}),
	$orig,
	$args,
    ) . $anchor;
}

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->put_unless_exists(
	calling_context =>
	    Bivio::UI::ViewLanguageAUTOLOAD->calling_context_of_new,
    );
    return $self;
}

sub prepare_html {
    my($proto, $arg1, $arg2, $task_id, $req) = @_;
    my($a) = $_CA->new({});
    my($rf);
    if (ref($arg1) eq 'HASH') {
	b_die($arg1, ': missing req')
	    unless $arg1->{req};
	$a->internal_put($arg1);
    }
    elsif (Bivio::UNIVERSAL->is_blessed($arg1)) {
	$rf = $arg1;
    }
    elsif (ref($arg1) eq 'SCALAR') {
	$a->put(
	    value => $$arg1,
	    req => $arg2,
	);
    }
    elsif (ref($arg1)) {
	b_die($arg1, ': invalid first argument');
    }
    else {
	$rf = $_RF->access_controlled_load(
	    $arg1, $_WN->to_absolute($arg2), $req);
    }
    $a->put(
	map(($_ => $rf->get($_)), @{$rf->get_keys}),
	value => ${$rf->get_content},
	req => $req = $rf->req,
	name => $_WN->from_absolute($rf->get('path')),
	path => $rf->get('path'),
    ) if $rf;
    $req ||= $a->get('req');
    $a->put_unless_exists(
	is_public => 0,
	modified_date_time => $_DT->now,
	name => '<inline>',
	realm_id => $req->get('auth_id'),
	user_id => $req->get('auth_user_id'),
	proto => $proto,
    );
    $a = $a->internal_get;
    return $a
	if defined($a->{title});
    _validator($a);
    my($v) = \$a->{value};
    if ($$v =~ s{^(
        \@${_TT}[ \t]*\S[^\r\n]+\r?\n
        | \@$_TT.*?\r?\n\@/$_TT\s*?\r?\n
    )}{}isox) {
	my($x) = $1;
	$a->{line_num} ||= 1;
	my($t) = $proto->render_html({%$a, value => $x})
	    =~ m{^<$_TT>(.*)</$_TT>$}so;
	if (defined($t)) {
	    $t =~ s/^\s+|\s+$//g;
	    $a->{title} = $t;
	}
	else {
	    $proto->render_error($x, 'not a header pattern', $a);
	    substr($$v, 0, 0) = $x;
	}
    }
    $a->{title} = Bivio::HTML->escape($_WN->to_title($a->{name}))
	unless defined($a->{title});
    return $a;
}

sub register_tag {
    my(undef, $tag, $class) = @_;
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

sub render_error {
    my(undef, $object, $err, $state) = @_;
    $state->{validator}->validate_error($object, $err, $state);
    return '';
}

sub render_html {
    my($proto, $args) = @_;
    unless (ref($args) eq 'HASH') {
	my(undef, $value, $name, $req, $task_id, $no_auto_links) = @_;
	Bivio::IO::Alert->warn_deprecated('pass a hash, not positional');
	$args = {
	    value => ref($value) ? $$value : $value,
	    name => $name,
	    req => $req,
	    source => $req,
	    task_id => $task_id,
	    no_auto_links => $no_auto_links,
	};
    }
    _validator($args);
    $args->{name} ||= '<inline>';
    $args->{path} ||= $args->{name};
    $args->{source} ||= $args->{req};
    $args->{proto} = $proto;
    $args->{no_auto_links} ||= !$_CFG->{deprecated_auto_link_mode};
    $args->{task_id} = _task_id($args)
	unless ref($args->{task_id});
    $args->{realm_id} ||= $args->{req}->get('auth_id');
    $args->{line_num} ||= 0;
    unless ($args->{realm_name}) {
	my($ro) = Bivio::Biz::Model->new($args->{req}, 'RealmOwner');
	$args->{realm_name} = $ro->get('name')
	    if $ro->unauth_load({realm_id => $args->{realm_id}});
    }
    $args->{is_public} = 1
	unless defined($args->{is_public});
    $args->{prefix_word_mode} = $args->{no_auto_links}
	|| $args->{value} =~ /\^/s ? 1 : 0;
    my($state) = {
	%$args,
#TODO: use $args->{proto} so don't have to pass both proto & args
	proto => $proto,
	args => $args,
	lines => [split(/\r?\n/, $args->{value})],
	tags => [],
	attrs => [],
	html => '',
    };
    while (defined(my $line = _next_line($state))) {
	$state->{html} .= $line =~ s/^\@// ? _fmt_tag($line, $state)
	    : _fmt_line($line, $state);
    }
    while ($state->{tags}->[0]) {
	_close_top($state->{tags}->[0], $state);
    }
    return $state->{html};
}

sub render_html_without_view {
    my($args) = shift->prepare_html(@_);
    # Generate unique symbol related to this module
    return (
	$_I->render_code_as_string(
	    sub {$args->{proto}->render_html($args)},
	    $args->{req},
	    'XHTMLWidget',
	),
	$args,
    );
}

sub render_plain_text {
    my($body, $wa) = shift->render_html_without_view(@_);
    $body =~ s{</p>}{\n}g;
    $body =~ s{<[^>]+>}{}g;
    $body =~ s{\n+$}{}s;
    return (Bivio::HTML->unescape($body), $wa);
}

sub _check_uri {
    my($uri, $orig, $args) = @_;
#TODO: Consider dropping this
    if ($uri =~ /^javascript:/i) {
	_fmt_err($orig, 'javascript links not allowed', $args);
	return 'link-error';
    }
    $args->{validator}->validate_uri($uri, $args);
    return $uri;
}

sub _close_implicit_tags {
    my($end_tag, $state) = @_;
    my($tags) = $state->{tags};
    return ''
	unless grep($end_tag eq $_, @$tags);
    while (@$tags && ($tags->[0] || '') ne $end_tag) {
	_close_top($tags->[0], $state);
    }
    return @$tags ? _close_top($end_tag, $state) : '';
}

sub _close_not_nestable_tags {
    my($start_tag, $state) = @_;
    return ''
	if $_MY_TAGS->{$start_tag};
    my($tags) = $state->{tags};
    while (@$tags) {
	my($t) = $tags->[0];
	last
	    if grep($start_tag eq $_, @{$_CHILDREN->{$t}});
	_close_top($t, $state);
    }
    return '';
}

sub _close_p {
    my($state, $attrs) = @_;
    my($tags) = $state->{tags};
    while (@$tags) {
	my($t) = $tags->[0];
	last
	    unless grep($t eq $_, @{$_CHILDREN->{p}}, 'p');
	$$attrs = $state->{attrs}->[0]
	    if $attrs;
	_close_top($t, $state);
	last
	    if $t eq 'p';
    }
    return '';
}

sub _close_top {
    my($tag, $state) = @_;
    if (($state->{tags}->[0] || '') eq $tag) {
	$state->{html} .= '</' . shift(@{$state->{tags}}) . '>';
	shift(@{$state->{attrs}});
#TODO: This "class="b_prose"" is a pain
	$state->{html} =~ s{<p(?: class="(?:b_)?prose")?></p>$}{}s
	    if $tag eq 'p';
    }
    return '';
}

sub _empty_tag {
    my($tag, $attrs_string, $line, $nl, $state) = @_;
    return "<$tag$attrs_string"
	. ' />'
	. (length($line)
	       ? "<!--IGNORED-TAG-VALUE=" . Bivio::HTML->escape($line) . '-->'
	       : "")
	. "$nl";
}

sub _fix_word {
    my($word) = @_;
    $word =~ s/#/ /;
    $word =~ s/_/ /g
	if $word =~ /^\w+$/;
    return $word;
}

sub _fmt_err {
    my(undef, undef, $args) = @_;
    return $args->{proto}->render_error(@_);
}

sub _fmt_href {
    my($tok, $state) = @_;
    return $tok
	if ($state->{tags}->[0] || '') eq 'a' && $tok !~ /^\^/;
    my($notwiki) = '\=';
    if ($tok =~ s{(^\W*)$notwiki(\S+)$notwiki(\W*$)}{
	"$1" . join(' ', split(/$notwiki/, $2)) . "$3"
    }e) {
	return $tok;
    }
    $tok = Bivio::HTML->unescape($tok);
    unless ($state->{prefix_word_mode} ? $tok =~ s{^\^}{} && $tok !~ /^\^/
	    : $tok =~ $_HREF) {
	$tok = shift(@_);
	$tok =~ s{^\^}{}o;
	return $tok;
    }
    # Any &'s were turned into &amp;
    # The trailing punctuation can't be everything, because http://a//? is a
    # legitimate URI.
    my($s, $m, $e) = $tok =~ m{(^[^\w/]*)(.+?)([\)\]\}\>\.,:;"'`~!\|]*$)};
    return ''
	unless defined($e);
    return Bivio::HTML->escape($s)
	. ($m =~ $_IMG
	? qq{<img src="}
	  . Bivio::HTML->escape_attr_value(
	      $state->{proto}->internal_format_uri("^$m", $state))
	  . qq{" />}
	: ( '<a href="'
	    . Bivio::HTML->escape_attr_value(
		$state->{proto}->internal_format_uri("^$m", $state))
	    . '"'
	    . ($state->{link_target}
		? ' target="'
		    . Bivio::HTML->escape_attr_value($state->{link_target})
		    . '"'
		: '')
	    . '>'
	    . Bivio::HTML->escape(_fix_word($m))
	    . '</a>'
        )) . Bivio::HTML->escape($e);
}

sub _fmt_line {
    my($line, $state) = @_;
    $line =~ s{^\s+|\s+$}{}sg;
    if (!length($line) || $line =~ s{^--+$}{<hr /><br />\n}) {
	my($attrs);
	_close_p($state, \$attrs);
	$state->{html} .= $line;
	return defined($attrs) ? _start_tag('p', $attrs, $state) : '';
    }
    my($nl) = $line =~ s/\@$// ? '' : "\n";
    _start_p($state);
    $line = Bivio::HTML->escape($line);
    $line =~ s{\^\&amp;(\#?\w+;)}{\&$1}g;
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
	unless $_MY_TAGS->{$tag} || $_CHILDREN->{$tag};
    return _close_implicit_tags($tag, $state)
	if $close;
    _close_not_nestable_tags($tag, $state);
    my($attrs) = defined($class) && length($class) ? {class => $class} : {};
    while ($line =~ s/^\s+(?:(?:(\w+)=)([^"\s]+)|(?:(\w+)=)"([^\"]*)")//) {
	my($k) = lc($1 ? $1 : $3);
	my($v) = defined($2) ? $2 : $4;
	$attrs->{$k} = $k =~ /^(?:src|href)$/
	    ? $state->{proto}->internal_format_uri($v, $state)
	    : $v;
    }
    $attrs->{target} = '_top'
	if $tag eq 'a'
	&& ! defined($attrs->{target})
	&& defined($state->{link_target});
    $line =~ s/^\s+|\s+$//g;
    my($nl) = $line =~ s/\@$// ? '' : "\n";
    if ($_MY_TAGS->{$tag}) {
	my($res);
	my($die) = Bivio::Die->catch_quietly(sub {
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
	    . Bivio::HTML->escape_attr_value($attrs->{$k}) . '"';
    }
    return _empty_tag($tag, $attrs_string, $line, $nl, $state)
	if $_EMPTY->{$tag};
    #TODO: This is wrong.  <p> is allowed inside <del> and <ins> but not in any
    #of the other tags in $_PHRASE
    _start_p($state)
	if grep($tag eq $_, @{$_CHILDREN->{p}});
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

sub _init_children {
    # From the XHTML DTD 1.0
    my($special_pre) = ['br', 'span', 'bdo', 'map'];
    my($special) = [@$special_pre, 'object', 'img'];
    my($fontstyle) = ['tt', 'i', 'b', 'big', 'small'];
    my($phrase) = ['em', 'strong', 'dfn', 'code', 'q', 'samp', 'kbd', 'var', 'cite', 'abbr', 'acronym', 'sub', 'sup'];
    my($inline_forms) = ['input', 'select', 'textarea', 'label', 'button'];
    my($misc_inline) = ['ins', 'del', 'script'];
    my($misc) = ['noscript', @$misc_inline];
    my($inline) = ['a', @$special, @$fontstyle, @$phrase, @$inline_forms];
    my($Inline) = [@$inline, @$misc_inline];
    my($heading) = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];
    my($lists) = ['ul', 'ol', 'dl'];
    my($blocktext) = ['pre', 'hr', 'blockquote', 'address'];
    my($block) = ['p', @$heading, 'div', @$lists, @$blocktext, 'fieldset', 'table'];
    my($Block) = [@$block, 'form', @$misc];
    my($Flow) = [@$block, 'form', @$inline, @$misc];
    my($a_content) = [@$special, @$fontstyle, @$phrase, @$inline_forms, @$misc_inline];
    my($pre_content) = ['a', @$fontstyle, @$phrase, @$special_pre, @$misc_inline, @$inline_forms];
    my($form_content) = [@$block, @$misc];
    my($button_content) = ['p', @$heading, 'div', @$lists, @$blocktext, 'table', @$special, @$fontstyle, @$phrase, @$misc];
    return {
	a => $a_content,
	abbr => $Inline,
	acronym => $Inline,
	address => $Inline,
	bdo => $Inline,
	big => $Inline,
	blockquote => $Block,
	br => [],
	button => $button_content,
	caption => $Inline,
	cite => $Inline,
	code => $Inline,
	col => [],
	colgroup => [qw(col)],
	dd => $Flow,
	del => $Flow,
	dfn => $Inline,
	div => $Flow,
	dl => [qw(dt dd)],
	dt => $Inline,
	em => $Inline,
	fieldset => ['legend', @$block, 'form', @$inline, @$misc],
	form => $form_content,
	h1 => $Inline,
	h2 => $Inline,
	h3 => $Inline,
	h4 => $Inline,
	h5 => $Inline,
	h6 => $Inline,
	hr => [],
	img => [],
	input => [],
	ins => $Flow,
	kbd => $Inline,
	label => $Inline,
	legend => $Inline,
	li => $Flow,
	object => ['param', @$block, 'form', @$inline, @$misc],
	ol => [qw(li)],
	optgroup => [qw(option)],
	option => ['#PCDATA'],
	p => $Inline,
	param => [],
	pre => $pre_content,
	q => $Inline,
	samp => $Inline,
	select => [qw(optgroup option)],
	small => $Inline,
	span => $Inline,
	strong => $Inline,
	sub => $Inline,
	sup => $Inline,
	table => [qw(caption col colgroup thead tfoot tbody tr)],
	tbody => [qw(tr)],
	td => $Flow,
	textarea => ['#PCDATA'],
	tfoot => [qw(tr)],
	th => $Flow,
	thead => [qw(tr)],
	tr => [qw(th td)],
	ul => [qw(li)],
	var => $Inline,
    };
}

sub _next_line {
    my($state) = @_;
    $state->{line_num}++;
    return shift(@{$state->{lines}});
}

sub _require_my_tags {
    my($proto) = @_;
    foreach my $c (@{Bivio::IO::ClassLoader->map_require_all('WikiText')}) {
	foreach my $t (@{$c->handle_register}) {
	    $proto->register_tag($t, $c);
	}
    }
    return;
}

sub _start_p {
    my($state) = @_;
    $state->{html} .= _start_tag(
	'p',
	$_C->if_version(6, ' class="b_prose"', ' class="prose"'),
	$state,
    ) unless $state->{tags}->[0];
    return '';
}

sub _start_tag {
    my($tag, $attrs, $state) = @_;
    unshift(@{$state->{tags}}, $tag);
    unshift(@{$state->{attrs}}, $attrs);
    return "<$tag$attrs>";
}

sub _task_id {
    my($args) = @_;
    return $_TI->from_any($args->{task_id})
	if $args->{task_id};
    my($t) = $args->{req}->get('task_id');
#TODO: This is really dicey
    return $t->get_name =~ /BLOG|WIKI|HELP/ ? $t : 'FORUM_WIKI_VIEW';
}

sub _validator {
    my($args) = @_;
#TODO: This should be encapsulated in validator
    return $args->{validator} ||= ($_WV ||= b_use('Action.WikiValidator'))
	->unsafe_get_self($args->{path}, $args->{req});
}

1;
