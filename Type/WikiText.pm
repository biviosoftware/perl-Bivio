# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::WikiText;
use strict;
use base 'Bivio::Type::Text64K';
use Bivio::Mail::RFC822;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = Bivio::Type->get_instance('WikiName')->REGEX;
my($_EMAIL) = qr{@{[Bivio::Mail::RFC822->ATOM_ONLY_ADDR]}}o;
my($_DOMAIN) = qr{@{[Bivio::Mail::RFC822->DOMAIN]}\.[a-z]{2,}}o;
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
my($_IMG) = __PACKAGE__->IMAGE_REGEX;

sub IMAGE_REGEX {
    return qr{\.(?:jpg|gif|jpeg|png|jpe)$};
}

sub render_html {
    my($self, $value) = @_;
    my($state) = {
	lines => [split(/\r?\n/, ref($value) ? $$value : $value)],
	tags => [],
	html => '',
    };
    while (defined(my $line = _next_line($state))) {
	$state->{html} .= $line =~ s/^\@// ? _fmt_tag($line, $state)
	    : _fmt_line($line, $state);
    }
    _close_tags($_CLOSE_ALL, $state);
    return $state->{html};
}

sub _close_top {
    my($tag, $state) = @_;
    $state->{html} .= '</' . shift(@{$state->{tags}}) . '>'
	if ($state->{tags}->[0] || '') eq $tag;
    $state->{html} =~ s{<$tag></$tag>$}{}s;
    return '';
}

sub _close_tags {
    my($to_close, $state) = @_;
    $to_close = $_TAGS->{$to_close}
	unless ref($to_close);
    my($tags) = $state->{tags};
    while (@$tags && $to_close->{$tags->[0]}) {
	_close_top($tags->[0], $state);
    }
    return '';
}

sub _fmt_href {
    my($tok) = @_;
    $tok = Bivio::HTML->unescape($tok);
    return shift(@_)
	unless $tok =~ m{(^\W*(?:\w+://\w.+|/\w.+|$_EMAIL|$_DOMAIN|$_WN)\W*$)};
    # Any &'s were turned into &amp;
    # The trailing punctuation can't be everything, because http://a//? is a
    # legitimate URI.
    my($s, $m, $e) = $tok =~ m#(^[^\w/]*)(.+?)([\)\]\}\>\.,:;"'`~!\|]*$)#;
    return Bivio::HTML->escape($s)
	. ($m =~ $_IMG
	? qq{<img src="}
	  . Bivio::HTML->escape_attr_value($m)
	  . qq{" />}
	: ( '<a href="'
	    . Bivio::HTML->escape_attr_value(
		$m =~ qr{^$_EMAIL$}o ? "mailto:$m"
		: $m =~ qr{^$_DOMAIN$}o ? "http://$m"
		: $m
	    ) . '">'
	    . Bivio::HTML->escape($m)
	    . '</a>'
        )) . Bivio::HTML->escape($e);
}

sub _fmt_line {
    my($line, $state) = @_;
    $line =~ s{^\s+|\s+$}{}sg;
    if (!length($line) || $line =~ s{^--+$}{<hr /><br />\n}) {
	_close_tags('p', $state);
	return $line . _start_tag('p', '', $state);
    }
    _start_p($state);
    $line = Bivio::HTML->escape($line);
    $line =~ s{(\S+)}{_fmt_token($1)}eg;
    return "$line\n";
}

sub _fmt_pre {
    my($line, $state) = @_;
    $state->{html} .= "\n";
    if (length($line)) {
	$state->{html} .= Bivio::HTML->escape($line) . "\n";
    }
    else {
	$state->{html} .= Bivio::HTML->escape($line) . "\n"
	    while defined($line = _next_line($state))
		&& $line !~ m{^\@/pre\s*$};
    }
    _close_top('pre', $state);
    return '';
}

sub _fmt_tag {
    my($line, $state) = @_;
    return "\n"
	if $line =~ /^\s*$/;
    return _fmt_line(@_)
	if $line =~ /^@/ || !($line =~ s/^(\/?)(\w+)//);
    my($close) = $1;
    my($tag) = lc($2);
    return _fmt_line(@_)
	unless $_TAGS->{$tag};
    _close_tags($tag, $state);
    return _close_top($tag, $state)
	if $close;
    my($attrs) = '';
    while ($line =~ s/^\s+(?:(\w+=)([^"\s]+)|(\w+="[^\"]+"))//) {
	$attrs .= ' '
	    . ($1 ? lc($1) . '"' . Bivio::HTML->escape_attr_value($2) . '"'
	    : $3);
    }
    $line =~ s/^\s+//;
    return "<$tag$attrs />\n"
	if $_EMPTY->{$tag};
    _start_p($state)
	if $_PHRASE->{$tag};
    $state->{html} .= _start_tag($tag, $attrs, $state);
    return _fmt_pre($line, $state)
	if $tag eq 'pre';
    if (length($line)) {
 	$state->{html} .= _fmt_line($line, $state);
	chomp($state->{html});
	_close_top($tag, $state);
	$state->{html} .= "\n";
    }
    $state->{html} .= _start_tag('p', '', $state)
	if $tag =~ /^(?:td|th|li|dd|dt|blockquote|center)$/;
    return '';
}

sub _fmt_token {
    my($tok) = @_;
    my($hit) = 0;
    foreach my $x (
	[qw(\* strong)],
	[qw(\_ em)],
    ) {
	my($c, $h) = @$x;
	$tok =~ s{(^\W*)$c(\S+)$c(\W*$)}{
	    "$1<$h>" . join(' ', split(/$c/, _fmt_href($2))) . "</$h>$3"
	}e && $hit++;
    }
    return $hit ? $tok : _fmt_href($tok);
}

sub _hash {
    my($a, $b) = @_;
    return {map(($_ => +{map(($_ => 1), @$b, $_)}), @$a)};
}

sub _next_line {
    return shift(@{shift(@_)->{lines}});
}

sub _start_p {
    my($state) = @_;
    $state->{html} .= _start_tag('p', '', $state)
	unless $state->{tags}->[0];
    return;
}

sub _start_tag {
    my($tag, $attrs, $state) = @_;
    unshift(@{$state->{tags}}, $tag);
    return "<$tag$attrs>";
}

1;
