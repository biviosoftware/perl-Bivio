# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::BLOB;
use strict;
$Bivio::Type::BLOB::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::BLOB - binary large object type

=head1 SYNOPSIS

    use Bivio::Type::BLOB;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type;
@Bivio::Type::BLOB::ISA = ('Bivio::Type');

=head1 DESCRIPTION

C<Bivio::Type::BLOB> is a binary large object.  The value is
passed around as a scalar_ref.  C<Bivio::SQL::PropertySupport> handles
this value specially.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : scalar_ref

Takes parameter literally, no copying, and returns a scalar reference
to it.  This avoids copying huge amounts of data.

=cut

sub from_literal {
    return defined($_[1]) ? \$_[1] : undef;
}

=for html <a name="from_sql_column"></a>

=head2 static from_sql_column(scalar param) : scalar_ref

Takes parameter literally, no copying, and returns a scalar reference
to it.  This avoids copying huge amounts of data.

=cut

sub from_sql_column {
    return defined($_[1]) ? \$_[1] : undef;
}

=for html <a name="to_html"></a>

=head2 static to_html(any value) : string

B<NOT SUPPORTED>

=cut

sub to_html {
    die("can't convert a blob to html");
}

=for html <a name="to_literal"></a>

=head2 static to_literal(any value) : string

Unwraps the scalar reference or returns undef.

B<Avoid use of this routine as the results may be large.>

=cut

sub to_literal {
    my($proto, $value) = @_;
    return ref($value) ? $$value : '';
}

=for html <a name="to_uri"></a>

=head2 static to_uri(any value) : string

B<NOT SUPPORTED>

=cut

sub to_uri {
    die("can't convert a blob to a uri");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
