# Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::ModelBase;
use strict;
$Bivio::Test::ModelBase::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::ModelBase::VERSION;

=head1 NAME

Bivio::Test::ModelBase - base class for Bivio::Test::(List|Form)Model

=head1 RELEASE SCOPE

Bivio

=head1 SYNOPSIS

    use Bivio::Test::ModelBase;

=cut

=head1 EXTENDS

L<Bivio::Test>

=cut

use Bivio::Test;
@Bivio::Test::ModelBase::ISA = ('Bivio::Test');

=head1 DESCRIPTION

C<Bivio::Test::ModelBase>

=cut

#=IMPORTS

#=VARIABLES

=for html <a name="new_unit"></a>

=head2 new_unit(string class_name, hash_ref attrs) : self

Calls L<new|"new">.

=cut

sub new_unit {
    my($self, $class_name, $attrs) = @_;
    ($attrs ||= {})->{model} = $class_name;
    return $self->new($attrs);
}

=head1 METHODS

=cut

=for html <a name="run_unit"></a>

=head2 run_unit(string class_name, array_ref cases)

Calls L<unit|"unit">.

=cut

sub run_unit {
    return shift->unit(@_);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
