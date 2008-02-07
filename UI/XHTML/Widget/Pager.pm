# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::Pager;
use strict;
use base 'Bivio::UI::Widget';
use Bivio::Biz::QueryType;
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

# Table Pager Widget
#   list_class : string (required)
#   pages : int (15) -- The number of pages to select from.

sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('_link');
    $self->initialize_attr(_link =>
	Link([$self . 'link_text'], [$self . 'link_href'], _num_class($self)));
    $self->initialize_attr(_selected =>
	SPAN(String([$self . 'selected']), _num_class($self, 1)));
    _create_navigation_link($self, 'prev');
    _create_navigation_link($self, 'next');
    return;
}

sub internal_new_args {
    my(undef, $list_class, $pages, $attributes) = @_;
    Bivio::Die->die('missing list_class')
        unless $list_class;
    return {
        list_class => $list_class,
        (defined($pages) ? (pages => $pages) : ()),
	($attributes ? %$attributes : ()),
    };
}

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    my($key) = 'Model.' . $self->get('list_class');
    my($query) = $req->get($key)->get_query;
    return unless $query->get('has_next') || $query->get('has_prev');

    $self->get('_prev')->render($req, $buffer);
    my($no_sep) = 0;
    foreach my $page (@{_get_page_numbers($self, $query)}) {
        $req->put($self . 'no_sep' => $no_sep++);
        if ($page == $query->get('page_number')) {
            $req->put($self . 'selected' => $page);
            $self->get('_selected')->render($req, $buffer);
            next;
        }
        $req->put($self . 'link_text' => $page);
        $req->put($self . 'link_href' => $req->get($key)->format_uri(
            Bivio::Biz::QueryType->THIS_LIST, undef, {
                page_number => $page,
            }));
        $self->get('_link')->render($req, $buffer);
    }
    $self->get('_next')->render($req, $buffer);
    return;
}

# Returns a widget which renders a navigator for the specified direction
# Returns a list of page numbers to render as links.
sub _create_navigation_link {
    my($self, $direction) = @_;
    my($key) = 'Model.' . $self->get('list_class');
    my($text) = vs_text("$key.paged_list.$direction");
    $self->initialize_attr('_' . $direction =>
	If([[$key, '->get_query'], 'has_' . $direction],
            Link(_nav($self, $direction, $text, 1), [$key, '->format_uri',
                Bivio::Biz::QueryType->from_name(uc($direction) . '_LIST')]),
            _nav($self, $direction, $text, 0),
        ));
    return;
}

sub _get_page_numbers {
    my($self, $query) = @_;
    my($pages) = [];
    return $pages unless $query->unsafe_get('page_count');
    my($page_count) = $self->get_or_default('pages', 15);
    my($last) = $query->get('page_number') + int(($page_count - 1) / 2);

    if ($last < $page_count) {
        $last = $page_count;
    }
    elsif ($last > $query->get('page_count')) {
        $last = $query->get('page_count');
    }

    foreach my $i (0 .. ($page_count - 1)) {
        my($page) = $last - $i;
        next if $page > $query->get('page_count') || $page <= 0;
        unshift(@$pages, $page);
    }
    return $pages;
}

sub _nav {
    my($self, $direction, $text, $on) = @_;
    return Join([
        _order_widgets($self, $direction,
	    SPAN(String($text), $direction . ' ' . ($on ? 'on' : 'off'))),
    ]);
}

# Returns the widgets in the correct order depending on the direction.
sub _num_class {
    my($self, $selected) = @_;
    return {
	class => [sub {
	   my(undef, $no_sep, $class) = @_;
	   return $class . ($no_sep ? '' : ' want_sep');
	}, [$self . 'no_sep'], $selected ? 'selected num' : 'num'],
    };
}

sub _order_widgets {
    my($self, $direction, @widgets) = @_;
    return $direction eq 'next' ? reverse(@widgets) : @widgets;
}

1;
