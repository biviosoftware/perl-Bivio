# Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.
# $Id$
package Bivio::t::Testee;
use strict;
$Bivio::t::Testee::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::t::Testee::VERSION;

=head1 NAME

Bivio::t::Testee - unit test testing class

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::t::Testee;

=cut

use Bivio::UNIVERSAL;
@Bivio::t::Testee::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::t::Testee> used only for testing L<Bivio::Test|Bivio::Test>.

=cut

#=IMPORTS
use Bivio::DieCode;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(any default_return) : Bivio::t::Testee

Instance created with I<default_return>

=cut

sub new {
    my($proto, $default_return) = @_;
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->[$_IDI] = {
	default_return => $default_return,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="die"></a>

=head2 die(Bivio::DieCode code)

Always dies with specified I<code>.

=cut

sub die {
    my($self, $code) = @_;
    Bivio::Die->throw($code || Bivio::DieCode->DIE);
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

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Software Artisans Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
