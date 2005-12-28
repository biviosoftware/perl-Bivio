# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::CalendarEventListRSS;
use strict;
use base 'Bivio::Biz::Action';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');

sub execute {
    my($proto, $req) = @_;
    $req->get('reply')->set_output_type('application/xml')
	->set_output($proto->render($req));
#    Bivio::IO::Alert->info($xml);
    return;
}

sub render {
    my($proto, $req) = @_;
    my($l) = Bivio::Biz::Model->new($req, 'CalendarEventList');
    return \(join(
	'',
	qq{<?xml version="1.0"?>\n},
	qq{#<!DOCTYPE rss PUBLIC "-//Netscape Communications//DTD RSS 0.91//EN" "http://my.netscape.com/publish/formats/rss-0.91.dtd">\n},
	qq{<rss version="0.91">\n},
	_xml_render(
	    [channel => [
		[title => $req->get_nested(qw[auth_realm owner display_name]) . ' Calendar'],
		[description => 'The RSS feed for the ' . $req->get_nested(qw[auth_realm owner display_name]) . ' Calendar'],
		[language => 'en'],
		@{$l->map_iterate(\&_render_item)},
	    ]],
	),
	"</rss>\n",
    ));
}

sub _dt {
    # TODO: Evaluate with user time zone?
    my($dt, $method) = @_;
    $method ||= 'rfc822';
    return $_DT->$method($_DT->is_date($dt) ?
			     $_DT->set_local_beginning_of_day($dt, 0)
			     : $dt);
}

sub _render_item {
    my($it) = @_;
    return [item => [
	[title => $it->get('RealmOwner.display_name')],
	[description => _render_item_desc($it)],
	[pubDate => _dt($it->get('CalendarEvent.dtstart'))],
    ]];
}

sub _render_item_desc {
    my($it) = @_;
    return join('', _xml_render(
	['' => [
	    [p => $it->get('CalendarEvent.description')],
	    [ul => [
		map(
		    [li => "$_: " . _dt($it->get('CalendarEvent.dt' . lc($_)))],
		    qw{Start End}
		),
		[li => 'Location: ' . $it->get('CalendarEvent.location')],
	    ]],
	]],
    ));
}

# TODO: Copied and modified from DAV.pm
sub _xml_render {
    return map({
	my($t, $v) = @$_;
	defined($v) && length($v)
	   ? (
	       $t && "<$t>",
	       ref($v) ? ("\n", _xml_render(@$v)) : Bivio::HTML->escape($v),
	       $t && "</$t>\n"
	   ) : '';
    } @_);
}

1;
