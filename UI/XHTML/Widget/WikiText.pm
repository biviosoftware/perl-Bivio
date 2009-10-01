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
my($_INLINE_RE);
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
my($_ROOT_TAG) = '#ROOT';
my($_CHILDREN) = _init_children();
my($_MY_TAGS);
_require_my_tags(__PACKAGE__);
my($_IMG) = qr{.*\.(?:jpg|gif|jpeg|png|jpe)};
my($_WIDGET_ATTRS) = [qw(value realm_id realm_name task_id is_public)];
my($_TT) = $_WN->TITLE_TAG =~ /(\w+)/;
my($_EMPTY) = {map((@{$_CHILDREN->{$_}} ? () : ($_ => 1)), keys(%$_CHILDREN))};

sub CAMEL_CASE_REGEX {
    return $_CAMEL_CASE;
}

sub DOMAIN_REGEX {
    return $_DOMAIN;
}

sub EMAIL_REGEX {
    return $_EMAIL;
}

sub IMG_REGEX {
    return $_IMG;
}

sub NEW_ARGS {
    return [qw(value ?class)];
}

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->req;
    my($args) = {
	source => $source,
	req => $req,
	map(($_ => $self->render_simple_attr($_, $source)), @$_WIDGET_ATTRS),
    };
    if (my $cc = $self->unsafe_get('calling_context')) {
	$args->{line_num} = $cc->calling_context_get('line') - 1;
	$args->{path} = $cc->calling_context_get('file');
    }
    else {
	$args->{path} = $args->{value};
    }
    $$buffer .= $self->render_html($args);
    # Don't call SUPER; we don't want html_attrs
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
#ignore leading caret
    $uri =~ s/^\^//;
    $uri = $uri =~ qr{^$_EMAIL$}o
	? "mailto:$uri"
	: $uri =~ qr{^$_DOMAIN$}o
	? 'http://' . ($uri =~ /^[^\.]+\.\w+$/s ? 'www.' : '') . $uri
	: $uri;
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

sub unsafe_load_wiki_data {
    my($proto, $path, $args) = @_;
    my($die_code);
    my($rf) = b_use('Action.WikiView')->unsafe_load_wiki_data(
	$args->{realm_id},
	$path,
	$args->{req},
	\$die_code,
    );
    _parse_err($args, $path, $die_code)
	unless $rf;
    return $rf;
}

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->put_unless_exists(
	calling_context =>
	    sub {Bivio::UI::ViewLanguageAUTOLOAD->unsafe_calling_context},
    );
    return $self;
}

