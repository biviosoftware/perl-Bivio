# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Setup::Finish;
use strict;
$Bivio::UI::Setup::Finish::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::Setup::Finish - setup finish view

=head1 SYNOPSIS

    use Bivio::UI::Setup::Finish;
    Bivio::UI::Setup::Finish->new();

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::Setup::Finish::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::Setup::Finish>

=cut

=head1 CONSTANTS

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

=head2 static new() : Bivio::UI::Setup::Finish

Creates a setup finished view.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::View::new($proto, 'finish');
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_model"></a>

=head2 get_default_model() : UserList

Returns an a dummy model.

=cut

sub get_default_model {
    return Bivio::Biz::TestModel->new(undef, undef, 'Setup Completed',
	    'Setup Completed');
}

=for html <a name="render"></a>

=head2 render(User user, Request req)

Creates a form for editing the specified model.

=cut

sub render {
    my($self, $user, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->print('<table border=0><tr><td>');

    $req->print('<form action='.'/'.$req->get_arg('club').'/admin>');

    $req->print('Congratulations, club setup is completed. After
pressing "next", enter your user name and password and you will be
directed to the club user list screen. From there you can add additional
club members.');
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
