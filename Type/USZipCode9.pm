# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::USZipCode9;
use strict;
$Bivio::Type::USZipCode9::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::USZipCode9::VERSION;

=head1 NAME

Bivio::Type::USZipCode9 - must be 9 digit zip

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::USZipCode9;

=cut

=head1 EXTENDS

L<Bivio::Type::USZipCode>

=cut

use Bivio::Type::USZipCode;
@Bivio::Type::USZipCode9::ISA = ('Bivio::Type::USZipCode');

=head1 DESCRIPTION

C<Bivio::Type::USZipCode9>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Ensures 9 digits.

=cut

sub from_literal {
    my($v, $e) = shift->SUPER::from_literal(@_);
    return ($v, $e)
	unless $v;
    return (undef, Bivio::TypeError->US_ZIP_CODE_9)
	unless length($v) == 9;
    return $v;
}

=for html <a name="to_html"></a>

=head2 static to_html(string value) : string

Insert the '-'.

=cut

sub to_html {
    my(undef, $value) = @_;
    substr($value, 5, 0) = '-';
    return $value;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
