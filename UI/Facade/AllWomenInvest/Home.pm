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
	    $self->image('quote')->put(align => 'nw', hspace => 4),
	    $self->page_text(<<'EOF'),
Want to pool your financial resources and brainpower and become an investor?
Investment clubs may be your answer
to financial empowerment.
<p>
AllWomenInvest is for women who want to be, or already are, members
of an investment club.  AllWomenInvest helps women invest; invest smartly;
and invest smoothly.  We firmly
believe that every woman should have knowledge of and access to investing
opportunities.  With a small monthly
contribution, say as little as $20 to $50, you too can be an investment club
member.  Why not start building your
financial resources to enable you to send your child to college, or buy a
home, or plan for your retirement, or
travel around the world, or buy a sports car?  AllWomenInvest encourages the
initiative for every woman, no
matter her age, background, or affiliation.
<p>
We have developed an environment with women in mind.  We offer you a
one-stop-shop experience so that you can
save time from your busy schedule.  We give you a chance to learn about
investing basics or improving your
existing investment skills in an interactive and fun setting.  In addition to
stock market news and quotes to
track your favorite stocks or learn about new ones, we also give you the
tools you need to set up an investment
club, manage it, and actually make your investments.
<p>
Not only that, we offer you a place where you can become part of an extensive
network of women who are, or plan
to become, members of investment clubs.  AllWomenInvest will give you access
to other women who are members of
investment clubs or share your interest in investing.
<p>
Whether you are already a member of an investment club or would like to learn
more about investment clubs and
investing,
EOF
	    $self->link($self->string('join for free', 'strong'),
		    'USER_CREATE'),
	    $self->page_text("\nto become a part of the AllWomenInvest"
		    .' network.'),
	   );
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
