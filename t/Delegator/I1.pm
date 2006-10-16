# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::t::Delegator::I1;
use strict;
$Bivio::t::Delegator::I1::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::t::Delegator::I1::VERSION;

=head1 NAME

Bivio::t::Delegator::I1 - test impl

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::t::Delegator::I1;

=cut

=head1 EXTENDS

L<Bivio::Delegate>

=cut

use Bivio::Delegate;
@Bivio::t::Delegator::I1::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::t::Delegator::I1>

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static_echo new() : Bivio::t::Delegator::I1

Does the new thing.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {
	value => shift,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="static_echo"></a>

=head2 static_echo(any arg) : any

Echo arg.

=cut

sub static_echo {
    shift;
    return @_;
}

=for html <a name="value"></a>

=head2 value() : any

Returns value passed in.

=cut

sub value {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{value};
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
