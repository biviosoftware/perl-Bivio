# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Bean;
use strict;
$Bivio::Test::Bean::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Bean::VERSION;

=head1 NAME

Bivio::Test::Bean - saves all values from AUTOLOAD methods called

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Bean;

=cut

use Bivio::UNIVERSAL;
@Bivio::Test::Bean::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Test::Bean> can be used to simulate a class which saves the
values of its arguments and returns them.  This is like a Java Bean.
However, when called, it returns its previous value.

Apache::FakeRequest doesn't do the right thing, because it only saves the
first argument, e.g.

     $r->header_out('Set-Cookie', 'abc');

Only returns 'Set-Cookie'.

=cut

#=IMPORTS
use vars ('$AUTOLOAD');

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Test::Bean

Creates a bean.  Set initial values by calling methods.

=cut

sub new {
    my($proto) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="AUTOLOAD"></a>

=head2 AUTOLOAD(...) : any

The widget and shortcut methods are dynamically loaded.

=cut

sub AUTOLOAD {
    my($self, @args) = @_;
    my($method) = $AUTOLOAD;
    $method =~ s/.*:://;
    return if $method eq 'DESTROY';
    my($fields) = $self->[$_IDI];
    my($res) = $fields->{$method} || [];
    $fields->{$method} = \@args if @args;
    return wantarray ? @$res : $res->[0];
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
