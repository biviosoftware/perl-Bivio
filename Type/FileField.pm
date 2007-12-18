# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::FileField;
use strict;
use Bivio::Base 'Bivio::Type';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_T) = __PACKAGE__->use('Type.Text');

sub from_string_ref {
    return shift->from_literal({
	content => shift,
	filename => shift || '',
	content_type => shift || 'application/octet-stream',
    });
}

sub from_disk {
    my($v, $e) = shift->unsafe_from_disk(@_);
    return $v
	if $v;
    my(undef, $file_name) = @_;
    Bivio::Die->die(
	$file_name, ': invalid disk file: ' ,
	$e || Bivio::TypeError::FILE_FIELD->NULL);
    # DOES NOT RETURN
}

sub from_literal {
    my($proto, $value) = @_;
    $proto->internal_from_literal_warning
        unless wantarray;
    return (undef, undef)
	unless defined($value);
    unless (ref($value) eq 'HASH') {
	return (undef, Bivio::TypeError->FILE_FIELD)
	    if length($value);
	return (undef, undef);
    }
    return $value
	if length(${$value->{content}});
    return (undef, undef)
	unless $value->{filename};
    return (undef, Bivio::TypeError->NOT_FOUND)
	unless $value->{content_type};
    return (undef, Bivio::TypeError->EMPTY);
}

sub from_sql_column {
    die("can't convert a FileField from sql");
}

sub get_width {
    return $_T->get_width;
}

sub to_literal {
    my(undef, $value) = @_;
    return ref($value) eq 'HASH' && defined($value->{filename})
	? $value->{filename} : '';
}

sub to_query {
    die("can't convert a FileField to a query");
}

sub to_uri {
    die("can't convert a FileField to a uri");
}

sub unsafe_from_disk {
    my($proto, $value) = @_;
    return (undef, undef)
	unless defined($value) && length($value);
    return $proto->use('IO.Ref')->nested_copy($value)
	if ref($value) eq 'HASH'
	&& grep(exists($value->{$_}), qw(filename content content_type)) == 3
	&& ref($value->{content}) eq 'SCALAR';
    return (undef, Bivio::TypeError->NOT_FOUND)
	unless -r $value && !(-d _);
    return {
	filename => $proto->use('Type.FilePath')->get_tail($value),
	content_type => $proto->use('Bivio::MIME::Type')
	    ->unsafe_from_extension($value),
        content => $proto->use('IO.File')->read($value),
    };
}

1;
