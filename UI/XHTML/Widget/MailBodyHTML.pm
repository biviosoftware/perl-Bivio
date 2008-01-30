# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::MailBodyHTML;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use HTML::Parser ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_EMPTY_TAG) = _hash(qw(
    br
    col
    hr
    img
));
my($_OUTER_TAG) = _hash(qw(body html));
my($_SAFE_TAG) = _hash(qw(
    a
    abbr
    acronym
    address
    b
    big
    blockquote
    body
    br
    caption
    center
    cite
    code
    col
    colgroup
    dd
    del
    dfn
    dir
    div
    dl
    dt
    em
    font
    h1
    h2
    h3
    h4
    h5
    h6
    hr
    html
    i
    img
    ins
    kbd
    label
    legend
    li
    noframes
    noscript
    ol
    p
    pre
    q
    s
    samp
    small
    span
    strike
    strong
    sub
    sup
    table
    tbody
    td
    tfoot
    th
    thead
    tr
    tt
    u
    ul
    var
));
my($_SAFE_ATTRIBUTE) = _hash(qw(
    abbr
    align
    alt
    axis
    background
    bgcolor
    border
    cellpadding
    cellspacing
    char
    charoff
    clear
    color
    colspan
    compact
    datetime
    face
    height
    href
    hspace
    name
    noshade
    nowrap
    rules
    scope
    size
    span
    start
    style
    summary
    title
    type
    type
    type
    valign
    value
    vspace
    width
));
my($_SAFE_PROPERTY) = _hash(qw(
    background
    background-color
    border
    border-collapse
    border-color
    border-spacing
    border-style
    border-top
    border-top-color
    border-top-style
    border-top-width
    border-width
    caption-side
    clear
    clip
    color
    counter-increment
    counter-reset
    direction
    display
    elevation
    empty-cells
    float
    font
    font-family
    font-size
    font-size-adjust
    font-stretch
    font-style
    font-variant
    font-weight
    height
    letter-spacing
    line-height
    list-style
    list-style-position
    list-style-type
    margin
    margin-top
    marker-offset
    marks
    max-height
    max-width
    min-height
    min-width
    orphans
    outline
    outline-color
    outline-style
    outline-width
    overflow
    padding
    padding-top
    table-layout
    text-align
    text-decoration
    text-indent
    text-shadow
    text-transform
    vertical-align
    visibility
    white-space
    widows
    width
    word-spacing
));
my($_NESTING_TAG) = _hash(qw(div dl ol table ul));

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(tag => 'div');
    $self->put_unless_exists(tag_if_empty => 1);
    $self->put_unless_exists(class => 'text_html');
    $self->initialize_attr('mime_cid_task');
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my($self, $value, $mime_cid_task, @rest) = @_;
    return {
	%{$self->SUPER::internal_new_args(div => $value, @rest)},
	mime_cid_task => $mime_cid_task,
    };
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    _clean($self, $self->render_attr(value => $source), $source, $buffer);
    return;
}

sub _hash {
    return {map(($_=> 1), @_)};
}

sub _clean {
    my($self, $value, $source, $buffer) = @_;
    my($state) = {
	buffer => '',
	ignore => 0,
	source => $source,
	self => $self,
	stack => [],
    };
    HTML::Parser->new(
	api_version => 3,
	strict_end => 0,
	strict_names => 0,
	strict_comment => 0,
	# HTML::Parser has a bug which makes unbroken_text not work right
	unbroken_text => 0,
	attr_encoded => 0,
	case_sensitive => 0,
	marked_sections => 1,
	handlers => {
	    start => [
		sub {_clean_start($state, @_)},
		'tagname,attr,attrseq',
	    ],
	    end => [
		sub {_clean_end($state, @_)},
		'tagname',
	    ],
	    text => [
		sub {_clean_text($state, @_)},
		'text,is_cdata',
	    ],
	    map(($_ => [sub {}, '']), qw(process comment declaration)),
	},
    )->parse($$value);
    _clean_end($state)
	while _top($state);
    $state->{buffer} =~ s/[\n\r][\t ]+|[\t ]+[\n\r]/\n/sg;
    $state->{buffer} =~ s/\n\n+/\n/sg;
    $$buffer .= $state->{buffer};
    return;
}

