# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::f1065::XlatorSet;
use strict;
$Bivio::UI::PDF::Form::f1065::XlatorSet::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::f1065::XlatorSet - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::f1065::XlatorSet;
    Bivio::UI::PDF::Form::f1065::XlatorSet->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::XlatorSet>

=cut

use Bivio::UI::PDF::Form::XlatorSet;
@Bivio::UI::PDF::Form::f1065::XlatorSet::ISA = ('Bivio::UI::PDF::Form::XlatorSet');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::f1065::XlatorSet>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::f1065::XlatorSet



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::XlatorSet::new(@_);
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
