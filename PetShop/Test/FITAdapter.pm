# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Test::FITAdapter;
$VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
use strict;

=head1 NAME

Bivio::PetShop::Test::FITAdapter - adapter for Bivio::PetShop::Test::PetShop

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Test::FITAdapter;

=cut

=head1 EXTENDS

L<Test::FIT::ActionFixture>

=cut

use Test::FIT::ActionFixture;
@Bivio::PetShop::Test::FITAdapter::ISA = ('Test::FIT::ActionFixture');

=head1 DESCRIPTION

C<Bivio::PetShop::Test::FITAdapter>

=cut

#=IMPORTS
use Bivio::PetShop::Test::PetShop;

#=VARIABLES
my($_PKG) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::PetShop::Test::FITAdapter

Creates an instance of L<Bivio::Test::Language|Bivio::Test::Language>, and
stores in super class.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->{$_PKG} = {
	petshop => Bivio::PetShop::Test::PetShop->new,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="do_login"></a>

=head2 do_login(string user, string password, string error_re)

Tries to login.

=cut

sub do_login {
    my($self, $user, $password, $error_re) = @_;
    # Trim spaces, because cells may be "empty" but need &nbsp;
    $error_re =~ s/^\s+|\s+$//g;
    $error_re = $error_re ? qr/$error_re/is : 0;
    my($die) = Bivio::Die->catch(sub {
	my($petshop) = $self->{$_PKG}->{petshop};
	$petshop->home_page;
        $petshop->login_as($user, $password);
    });
    if ($die) {
	$self->ok($error_re && $die->as_string =~ $error_re,
	    $die->as_string);
    }
    else {
	$self->ok(!$error_re, 'login was successful');
    }
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
