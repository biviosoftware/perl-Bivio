# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Menu;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WDN) = __PACKAGE__->use('Type.WikiDataName');
my($_WN) = __PACKAGE__->use('Type.WikiName');

sub SUFFIX {
    return '.bmenu';
}

sub handle_register {
    return ['b-menu'];
}

sub render_html {
    my($proto, $args) = @_;
    my($class) =  delete($args->{attrs}->{class}) || 'bmenu';
    my($value) =  delete($args->{attrs}->{value}) || $args->{value};
    Bivio::Die->die(
	$args->{attrs}, ': only accepts "class" and "value" attributes',
    ) if %{$args->{attrs}};
    my($path) = $_WDN->to_absolute($value, $args->{is_public}) . $proto->SUFFIX;
    my($csv) = $proto->use('ShellUtil.CSV')->parse_records(
	Bivio::Biz::Model->new($args->{req}, 'RealmFile')->unauth_load_or_die({
	    path => $path,
	    realm_id => $args->{realm_id},
	    is_public => $args->{is_public},
        })->get_content,
    );
    return unless @$csv;
    my($line) = 2;
    my($b) = '';
    TaskMenu(
	# in a SPAN because MSIE 6 can't identify multi classed items
	[map(Tag('SPAN', Link(_parse_row($_, $args, $path, $line++))), @$csv)],
	$class,
    )->put_and_initialize(
	parent => undef,
	selected_item => sub {
	    my($w, $source) = @_;
            my($re) = $w->get_nested(qw(value selected_regexp));
	    return ($source->req->unsafe_get('uri') || '') =~ qr{$re}i ? 1 : 0;
	},
    )->render($args->{source}, \$b);
    return $b;
}

sub _has_value {
    my($v) = @_;
    return defined($v) && length($v);
}

sub _parse_row {
    my($row, $args, $path, $line) = @_;
    Bivio::Die->die($path, ", line $line: missing Label value")
        unless _has_value($row->{Label});
    unless (_has_value($row->{Link})) {
	$row->{Link} = $row->{Label};
	$row->{Label} = $_WN->to_title($row->{Label});
    }
    my($href) = $args->{proto}->internal_format_uri($row->{Link}, $args);
    return {
	value => Simple(_render_label($row->{Label}, $args)),
	href => $href,
	selected_regexp => _has_value($row->{'Selected Regexp'})
	    ? qr/$row->{'Selected Regexp'}/i
	    : qr/^\Q$href\E$/,
	(_has_value($row->{Class}) ? (class => $row->{Class}) : ()),
    };
}

sub _render_label {
    my($label, $args) = @_;
    my($res) = $args->{proto}->render_html({
	%$args,
	value => $label,
    });
    $res =~ s{<p(?: class="(?:b_)?prose")?>(.*?)</p>$}{$1}s;
    chomp($res);
    return $res;
}

1;
