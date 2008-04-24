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
	[map(Link(_parse_row($_, $args, $path, $line++)), @$csv)],
	$class,
    )->put_and_initialize(parent => undef)->render($args->{source}, \$b);
    return $b;
}

sub _parse_row {
    my($row, $args, $path, $line) = @_;
    Bivio::Die->die($path, ", line $line: missing Label value")
        unless defined($row->{Label}) && length($row->{Label});
    unless (defined($row->{Link}) && length($row->{Link})) {
	$row->{Link} = $row->{Label};
	$row->{Label} = $_WN->to_title($row->{Label});
    }
    return (
	$row->{Label},
	$args->{proto}->internal_format_uri($row->{Link}, $args),
	(defined($row->{Class}) && length($row->{Class}))
	    ? $row->{Class} : ()
    );
}

1;
