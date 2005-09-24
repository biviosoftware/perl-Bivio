# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Type;
use strict;
$Bivio::Test::Type::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Type::VERSION;

=head1 NAME

Bivio::Test::Type - test types

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Type;

=cut

=head1 EXTENDS

L<Bivio::Test::Unit>

=cut

use Bivio::Test::Unit;
@Bivio::Test::Type::ISA = ('Bivio::Test::Unit');

=head1 DESCRIPTION

C<Bivio::Test::Type>

=cut

#=IMPORTS
use Bivio::TypeError;

#=VARIABLES
use vars (qw($AUTOLOAD));

=head1 METHODS

=cut

=for html <a name="AUTOLOAD"></a>

=head2 AUTOLOAD()

Converts TypeErrors.

=cut

sub AUTOLOAD {
    my($func) = $AUTOLOAD;
    $func =~ s/.*:://;
    return if $func eq 'DESTROY';
    return [undef, Bivio::TypeError->$func(@_)];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
