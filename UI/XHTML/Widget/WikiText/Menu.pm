# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Menu;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WDN) = b_use('Type.WikiDataName');
my($_WN) = b_use('Type.WikiName');
my($_R) = b_use('Type.Regexp');
my($_C) = b_use('FacadeComponent.Constant');
my($_S) = b_use('Type.String');
my($_SUFFIX) = '.bmenu';

sub TARGET {
    return __PACKAGE__ . '::b-menu-target';
}

sub handle_register {
    return ['b-menu', 'b-menu-target', 'b-menu-source'];
}

sub internal_submenu {
    my(undef, $args, $links) = @_;
    return Join([TaskMenu([map(Tag(span => Link($_)), @$links)], 'b_submenu', {
        selected_item => sub {
            my($w, $source) = @_;
            return ($source->ureq('uri') || '') =~
                $w->get_nested(qw(value selected_regexp)) ? 1 : 0;
        },
    }), And([['->req', 'Type.UserAgent'], '->eq_browser_msie_6'],
            Script('b_submenu_ie6'))]);
}

sub render_html {
    my($proto, $args) = @_;
    # load here to avoid subclass redfined error
    my($_WT) = b_use('XHTMLWidget.WikiText');
    my($class) =  delete($args->{attrs}->{class}) || 'bmenu';
    my($value) =  delete($args->{attrs}->{value}) || $args->{value};
    my($prefix) = delete($args->{attrs}->{b_selected_label_prefix});
    if ($args->{tag} eq 'b-menu-target') {
        my($die) = Bivio::Die->catch_quietly(sub {
            my($v) = $_WT->prepare_html(
                $args->{realm_id},
                $args->{req}->get('path_info'),
                $args->{task_id},
                $args->{req},
            );
            ($v->{value}) = grep($_ && /^\@b-menu-source/,
                                 split(/\r?\n/, $v->{value}));
            $v->{value} ||= '';
            $_WT->render_html($v);
            return;
        });
        #b-menu-source is now pre-rendered and therefore on the req
        return $die ? '' : $args->{req}->get_or_default($proto->TARGET, '');
    }
    Bivio::Die->die(
	$args->{attrs}, ': only accepts "class", "value", and',
        ' "b_selected_label_prefix" attributes',
    ) if %{$args->{attrs}};
    my($links) = _parse_csv($value, $args);
    return ''
	unless $links && @$links;
    my($buf) = '';
    TaskMenu([map(_item_widget($proto, $args, $_, $prefix), @$links)], $class)
	->put(selected_item => sub {
                my($w, $source) = @_;
                return ($source->ureq('uri') || '') =~
                    $w->get_nested(qw(value selected_regexp)) ? 1 : 0;
            },
        )->initialize_and_render($args->{source}, \$buf);
    if ($args->{tag} eq 'b-menu-source') {
        $args->{req}->put($proto->TARGET, $buf);
        return '';
    }
    return $buf;
}

sub _has_value {
    my($v) = @_;
    return defined($v) && length($v);
}

sub _item_widget {
    my($proto, $args, $row, $prefix) = @_;
    my($c) = delete($row->{class});
    $row->{value} = Simple($row->{value});
    return Tag(span => Link($row), $c ? $c : ())
        unless my $links = delete($row->{links});
    my($selected_regexp) = delete($row->{selected_regexp});
    return Tag(span => Join([Link($row),
        $proto->internal_submenu($args, $links),
    ], {selected_regexp => $selected_regexp}),  $c ? $c : ());
}

sub _join_regexp {
    my($links, $re) = @_;
    return join(
	'|',
	map($_->{selected_regexp}, @$links), _has_value($re) ? $re : (),
    );
}

sub _parse_csv {
    my($value, $args) = @_;
    my($path) = $_WDN->to_absolute($value, $args->{is_public}) . $_SUFFIX;
    return
	unless my $rf = $args->{proto}->unsafe_load_realm_file($path, $args);
    my($csv) = b_use('ShellUtil.CSV')->parse_records($rf->get_content);
    $args = {%$args, path => $path, line_num => 1};
    unless (@$csv) {
	$args->{proto}->render_error(undef, 'no lines in menu', $args);
	return;
    }
    return [map(_parse_csv_row($_, $args), @$csv)];
}

sub _parse_csv_row {
    my($row, $args) = @_;
    $args->{line_num}++;
    foreach my $k (keys(%$row)) {
	$row->{$k} =~ s/^\s+|\s+$//s
	    if _has_value($row->{$k});
    }
    if (_has_value($row->{Link}) && $row->{Link} =~ s/\Q$_SUFFIX\E$//oi) {
	my($links) = _parse_csv($row->{Link}, $args);
	return {
	    links => $links,
	    value => _render_label($row, $args),
	    href => $links->[0]->{href},
	    selected_regexp => _join_regexp($links,
		_selected_regexp($row->{'Selected Regexp'})),
	    (_has_value($row->{Class}) ? (class => $row->{Class}) : ()),
	};
    }
    elsif (_has_value($row->{Label})) {
#TODO: Encapsulate in WikiText
	_set_missing_link_from_label($row);
	my($href) = $args->{proto}->internal_format_uri($row->{Link}, $args);
	return {
	    value => _render_label($row, $args),
	    href => $href,
	    selected_regexp =>
		_selected_regexp($row->{'Selected Regexp'}, $href),
	    (_has_value($row->{Class})
		 ? (class => $row->{Class}) : ()),
	};
    }
    $args->{proto}->render_error(undef, 'missing Label value', $args);
    return;
}

sub _render_label {
    my($row, $args) = @_;
    my($res) = $args->{proto}->render_html({
        %$args,
        value => $row->{Label},
    });
    $res =~ s{<p(?: class="(?:b_)?prose")?>(.*?)</p>$}{$1}s;
    # Need to strip the <a>, because page won't render otherwise
    $args->{proto}->render_error(
	$row->{Label}, 'Label contains ^ or embedded link', $args,
    ) if $res =~ s{<a[^>]+>(.*?)</a>}{$1}s;
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

1;
