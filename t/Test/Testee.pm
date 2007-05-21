# Copyright (c) 2001 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::t::Test::Testee;
use strict;
$Bivio::t::Test::Testee::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::t::Test::Testee::VERSION;

=head1 NAME

Bivio::t::Test::Testee - unit test testing class

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::t::Test::Testee;

=cut

use Bivio::UNIVERSAL;
@Bivio::t::Test::Testee::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::t::Test::Testee> used only for testing L<Bivio::Test|Bivio::Test>.

=cut

#=IMPORTS
use Bivio::DieCode;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(any default_return) : Bivio::t::Test::Testee

Instance created with I<default_return>

=cut

sub new {
    my(undef, $default_return) = @_;
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {
	default_return => $default_return,
    };
    return $self;
}

=head1 METHODS

=cut

sub as_string {
    my($self) = @_;
    return ref($self) ? ref($self) . '[' . (($self->[$_IDI] || {})->{default_return} || '') . ']' : ref($self);
}

=for html <a name="die"></a>

=head2 die(Bivio::DieCode code)

Always dies with specified I<code>.

=cut

sub die {
    my($self, $code) = @_;
    Bivio::Die->throw($code || Bivio::DieCode->DIE, {
	message => $code,
    });
    # DOES NOT RETURN
}

=for html <a name="ok"></a>

=head2 ok(any result, ...) : any

Returns I<any> or I<default_return> as specified to L<new|"new">
If no instance, returns undef.

=cut

sub ok {
    my($self) = shift;
    return @_ if @_ >= 1;
    return ref($self) ? $self->[$_IDI]->{default_return} : undef;
}

=for html <a name="want_scalar"></a>

=head2 want_scalar(any result, ...) : any

Returns the results as an array in list context or scalar count
in array context.

=cut

sub want_scalar {
    shift;
    return @_;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
