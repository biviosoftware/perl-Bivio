# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::MoneyXlator;
use strict;
$Bivio::UI::PDF::Form::MoneyXlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::MoneyXlator - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::MoneyXlator;
    Bivio::UI::PDF::Form::MoneyXlator->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::FloatXlator>

=cut

use Bivio::UI::PDF::Form::FloatXlator;
@Bivio::UI::PDF::Form::MoneyXlator::ISA = ('Bivio::UI::PDF::Form::FloatXlator');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::MoneyXlator>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::MoneyXlator



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::FloatXlator::new(@_, ',', 2);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
