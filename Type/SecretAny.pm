# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Type::SecretAny;
use strict;
$Bivio::Type::SecretAny::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Type::SecretAny - serialize and encrypt any perl datastructure

=head1 SYNOPSIS

    use Bivio::Type::SecretAny;

=cut

=head1 EXTENDS

L<Bivio::Type>

=cut

use Bivio::Type::Secret;
@Bivio::Type::SecretAny::ISA = ('Bivio::Type::Secret');

=head1 DESCRIPTION

C<Bivio::Type::SecretAny> can be used to serialize any perl data structure.
It uses L<Data::Dumper|Data::Dumper> to serialize and
encrypts with L<Bivio::Type::Secret|Bivio::Type::Secret>.

B<Does not handle a single C<undef>.>

=cut

#=IMPORTS
use Bivio::TypeError;
use Bivio::Die;
use Bivio::IO::Alert;
use Data::Dumper ();


#=VARIABLES

=head1 METHODS

=cut

=for html <a name="from_literal"></a>

=head2 static from_literal(string value) : array

Returns the deserialized I<value>.

=cut

sub from_literal {
    my($proto, $value) = @_;

    # Decrypt and make sure surrounded by magic.
    my($s, $err) = $proto->SUPER::from_literal($value);
    return ($s, $err) unless defined($s);

    # Don't want die handler being executed, so tell Bivio::Die
    # we are about to eval.  Convoluted, sorry.
    my($res) = Bivio::Die->eval(sub {return eval($s) || die($@)});

    # We got something(?)
    return $res if $res;

    # Error during eval
    Bivio::IO::Alert->warn($@);
    return (undef, Bivio::TypeError::ANY());
}

=for html <a name="from_sql_column"></a>

=head2 static from_sql_column(string value) : any

B<NOT IMPLEMENTED>

=cut

sub from_sql_column {
    die("not implemented");
}

=for html <a name="get_width"></a>

=head2 static get_width : int

Returns 100000.

=cut

sub get_width {
    return 100000;
}

=for html <a name="to_literal"></a>

=head2 static to_literal(any value) : string

Returns I<value> serialized.

=cut

sub to_literal {
    my($proto, $value) = @_;

    # Set up to serialize
    my($dd) = Data::Dumper->new([$value]);
    $dd->Indent(0);
    $dd->Terse(1);

    # Serialize and encrypt
    return $proto->SUPER::to_literal($dd->Dumpxs());
}

=for html <a name="to_sql_param"></a>

=head2 static to_sql_param(any value) : int

B<NOT IMPLEMENTED>

=cut

sub to_sql_param {
    die("not implemented");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
