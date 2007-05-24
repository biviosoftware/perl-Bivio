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
    my($proto, $file_name) = @_;
    return {
	filename => $proto->use('Type.FilePath')->get_tail($file_name),
	content_type => $proto->use('Bivio::MIME::Type')
	    ->unsafe_from_extension($file_name),
        content => $proto->use('Bivio::IO::File')->read($file_name),
    };
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

1;
