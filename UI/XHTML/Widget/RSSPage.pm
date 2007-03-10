# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RSSPage;
use strict;
use base 'Bivio::UI::Widget::List';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub execute {
    return shift->execute_with_content_type(shift, 'application/xml');
}

sub initialize {
    my($self) = @_;
    my($ih) = $self->get('item_hash');
    my($seen) = {};
    my($list) = $self->get('list_class');
#TODO: Check $list is a scalar here.  Not clear why this has to be
    $self->put(
	head => Join([
	    q{<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>},
#TODO: Might it be better to render off the task?
	    map(Tag($_ => Prose(vs_text('rsspage', $list, $_))),
		qw(title description)),
#TODO: Refactor or add XML(?) link widget that formats full http URI
# as required by some RSS readers
	    $self->unsafe_get('source_task') ? Tag(link => String(
#TODO: URI or Link, instead of format_ call?
		$self->get_request->format_http({
		    task_id => $self->get('source_task'),
		    query => undef,
		}), {escape_html => 1})) : (),
	    Tag(language => 'en-us'),
	], {join_separator => "\n"}),
	columns => [
	    Tag(item => Join([
		map(Tag(($seen->{$_} = $_) => $ih->{$_}), sort(keys(%$ih))),
	    ], {join_separator => "\n"})),
	    Simple("\n"),
	],
	foot => Join([
	    <<'EOF',
</channel>
</rss>
EOF
	]),
    );
    foreach my $required (qw(title description pubDate)) {
	Bivio::Die->die($required, ': is a required tag in item_hash')
	    unless $seen->{$required};
    }
    $self->map_invoke(initialize_attr => [qw(head foot)]);
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $list_class, $item_hash, $attributes) = @_;
    return '"list_class" must be a defined scalar'
	unless defined($list_class) && !ref($list_class);
    return '"item_hash" must be an hash_ref'
	unless ref($item_hash) eq 'HASH';
    return {
	list_class => $list_class,
	item_hash => $item_hash,
	($attributes ? %$attributes : ()),
    };
}

sub render {
    my($self, $source, $buffer) = @_;
    $self->render_attr(head => $source, $buffer);
    shift->SUPER::render(@_);
    $self->render_attr(foot => $source, $buffer);
    return;
}

1;
