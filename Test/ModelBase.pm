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

=for html <a name="unit"></a>

=head2 static unit(string model, array_ref method_groups)

=head2 static unit(hash_ref new_attrs, array_ref method_groups)

=head2 unit(array_ref method_groups)

Instantiates this class with I<model> or I<new_attrs> (which must include
I<model>), and calls the instance method form with I<method_groups>.

Wraps I<method_groups> in an object group, with a call to the list model's,
new.  See L<Bivio::Test::unit|Bivio::Test/"unit"> for details.

I<method_groups> are just like normal method groups with the exception that if
the expect is an array of hashes and the method begins with C<load>
or C<unauth_load)>, the actual return is the result of
L<Bivio::Biz::ListModel::map_rows|Bivio::Biz::ListModel/"map_rows">
filtered to only include the keys contained the first row of the expected
return.

=cut

sub unit {
    return shift->new(shift)->unit(shift)
	if @_ == 3;
    my($self, $method_groups) = @_;
    return $self->SUPER::unit([
	$self->get('class_name') => $method_groups,
    ]);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
