# Copyright (c) 1999-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Type::FileField;
use strict;
use Bivio::Base 'Bivio::Type';
use Bivio::Type::Text;

# C<Bivio::Type::FileField> is a hash_ref.  The attributes are:
#
#
# content
#
# A scalar_ref pointing to the content.
#
# content_type
#
# The I<content-type> string in the input.
#
# filename
#
# Name supplied in the I<content-disposition> attribute.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
    # Checks the incoming file for valid values.
    $proto->internal_from_literal_warning
        unless wantarray;
    return (undef, undef) unless defined($value);

    unless (ref($value) eq 'HASH') {
	# url-encoded form?
	return (undef, Bivio::TypeError::FILE_FIELD()) if length($value);

	# NULL field
	return (undef, undef);
    }

    return $value if length(${$value->{content}});

    # NULL if no filename
    return (undef, undef)
	    unless $value->{filename};

    # NOT_FOUND if no content_type
    return (undef, Bivio::TypeError::NOT_FOUND())
	    unless $value->{content_type};

    # Else zero length file
    return (undef, Bivio::TypeError::EMPTY());
}

sub from_sql_column {
    # B<NOT SUPPORTED>
    die("can't convert a FileField from sql");
}

sub get_width {
    # Returns same as Text.
    return Bivio::Type::Text->get_width;
}

sub to_literal {
    my(undef, $value) = @_;
    # Returns the filename, not the content.
    return ref($value) eq 'HASH' && defined($value->{filename})
	    ? $value->{filename} : '';
}

sub to_query {
    # B<NOT SUPPORTED>
    die("can't convert a FileField to a query");
}

sub to_uri {
    # B<NOT SUPPORTED>
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
