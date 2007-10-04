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

my($_IDI) = __PACKAGE__->instance_data_index;

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{link};
    $fields->{link} = $self->initialize_value('link',
        Link([__PACKAGE__ . 'link_text'],
            [__PACKAGE__ . 'link_href']));
    $fields->{selected} = $self->initialize_value('selected',
        B(String([__PACKAGE__ . 'selected'])));
    $fields->{blank} = $self->initialize_value('blank', vs_blank_cell());
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
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($key) = 'Model.' . $self->get('list_class');
    my($query) = $req->get($key)->get_query;
    return unless $query->get('has_next') || $query->get('has_prev');

    $fields->{prev}->render($req, $buffer);

    foreach my $page (@{_get_page_numbers($self, $query)}) {
        $fields->{blank}->render($req, $buffer);

        if ($page == $query->get('page_number')) {
            $req->put(__PACKAGE__ . 'selected' => $page);
            $fields->{selected}->render($req, $buffer);
            next;
        }
        $req->put(__PACKAGE__ . 'link_text' => $page);
        $req->put(__PACKAGE__ . 'link_href' => $req->get($key)->format_uri(
            Bivio::Biz::QueryType->THIS_LIST, undef, {
                page_number => $page,
            }));
        $fields->{link}->render($req, $buffer);
    }
    $fields->{blank}->render($req, $buffer);
    $fields->{next}->render($req, $buffer);
    return;
}

# Returns a widget which renders a navigator for the specified direction
# Returns a list of page numbers to render as links.
sub _create_navigation_link {
    my($self, $direction) = @_;
    my($fields) = $self->[$_IDI];
    my($key) = 'Model.' . $self->get('list_class');
    my($text)= vs_text("$key.paged_list.$direction");
    $fields->{$direction} = $self->initialize_value($direction,
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
sub _order_widgets {
    my($self, $direction, @widgets) = @_;
    return $direction eq 'next' ? reverse(@widgets) : @widgets;
}

1;
