# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Menu;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WDN) = b_use('Type.WikiDataName');
my($_WN) = b_use('Type.WikiName');
my($_SUFFIX) = '.bmenu';
my($_R) = b_use('Type.Regexp');

sub handle_register {
    return ['b-menu'];
}

sub render_html {
    my($proto, $args) = @_;
    my($class) =  delete($args->{attrs}->{class}) || 'bmenu';
    my($value) =  delete($args->{attrs}->{value}) || $args->{value};
    my($prefix) = delete($args->{attrs}->{b_selected_label_prefix});
    Bivio::Die->die(
	$args->{attrs}, ': only accepts "class", "value", and',
        ' "b_selected_label_prefix" attributes',
    ) if %{$args->{attrs}};
    my($links) = _visit($value, $args);
    return unless @$links;
    my($buf) = '';
    TaskMenu([map(_item_widget($_, $prefix), @$links)], $class)
        ->put_and_initialize(
            parent => undef,
            selected_item => sub {
                my($w, $source) = @_;
                return ($source->ureq('uri') || '') =~
                    $w->get_nested(qw(value selected_regexp)) ? 1 : 0;
            },
        )->render($args->{source}, \$buf);
    return $buf;
}

sub _has_value {
    my($v) = @_;
    return defined($v) && length($v);
}

sub _item_widget {
    my($row, $prefix) = @_;
    my($c) = delete($row->{class});
    $row->{value} = Simple($row->{value});
    return Tag(span => Link($row), $c ? $c : ())
        unless my $links = delete($row->{links});
    my($selected_regexp) = delete($row->{selected_regexp});
    return Tag(span => Join([
        Link($row),
        TaskMenu([map(Tag(span => Link($_)), @$links)], 'b_submenu'),
    ], {selected_regexp => $selected_regexp}),  $c ? $c : ());
}

sub _join_regexp {
    my($links, $re) = @_;
    return join('|',
                map($_->{selected_regexp}, @$links),
                _has_value($re) ? $re : ());
}

sub _render_label {
    my($row, $args) = @_;
    my($res) = $args->{proto}->render_html({
        %$args,
        value => $row->{Label},
    });
    $res =~ s{<p(?: class="(?:b_)?prose")?>(.*?)</p>$}{$1}s;
    chomp($res);
    return Simple($res);
}

sub _set_missing_link_from_label {
    my($row) = @_;
    unless (_has_value($row->{Link})) {
        $row->{Link} = $row->{Label};
        $row->{Label} = $_WN->to_title($row->{Label});
    }
    return;
}

sub _selected_regexp {
    my($re,$href) = @_;
    return _has_value($re)
        ? $_R->from_literal('(?is-xm:'.$re.')')
        : _has_value($href)
        ? $_R->from_literal('(?is-xm:^'.$_R->quote_string($href).'$)')
        : ();
}

sub _visit {
    my($value, $args) = @_;
    my($path) = $_WDN->to_absolute($value, $args->{is_public}) . $_SUFFIX;
    my($csv) = b_use('ShellUtil.CSV')->parse_records(
	Bivio::Biz::Model->new($args->{req}, 'RealmFile')->unauth_load_or_die({
	    path => $path,
	    realm_id => $args->{realm_id},
	    is_public => $args->{is_public},
        })->get_content,
    );
    return unless @$csv;
    my($line) = 2;
    return [map({
        if (_has_value($_->{Link}) && $_->{Link} =~ s/\.bmenu$//) {
            my($links) = _visit($_->{Link}, $args);
            {
                links => $links,
                value => _render_label($_, $args),
                href => $links->[0]->{href},
                selected_regexp => _join_regexp($links,
                    _selected_regexp($_->{'Selected Regexp'})),
                (_has_value($_->{Class}) ? (class => $_->{Class}) : ()),
            };
        }
        else {
            Bivio::Die->die($path, ", line $line: missing Label value")
                    unless _has_value($_->{Label});
            $line++;
            _set_missing_link_from_label($_);
            my($href) = $args->{proto}->internal_format_uri($_->{Link}, $args);
            {
                value => _render_label($_, $args),
                href => $href,
                selected_regexp => _selected_regexp($_->{'Selected Regexp'}, $href),
                (_has_value($_->{Class}) ? (class => $_->{Class}) : ()),
            };
        }
    } @$csv)];
}

1;
