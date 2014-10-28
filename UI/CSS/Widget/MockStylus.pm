# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::CSS::Widget::MockStylus;
use strict;
use Bivio::Base 'CSSWidget.Simple';
b_use('UI.ViewLanguageAUTOLOAD');

my($_CSS2_PROPERTIES) = {map(
    ($_ => 1),
    qw(
	azimuth
	background-attachment
	background-color
	background-image
	background-position
	background-repeat
	background
	border-collapse
	border-color
	border-spacing
	border-style
	border-top
	border-right
	border-bottom
	border-left
	border-top-color
	border-right-color
	border-bottom-color
	border-left-color
	border-top-style
	border-right-style
	border-bottom-style
	border-left-style
	border-top-width
	border-right-width
	border-bottom-width
	border-left-width
	border-width
	border
	bottom
	caption-side
	clear
	clip
	color
	content
	counter-increment
	counter-reset
	cue-after
	cue-before
	cue
	cursor
	direction
	display
	elevation
	empty-cells
	float
	font-family
	font-size
	font-style
	font-variant
	font-weight
	font
	height
	left
	letter-spacing
	line-height
	list-style-image
	list-style-position
	list-style-type
	list-style
	margin-right
	margin-left
	margin-top
	margin-bottom
	margin
	max-height
	max-width
	min-height
	min-width
	orphans
	outline-color
	outline-style
	outline-width
	outline
	overflow
	padding-top
	padding-right
	padding-bottom
	padding-left
	padding
	page-break-after
	page-break-before
	page-break-inside
	pause-after
	pause-before
	pause
	pitch-range
	pitch
	play-during
	position
	quotes
	richness
	right
	speak-header
	speak-numeral
	speak-punctuation
	speak
	speech-rate
	stress
	table-layout
	text-align
	text-decoration
	text-indent
	text-transform
	top
	unicode-bidi
	vertical-align
	visibility
	voice-family
	volume
	white-space
	widows
	width
	word-spacing
	z-index
    ),
)};

sub control_on_render {
    my($self, $source, $wo) = shift->widget_render_args(@_);
    my($section) = '';
    my($append_brace) = sub {
	$section .= '{'
	    unless $section =~ /\{/;
	return;
    };
    my($new_section) = sub {
	return
	    unless $section;
	$append_brace->();
	$section .= "}\n";
	$wo->append_buffer($section);
	$section = '';
	return;
    };
    foreach my $line (split(/\n/, ${$self->render_attr('value', $source)})) {
	$line = _strip_comment($line);
	if ($line =~ /^\s*$/s) {
	    $new_section->();
	    next;
	}
	if ($line =~ /^\S/) {
	    $new_section->()
		if $section =~ /\{/;
	    $section .= ','
		if $section;
	    $section .= $line;
	    next;
	}
	$self->die($line, $source, 'missing property declaration')
	    unless $line =~ s/^\s+(\S+)\s+//;
	my($property) = $1;
	$append_brace->();
	$section .= _property($property, $line);
    }
    $new_section->();
    return;
}

sub _property {
    my($property, $value) = @_;
    return join(
	'',
	map(
	    "$_:$value;",
	    $property,
	    $_CSS2_PROPERTIES->{$property} ? ()
		: map("-$_-$property", qw(ms o moz webkit)),
	),
    );
}

sub _strip_comment {
    my($line) = @_;
    $line =~ s{//.*|^\!.*}{};
    return $line;
}

1;
