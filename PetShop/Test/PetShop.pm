# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Test::PetShop;
use strict;
$Bivio::PetShop::Test::PetShop::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Test::PetShop::VERSION;

=head1 NAME

Bivio::PetShop::Test::PetShop - test language for the PetShop

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Test::PetShop;

=cut

=head1 EXTENDS

L<Bivio::Test::Language>

=cut

use Bivio::Test::Language;
@Bivio::PetShop::Test::PetShop::ISA = ('Bivio::Test::Language');

=head1 DESCRIPTION

C<Bivio::PetShop::Test::PetShop>

=cut

#=IMPORTS
use Bivio::Test::HTTP::Page;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;
my($_CURRENT_PAGE);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::PetShop::Test::PetShop

Creates a new PetShop test languange.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_to_cart"></a>

=head2 add_to_cart()

Selects the 'Add to Cart' button.

=cut

sub add_to_cart {
    my($self) = @_;
    _get_current_page($self)->submit(
	'fn\d', [v => 1, 'f0.x' => 5, 'f0.y' => 5]);
    return;
}

=for html <a name="click_on"></a>

=head2 click_on(string link_name)

Goes to the URI for the specified link.

=cut

sub click_on {
    my($self, $link_name) = @_;
    _get_current_page($self)->follow_link($link_name);
    return;
}

=for html <a name="home_page"></a>

=head2 home_page() : Bivio::Test::HTTP::Page

Requests and returns the PetShop homepage.

=cut

sub home_page {
    my($self) = @_;
    return _set_current_page($self, 'http://petshop.bivio.biz');
}

=for html <a name="verify_cart"></a>

=head2 verify_cart(string item_name)

Verifies that the named item is in the cart.

=cut

sub verify_cart {
    my($self, $item_name) = @_;
    _get_current_page($self)->verify_text($item_name);
    return;
}

#=PRIVATE SUBROUTINES

# _get_current_page(self) : Bivio::Test::HTTP::Page
#
# Ensures the current_page is set.
#
sub _get_current_page {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    Bivio::Die->die('no page loaded')
	    unless $fields->{current_page};
    return $fields->{current_page};
}

# _set_current_page(string uri) : Bivio::Test::HTTP::Page
#
# Goes to the specified uri and saves it as the current page.
#
sub _set_current_page {
    my($self, $uri) = @_;
    my($fields) = $self->[$_IDI];

    if ($fields->{current_page}) {
	$fields->{current_page}->goto_page($uri);
    }
    else {
	$fields->{current_page} = Bivio::Test::HTTP::Page->new($uri);
    }
    return $fields->{current_page};
}

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
