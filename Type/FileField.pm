# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::FileField;
use strict;
$Bivio::Type::FileField::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::FileField - a form field which contains a file

=head1 SYNOPSIS

    use Bivio::Type::FileField;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::FileField::ISA = ('Bivio::Type');

=head1 DESCRIPTION

C<Bivio::Type::FileField> is a hash_ref.  The attributes are:

=over 4

=item content

A scalar_ref pointing to the content.

=item content_type

The I<content-type> string in the input.

=item filename

Name supplied in the I<content-disposition> attribute.

=back

=cut

#=IMPORTS
use Bivio::Type::Text;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 from_literal(any value) : hash_ref

Checks the incoming file for valid values.

=cut

sub from_literal {
    my($self, $value) = @_;
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

=for html <a name="from_sql_column"></a>

=head2 static from_sql_column(scalar param) : undef

B<NOT SUPPORTED>

=cut

sub from_sql_column {
    die("can't convert a FileField from sql");
}

=for html <a name="get_width"></a>

=head2 get_width() : int

Returns same as Text.

=cut

sub get_width {
    return Bivio::Type::Text->get_width;
}

=for html <a name="to_literal"></a>

=head2 static to_literal(hash_ref value) : string

Returns the filename, not the content.

=cut

sub to_literal {
    my(undef, $value) = @_;
    return ref($value) eq 'HASH' && defined($value->{filename})
	    ? $value->{filename} : '';
}

=for html <a name="to_query"></a>

=head2 static to_query(any value) : string

B<NOT SUPPORTED>

=cut

sub to_query {
    die("can't convert a FileField to a query");
}

=for html <a name="to_uri"></a>

=head2 static to_uri(any value) : string

B<NOT SUPPORTED>

=cut

sub to_uri {
    die("can't convert a FileField to a uri");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
