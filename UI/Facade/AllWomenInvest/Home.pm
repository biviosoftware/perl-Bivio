# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::UI::Facade::AllWomenInvest::Home;
use strict;
$Bivio::UI::Facade::AllWomenInvest::Home::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Facade::AllWomenInvest::Home - introduction

=head1 SYNOPSIS

    use Bivio::UI::Facade::AllWomenInvest::Home;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::Facade::AllWomenInvest::Home::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::Facade::AllWomenInvest::Home> is intro to clubs.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="new"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Simple grid.

=cut

sub create_content {
    my($self) = @_;
    return $self->join(
	    $self->link($self->string('Return to Investment Clubs', 'strong'),
		    'http://www.allwomeninvest.com/investment_club.htm'),
	   );
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
