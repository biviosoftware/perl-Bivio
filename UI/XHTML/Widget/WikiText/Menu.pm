# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Menu;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WN) = Bivio::Type->get_instance('WikiName');

sub SUFFIX {
    return '.bmenu';
}

sub handle_register {
    return ['b-menu'];
}

sub render_html {
    my($proto, $args) = @_;
    my($class) =  delete($args->{attrs}->{class}) || 'bmenu';
    Bivio::Die->die($args->{attrs}, ': only accepts class attribute')
        if %{$args->{attrs}};
    my($path) = $_WN->to_absolute($args->{value}, $args->{is_public})
	. $proto->SUFFIX;
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
    $row->{Link} = $row->{Label}
	unless defined($row->{Link}) && length($row->{Link});
    return (
	$row->{Label},
	$args->{proto}->internal_format_uri($row->{Link}, $args),
    );
}

1;