sub _clean_attr {
    my($state, $name, $v) = @_;
    return if !$_SAFE_ATTRIBUTE->{$name} || $v =~ /"/;
    $v =~ s/\s+/ /sg;
    if ($name eq 'href') {
	$v = _clean_attr_href($state, $v);
    }
    elsif ($name eq 'style') {
	$v = _clean_attr_style($state, $v);
    }
    return defined($v) && length($v) ? qq{ $name="$v"} : ();
}

sub _clean_attr_href {
    my($state, $v) = @_;
    return $v =~ /^(?:https?|ftp|mailto):/s ? $v
	: $v =~ /^cid:(.+)/ ? _clean_attr_href_cid($state, $1)
	: undef;
}

sub _clean_attr_href_cid {
    my($state, $cid) = @_;
    return $state->{source}->unsafe_get_cursor_for_mime_cid($cid)
	? $state->{source}->format_uri_for_mime_cid(
	    $cid,
	    ${$state->{self}->render_attr('mime_cid_task', $state->{source})},
	) : undef;
}

sub _clean_attr_style {
    my(undef, $v) = @_;
    return $v =~ m{[!{}]|/\*|\*|/} ? undef
	: join(
	    ';',
	    map({
		my($x, $y) = split(/\s*:\s*/, $_, 2);
		!$_SAFE_PROPERTY->{$x} || $y =~ /url\s*\(/ ? ()
		    : "$x:$y";
	    } split(/\s*;\s*/, $v)),
	);
}

sub _clean_end {
    my($state, $tag) = @_;
    $tag = _top($state)
	unless defined($tag);
    return unless grep($tag eq $_, @{$state->{stack}});
    while (my $top = shift(@{$state->{stack}})) {
	if ($state->{ignore}) {
	    $state->{ignore}--;
	}
	elsif (!$_EMPTY_TAG->{$top} && !$_OUTER_TAG->{$top}) {
	    $state->{buffer} .= "</$top>";
	}
	last if $top eq $tag;
    }
    return;
}

sub _clean_start {
    my($state, $tag, $attr, $seq) = @_;
    _clean_start_nesting($state, $tag);
    _clean_start_not_nesting($state, $tag);
    unshift(@{$state->{stack}}, $tag);
    if ($state->{ignore} || !$_SAFE_TAG->{$tag}) {
	$state->{ignore}++;
	return;
    }
    return if $_OUTER_TAG->{$tag};
    $state->{buffer} .= join(
	'',
        "<$tag",
	map(_clean_attr($state, $_, $attr->{$_}), @$seq),
	$_EMPTY_TAG->{$tag} ? ' />' : '>',
    );
    return;
}

sub _clean_start_nesting {
    my($state, $tag) = @_;
    _clean_end($state)
	if $tag eq _top($state) && !$_NESTING_TAG->{$tag};
    return;
}

sub _clean_start_not_nesting {
    my($state, $tag) = @_;
    if ($tag =~ /^(?:tr)/) {
	if (_top($state) =~ /^(?:td|th)$/) {
	    _clean_end($state);
	    _clean_start_nesting($state, $tag);
	}
	_clean_start($state, 'table')
	    unless _top($state) =~ /^(?:table|thead|tbody|tfoot)$/;
    }
    elsif ($tag =~ /^(?:td|th)$/) {
	_clean_start($state, 'tr')
	    unless _top($state) eq 'tr';
    }
    elsif ($tag =~ /^(?:body|html)$/) {
	_clean_end($state)
	    while _top($state);
    }
    return;
}

sub _clean_text {
    my($state, $text) = @_;
    return if $state->{ignore};
    $state->{buffer} .= $text;
    return;
}

sub _top {
    return shift->{stack}->[0] || 0;
}

1;
