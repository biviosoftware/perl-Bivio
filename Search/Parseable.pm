# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parseable;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = __PACKAGE__->use('IO.File');

sub as_string {
    my($self) = @_;
    return !ref($self) ? shift->SUPER::as_string(@_)
	: (
	    $self->simple_package_name . '['
	    . $self->get_or_default(path => '')
	    . ','
	    . $self->get('content_type')
	    . ']'
	);
}

sub get_content {
    my($self) = @_;
    return $self->get_if_defined_else_put(content => sub {
        return $self->get('realm_file')->get_content;
    });
}

sub get_os_path {
    my($self) = @_;
    return $self->get_if_defined_else_put(os_path => sub {
        my $rf = $self->unsafe_get('realm_file');
	return $rf ? $rf->get_os_path
	    : $_F->write($_F->temp_file($self->req), $self->get('content'));
    });
}

sub get_request {
    return shift->get('req');
}

sub new {
    my($proto, $realm_file_or_attr) = @_;
    return $proto->SUPER::new(
	Bivio::UNIVERSAL->is_blessed($realm_file_or_attr) ? {
	    realm_file => $realm_file_or_attr,
	    path => $realm_file_or_attr->get('path'),
	    req => $realm_file_or_attr->req,
	    content_type => $realm_file_or_attr->get_content_type,
	} : _assert_keys($realm_file_or_attr),
    );
}

sub _assert_keys {
    my($attr) = @_;
    foreach my $x (
	[req => qr{::Request$}],
	[content_type => ''],
	[content => qr{^SCALAR$}],
    ) {
	my($k, $t) = @$x;
	Bivio::Die->die($k, ': not defined')
            unless my $v = $attr->{$k};
	Bivio::Die->die(ref($v), ': is invalid type for ', $k)
	    if $t && ref($v) !~ $t;
    }
    $attr->{path} = ''
	unless defined($attr->{path});
    return $attr;
}

1;
