# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::USZipCode;
use strict;
$Bivio::Type::USZipCode::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::USZipCode::VERSION;

=head1 NAME

Bivio::Type::USZipCode - United States 5+4 zipcode

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::USZipCode;

=cut

=head1 EXTENDS

L<Bivio::Type::Name>

=cut

use Bivio::Type::Name;
@Bivio::Type::USZipCode::ISA = ('Bivio::Type::Name');

=head1 DESCRIPTION

C<Bivio::Type::USZipCode> United States 5+4 zipcode.

=cut

#=IMPORTS
use Bivio::TypeError;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Trims whitespace and checks syntax an returns (value).

Returns C<undef> if the zip is empty or zero length.

Return (C<undef>, L<Bivio::TypeError::US_ZIP_CODE|Bivio::TypeError::US_ZIP_CODE>)
if the syntax check fails.

=cut

sub from_literal {
    my(undef, $value) = @_;
    Bivio::IO::Alert->warn("don't call from_literal in scalar context")
            unless wantarray;
    return undef unless defined($value);
    # Remove all spaces and dashes
    $value =~ s/[-\s]+//g;
    return undef unless length($value);
    return (undef, Bivio::TypeError->US_ZIP_CODE)
	unless $value =~ /^\d{5}(?:\d{4})?$/;
    return $value;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