sub prepare_html {
    my($proto, $arg1, $arg2, $task_id, $req) = @_;
    my($args) = $_CA->new({});
    my($rf);
    if (ref($arg1) eq 'HASH') {
	b_die($arg1, ': missing req')
	    unless $arg1->{req};
	$args->internal_put($arg1);
    }
    elsif (Bivio::UNIVERSAL->is_blessed($arg1)) {
	$rf = $arg1;
    }
    elsif (ref($arg1) eq 'SCALAR') {
	$args->put(
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
    $args->put(
	map(($_ => $rf->get($_)), @{$rf->get_keys}),
	value => ${$rf->get_content},
	req => $req = $rf->req,
	name => $_WN->from_absolute($rf->get('path')),
	path => $rf->get('path'),
    ) if $rf;
    $req ||= $args->get('req');
    $args->put_unless_exists(
	is_public => 0,
	modified_date_time => $_DT->now,
	name => '<inline>',
	realm_id => $req->get('auth_id'),
	user_id => $req->get('auth_user_id'),
	proto => $proto,
    );
    $args = $args->internal_get;
    return $args
	if defined($args->{title});
    _validator($args);
    my($v) = \$args->{value};
    if ($$v =~ s{^(
        \@${_TT}[ \t]*\S[^\r\n]+\r?\n
        | \@$_TT.*?\r?\n\@/$_TT\s*?\r?\n
    )}{}isox) {
	my($x) = $1;
	$args->{line_num} ||= 1;
	my($t) = $proto->render_html({%$args, value => $x})
	    =~ m{^<$_TT>(.*)</$_TT>$}so;
	if (defined($t)) {
	    $t =~ s/^\s+|\s+$//g;
	    $args->{title} = $t;
	}
	else {
	    _parse_err($args, $x, 'not a header pattern');
	    substr($$v, 0, 0) = $x;
	}
    }
    $args->{title} = Bivio::HTML->escape($_WN->to_title($args->{name}))
	unless defined($args->{title});
    return $args;
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
    $_CHILDREN->{$tag} = $class->EXPECTED_CHILDREN;
    # All tags can have registered tags except empty tags
    while (my($k, $v) = each(%$_CHILDREN)) {
	push(@$v, $tag)
	    if @$v;
    }
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
    my($state) = {
	%$args,
	proto => $proto,
	args => $args,
	lines => [split(/\r?\n/, $args->{value})],
	tags => [],
	attrs => [],
	html => '',
    };
    return _eval($state, _parse($state));
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
    my($args) = shift->prepare_html(@_);
    $args->{want_plain_text} = 1;
    my($body) = $_I->render_code_as_string(
	sub {$args->{proto}->render_html($args)},
	$args->{req},
	'XHTMLWidget',
    );
    $body =~ s/\n+/\n/sg;
    return ($body, $args);
}

sub _check_uri {
    my($uri, $orig, $args) = @_;
#TODO: Consider dropping this
    if ($uri =~ /^javascript:/i) {
	_parse_err($args, $orig, 'javascript links not allowed');
	return 'link-error';
    }
    $args->{validator}->validate_uri($uri, $args);
    return $uri;
}

sub _eval {
    my($state, $tree) = @_;
    return join(
	'',
	map({
	    $state->{line_num} = $_->{line_num};
	    $_->{op}->($state, $_);
	} @{$tree->{children}}),
    );
}

sub _eval_char_entity {
    my($state, $args) = @_;
    return $state->{want_plain_text}
	? Bivio::HTML->unescape($args->{content})
	: $args->{content};
}

sub _eval_literal {
    my($state, $args) = @_;
    return $state->{want_plain_text} ? $args->{content}
	: Bivio::HTML->escape($args->{content});
}

sub _eval_tag {
    my($state, $args) = @_;
    my($tag) = $args->{tag};
    my($attrs) = {%{$args->{attrs}}};
    return $_MY_TAGS->{$tag}
	? _eval_tag_custom($state, $tag, $attrs)
	: $_EMPTY->{$tag} ? ''
	: _eval($state, $args) . "\n"
	if $state->{want_plain_text};
    $attrs->{target} = '_top'
	if $tag eq 'a'
	&& ! defined($attrs->{target})
	&& defined($state->{link_target});
    foreach my $k (qw(src href)) {
	next
	    unless $attrs->{$k};
	$attrs->{$k}
	    = $state->{proto}->internal_format_uri($attrs->{$k}, $state);
    }
    return _eval_tag_custom($state, $tag, $attrs)
	if $_MY_TAGS->{$tag};
    my($start) = join(
	' ',
	$tag,
	map(
	    qq{$_="} . Bivio::HTML->escape_attr_value($attrs->{$_}) . '"',
	    sort(keys(%$attrs)),
	),
    );
    if ($_EMPTY->{$tag}) {
	_parse_err(
	    $state,
	    $tag,
	    ['empty tags are not allowed to have a value: ', $args->{children}],
	) if @{$args->{children}};
	return "<$start />";
    }
    return "<$start>" . _eval($state, $args) . "</$tag>";
}

sub _eval_tag_custom {
    my($state, $tag, $attrs) = @_;
    my($res);
    my($die) = Bivio::Die->catch_quietly(sub {
	my($method) = $state->{want_plain_text} ? 'render_plain_text'
	    : 'render_html';
        $res = $_MY_TAGS->{$tag}->$method({
	    %{$state->{args}},
	    tag => $tag,
	    attrs => $attrs,
	});
	return;
    });
    return _parse_err($state, $tag, $die)
	if $die;
    return $res;
}

sub _fix_word {
    my($word) = @_;
    $word =~ s/#/ /;
    $word =~ s/_/ /g
	if $word =~ /^\w+$/;
    return $word;
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
    $_INLINE_RE = qr{^(?:@{[join('|', grep(!/^br$/, @$Inline))]})$};
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
    my($res) = {
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
    $res->{$_ROOT_TAG} = [sort(keys(%$res))];
    return $res;
}

sub _next_line {
    my($state) = @_;
#rjn: need to be able to set the line when parsing a content item
    $state->{line_num}++;
    return shift(@{$state->{lines}});
}

sub _parse {
    my($state) = @_;
    $state->{parse} = {
	stack => [],
	options => {paragraphing => 1},
    };
    _parse_stack_push($state, my $root = {
	op => \&_eval,
	tag => $_ROOT_TAG,
    });
    while (defined(my $line = _next_line($state))) {
	if ($line =~ /^\@[a-z]/i) {
	    _parse_tag_start($state, $line);
	}
	elsif ($line =~ /^\@\/[a-z]/i) {
	    _parse_tag_end($state, $line);
	}
	else {
	    _parse_line($state, $line);
	}
    }
    delete($state->{parse});
    return $root;
}

sub _parse_child_ok {
    my($state, $tag) = @_;
    return grep($tag eq $_, @{$_CHILDREN->{_parse_stack_top($state)->{tag}}})
	? 1 : 0;
}

sub _parse_content {
    my($state, $value) = @_;
    # OPTIMIZATION: Only parse chars if magic chars appear in string at all
    my($chars) = [split('', $value)];
    my($ch);
    my($res) = '';
    my($next) = sub {
	return !@$chars ? ''
	    : ord($ch = shift(@$chars)) > 0 ? $ch
	    : _parse_err(
		$state, undef,
		[sprintf('0x%x', ord($ch)), ': invalid character']);
    };
    my($out) = sub {
	my($code, @args) = @_;
	_parse_tag_start($state, '@p.b_prose')
	    if ($code || length($res))
	    && _parse_child_ok($state, 'p')
	    && _parse_paragraphing_ok($state);
	_parse_out($state, \&_eval_literal, $res)
	    if length($res);
	$res = $ch = '';
	$ch = $code->($state, $next, @args)
	    if $code;
	unshift(@$chars, split('', $ch))
	    if length($ch);
	$ch = '';
	return;
    };
    # OPTIMIZATION: don't loop over characters if no specials
    unless ($value =~ /[\@\^\*_]/) {
	$res = $value;
	$out->();
	return 1;
    }
    my($prev);
    while (length($next->())) {
	if ($ch eq '^') {
	    $out->(\&_parse_content_link);
	}
	elsif ($ch =~ /[\*\_]/
	   && !_parse_stack_in_tag($state, qr{^(?:pre|code)$})
	) {
	    $out->(\&_parse_content_font, $ch)
		if !defined($prev) || !length($prev) || $prev =~ /\W/;
	}
	elsif ($ch eq '@') {
	    last
		unless length($next->());
	    next
		if $ch eq '@';
	    if ($ch eq '&') {
		$out->(\&_parse_content_special)
	    }
	    else {
		$ch = '@' . $ch;
	    }
	}
    }
    continue {
	$prev = $ch;
	$res .= $ch;
	$ch = '';
    }
    $out->();
    return $ch ne '@';
}

sub _parse_content_font {
    my($state, $next, $which) = @_;
    _parse_out($state, \&_eval_tag, {
	tag => $which eq '*' ? 'strong' : 'em',
	attrs => {},
    });
    my($my_op) = _parse_stack_top($state);
    my($content) = '';
    my($ch);
    my($extra) = '';
    while (length($ch = $next->())) {
	if ($ch =~ /[\*\_\s]/) {
	    last
		unless $ch eq $which;
	    $extra = '';
	    $ch = '';
	    $content .= ' ';
	}
	else {
	    $content .= $ch;
	    $extra .= $ch;
	}
    }
    substr($content, -length($extra)) = ''
	if length($extra);
    $content =~ s/\s+$//s;
    _parse_content($state, $content);
    _parse_stack_pop($state, $my_op);
    return $extra . $ch;
}

sub _parse_content_link {
    my($state, $next) = @_;
    my($link) = '';
    my($ch) = $next->();
    return _parse_out($state, \&_eval_literal, $ch)
	if $ch eq '^';
    while ($ch =~ /\S/) {
	$link .= $ch;
	last
	    unless length($ch = $next->());
    }
    $ch = ($link =~ s/([\)\]\}\>\.,:;"'`~!\|]*)$// ? $1 : '') . $ch;
    _parse_out(
	$state,
	length($link) ? (
	    \&_eval_tag,
	    $link =~ $_IMG ? {tag => 'img', attrs => {src => $link}} : (
		{tag => 'a', attrs => {href => $link}},
		_fix_word($link),
	    ),
	) : (
	    \&_eval_literal,
	    '^',
	),
    );
    return $ch;
}

sub _parse_content_special {
    my($state, $next) = @_;
    my($value) = '';
    my($ch) = $next->();
    my($pat) = qr{[a-z]}i;
    if ($ch eq '#') {
	$pat = qr{[0-9]};
	$value .= $ch;
	$ch = $next->();
    }
    while ($ch =~ $pat) {
	$value .= $ch;
	$ch = $next->();
    }
    _parse_err($state, undef, 'invalid character entity')
	unless length($value) >= ($value =~ /#/ ? 3 : 2);
    _parse_out($state, \&_eval_char_entity, "&$value;");
    return $ch eq ';' ? '' : $ch;
}

sub _parse_err {
    my($state, $object, $err) = @_;
    return $state->{proto}->render_error($object, $err, $state);
}

sub _parse_hr {
    my($state) = @_;
    _parse_tag_start($state, '@hr');
    _parse_tag_start($state, '@br');
    return;
}

sub _parse_line {
    my($state, $line) = @_;
    return
	if $line =~ /^\@\!/s;
    return _parse_line_empty($state)
        if $line =~ /^\s*$/s;
    return _parse_hr($state)
	if $line =~ /^--+\s*$/s;
    _parse_out($state, \&_eval_literal, "\n")
	if _parse_content($state, $line);
    return;
}

sub _parse_line_empty {
    my($state) = @_;
    return _parse_out($state, \&_eval_literal, "\n")
	unless _parse_paragraphing_ok($state);
    my($curr) = _parse_stack_in_tag($state, qr{^p$});
    $curr &&= $curr->{attrs}->{class};
    return _parse_tag_start(
	$state,
	'@p class="' . (defined($curr) ? $curr : 'b_prose') . '"',
    );
}

sub _parse_out {
    my($state, $op, $args, $content) = @_;
    $args = {content => $args}
	unless ref($args);
    $args->{op} = $op;
    push(@{_parse_stack_top($state)->{children}}, $args);
    _parse_stack_push($state, $args);
    if (defined($content)) {
	_parse_out($state, \&_eval_literal, $content);
	_parse_stack_pop($state, $args->{tag});
    }
    _parse_stack_pop($state, $args)
	unless $args->{tag} && !$_EMPTY->{$args->{tag}};
    return '';
}

sub _parse_paragraphing_ok {
    my($state) = @_;
    return $state->{parse}->{options}->{paragraphing}
	&& !_parse_stack_in_tag($state, qr{^(?:div|dt|h\d|pre|script|select|textarea)$})
	&& !_parse_stack_top($state, qr{^(?:ul|dl|ol)$})
	&& (
	    _parse_stack_in_tag(
		$state,
		qr{^(?:blockquote|del|dd|fieldset|form|ins|li|object|p|td)$},
	    ) || _parse_stack_top($state, $_ROOT_TAG)
	) ? 1 : 0;
}

sub _parse_stack_in_tag {
    my($state, $tag_re) = @_;
    return grep($_->{tag} =~ $tag_re, @{$state->{parse}->{stack}});
}

sub _parse_stack_pop {
    my($state, $tag) = @_;
    my($stack) = $state->{parse}->{stack};
    b_die($tag, ': stack too short')
	unless @$stack > 1;
    shift(@$stack);
    return;
}

sub _parse_stack_push {
    my($state, $args) = @_;
    $args->{line_num} = $state->{line_num};
    $args->{children} = [];
    unshift(@{$state->{parse}->{stack}}, $args);
    return;
}

sub _parse_stack_top {
    my($state, $tag) = @_;
    my($top) = $state->{parse}->{stack}->[0];
    return $top
	unless $tag;
    return $top->{tag} =~ $tag
	if ref($tag);
    return $top->{tag} eq $tag;
}

sub _parse_tag_attrs {
    my($state, $line) = @_;
    my($attrs) = {};
    $attrs->{class} = $1
	if $$line =~ s/^\.([\w\-]+)//s;
    while ($$line =~ s/^\s+(?:(?:(\w+)=)([^"\s]+)|(?:(\w+)=)"([^\"]*)("?))//s) {
	if (defined($3) && !$5) {
	    _parse_err($state, $1, 'attribute value not terminated by quote');
	    last;
	}
	$attrs->{lc($1 ? $1 : $3)} = defined($2) ? $2 : $4;
    }
    return $attrs;
}

sub _parse_tag_end {
    my($state, $line) = @_;
    return
	unless my $tag = _parse_tag_ok($state, \$line);
    return _parse_err($state, $tag, 'spurious end tag')
	unless _parse_stack_in_tag($state, qr{^$tag$});
    _parse_stack_pop($state, $tag)
	until _parse_stack_top($state, $tag);
    _parse_stack_pop($state, $tag);
    return;
}

sub _parse_tag_start {
    my($state, $line) = @_;
    return
	unless my $tag = _parse_tag_ok($state, \$line);
    my($attrs) = _parse_tag_attrs($state, \$line);
    _parse_out(
	$state,
	\&_eval_tag,
	{tag => 'p', attrs => {class => 'b_prose'}},
    ) if _parse_child_ok($state, 'p')
 	&& _parse_paragraphing_ok($state)
	&& $tag =~ $_INLINE_RE;
    _parse_stack_pop($state, $tag)
	until _parse_child_ok($state, $tag);
    _parse_out($state, \&_eval_tag, {tag => $tag, attrs => $attrs});
    $line =~ s/^\s+|\s+$//s;
    if (length($line)) {
	return _parse_err(
	    $state,
	    $tag,
	    ['empty tags are not allowed to have a value: ', $line],
	) if $_EMPTY->{$tag};
	_parse_content($state, $line);
	_parse_stack_pop($state, $tag);
    }
    return;
}

sub _parse_tag_ok {
    my($state, $line) = @_;
    $$line =~ s/^(\@\/?)([\w\-]+)//s
	|| b_die($line, ': invalid internal call');
    my($tag) = lc($2);
    return _parse_err($state, "$1$tag$$line", 'unknown tag')
	unless $_CHILDREN->{$tag};
    return $tag
}

sub _require_my_tags {
    my($proto) = @_;
    foreach my $c (@{b_use('IO.ClassLoader')->map_require_all('WikiText')}) {
	foreach my $t (@{$c->handle_register}) {
	    $proto->register_tag($t, $c);
	}
    }
    return;
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
	->unsafe_get_self($args->{path}, $args->{realm_id}, $args->{req});
}

1;
