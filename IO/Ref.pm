# Copyright (c) 2001 bivio Software Artisans, Inc.  All Rights reserved.
# $Id$
package Bivio::IO::Ref;
use strict;
$Bivio::IO::Ref::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::Ref::VERSION;

=head1 NAME

Bivio::IO::Ref - manipulate references

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::IO::Ref;

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::Ref::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::IO::Ref> manipulates references.

=cut

#=IMPORTS
use Data::Dumper ();

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="to_string"></a>

=head2 static to_string(any ref) : string_ref

Converts I<ref> into a string_ref.  The string is formatted "tersely"
using C<Data::Dumper>.

=cut

sub to_string {
    my(undef, $ref) = @_;
    my($dd) = Data::Dumper->new([$ref]);
    $dd->Indent(1);
    $dd->Terse(1);
    $dd->Deepcopy(1);
    my($res) = $dd->Dumpxs();
    return \$res;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
