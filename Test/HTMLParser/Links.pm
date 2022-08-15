# Copyright (c) 2002-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Links;
use strict;
use Bivio::Base 'Test.HTMLParser';
use Bivio::IO::Trace;

our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
__PACKAGE__->register(['Cleaner']);

sub html_parser_end {
    # (self, string, string) : undef
    # Dispatch to the _end_XXX routines.
    my($self, $tag) = @_;
    my($fields) = $self->[$_IDI];
    pop(@{$fields->{xpath}});
    return _end_a($self)
        if $tag =~ /^(?:a|button)$/;
    return;
}

sub html_parser_start {
    # (self, string, hash_ref, array_ref, string) : undef
    # Dispatches to the _start_XXX routines.
    my($self, $tag, $attr) = @_;
    my($fields) = $self->[$_IDI];
    push(@{$fields->{xpath}}, $tag . ($attr->{class} ? ".$attr->{class}" : ''));
    return _start_a($fields, $tag, $attr)
        if $tag =~ /^(?:a|button)$/;
    return _start_img($self, $attr)
        if $tag eq 'img';
    return;
}

sub html_parser_text {
    # (self, string) : undef
    # Text is applied to the current link, if any.
    #
    # For links, we can't assume that we are called with an entire sequence
    # of text (like Forms), so we append until the end_a.
    my($self, $text) = @_;
    my($fields) = $self->[$_IDI];
    $text = $self->get('cleaner')->text($text);
    $fields->{text} .= $text if $fields->{href};
    return;
}

sub new {
    # (proto, Test.HTMLParser) : HTMLParser.Links
    # Parses cleaned html for links.
    my($proto, $parser) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
	xpath => [],
    };
    return $self;
}

sub _end_a {
    # (self) : undef
    # No longer in a link.
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    _link($self, $fields->{text})
	if defined($fields->{text}) && defined($fields->{href});
    $fields->{href} = undef;
    return;
}

sub _link {
    # (self, string, string) : undef
    # Adds the link.  Creates unique name ($label_$i) if not unique.
    my($self, $label, $alt) = @_;
    my($fields) = $self->[$_IDI];
    my($base, $i) = $label;
    while ($self->get('elements')->{$label}) {
	return if $self->get('elements')->{$label}->{href}
            eq ($fields->{href} || '');
	$label = $base . '_' . ++$i;
    }
    $self->get('elements')->{$label} = {
	label => $label,
	href => $fields->{href},
	alt => $alt,
    };
    _trace($label, '->', $fields->{href}) if $_TRACE;
    return;
}

sub _start_a {
    # Stores the href
    my($fields, $tag, $attr) = @_;
    if ($tag eq 'button') {
        # subscription.html
        # <button onclick="location.href=&#39;/btest8331/admin/subscribe?ecservice=2&#39;;">Renew Service</button>
        return
            unless ($attr->{onclick} || '') =~ /^location.href='([^']+)/;
        $attr->{href} = $1;
    }
    b_die(
	"already have an href (missing </$tag>). current=",
        $fields->{href},
	' new=', $attr->{href},
    ) if $fields->{href};
    return
	if $attr->{name} && !$attr->{href}
	# DropDown creates links that are meaningless for testing
        || $attr->{onclick} && ($attr->{href} || '') eq '#';
    unless (defined($attr->{href}) || $attr->{name}) {
	b_info(
	    join('/', @{$fields->{xpath}}),
            ': missing href or name, ignoring: ',
	    $attr,
	);
	return;
    }
    $fields->{href} = $attr->{href};
    $fields->{text} = '';
    return;
}

sub _start_img {
    # (self, hash_ref) : undef
    # Adds a new link.
    my($self, $attr) = @_;
    my($fields) = $self->[$_IDI];
    return unless $fields->{href};
    b_die('missing src: ', $attr)
        unless $attr->{src};
    # Delete the gif/jpg suffix and any directory prefix
    $attr->{src} =~ s/(?:.*\/)?([^\/]+)\.\w+$/$1/;
    _link($self, $attr->{src}, $attr->{alt});
    return;
}

1;
