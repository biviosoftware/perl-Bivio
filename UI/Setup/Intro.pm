# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Setup::Intro;
use strict;
$Bivio::UI::Setup::Intro::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::Setup::Intro - a setup introduction view

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::Setup::Intro::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::Setup::Intro> draws an introductory club setup view.

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Setup::Intro

Creates a setup introduction view.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::View::new($proto, 'intro');
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_model"></a>

=head2 get_default_model() : UserList

Returns a dummy model.

=cut

sub get_default_model {
    return Bivio::Biz::TestModel->new(undef, undef, 'Setup Introduction',
	    'Introduction');
}

=for html <a name="render"></a>

=head2 render(User user, Request req)

Draws an introductary club setup view.

=cut

sub render {
    my($self, $user, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->print('<table border=0><tr><td>');

    $req->print('<form action='.$req->make_path('admin').' method="post">');

    $req->print('Welcome to club setup.');
    $req->print('<p><input type="submit" value="Next">');

    $req->print('</form></td></tr></table>');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
